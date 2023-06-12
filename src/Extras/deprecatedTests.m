%% deprecatedTests file
% File for doing random tests for developing purposes
%% Cleanup
clc
clear
close all

%% Loads required packages
addpath(genpath('extended\Domains\JSSP')); % Adds JSSP functionality
addpath(genpath('extended\Utils')); % Adds assorted utilities

%% HH creation
% --- Basic parameters
nbRules = 4;
nbFeatures = 3; 
nbSolvers = 4;
targetProblem = "job shop scheduling";
userModel = [0.2 0.4 0.6 1;...
             0.1 0.3 0.9 3;...
             0.8 0.7 0.2 1;...
             0.5 0.5 0.5 2];

% --- Main process
testHH = ruleBasedSelectionHH(nbRules, targetProblem); % Initializes to random model
testHH.value = userModel; % Sets a user-defined model
testHH.initializeModel(nbRules, nbFeatures, nbSolvers); % Sets a random model

% --- Instance assignment
% ------ Load first set of training instances
instanceDataset = '..\..\BaseInstances\JobShopScheduling\files\mat\Instances\E02\instanceDataset.mat';
load(instanceDataset);
trainInstances1 = num2cell(allInstances); % Stores instances as cell array

% ------ Load second set of training instances
instanceDataset = '..\..\BaseInstances\JobShopScheduling\files\mat\Instances\E01\instanceDataset.mat';
load(instanceDataset);
trainInstances2 = num2cell(allInstances); % Stores as cell array

testHH.trainingInstances = trainInstances1; % Assigns first set to HH

%% Testing solution of a single instance for analyzing time consumption
for idx = 1:30
    tic, 
    sI=testHH.solveInstanceSet(trainInstances1(1)); 
    toc, 
end

%% Validating schedule update and storage
% test = []; 
% for idx = 1 : 26
% %     test = [test;[testHH.performanceData{1}{idx}.solution.makespan testHH.performanceData{1}{idx}.solution.currentMakespan]]; 
%     test = [test;[testHH.performanceData{1}{idx}.solution.makespan]]; 
% end