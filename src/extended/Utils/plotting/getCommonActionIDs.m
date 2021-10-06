function commonActionIDs = getCommonActionIDs(testValues, allSelectors, toEuclid)
% getCommonActionIDs   Function for testing several selectors and getting 
% the action ID of each common point within its domain.
%  Inputs:
%   testValues - Matrix with test points. Rows: points; Columns:
%   dimensions.
%   allSelectors - Hypermatrix representing the selectors. Rows: rules; Columns:
%   features+action; Layers: Selectors.
%   toEuclid - Flag for indicating if Euclidean distance should be used

nbSelectors = size(allSelectors,3);
nbPoints = size(testValues,1);

% Get action zone of each selector
allActionIDs = nan(nbPoints, nbSelectors);
for idS = 1 : nbSelectors
    allActionIDs(:,idS) = getActionIDs(testValues, allSelectors(:,:,idS), toEuclid);
end

% Detect common actions
commonActionIDs = nan(nbPoints, 1); % Allocate memory
validIDs = range(allActionIDs,2)==0; % Gets common points  
commonActionIDs(validIDs) = allActionIDs(validIDs,1); % Assigns common actions
end