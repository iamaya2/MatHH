function [featureValue]= CalculateFeature(Instance, featID)
% To-do:
% Create private function for memory-based feature
switch featID
    case 1
        featureValue=Mirsh222(Instance);
    case 2
        featureValue=Mirsh15(Instance);
    case 3
        featureValue=Mirsh29(Instance);
    case 4
        featureValue=Mirsh282(Instance);
    case 5
        featureValue=Mirsh95(Instance);
    case num2cell(101:105) % equivalent to {101,102,...}
        callErrorCode(0)
        featureValue = processMemoryBasedFeature(Instance, 1, featID-100);
    otherwise
        callErrorCode(108) % Unknown feature ID
end
end

function featureValue = processMemoryBasedFeature(Instance, memoryShift, featureID)
callErrorCode(0) % WIP
featureValue = 1;
% processMemoryBasedFeature   Validates and retrieves memory
% information. Requires the memory shift and the feature ID.
if Instance.memorySize >= memoryShift % Validate if enough memory
    recoveredState = Instance.memory(memoryShift,:);
    featureLocation = Instance.featureIDs == featureID;    
    featureValue = recoveredState(featureLocation);
else
    callErrorCode(106) % Wrong memory size
end
        
end