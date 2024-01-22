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
        featureValue = processMemoryBasedFeature(Instance, 1, featID-100);
    case num2cell(201:205) % equivalent to {201,202,...}        
        featureValue = processMemoryBasedFeature(Instance, 2, featID-200);
    case num2cell(301:305) % equivalent to {301,302,...}        
        featureValue = processMemoryBasedFeature(Instance, 3, featID-300);
    case num2cell(401:405) % equivalent to {401,402,...}        
        featureValue = processMemoryBasedFeature(Instance, 4, featID-400);
    case num2cell(501:505) % equivalent to {501,502,...}        
        featureValue = processMemoryBasedFeature(Instance, 5, featID-500);    
    otherwise
        callErrorCode(108) % Unknown feature ID
end
end

function featureValue = processMemoryBasedFeature(Instance, memoryShift, featureID)
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