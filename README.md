# MatHH: A Matlab-based Hyper-Heuristic framework
---
This repository contains a description of `MatHH`, a framework developed in Matlab for coding and testing hyper-heuristics.

## Required packages
In order to properly use `MatHH`, the following packages are required:

- `Utils`: a set of diverse utility functions to better organize the code; available at: [Github](https://github.com/iamaya2/Utils)
- *Problem domains:* different packages can be developed/used for providing domain-specific capabilities. So far, the following packages have been tested:
   - `JSSP-Matlab-OOP`: an object-oriented class for handling Job-Shop scheduling problems; available at: [Github](https://github.com/iamaya2/JSSP-Matlab-OOP)
   
It is also necessary to define the training instances that will be used. To this end, we suggest using the `BaseInstances` package (available at: [Github](https://github.com/iamaya2/BaseInstances)), which contains some instances that can be used with this framework.   

### File organization
Seeking to facilitate the maintenance of the required packages, the root folder of each package should be located at the same level. Hence, the following structure is suggested:

```
\BaseInstances
\JSSP-Matlab-OOP
\MatHH
   \src
\Utils
   \distance
   ...
```   
   
***Note**: remember you can use `addpath(genpath(pathString))` for temporarily adding these packages to Matlab's search path, so that you can put your codes in different folders.*

## Currently supported hyper-heuristics
The following kinds of hyper-heuristics (HHs) are currently supported:

HH model 		| Class name 				| Description
-- 				| -- 						| --
Selection 		| `selectionHH.m`		 	| Parent class for selection hyper-heuristics
--- Rule-based 	| `ruleBasedSelectionHH.m` 	| Class for rule-based selection hyper-heuristics

## Upcoming functionality

- [ ] Sequence-based selection hyper-heuristics
- [ ] Support for balanced partition problems 

## Example
The following example is also provided in the file `example.m` so that you can run it directly into Matlab. This example shows how to create a simple HH and associate it to the Job-Shop Scheduling problem. Besides, we also provide some examples about how to train the HH model and about how to use it for solving a set of new instances. Some details about the information that can be used are also provided. 

### Cleanup
The first thing is to make sure that the workspace is pristine:

```
clc
clear
close all
```

### Package loading 
Then, the required packages must be added to the search path:

```
addpath(genpath("..\..\JSSP-Matlab-OOP")); % Adds JSSP functionality
addpath(genpath("..\..\Utils")); % Adds assorted utilities
```

### HH creation
Before creating the hyper-heuristic, we must first define some basic parameters:

```
nbRules = 4; % Number of rules for the model 
targetProblem = "job shop scheduling"; % String representing the problem domain 
```

Now, we can create a basic HH: 

```
testHH = ruleBasedSelectionHH(nbRules, targetProblem); % Initializes to random model
```

We can also define our own model by providing the rule matrix:

```
userModel = [0.2 0.4 0.6 1;...
             0.1 0.3 0.9 3;...
             0.8 0.7 0.2 1;...
             0.5 0.5 0.5 2];  % User-defined rule matrix 
testHH.value = userModel; % Sets the user-defined model			 
```			 

Similarly, we can create a random model with fixed parameters: 

```			 
nbFeatures = 3; % Number of features for the model 
nbSolvers = 4; % Number of solvers that will be available 
testHH.initializeModel(nbRules, nbFeatures, nbSolvers); % Generates a random model
```			 

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

%% HH training
% --- Required variables:
criterion = 1;  % Train for a fixed number of iterations

% --- Train using default parameters:
testHH.train(criterion);

% --- Define training parameters (for training a HH with UPSO)
maxIter = 10;
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