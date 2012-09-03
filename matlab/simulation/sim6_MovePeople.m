function sim6_MovePeople
% Move people.



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



% These will be indices of people to be deleted at the end
pToBeDeleted = [];      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each person in the system that is “in transit”
for p=1:nPeople
    if strcmp(Person(p).state, 'in transit')
        %fprintf('t=%d, trying to move person %d', iTime, p);

        % Check if the person is starting at a node
        if strcmp(Person(p).locType, 'node')
            nId = Person(p).locId;
            n = find(nId == nodeIds);
            %fprintf(' at node %d.\n', nId);

            % Check if the person is going to a node
            if strcmp(Person(p).destType, 'node')
                nDestId = Person(p).destId;     % destination node id
                nDest = find(nDestId == nodeIds);
                tn = tNodeNode(n, nDest);       % time from current to dest
                %fprintf(' Destination is node %d, time=%f.\n', nDestId, tn);

                % Find neighbors whose times to destination are smaller than tn
                % Consider them in random order
                % For neighbor i, move there with probability pMove.
                % Let the average time to move from n to i be tni
                % Then if we try to move there every second, the number of
                % tries before we succeed is a geometric random variable.
                % A geometric rv has mean = 1/pMove.

                %fprintf('  Neighbors:\n');
                nOrder = randperm( length(Node(n).neighbor) );
                for i=1:length(nOrder)
                    ni = find( Node(n).neighbor(nOrder(i)) == nodeIds );
                    ti = tNodeNode(ni, nDest);       % time from nbr to dest
                    %fprintf('   node %d, time=%f\n', Node(n).neighbor(nOrder(i)), ti);
                    if ti < tn
                        pMove = 1/tNodeNode(n,ni);
                        if rand < pMove
                            %fprintf('   Moving there (prob was %f)\n', pMove);
                            % Set the new location
                            Person(p).locId = Node(n).neighbor(nOrder(i));
                            if ni == nDest
                                Person(p).state = 'resting';   % have arrived at destination
                            end
                            break;
                        end
                    end
                end

            % The person is going to a sink
            else
                sDestId = Person(p).destId;     % destination sink id 
                sDest = find(sDestId == sourcesinkIds);
                ts = tNodeSink(n,sDest);        % time from current to dest
                %fprintf(' Destination is sink %d, time=%f.\n', sDestId, ts);

                % See if the destination sink is one of the neighbors
                fMove = false;
                for i=1:length(Node(n).neighborSourceSink)
                    sNbrId = Node(n).neighborSourceSink(i);
                    if sNbrId == sDestId
                        % Try to move there
                        if rand < 0.9   %%% WAH - don't use magic number %%%
                            %fprintf('   moving to sink %d\n', sDestId);
                            % Remember to remove this person
                            pToBeDeleted = [p pToBeDeleted];
                            fMove = true;
                            break;
                        end
                    end 
                end
                if fMove    continue;   end     % done with this person
                       
                % Try to move to a neighboring node closer to the sink.
                %fprintf('  Neighbors:\n');
                nOrder = randperm( length(Node(n).neighbor) );
                for i=1:length(nOrder)
                    ni = find( Node(n).neighbor(nOrder(i)) == nodeIds );
                    ti = tNodeSink(ni, sDest);      % time from nbr to dest
                    %fprintf('   node %d, time=%f\n', Node(n).neighbor(nOrder(i)), ti);
                    if ti < ts
                        pMove = 1/tNodeNode(n,ni);
                        if rand < pMove
                            %fprintf('   Moving there (prob was %f)\n', pMove);
                            Person(p).locId = Node(n).neighbor(nOrder(i));   % Set the new location
                            break;
                        end
                    end
                end

            end

        % The person is starting at a source
        else
            sId = Person(p).locId;
            s = find( sId == sourcesinkIds );
            %fprintf(' at source %d.\n', sId);

            % Assume that a person at a source always goes to a node, not a sink
            nDestId = Person(p).destId;
            %fprintf(' Destination is node %d.\n', nDestId);

%             fprintf('  Neighbors:\n');
%             for i=1:length(SourceSink(s).neighborNode)
%                 fprintf('   node %d\n', SourceSink(s).neighborNode(i));
%             end
                
            % Move the person to one of the neighboring nodes (at random)
            nOrder = randperm(length(SourceSink(s).neighborNode));
            njId = SourceSink(s).neighborNode( length(SourceSink(s).neighborNode)*ceil(rand) );
            %fprintf(' Moving to node %d\n', njId);
            
            Person(p).locType = 'node';     % Set the new location
            Person(p).locId = njId;
            if njId == nDestId
                Person(p).state = 'resting';   % have arrived at destination
            else
                Person(p).state = 'in transit';
            end
        end
    end
end


% Delete any people that have moved to sinks
if length(pToBeDeleted) > 0
    NewPerson = [];
    % Go through the list of existing people
    for p=1:nPeople
        % Test if this person is not in the list of deletions
        if isempty(find(p==pToBeDeleted))
            % Is still alive; add to the list
            NewPerson = [NewPerson Person(p)];
        else
            %fprintf('deleting person %d\n', p);
        end
    end
    Person = NewPerson;
    nPeople = length(Person);
    %fprintf('Number of people is now %d\n', nPeople);
end

