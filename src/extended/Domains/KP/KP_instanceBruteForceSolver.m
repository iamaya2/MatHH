%% Function for brute forcing KP instances
function bestSolutionPerInstance = KP_instanceBruteForceSolver(allInstances)
% Prevent warnings
warningState = warning().state;
warning('off')
%  --- Sweep instances
nbInstances = length(allInstances);
bestSolutionPerInstance = KPSolution.empty();
for idI = 1 : nbInstances
    % --- --- Select instance
    thisInstance = allInstances{idI};
    % --- --- Brute force instance
    nbItems = length(thisInstance.items);
    allSolutions = KPSolution.empty();
    fprintf('Brute-forcing instance %d/%d... \n', idI, nbInstances)
    for idx = 1 : nbItems
        fprintf('\tTesting combinations with %d elements... ', idx)
        testCombinations = nchoosek([thisInstance.items], idx);
        nbCombinations = size(testCombinations,1);
        fprintf('Generated a total of %d combinations... Testing them... ', nbCombinations)
        validFlag = zeros(1, nbCombinations);
        for idC = 1 : nbCombinations
            newSolution = KPSolution();
            newSolution.knapsack.capacity = thisInstance.capacity;
            newSolution.knapsack.ID = thisInstance.solution.knapsack.ID;
            newSolution.knapsack.items = testCombinations(idC,:);
            newSolution.knapsack.updateLength();
            newSolution.knapsack.updateCurrentWeight();
            newSolution.knapsack.updateCurrentProfit();
            newSolution.knapsack.checkValidity();
            allSolutions = [allSolutions; newSolution];
            % Check if the solution is valid
            if newSolution.knapsack.isUsable || newSolution.knapsack.currentWeight == newSolution.knapsack.capacity
                validFlag(idC) = 1;
            end
        end
        fprintf('Done!\n')
        if ~any(validFlag)
            fprintf('\t --- Detected stagnation (all combinations of these elements are invalid). Aborting search! ---\n')
            break
        end
    end
    fprintf('Done! Tested a total of %d solutions...\n', length(allSolutions))
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
    
end

% Restore warnings to original state
warning(warningState)