function allVols = PlotZones3D(Rules, varargin)
% PlotZones3D   Function for plotting a rule-based HH
%  This function receives a matrix representing a set of rules
%  (condition:action) and plots the regions where each action is selected.
%  By default, it plots against the first three features of the model and
%  uses a fixed number of points, although other features can be selected.
%
%  Default values:
%    points             = 0:0.1:1;
%    selectedFeatures   = 1:3;
%    distanceMetric     = Euclidean
%
%  Inputs:
%    Rules - Matrix containing the selector. One row per rule and one
%    column per feature. An additional column must be included, which
%    indicates the action (solver) used when that rule is selected.
%
%  Optional inputs:
%    1 - Vector with the points that will be evaluated (per dimension)
%    2 - Flag indicating if Euclidean distance will be used
%    3 - Vector with three elements containing the IDs of the features
%    (columns) to use when plotting
%
%  Example:
%    addpath(genpath("..\")); % Loads required utilities
%    testSelector = [rand(5,6) randi(4,5,1)]; % Creates a random selector with
%    5 rules, 6 features and 4 solvers
%    PlotZones3D(testSelector); % Plots the zone of influence from the
%    perspective of the first three features.
%    PlotZones3D(testSelector,0:0.2:1,true,[1 4 5]); % Plot again, but with
%    a smaller resolution, while keeping the Euclidean distance, and from
%    the perspective of features 1, 4, and 5.
%    volumes = PlotZones3D(testSelector); % Repeats the plot but returns
%    the volume occuppied by each action in vector volumes.


forCIM = false;

% Common parameters
rX = 1; rY = 2; rZ = 3;
points = 0:0.1:1;
toEuclid = true;

% Custom parameters
if nargin == 2
    points = varargin{1};
elseif nargin == 3
    points = varargin{1};
    toEuclid = varargin{2};
elseif nargin == 4
    points = varargin{1};
    toEuclid = varargin{2};
    selectedFeatures = varargin{3};
    rX = selectedFeatures(1);
    rY = selectedFeatures(2);
    rZ = selectedFeatures(3);
end


Action = Rules(:,end);
ActionMarker = "s";
ActionSize = 12;

[X, Y, Z] = meshgrid(points);
allActionIDs = nan(size(X));
allColors = [0 0 0; 0.85 0 0; 0 0 0.85; 0.85 0 0.85; 0.75 * ones(1,3);  0.5 * ones(1,3);];

% Evaluate all points
for idx = 1 : size(X,1)
    for idy = 1 : size(Y,2)
        for idz = 1 : size(Z,2)
            RuleDistances = measureRules( [X(idx,idy,idz) Y(idx,idy,idz) Z(idx,idy,idz)], Rules(:,[rX rY rZ]), toEuclid );
            [~, ActionID] = min(RuleDistances);
            OwnAction = Action(ActionID);
            allActionIDs(idx,idy,idz) = OwnAction;
        end
    end
end

zz = [X(:) Y(:) Z(:)];
A = allActionIDs(:);
uniqueActions = unique(allActionIDs);
allVols = nan(1,max(uniqueActions)); % Allocate memory for each volume, considering that some selectors may not include all solvers

for idA = uniqueActions'
    validIDs = A == idA; % Gets positions with ID = idA
    P = zz(validIDs,:);
    [k, vol] = boundary(P,0.985); % Generate the boundary for this action
    allVols(idA) = vol; % Stores volume for this action
    tr = trisurf(k,P(:,1),P(:,2),P(:,3),'FaceColor',allColors(idA+1,:),'FaceAlpha',0.5);
    tr.EdgeColor=tr.FaceColor; tr.EdgeAlpha = 0.75; tr.LineStyle=':';
    hold on
end
plot3([0 0 1 1 0],[0 1 1 0 0],zeros(1,5),'-k','LineWidth',0.25); % bottom plate
plot3([0 0 1 1 0],[0 1 1 0 0],ones(1,5),'-k','LineWidth',0.25); % top plate
% plot3(zeros(1,5),[0 1 1 0 0],[0 0 1 1 0],'-k','LineWidth',0.25); % side plate 1
% plot3(ones(1,5),[0 1 1 0 0],[0 0 1 1 0],'-k','LineWidth',0.25); % side plate 2
plot3([0 0 1 1 0],zeros(1,5),[1 0 0 1 1],'-k','LineWidth',0.25); % front plate
plot3([0 0 1 1 0],ones(1,5),[1 0 0 1 1],'-k','LineWidth',0.25); % back plate
axis equal
% title('Shrink Factor = 0')
end