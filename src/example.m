%% Cleanup
clc
clear
close all

%% Loads required packages
addpath(genpath('extended/Domains/JSSP')); % Adds JSSP functionality
addpath(genpath('extended/Utils')); % Adds assorted utilities

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
instanceDataset = '../../BaseInstances/JobShopScheduling/files/mat/Instances/E02/instanceDataset.mat';
load(instanceDataset);
trainInstances1 = num2cell(allInstances); % Stores instances as cell array

% ------ Load second set of training instances
instanceDataset = '../../BaseInstances/JobShopScheduling/files/mat/Instances/E01/instanceDataset.mat';
load(instanceDataset);
trainInstances2 = num2cell(allInstances); % Stores as cell array

testHH.trainingInstances = trainInstances1; % Assigns first set to HH

%% HH training
% --- Required variables:
criterion = 1;  % Train for a fixed number of iterations

% --- Train using default parameters:
testHH.train(criterion);

% --- Define training parameters (for training a HH with UPSO)
maxIter = 100;
populationSize = 20;
selfConf = 2.1;
globalConf = 2.1;
unifyFactor = 0.5;
visualMode = false;

% --- Training process:
% ------ position: vector containing the HH model
% ------ fitness: best fitness value found by UPSO
% ------ details: structure with extra information about the process
testHH2 = ruleBasedSelectionHH(nbRules, targetProblem); % Creates a new HH
testHH2.trainingInstances = trainInstances1; % Assigns first set of instances to HH
[position, fitness, details] = testHH2.train(criterion, maxIter, populationSize, selfConf, globalConf, unifyFactor, visualMode);

% --- Use training information, e.g. to plot performance evolution across
% iterations:
figure, plot(details.procedureEvolution.fitness.raw)

%% HH usage after training
% --- Solve a set of new instances
solvedInstances = testHH2.solveInstanceSet(trainInstances2);

% --- Display the initial feature values when solving the second instance
selectedStep = 1;
selectedInstance = 2;
testHH2.performanceData{selectedInstance}{selectedStep}.featureValues

% --- Plot the final solution of the third instance
selectedInstance = 3;
testHH2.performanceData{selectedInstance}{end}.solution.plot()

% --- Plot the solution of the third instance before taking the fourth
% decision
selectedStep = 4;
selectedInstance = 3;
testHH2.performanceData{selectedInstance}{selectedStep}.solution.plot()

%% Visualize resulting zones of influence
% --- Using default values:
points             = 0:0.01:1;
selectedFeatures   = 1:2;
selectedFeatures2  = 3:4;
useEuclid          = true; % Use Euclidean distance
doRules            = true; % Plot rules along with zones
testHH2.plotZones(points, useEuclid, selectedFeatures, doRules)
testHH2.plotZones(points, useEuclid, selectedFeatures2, doRules)