function [normalizedFeature]= normalizeFeature(featureValue, featureID)

    if featureID ==1 
        normalizedFeature = featureValue/2; 
    elseif featureID ==2 
        normalizedFeature = featureValue/1.73;
    elseif featureID ==3 
        normalizedFeature = featureValue/2;    
    elseif featureID ==4 
        normalizedFeature = featureValue/1.6875;
    elseif featureID ==5 
        normalizedFeature = featureValue/1.5;
    end
end
