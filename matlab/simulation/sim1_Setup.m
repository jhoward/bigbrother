function sim1_Setup
% Set up the simulation - this is called once at the beginning.
% It populates various global variables.


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


MAXPEOPLENODE = 200;     % Maximum number of people at a node
NTYPES = 2;             % Number of types of people


% Read or create background image
Ibkgnd = imread('images/map_color.bmp');
%Ibkgnd = ones(800,1033);     % plain white background
%Ibkgnd = ones(300,1033);     % plain white background
WIDTH = size(Ibkgnd,2);
HEIGHT = size(Ibkgnd,1);
%figure('Position', [20 40 round(0.85*WIDTH) round(0.85*HEIGHT)])    % [left, bottom, width, height]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set x,y locations of nodes, and id numbers
nums = xlsread('layouts/xyNode.xls');
fprintf('Size is %d\n', size(nums, 1));
NUMNODES = size(nums,1);
for n=1:size(nums, 1)
    Node(n).xy(1) = nums(n,1);
    Node(n).xy(2) = nums(n,2);
    nodeIds(n) = nums(n,3);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set list of neighbors for each node
nums = xlsread('layouts/neighborNode.xls');
fprintf('Size is %d\n', size(nums, 1));
if size(nums,1) ~= NUMNODES
    fprintf('hey! error reading neighborNode spreadsheet\n');
    pause
end
for n=1:NUMNODES
    if nums(n,1) ~= nodeIds(n)
        fprintf('unexpected node id = %d\n', nums(n,1));
        pause
    end
    
    Node(n).neighbor = [];              % list of node neighbors
    Node(n).neighborSourceSink = [];    % list of source/sink neighbors
    
    for m=2:size(nums,2)
        if isnan(nums(n,m))
            % We have hit the end of list of neighbors
            break;
        elseif nums(n,m) < 1000
            % This neighbor is a node
            Node(n).neighbor = [Node(n).neighbor nums(n,m)];
        else
            % This neighbor is a source/sink
            Node(n).neighborSourceSink = [Node(n).neighborSourceSink nums(n,m)];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set travel times to neighbors for each node        
%  tNode(i) is the estimated time to the ith neighbor node
%  tSourceSink(i) is the estimated time to the ith neighbor source/sink
nums = xlsread('layouts/neighborTime.xls');
fprintf('Size is %d\n', size(nums, 1));
if size(nums,1) ~= NUMNODES
    fprintf('hey! error reading neighborTime spreadsheet\n');
    pause
end

for n=1:NUMNODES
    if nums(n,1) ~= nodeIds(n)
        fprintf('unexpected node id = %d\n', nums(n,1));
        pause
    end

    m = 2;
    for i=1:length(Node(n).neighbor)
        Node(n).tNode(i) = nums(n,m);
        m = m+1;
    end
    
    for i=1:length(Node(n).neighborSourceSink)
        Node(n).tSourceSink(i) = nums(n,m);
        m = m+1;
    end    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the minimum time between any pair of nodes.
%  tNodeNode(i,j) is the minimum time from i to j.
sim1a_Dijkstra;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set information about sources and sinks
nums = xlsread('layouts/xySourceSink.xls');
NUMSOURCESINK = size(nums,1);

for s=1:NUMSOURCESINK
    SourceSink(s).xy(1) = nums(s,1);            % location on map (pixels)
    SourceSink(s).xy(2) = nums(s,2);
    sourcesinkIds(s) = nums(s,3);               % Id number of source/sink
    SourceSink(s).pFromSource = nums(s,4);      % emission probability
    SourceSink(s).pToSink = nums(s,5);          % absorption probability
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Connections between nodes and source/sinks
nums = xlsread('layouts/neighborSourceSink.xls');
if size(nums,1) ~= NUMSOURCESINK
    fprintf('hey! error reading neighborSourceSink spreadsheet\n');
    pause
end
for s=1:NUMSOURCESINK
    if nums(s,1) ~= sourcesinkIds(s)
        fprintf('unexpected source/sink id = %d\n', nums(s,1));
        pause
    end

    SourceSink(s).neighborNode = [];           % list of node neighbors    
    for t=2:size(nums,2)
        if isnan(nums(s,t))
            % We have hit the end of list of neighbors
            break;
        else
            % This neighbor is a source/sink
            SourceSink(s).neighborNode = [nums(s,t) SourceSink(s).neighborNode];
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the minimum time from any node i to sink j
tNodeSink = Inf(NUMNODES,NUMSOURCESINK);
for n=1:NUMNODES
    for s=1:NUMSOURCESINK
        sId = sourcesinkIds(s);
        
        % Find nodes that are neighbors to sink s
        for m=1:NUMNODES
            s1 = find(Node(m).neighborSourceSink == sId);
            if isempty(s1)   continue;   end
            
            % Calculate total time from n to s, through m
            t = tNodeNode(n,m) + Node(m).tSourceSink(s1);
            
            if t < tNodeSink(n,s)
                tNodeSink(n,s) = t;
            end
        end
    end
end


% Call this function which initializes things that are specific to the
% scene, such as the starting number of people, the "desired person count"
% processes, etc.
sim1b_Initialize;

