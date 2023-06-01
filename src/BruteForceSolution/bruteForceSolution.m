%%
clc
clear 
close all

addpath(genpath("..\"));

%%
% dataset  = "InstanceRepository\PreliminaryInstances\AllvsMPA\*.mat";
dataset     = 'TE07'; 
datasetDir  = ['InstanceRepository\HHInstances\' dataset '\*.mat'];
allFiles    = dir(datasetDir);
nbFiles     = length(allFiles);

% load([allFiles(nbFiles).folder '\' allFiles(nbFiles).name]);
% allInstances(nbFiles) = JSSPInstance{1};
% allInstances(nbFiles) = generatedInstance;
% allInstances(nbFiles) = cell{1};
allInstances(nbFiles) = getInstance([allFiles(nbFiles).folder '\' allFiles(nbFiles).name]);
for idF = 1 : nbFiles-1
%     load([allFiles(idF).folder '\' allFiles(idF).name]);
%     allInstances(idF) = JSSPInstance{1};
%     allInstances(idF) = generatedInstance;
%     allInstances(idF) = cell{1};
    allInstances(idF) = getInstance([allFiles(idF).folder '\' allFiles(idF).name]);
end
%%
% % dummy instance
% instanceData = [     4     2     4     1;
%      4     4     1     1;
%      4     1     2     5];
% %  Machine orderings (M):
% instanceData(:,:,2) = [     4     1     4     3;
%      2     3     4     3;
%      5     2     1     4];
% instanceToSolve = JSSPInstance(instanceData);

%% Solve instance dataset
timerID = tic();
nbInstances  = length(allInstances);
for idI = 1:nbInstances
    instanceToSolve = createJSSPInstanceFromInstance(allInstances(idI));
    % --- Get instance data
    nbJobs = instanceToSolve.nbJobs;
    nbMachs = instanceToSolve.nbMachines;

    % --- Generate all orderings    
    if idI == 1        
        [nbOrderings,~,allOrderings] = uniqperms(repmat(1:nbJobs,1,nbMachs));
        allMakespans = nan(nbOrderings,length(allInstances)); 
    end

    % --- Solve with each ordering and store result
    for idx = 1 : nbOrderings
        if mod(idx,100) == 0, clc, fprintf("Progress: Instance: %d/%d\n\tTesting ordering %d/%d...\n",idI,nbInstances, idx,nbOrderings); end
        newInstance = createJSSPInstanceFromInstance(instanceToSolve);
        currentOrdering = allOrderings(idx,:);
        for idT = 1 : length(currentOrdering)
            newInstance.scheduleJob(currentOrdering(idT));
        end
        if ~strcmp(newInstance.status,'Solved'), error("Instance not fully solved. Aborting test..."), end
        allMakespans(idx,idI) = newInstance.solution.makespan;
    end
end
timeTaken = toc(timerID);
fprintf("All solutions tested. Time taken: %.2f\n", timeTaken);

%% Save results file
save(['Solutions' dataset '.mat'])

%% Get best/worst solutions for each instance
[bestMakespans, bestMakespansLocations] = min(allMakespans,[],1);
[bestMakespans; bestMakespansLocations]

[worstMakespans, worstMakespansLocations] = max(allMakespans,[],1);
[worstMakespans; worstMakespansLocations]

fprintf("Total makespan range for this dataset: [%d,%d]\n", sum(bestMakespans), sum(worstMakespans))


%% Auxiliary functions
function instance = getInstance(fullPath)
S = load(fullPath);
instanceVar = fieldnames(S);
switch lower(instanceVar{1})
    case 'jsspinstance'
        tempVar = S.(instanceVar{1});
        instance = tempVar{1};
    case 'cell'
        tempVar = S.(instanceVar{1});
        instance = tempVar{1};
    case 'generatedinstance'
        instance = S.(instanceVar{1});
end
end
% instance = JSSPInstance();
% load(fullPath);
% if exist('JSSPInstance') == 1
%     instance = JSSPInstance{1};
% elseif exist('generatedInstance') == 1
%     instance = generatedInstance;
% else
%     instance = cell{1};
% end
% end