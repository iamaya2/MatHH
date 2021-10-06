function allArea = PlotCommonZones(allSelectors, varargin)
% PlotCommonZones   Function for plotting several rule-based HHs
%  This function receives a hypermatrix representing several sets of rules
%  (condition:action) and plots the regions where all of their actions intersect.
%  By default, it plots against the first two features of the model and
%  uses a fixed number of points, although other features can be selected.
%
%  Default values:
%    points             = 0:0.01:1;
%    selectedFeatures   = 1:2;
%    distanceMetric     = Euclidean
%
%  Inputs:
%    allSelectors - Hypermatrix containing all selectors. One row per rule and one
%    column per feature. An additional column must be included, which
%    indicates the action (solver) used when that rule is selected. One layer per selector.
%
%  Optional inputs:
%    1 - Vector with the points that will be evaluated (per dimension)
%    2 - Flag indicating if Euclidean distance will be used
%    3 - Vector with three elements containing the IDs of the features
%    (columns) to use when plotting
%    4 - Flag for indicating if the rules should be plotted as well
%
%  Example:
%    addpath(genpath("..\")); % Loads required utilities
%    testSelector = [rand(5,6) randi(4,5,1)]; % Creates a random selector with
%    5 rules, 6 features and 4 solvers
%    testSelector2 = testSelector; % Duplicates the selector so all regions
%    are common
%    testSelector2(4,end) = testSelector(1,end); % Changes the fourth
%    action by that of the first one so that a region is not common
%    testSelector3 = [rand(5,6) randi(4,5,1)]; % Creates another random selector
%    figure, PlotZones(testSelector); % Plots the zone of influence from the
%    perspective of the first two features (first selector).
%    figure, PlotZones(testSelector2); % Plots the zone of influence from the
%    perspective of the first two features (second selector).
%    figure, PlotZones(testSelector2); % Plots the zone of influence from the
%    perspective of the first two features (third selector).
%    Build the hyper-matrix:
%    tS(:,:,1) = testSelector; tS(:,:,2) = testSelector2; tS(:,:,3) = testSelector3;
%    figure, PlotCommonZones(tS(:,:,1:2)); % Plots common zones between
%    first two selectors (should be a lot of common data)
%    figure, PlotCommonZones(tS(:,:,1:2),0:0.01:1,true,1:2,true); % Plots again but
%    including the rules (for verification)
%    figure, PlotCommonZones(tS); % Plots common zones between all
%    selectors (common data should be lower)
%    figure, PlotCommonZones(tS,0:0.01:1,true,1:2,true); % Plots again but
%    including the rules (for verification)


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


[X, Y] = meshgrid(points);
vX = X(:);
vY = Y(:);
allColors = [0 0 0; 1 1 0; 0 1 0; 1 0 0; 0 0 1; 1 0 1;];

allActionIDs = getCommonActionIDs([vX vY], allSelectors(:,[rX rY end],:), toEuclid ); % Evaluate all points

zz = [vX vY];
uniqueActions = unique(allActionIDs); % Gets 'unique' actions
validActions = ~isnan(uniqueActions); % Checks for nans
uniqueActions = uniqueActions(validActions); % Remove nans

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

if plotRules
    for idS = 1 : size(allSelectors,3)
        PlotRules(allSelectors(:,:,idS),[rX rY]); % Plots rules (if desired)
    end
end 
end