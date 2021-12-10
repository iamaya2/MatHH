function allArea = PlotZones(Rules, varargin)
% PlotZones   Function for plotting a rule-based HH
%  This function receives a matrix representing a set of rules
%  (condition:action) and plots the regions where each action is selected.
%  By default, it plots against the first two features of the model and
%  uses a fixed number of points, although other features can be selected.
%
%  Default values:
%    points             = 0:0.01:1;
%    selectedFeatures   = 1:2;
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
%    3 - Vector with two elements containing the IDs of the features
%    (columns) to use when plotting
%    4 - Flag for indicating if the rules should be plotted as well
%
%  Example:
%    addpath(genpath("..\")); % Loads required utilities
%    testSelector = [rand(5,6) randi(4,5,1)]; % Creates a random selector with
%    5 rules, 6 features and 4 solvers
%    PlotZones(testSelector); % Plots the zone of influence from the
%    perspective of the first two features.
%    PlotZones(testSelector,0:0.005:1,true,[4 5]); % Plot again, but with
%    a better resolution, while keeping the Euclidean distance, and from
%    the perspective of features 4 and 5.
%    areas = PlotZones(testSelector); % Repeats the plot but returns
%    the area occuppied by each action in vector volumes.
%    figure, areas = PlotZones(testSelector,0:0.005:1,true,[3 4],true); %
%    Plots the selector with modified parameters, plus the rules of the
%    model.


rX = 1; rY = 2;
plotRules = false;
if nargin < 2
    points = 0:0.01:1;
    toEuclid = true;
elseif nargin < 3
    points = varargin{1};
    toEuclid = true;
elseif nargin < 4
    points = varargin{1};
    toEuclid = varargin{2};
elseif nargin < 5
    points = varargin{1};
    toEuclid = varargin{2};
    selectedFeatures = varargin{3};
    rX = selectedFeatures(1);
    rY = selectedFeatures(2);
else
    points = varargin{1};
    toEuclid = varargin{2};
    selectedFeatures = varargin{3};
    rX = selectedFeatures(1);
    rY = selectedFeatures(2);
    plotRules = varargin{4};
end


Action = Rules(:,end);
ActionMarker = "s";
ActionSize = 12;

[X, Y] = meshgrid(points);
vX = X(:);
vY = Y(:);
% allColors = [0 0 0; 1 1 0; 0 1 0; 1 0 0; 0 0 1; 1 0 1;];
allColors = [0 0 0; 0.85 0 0; 0 0 0.85; 0.85 0 0.85; 0.75 * ones(1,3);  0.5 * ones(1,3);];

allActionIDs = getActionIDs([vX vY], Rules(:,[rX rY end]), toEuclid ); % Evaluate all points

zz = [vX vY];
uniqueActions = unique(allActionIDs);
allArea = nan(1,max(uniqueActions)); % Allocate memory for each area, considering that some selectors may not include all solvers

for idA = uniqueActions'
    validIDs = allActionIDs == idA; % Gets positions with ID = idA
    P = zz(validIDs,:);
    [k, area] = boundary(P,0.985); % Generate the boundary for this action
    allArea(idA) = area; % Stores volume for this action
    tr = patch(P(k,1), P(k,2), allColors(idA+1,:), 'FaceAlpha', 0.5); % Creates patch using boundary points
    tr.EdgeColor=tr.FaceColor; tr.EdgeAlpha = 0.75; tr.LineStyle=':';
    hold on
end

plot([0 0 1 1 0],[0 1 1 0 0],'-k','LineWidth',0.25);

if plotRules, PlotRules(Rules,[rX rY]); end % Plots rules (if desired)

xlabel(['F_' num2str(rX)])
ylabel(['F_' num2str(rY)])
axis equal
axis square
end