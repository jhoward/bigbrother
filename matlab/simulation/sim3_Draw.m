function sim3_Draw
% Draw the simulated scene.



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


imshow(Ibkgnd, 'InitialMagnification', 80);       % percent magnification
%imshow(Ibkgnd);       % percent magnification

% Print time
text(20,20, sprintf('t =%3d', iTime), 'BackgroundColor', 'w', 'FontSize', 8);


% Print desired number of people vs actual count above node
for n=1:NUMNODES
    x1 = Node(n).xy(1);
    y1 = Node(n).xy(2);
    if Node(n).D(iTime) > 0
    %if nodeIds(n) == 13
        text(x1-10, y1-10, sprintf('%2d', Node(n).D(iTime)), ...
            'Color', 'g', 'BackgroundColor', 'w', 'FontSize', 7);
        text(x1+5, y1-10, sprintf('%2d', Node(n).C), ...
            'Color', 'k', 'BackgroundColor', 'w', 'FontSize', 7);
        rectangle('Position', [x1-20, y1-20, 40 40], ...
            'EdgeColor', 'r', 'LineWidth', 2);
    end
end




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Comment out the below, to clean up display
% 
% % Print actual number of people above node
% for n=1:NUMNODES
%     x1 = Node(n).xy(1);
%     y1 = Node(n).xy(2);
%     if Node(n).C > 0
%         text(x1+5, y1-10, sprintf('%2d', Node(n).C), ...
%             'Color', 'r', 'BackgroundColor', 'w', 'FontSize', 7);
%     end
% end
% 
% Draw lines between connected nodes
% for n1=1:NUMNODES
%     for i=1:length(Node(n1).neighbor)
%         n2 = find(Node(n1).neighbor(i) == nodeIds);
%         x1 = Node(n1).xy(1);
%         y1 = Node(n1).xy(2);
%         x2 = Node(n2).xy(1);
%         y2 = Node(n2).xy(2);
%         line( [x1 x2], [y1 y2] );
%         text(x1+(x2-x1)/3, y1+(y2-y1)/3, ...
%             sprintf('%.0f', Node(n1).tNode(i)), 'FontSize', 7);
%     end
% end
% 
% % Draw lines between nodes and source/sinks
% for s=1:NUMSOURCESINK
%     for i=1:length(SourceSink(s).neighborNode)
%         n = find(SourceSink(s).neighborNode(i) == nodeIds);
%         x1 = SourceSink(s).xy(1);
%         y1 = SourceSink(s).xy(2);
%         x2 = Node(n).xy(1);
%         y2 = Node(n).xy(2);
%         line( [x1 x2], [y1 y2] );
%         text(x1+(x2-x1)/2 - 5, y1+(y2-y1)/2 - 5, ...
%             sprintf('%.0f', Node(n).tSourceSink(i)), 'FontSize', 7);
%     end
%     text(x1-15,y1+25, sprintf('%0.1f/%0.1f', ...
%         SourceSink(s).pFromSource, SourceSink(s).pToSink), 'FontSize', 7);
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Draw circles for the nodes
for n1=1:NUMNODES
    x1 = Node(n1).xy(1);
    y1 = Node(n1).xy(2);
    rectangle('Position', [x1-5 y1-5 10 10], ...
        'Curvature', [1 1], 'FaceColor', 'b', 'EdgeColor', 'b');
end

% Draw the source/sinks as squares
for s=1:NUMSOURCESINK
    x1 = SourceSink(s).xy(1);
    y1 = SourceSink(s).xy(2);
    rectangle('Position', [x1-15 y1-15 30 30], ...
        'FaceColor', 'w');
end

% Print source/sink id inside node
for s=1:NUMSOURCESINK
    x1 = SourceSink(s).xy(1);
    y1 = SourceSink(s).xy(2);
    text(x1-15, y1, sprintf('%2d', sourcesinkIds(s)), 'Color', 'k', 'FontSize', 7);
end


% Draw any sensor hits 
for n=1:NUMNODES
    x1 = Node(n).xy(1);
    y1 = Node(n).xy(2);
    if Node(n).Z == 2
        % a sensor hit occurred
        rectangle('Position', [x1-10 y1-10 20 20], ...
            'Curvature', [1 1], 'FaceColor', 'r', 'EdgeColor', 'r');
    end
end


% % Print sensor or node id
% for n=1:NUMNODES
%     x1 = Node(n).xy(1);
%     y1 = Node(n).xy(2);
%     text(x1+5, y1+5, sprintf('%2d', nodeIds(n)), 'Color', 'b', 'FontSize', 10);
% end
