function sim1a_Dijkstra
% Use Dijkstra's algorithm to find the shortest path between every pair of
% nodes in a graph.


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

HUGE = 1e10;    % some large number (larger than any distance)

% Form the input data.  We need:
%   a set of nodes (vertices)
%   for each node, a list of its neighbors
%   for each neighbor, the distance to that neighbor
% The output is:
%   the shortest distance between each node i to each node j

% Construct:
%   nbrs, where nbrs(i,j) == true if i is neighbor to j
%   tNode, where tNode(i,j) is the time from i to j (don't care what the
%       value is if they aren't neighbors)
nbrs = false(NUMNODES, NUMNODES);
tNode = HUGE*ones(NUMNODES, NUMNODES);

for n=1:NUMNODES
    nbrs(n,n) = true;   % I suppose a node is neighbor to itself

    for i=1:length(Node(n).neighbor)
        m = find(Node(n).neighbor(i) == nodeIds);
        nbrs(n,m) = true;
        tNode(n,m) = Node(n).tNode(i);
    end
end


% The algorithm (from http://en.wikipedia.org/wiki/Dijkstra's_algorithm):
% Let the node we are starting be called an initial node.
% Let a distance of a node Y be the distance from the initial node to it.
% Dijkstra's algorithm will assign some initial distance values and will
% try to improve them step-by-step.
%
% 1. Assign to every node a distance value. Set it to zero for our initial
%    node and to infinity for all other nodes.
% 2. Mark all nodes as unvisited. Set initial node as current.
% 3. For current node, consider all its unvisited neighbours and calculate
%    their distance (from the initial node). For example, if current node
%    (A) has distance of 6, and an edge connecting it with another node (B)
%    is 2, the distance to B through A will be 6+2=8. If this distance is
%    less than the previously recorded distance (infinity in the beginning,
%    zero for the initial node), overwrite the distance.
% 4. When we are done considering all neighbours of the current node, mark
%    it as visited. A visited node will not be checked ever again; its
%    distance recorded now is final and minimal.
% 5. Set the unvisited node with the smallest distance (from the initial
%    node) as the next "current node" and continue from step 3.




% This will be the output ... distance from any i to any j
tNodeNode = HUGE*ones(NUMNODES, NUMNODES);

for nInitial = 1:NUMNODES
    % 1. Assign to every node a distance value. Set it to zero for our initial
    %    node and to infinity for all other nodes.
    distanceNode = HUGE*ones(1,NUMNODES);
    distanceNode(nInitial) = 0;

    % 2. Mark all nodes as unvisited. Set initial node as current.
    visitedNode = false(NUMNODES,1);
    nCurrent = nInitial;

    while true
        % 3. For current node, consider all its unvisited neighbours and calculate
        %    their distance (from the initial node). For example, if current node
        %    (A) has distance of 6, and an edge connecting it with another node (B)
        %    is 2, the distance to B through A will be 6+2=8. If this distance is
        %    less than the previously recorded distance (infinity in the beginning,
        %    zero for the initial node), overwrite the distance.
        for n=1:NUMNODES
            if ~nbrs(n,nCurrent)    continue;   end     % ignore if not neighbor
            if n == nCurrent        continue;   end     % ignore if self
            if visitedNode(n)       continue;   end     % ignore if already visited

            % Calculate distance to neighbor
            d = distanceNode(nCurrent) + tNode(nCurrent, n);
            if d < distanceNode(n)
                distanceNode(n) = d;
            end
        end

        % 4. When we are done considering all neighbours of the current node, mark
        %    it as visited. A visited node will not be checked ever again; its
        %    distance recorded now is final and minimal.
        visitedNode(nCurrent) = true;

        % 5. Set the unvisited node with the smallest distance (from the initial
        %    node) as the next "current node" and continue from step 3.
        d = HUGE;
        for n=1:NUMNODES
            if visitedNode(n)   continue;   end     % ignore if already visited
            if distanceNode(n) < d
                d = distanceNode(n);
                nCurrent = n;
            end
        end
        if d == HUGE
            break;
        end     % all done; no more unvisited nodes

    end

    % Save distances in output table
    tNodeNode(nInitial,:) = distanceNode(1,:);
end


