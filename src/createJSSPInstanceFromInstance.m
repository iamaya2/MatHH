%% Code for generating a JSSP instance using instance data information from instance generator
% instanceData: nbJobs*nbMachines*2 array.
%   First layer: Processing times.
%   Second layer: Machine sequence
function [newInstanceCopy, JSSPdata] = createJSSPInstanceFromInstance(fullInstance, varargin)
nbJobs = length(fullInstance.instanceData);
nbMachines = length(fullInstance.instanceData(1).activities);
JSSPdata = nan(nbJobs,nbMachines,2);
for idx = 1 : nbJobs
    JSSPdata(idx,:,1) = [fullInstance.instanceData(idx).activities.processingTime];
    JSSPdata(idx,:,2) = [fullInstance.instanceData(idx).activities.machineID];
end
newInstanceCopy = JSSPInstance(JSSPdata);
end

