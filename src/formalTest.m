%% formalTest sample file
% File for showing a sample formal test for researching purposes
% Goal: To train HHs with two different sets of parameters and compare them
%% Cleanup
clc
clear
close all

%% Load required packages
addpath(genpath('extended\Domains\JSSP')); % Adds JSSP functionality
addpath(genpath('extended\Utils')); % Adds assorted utilities

%% Instance datasets
% -- First set of instances (training)
instanceDataset = '..\..\BaseInstances\JobShopScheduling\files\mat\Instances\E02\instanceDataset.mat';
load(instanceDataset);
trainInstances = num2cell(allInstances); % Stores instances as cell array

% -- Second set of instances (testing)
instanceDataset = '..\..\BaseInstances\JobShopScheduling\files\mat\Instances\E01\instanceDataset.mat';
load(instanceDataset);
testInstances = num2cell(allInstances); % Stores instances as cell array

%% First HH model
%% -- Model parameters
nbRules = 4;
nbFeatures = 3; 
nbSolvers = 4;
targetProblem = "job shop scheduling";
%% -- Training parameters
%  ---- Required variables:
criterion = 1;  % Train for a fixed number of iterations
%  ---- Optional variables:
maxIter = 10;
populationSize = 20;
selfConf = 2.1;
globalConf = 2.1;
unifyFactor = 0.5;
visualMode = false;
%% -- Model initialization
firstHH = ruleBasedSelectionHH(nbRules, targetProblem); % Initializes to random model
firstHH.initializeModel(nbRules, nbFeatures, nbSolvers); % Sets a random model
%% -- Training process
firstHH.trainingInstances = trainInstances;
[position, fitness, details] = firstHH.train(criterion, maxIter, populationSize, selfConf, globalConf, unifyFactor, visualMode);


%% Second HH model
%% -- Model parameters
nbRules = 5;
nbFeatures = 2; 
nbSolvers = 3;
targetProblem = "job shop scheduling";
%% -- Training parameters
%  ---- Required variables:
criterion = 1;  % Train for a fixed number of iterations
%  ---- Optional variables:
maxIter = 7;
populationSize = 15;
selfConf = 2.5;
globalConf = 2.4;
unifyFactor = 0.7;
visualMode = false;
%% -- Model initialization
secondHH = ruleBasedSelectionHH(nbRules, targetProblem); % Initializes to random model
secondHH.initializeModel(nbRules, nbFeatures, nbSolvers); % Sets a random model
%% -- Training process
secondHH.trainingInstances = trainInstances;
[position2, fitness2, details2] = secondHH.train(criterion, maxIter, populationSize, selfConf, globalConf, unifyFactor, visualMode);


%% Testing of models
firstSolvedInstances = firstHH.solveInstanceSet(testInstances);
secondSolvedInstances = secondHH.solveInstanceSet(testInstances);

%% Result handling
%% -- Print makespan evolution for a random instance and both solvers
selectedID = randi(length(testInstances));
test = []; 
for idx = 1 : length(firstHH.performanceData{selectedID})
    test = [test;[firstHH.performanceData{selectedID}{idx}.solution.makespan secondHH.performanceData{selectedID}{idx}.solution.makespan]];     
end
test
%% -- Plot fitness evolution (training) for both methods 
firstHH.plotFitnessEvolution();
secondHH.plotFitnessEvolution();
%% -- Print final makespan across all instances for both methods
test = []; 
for idx = 1 : length(testInstances)
    test = [test;[firstHH.performanceData{idx}{end}.solution.makespan secondHH.performanceData{idx}{end}.solution.makespan]];     
end
test
%% -- Print training parameters for both methods
% --- Pending check: parameters are not being stored when training
firstHH.trainingParameters
secondHH.trainingParameters
%% -- Print HH for both models
firstHH.disp()
secondHH.disp()

%% Post-processing