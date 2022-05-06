%% File for debugging purposes (not to be uploaded to Github)
%% Cleanup
clc
clear
close all

%% Loads required packages
addpath('../'); % Adds root folder (without subfolders)
addpath(genpath('../extended/Domains/JSSP')); % Adds JSSP functionality
addpath(genpath('../extended/Utils')); % Adds assorted utilities

%% Loads instances for testing

% ------ First set of training instances (5x5)
instanceDataset = '../../BaseInstances/JobShopScheduling/files/mat/Instances/E02/instanceDataset.mat';
load(instanceDataset);
trainInstances1 = num2cell(allInstances); % Stores instances as cell array

% ------ Second set of training instances (15x15)
instanceDataset = '../../BaseInstances/JobShopScheduling/files/mat/Instances/E01/instanceDataset.mat';
load(instanceDataset);
trainInstances2 = num2cell(allInstances); % Stores as cell array

%% 1. Create raw HH2
HH1 = ruleBasedSelectionHHMulti();

%% 2. Create HH2 with custom parameters
props = struct('nbLayers',2,'selectedSolvers',1:2,'selectedFeatures',2:4,...
                'nbRules',10);
HH2 = ruleBasedSelectionHHMulti(props);

dummyHH = ruleBasedSelectionHH(struct('nbRules',5));
props2 = props;
props2.innerHHs = [ruleBasedSelectionHH()  dummyHH ruleBasedSelectionHH()];
HH3 = ruleBasedSelectionHHMulti(props2);    

%% 3. Test getRuleAction method
% -- Parameters for inner HHs
pr1 = struct('nbRules',10,'selectedSolvers',[2 4],'selectedFeatures',1:2, 'nbLayers', 1);
pr2 = struct('nbRules',11,'selectedSolvers',[1 3],'selectedFeatures',1:2, 'nbLayers', 1);
% -- Inner HHs
iHH1 = ruleBasedSelectionHHMulti(pr1);
iHH2 = ruleBasedSelectionHHMulti(pr2);
% -- Parameters for HH2
pr3 = struct('nbRules',5,'selectedSolvers',1,'selectedFeatures',1:2, ...
                'nbLayers',2,'innerHHs',[iHH1 iHH2]); % for iHH1
pr4 = pr3; pr4.selectedSolvers = 2; % for iHH2            
pr5 = pr3; pr5.selectedSolvers = 1:2; % for iHH1 or iHH2
% -- HH2 creation
HH3 = ruleBasedSelectionHHMulti(pr3); % Should only use iHH1
HH4 = ruleBasedSelectionHHMulti(pr4); % Should only use iHH2
HH5 = ruleBasedSelectionHHMulti(pr5); % Should use either iHH1 or iHH2
% -- HH2 analysis
%      tt5 must be the same as either tt3 or tt4, depending on the rule
%      selected
tt=[]; for idx = 1 : 30, tt = [tt HH3.getRuleAction(3,trainInstances1{idx})]; end, tt3 = tt
tt=[]; for idx = 1 : 30, tt = [tt HH4.getRuleAction(3,trainInstances1{idx})]; end, tt4 = tt
tt=[]; for idx = 1 : 30, tt = [tt HH5.getRuleAction(3,trainInstances1{idx})]; end, tt5 = tt

%% 4. Test inherited plotZones method
% -- HH2 plots
HH3.plotZones
HH4.plotZones
HH5.plotZones
% Result: Method must be updated (probably overloaded) since it seems to be
% plotting only the info about the outermost layer.

%% 5. Test getStepData method
sDEmpty = HH5.getStepData(trainInstances1{1},3,[]); % Should have empty layer choices
sDEmpty2 = HH5.getStepData(trainInstances1{1},2,3); % Should have innerID = 3
sDEmpty3 = HH5.getStepData(trainInstances1{1},4,[2 1]); % Should have innerID = [2 1]

%% 6. Test solving instances
% -- Solve one instance with each innerHH (iHH1 and iHH2)
selectedInstanceSubset = trainInstances1(1);
solvedInstanceiHH1 = iHH1.solveInstanceSet(selectedInstanceSubset);
solvedInstanceiHH2 = iHH2.solveInstanceSet(selectedInstanceSubset);
% -- Solve same instance with each HH2 (HH3 - HH5)
solvedInstanceHH3 = HH3.solveInstanceSet(selectedInstanceSubset);
solvedInstanceHH4 = HH4.solveInstanceSet(selectedInstanceSubset);
solvedInstanceHH5 = HH5.solveInstanceSet(selectedInstanceSubset);
% -- Compare solutions and validate that iHH1 == HH3, iHH2 == HH4,
%       iHH1~=iHH2~=HH5
disp('The following should be true:')
isequal(solvedInstanceiHH1{1}.solution, solvedInstanceHH3{1}.solution)
isequal(solvedInstanceiHH2{1}.solution, solvedInstanceHH4{1}.solution)
disp('The following should be false:')
isequal(solvedInstanceiHH1{1}.solution, solvedInstanceHH5{1}.solution)
isequal(solvedInstanceiHH2{1}.solution, solvedInstanceHH5{1}.solution)
isequal(solvedInstanceiHH1{1}.solution, solvedInstanceiHH2{1}.solution)
% -- Repeat for a whole set of instances (e.g. trainInstances1)
selectedInstanceSubset = trainInstances1; % Use all set
% -- -- Solve instances
solvedInstanceiHH1 = iHH1.solveInstanceSet(selectedInstanceSubset);
solvedInstanceiHH2 = iHH2.solveInstanceSet(selectedInstanceSubset);
solvedInstanceHH3 = HH3.solveInstanceSet(selectedInstanceSubset);
solvedInstanceHH4 = HH4.solveInstanceSet(selectedInstanceSubset);
solvedInstanceHH5 = HH5.solveInstanceSet(selectedInstanceSubset);
% -- -- Check that conditions hold 
allChecksTrue = [];
allChecksFalse = [];
for idx = 1 : length(selectedInstanceSubset)
    check1T = isequal(solvedInstanceiHH1{idx}.solution, solvedInstanceHH3{idx}.solution);
    check2T = isequal(solvedInstanceiHH2{idx}.solution, solvedInstanceHH4{idx}.solution);
    allChecksTrue = [allChecksTrue [check1T;check2T]];
    
    check1F = isequal(solvedInstanceiHH1{idx}.solution, solvedInstanceHH5{idx}.solution);
    check2F = isequal(solvedInstanceiHH2{idx}.solution, solvedInstanceHH5{idx}.solution);
    check3F = isequal(solvedInstanceiHH1{idx}.solution, solvedInstanceiHH2{idx}.solution);
    allChecksFalse = [allChecksFalse [check1F;check2F;check3F]];
end
disp('The following should be true:')
all(allChecksTrue,2)
disp('The following should be false:')
any(allChecksFalse,2)
% -- -- In some cases the second batch of tests may not hold since some
% instances may yield the same solution even if using different solvers.
% So, use the following plots to validate that choices were actually
% different (and correct):
% -- -- -- Plotting info about instance 3 since it showed the same result
% for iHH2 and HH5:
figure
subplot(1,2,1)
iHH2.plotSolverUsageDistribution(3);
subplot(1,2,2)
HH5.plotSolverUsageDistribution(3);
% -- -- -- Plotting info about solver usage across the whole set:
figure
subplot(1,2,1)
iHH2.plotSolverUsageDistributionMulti(1:30,true);
subplot(1,2,2)
HH5.plotSolverUsageDistributionMulti(1:30,true);
