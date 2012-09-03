% Simulate evolution of population density
clear all
close all
rand('state', 0);       % initialize random number generator

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


% Disable warning about displaying an image that's too big to fit on the
% screen.  (Actually this disables all warnings; I don't know how to just
% disable that particular one.)
%warning off all

% Controls whether imshow includes a border
% around the image in the figure window. Possible values:
% {'loose'} — Include a border between the image and the edges of the 
% figure window, thus leaving room for axes labels, titles, etc.
% 'tight' — Adjust the figure size so that the image entirely fills the figure.
iptsetpref('ImshowBorder','tight');

sim1_Setup;             % Call a function to set up the variables above

% % create avi file.  'Indeo5' seems to be best, but is not on Vista
% aviobj = avifile('simulation.avi', ...
%     'compression', 'Cinepak', ...
%     'fps', 5, ...
%     'keyframe', 0.05);
% fp = fopen('data.txt','w');


t = [2010, 1, 1, 0, 0, 0];
t = datenum(t);
oneSec = [0, 0, 0, 0, 0, 1];
oneSec = datenum(oneSec);
fPointers = [];

%create the output files.
for n = 1:NUMNODES
    nn = nodeIds(n);
    s = ['data/sensor', int2str(nn), '.txt'];
    v = fopen(s,'w');
    fclose(v);
end;

fopen('data/numpeople.txt', 'w');


fprintf('Running until %d\n', TMAX);
for iTime = 1:TMAX    
    if mod(iTime,500) == 0
        fprintf('%d\n', iTime);
    end
    
    
    sim2_Sensors;
    %sim3_Draw;              % Draw current scene
    
    %Output data 
    %fprintf(fp, '%d   ', iTime);
    %for n=1:NUMNODES
    %    fprintf(fp, '%d ', Node(n).C);      % ground truth count
    %end
    %fprintf(fp, '   ');
    %for n=1:NUMNODES
    %    fprintf(fp, '%d ', Node(n).Z);      % sensor readings
    %end
    %fprintf(fp, '\n');
    %pause(0.05);

    sim4_UpdateNodes;
    sim5_ChangeStates;
    sim6_MovePeople;
    
    %Update output files.
    for n = 1:NUMNODES
        nn = nodeIds(n);
        s = ['data/sensor', int2str(nn), '.txt'];
        v = fopen(s,'a');
        if Node(n).C > 0
            tmp = t + iTime * oneSec;
            out = [datestr(tmp, 'yyyy-mm-dd HH:MM:SS'), '\n'];
            out = [int2str(Node(n).C), '     ', out];
            fprintf(v, out);
        end;
        fclose(v);
    end;
    
    if nPeople > 0
        v = fopen('data/numpeople.txt', 'a');
        tmp = t + iTime * oneSec;
        out = [int2str(nPeople), '    ', datestr(tmp, 'yyyy-mm-dd HH:MM:SS'), '\n'];
        fprintf(v, out);
        fclose(v);
    end;

end



