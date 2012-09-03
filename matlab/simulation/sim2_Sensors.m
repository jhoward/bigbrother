function sim2_Sensors
% Simulate sensor hits.



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



for n=1:NUMNODES
    x = Node(n).C;      % Actual count at this node
    p = Pz(n,2,x+1);    % Probability that a hit occurs

    if rand < p     % roll the die
        Node(n).Z = 2;      % a sensor hit occurred
    else
        Node(n).Z = 1;      % no hit
    end
end
