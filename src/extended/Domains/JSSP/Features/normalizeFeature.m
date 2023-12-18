function [normalizedFeature]= normalizeFeature(featureValue, featureID)
switch featureID
    case 1
        normalizedFeature = featureValue/2;
    case 2
        normalizedFeature = featureValue/1.73;
    case 3
        normalizedFeature = featureValue/2;
    case 4
        normalizedFeature = featureValue/1.6875;
    case 5
        normalizedFeature = featureValue/1.5;
    otherwise
        normalizedFeature = featureValue; % No normalization unless known
end
