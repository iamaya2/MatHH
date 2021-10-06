function allActionIDs = getActionIDs(testValues, Rules, toEuclid)
% getActionIDs   Function for testing a selector and getting the action ID
% of each point within its domain.
%  Inputs:
%   testValues - Matrix with test points. Rows: points; Columns:
%   dimensions.
%   Rules - Matrix representing the selector. Rows: rules; Columns:
%   features+action
%   toEuclid - Flag for indicating if Euclidean distance should be used

Action = Rules(:,end);
allActionIDs = nan(size(testValues,1),1); % Allocate memory for each test point
% Evaluate all points
for idx = 1 : length(allActionIDs)
    RuleDistances = measureRules(testValues(idx,:), Rules(:,1:2), toEuclid);
    [~, ActionID] = min(RuleDistances); % Gets ID (row) of closest rule
    allActionIDs(idx) = Action(ActionID); % Gets corresponding action
end
end