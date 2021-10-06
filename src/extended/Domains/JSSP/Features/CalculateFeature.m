function [featureValue]= CalculateFeature(Instance, featID) 
    if featID==1
        featureValue=Mirsh222(Instance);
    elseif featID==2
        featureValue=Mirsh15(Instance);
    elseif featID==3
        featureValue=Mirsh29(Instance);
    elseif featID==4
        featureValue=Mirsh282(Instance);
    elseif featID==5
        featureValue=Mirsh95(Instance);
    end
end    