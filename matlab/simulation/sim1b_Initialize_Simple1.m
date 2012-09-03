function sim1b_Initialize
% Initialize the simulation - this is called once at the beginning.
% It is specific to the scene being simulated.


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
% The prob that a free person in the system will want to go to a node that
% wants a person.
PROBDEST = 0.75;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the probabilities for the observations.
Pz = zeros(NUMNODES,2,MAXPEOPLENODE+1);
for n=1:NUMNODES
    %     for x=0:MAXPEOPLENODE
    %         Pz(n,2,x+1) = 1 - 0.1^x;
    %         Pz(n,1,x+1) = 1-Pz(n,2,x+1);
    %     end

    % For now, certain detection
    Pz(n,1,1) = 1;
    Pz(n,1,2:end) = 0;
    Pz(n,2,1) = 0;
    Pz(n,2,2:end) = 1;
end
% Some nodes are "hidden"; they have no sensors
% Pz(1,1,:) = 1;
% Pz(1,2,:) = 0;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Define the schedules for the desired count processes
% %   D(t) is the desired count at time t
% % At certain times, at certain nodes, D will ramp up to a constant level,
% % stay there awhile, and then ramp down.
% TMAX = 100;
% for n=1:NUMNODES
%     Node(n).D(1:TMAX) = 0;
%     if n==1
%         Node(n).D(11:20) = 1:10;
%         Node(n).D(21:50) = 10;
%         Node(n).D(51:60) = 9:-1:0;
%     end
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the schedules for the desired count processes
%   D(t) is the desired count at time t
% At certain times, at certain nodes, D will ramp up to a constant level,
% stay there awhile, and then ramp down.
%  For each node that has a process:
%   Ramp up occurs between tStart1 to tStart2
%   Desired count goes from 0 to nRoom
%   Ramp down occurs beween tEnd1 to tEnd2
TMAX = 100;
for n=1:NUMNODES
    Node(n).D(1:TMAX) = 0;
end


sim1c_InitProcesses( ...
    12, ...         % node id 
    10, ...         % tStart1
    30, ...         % tStart2
    10, ...         % nRoom
    60,  ...        % tEnd1
    70);            % tEnd2





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create people
nPeople = 0;
for n=1:NUMNODES
    Node(n).C = 0;              % number of people at this node
    Node(n).Z = 0;              % current sensor reading
    Node(n).A = 0;
end


% nPeople = 3;
% Person(1).type = 1;
% Person(1).state = 'resting';
% Person(1).locType = 'node';
% Person(1).locId = 11;
% Node(2).C = Node(2).C + 1;
% Node(2).A = Node(2).A + 1;
% Person(1).destType = '';
% Person(1).destId = 0;
%     
% Person(2).type = 1;
% Person(2).state = 'pending depart';
% Person(2).locType = 'node';
% Person(2).locId = 11;
% Node(2).C = Node(2).C + 1;
% Person(2).destType = '';
% Person(2).destId = 0;
% 
% Person(3).type = 1;
% Person(3).state = 'in transit';
% Person(3).locType = 'node';
% Person(3).locId = 11;
% Node(2).C = Node(2).C + 1;
% Person(3).destType = 'source/sink';
% Person(3).destId = 1001;


