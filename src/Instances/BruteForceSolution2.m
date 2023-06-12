% This code works for a cell array of instances
%% 
%CLEANING AND FOLDERS
%First let's clean everything and add needed folders
clc
clear
close all

addpath(genpath('extended/Domains/JSSP')); % Adds JSSP functionality
addpath(genpath('extended/Utils')); % Adds assorted utilities

%First load instance set to solve in a cell array an save it to
%allInstances 
load('instances_adv1_adv2_comb.mat')
allInstances=instances_comb;

%% Solve instance dataset
 
timerID = tic();
nbInstances  = length(allInstances);
for idI = 1:nbInstances
    instanceToSolve = createJSSPInstanceFromInstance(allInstances{idI});
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
save(['SolutionsInstances_Comb.mat'])

%% Get best/worst solutions for each instance
[bestMakespans, bestMakespansLocations] = min(allMakespans,[],1);
[bestMakespans; bestMakespansLocations]

[worstMakespans, worstMakespansLocations] = max(allMakespans,[],1);
[worstMakespans; worstMakespansLocations]

fprintf("Total makespan range for this dataset: [%d,%d]\n", sum(bestMakespans), sum(worstMakespans))


%% Auxiliary functions
% function instance = getInstance(fullPath)
% S = load(fullPath);
% instanceVar = fieldnames(S);
% switch lower(instanceVar{1})
%     case 'jsspinstance'
%         tempVar = S.(instanceVar{1});
%         instance = tempVar{1};
%     case 'cell'
%         tempVar = S.(instanceVar{1});
%         instance = tempVar{1};
%     case 'generatedinstance'
%         instance = S.(instanceVar{1});
% end
% end



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