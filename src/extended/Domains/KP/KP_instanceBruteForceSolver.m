%% File for brute forcing KP instances
%% Cleanup
clc
clear
close all

%% Global variables
basepath = '..\..\..\';
matInstancePath = [basepath '..\..\BaseInstances\Knapsack\files\mat\Toy\'];
toSave = true; % For defining if best solutions are updated

%% Loads required packages
addpath(basepath); % Adds root folder (without subfolders)
addpath([basepath 'extended\Domains\']); % Adds common domain classes (abstract)
addpath(genpath([basepath 'extended\Domains\KP'])); % Adds KP domain functionality
addpath(genpath([basepath 'extended\Utils'])); % Adds assorted utilities

%% Load instance files while brute-forcing them
%  --- Define instances to load
allInstances = {'toy01', 'toy02', 'toy03', 'toy04'};
%  --- Sweep instances
nbInstances = length(allInstances);
bestSolutionPerInstance = KPSolution.empty();
for idI = 1 : nbInstances
    % --- --- Select instance
    thisInstanceName = allInstances{idI};
    % --- --- Load instance
    fprintf('Attempting to load instance %s ... ', thisInstanceName)
    load([matInstancePath thisInstanceName '.mat'])
    thisInstance = eval(thisInstanceName);
    fprintf('OK!\n')
    % --- --- Brute force instance
    nbItems = length(thisInstance.items);
    allSolutions = KPSolution.empty();
    fprintf('Brute-forcing instance %s... ', thisInstanceName)
    for idx = 1 : nbItems
        testCombinations = nchoosek([thisInstance.items], idx);
        for idC = 1 : size(testCombinations,1)
            newSolution = KPSolution();
            newSolution.knapsack.capacity = thisInstance.capacity;
            newSolution.knapsack.ID = thisInstance.solution.knapsack.ID;
            newSolution.knapsack.items = testCombinations(idC,:);
            newSolution.knapsack.updateLength();
            newSolution.knapsack.updateCurrentWeight();
            newSolution.knapsack.updateCurrentProfit();
            newSolution.knapsack.checkValidity();
            allSolutions = [allSolutions; newSolution];
        end
    end
    fprintf('done! Tested a total of %d solutions...\n', length(allSolutions))
    % --- --- Identify valid solutions
    allValidSolutions = [];
    bestValue = -inf;
    for idx = 1 : length(allSolutions)
        if allSolutions(idx).knapsack.isUsable || allSolutions(idx).knapsack.currentWeight == allSolutions(idx).knapsack.capacity
            allValidSolutions = [allValidSolutions; allSolutions(idx)];
            % --- --- Update best solution
            if allSolutions(idx).knapsack.currentProfit > bestValue
                bestValue = allSolutions(idx).knapsack.currentProfit;
                bestSolution = allSolutions(idx);                
            end
        end
    end   
    bestSolutionString = formattedDisplayText(bestSolution.knapsack);
    fprintf('\tBest solution found:\n%s\n', bestSolutionString);
    bestSolutionPerInstance(idI) = bestSolution;
    % --- --- Update file
    if toSave
        thisInstance.bestSolution = bestSolution;
        save([matInstancePath thisInstanceName '.mat'],thisInstanceName)
    end
end