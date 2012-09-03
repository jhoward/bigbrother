function sim5_ChangeStates
% Change states of people.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global parameters 
global TMAX             % Simulation will run from 1..TMAX seconds
global iTime            % Current time
global Ibkgnd           % Background image (usually a map)
global NUMNODES         % Number of nodes
global Node             % An array of structures, 1..NUMNODES.  Each has fields
                        %  xy(1..2) - location on map
                        %  neighbor(1..M) - neighbor(i) is the node id of the ith neighbor
                        %  tNode(1..M) - tNode(i) is the est time to the ith neighbor node
                        %  neighborSourceSink(1..K) - list of source/sink ids that are attached
                        %  tSourceSink(1..K) - time to the source/sink that is attached
                        %  D(1..TMAX) - the desired count of each type at time t
                        %  C - current count of people at this node
                        %  Z - the sensor reading at this node
                        %  A - actual resting plus anticipated (en route) people to this node
global nodeIds          % nodeIds(1..NUMNODES) - an array of node ids
global NUMSOURCESINK    % Number of sources/sinks
global SourceSink       % An array of structures, 1..NUMSOURCESINK.  Each has fields
                        %  xy(1..2) - location on map
                        %  neighborNode(1..K) - list of node ids that are attached
                        %  pFromSource - prob for person coming from here
                        %  pToSink - prob for person going to here
global sourcesinkIds    % sourcesinkIds(1..NUMSOURCESINK) - an array of source/sink ids

global tNodeNode        % tNodeNode(i,j) is the minimum time (or distance) from node i to j
global tNodeSink        % tNodeSink(i,j) is the min time from node i to sink j

global nPeople          % Number of people in the system
global MAXPEOPLENODE    % Maximum number of people at a node
global NTYPES           % Number of types of people
global WIDTH            % Width of scene in pixels
global HEIGHT           % Height of scene in pixels
global Person           % This is an array of structures, 1..nPeople.  Each has fields
                        %  type - type of this person (1..NTYPES) (not used for now)
                        %  state - 'resting', 'pending depart', 'in transit'
                        %  locType - 'node' or 'source/sink'
                        %  locId - id of the node or source/sink
                        %  destType - if in transit, the type of the destination
                        %  destId - if in transit the id of the destination node or source/sink

global PROBDEST         % The prob that a free person in the system will want to go to specific node
global Pz               % Observation probabilities; Pz(n,z,x) is prob of seeing z at node n, if x people
                        % z = 1 represents no detection; z = 2 represents a detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each node that has excess people (A>D), take up to that number of people
% that are resting at that node, and mark them “pending departure”.
for n=1:NUMNODES
    if Node(n).A > Node(n).D(iTime)
%         fprintf('t=%d, node %d has excess people; A=%d, D=%d\n', ...
%             iTime, nodeIds(n), Node(n).A, Node(n).D(iTime));

        % This is the number that we want to get rid of
        nExcess = Node(n).A - Node(n).D(iTime);

        % Find up to this number of people who are resting at this node
        nFound = 0;
        for p=1:nPeople
            if Person(p).locId == nodeIds(n) && strcmp(Person(p).state,'resting')
                %fprintf('t=%d, marking person %d at node %d as pending depart\n', iTime, p, nodeIds(n));
                Person(p).state = 'pending depart';
                nFound = nFound + 1;
                if nFound >= nExcess    break;      end
            end
        end

    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find nodes that have a deficit of people (A<D).
% Try to fill each deficit slot.  If we end up filling the slot, mark
% the person as “in transit” with destination equal to this node.
for n=1:NUMNODES
    if Node(n).A < Node(n).D(iTime)
%         fprintf('t=%d, node %d has deficit of people; A=%d, D=%d\n', ...
%             iTime, nodeIds(n), Node(n).A, Node(n).D(iTime));

        % This is the number of slots that we want to fill
        nSlots = Node(n).D(iTime) - Node(n).A;

        % For each slot that we want to fill
        for slot=1:nSlots

            % Try to fill the slot with a person that is already in the
            % system, with state = “pending departure”.
            pOrder = randperm(nPeople);  % Evaluate candidates in random order
            fFound = false;
            for iPerson=1:length(pOrder)
                p = pOrder(iPerson);
                if Person(p).locId ~= nodeIds(n) && strcmp(Person(p).state,'pending depart')
                    if rand < PROBDEST
                        % Assign this person to go here
                        %fprintf('t=%d, sending person %d to node %d\n', iTime, p, nodeIds(n));
                        Person(p).state = 'in transit';
                        Person(p).destType = 'node';
                        Person(p).destId = nodeIds(n);
                        fFound = true;
                        break;
                    end
                end
            end
            if fFound   continue;   end

            % If we can’t fill it with a person already in the system, we
            % can try to create a new person from a source.  For each
            % source (in random order), there is a fixed probability for
            % a person coming from that source.
            sOrder = randperm(NUMSOURCESINK);
            for iSource=1:length(sOrder)
                s = sOrder(iSource);
                if rand < SourceSink(s).pFromSource
                    % Create a new person
                    nPeople = nPeople + 1;
                    Person(nPeople).type = 1;
                    Person(nPeople).state = 'in transit';
                    Person(nPeople).locType = 'source/sink';
                    Person(nPeople).locId = sourcesinkIds(s);
                    Person(nPeople).destType = 'node';
                    Person(nPeople).destId = nodeIds(n);
%                     fprintf('t=%d, creating person %d at source %d going to node %d\n', ...
%                         iTime, nPeople, sourcesinkIds(s), nodeIds(n));
                    break;
                end
            end

        end

    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each remaining person that is pending departure,
% try to send this person to a sink.  For each sink (in random order),
% there is a fixed probability for a person going to that sink.
% If we end up sending the person, mark the person as “in transit” with
% destination equal to that sink.
for p=1:nPeople
    if strcmp(Person(p).state, 'pending depart')
        sOrder = randperm(NUMSOURCESINK);

        for iSink=1:length(sOrder)
            s = sOrder(iSink);
            if rand < SourceSink(s).pToSink
                % Send this person to that sink
%                 fprintf('t=%d, sending person %d at node %d to sink %d\n', ...
%                     iTime, p, Person(p).locId, sourcesinkIds(s));
                Person(p).state = 'in transit';
                Person(p).destType = 'source/sink';
                Person(p).destId = sourcesinkIds(s);
                break;
            end
        end
    end
end

