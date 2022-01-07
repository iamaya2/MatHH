% function MAP_Elites(instances, properties)
function [bestGenoma,bestGenomaFitness,bestIterations,details] = MAP_Elites_v2(testHH, instances, parameters, varargin)
% MAP_ElITES Summary of this function goes here
% v2: Uses a base solution extracted from initial ones
%   testHH: sequenceBasedSelection obj
%   properties: parameters associated to the MAP-Elites 
%   varargin: 1. Plotting flag (true/false)
    
    %% Read properties
    nbInstances = parameters.nbInstances;
    nbRegionsDim = parameters.nbRegionsDim;         % Number of solvers
    nbDimInt = parameters.nbDimInt;                 % Number of sequence steps (columnas) 
    nbInitialGenomes = parameters.nbInitialGenomes; % Number of initial solutions                   
    searchDomain = parameters.searchDomain;         % Pending: change 2 for nbSolvers         
    nbIterations = parameters.nbIterations;         % Number of iterations 
    mutationRate = parameters.mutationRate;         % Probability of a dimension to be mutated
    nbPointsDim = nbRegionsDim+1;                   % Points of the graph 
    normalization = parameters.normalization;       % Normalization of fitness
    selectedType = parameters.type;                 % (1) Pac-man, (2) Rebounce
    mutationType = parameters.mutationType;         % (1) Original, (2) 5 operators 
    
    nbIterations = nbIterations - nbInitialGenomes; 
    
    if length(varargin) == 1, toPlot = varargin{1}; else, toPlot = false; end
    
    
    %% Algorithm preparation
    % 0. Timer ID
    timerID = tic;
    % 1. Define N dimensions of interest for variation (feature space)
    nbRegionsDimVec = nbRegionsDim * ones(1, nbDimInt);
    % 2. Discretize feature space
    disSearchSpace = zeros(nbDimInt, nbPointsDim);
    gridSearchSpaceF = nan(nbRegionsDimVec);
    gridSearchSpace = cell(nbRegionsDimVec);
    for idx = 1 : nbDimInt
        disSearchSpace(idx,:) = linspace(searchDomain(1),searchDomain(end), nbPointsDim);
    end
    
    % 1. Initialization
    bestGenoma = 0; 
    bestGenomaFitness = inf; 
    bestIterations = inf; 
    iter = 0; 
    evolution = nan(1,nbIterations+1);
    % initialGenomes = (searchDomain(end)-searchDomain(1)).*randi(searchDomain(end), nbInitialGenomes, nbDimInt);
    initialGenomes = randi(searchDomain(end), nbInitialGenomes, nbDimInt);
    % Shuffling
    shuffledGenomeID = randperm(nbInitialGenomes);
    % Assignment to grid
    for genomeID = shuffledGenomeID
        iter = iter + 1; 
        targetGenome = initialGenomes(genomeID,:);
        [fGenome,bestGenoma,bestGenomaFitness,bestIterations] = performance(testHH, instances,nbInstances,...
                      targetGenome,bestGenoma,bestGenomaFitness,normalization,selectedType,bestIterations,iter);
        [disSearchSpace, gridSearchSpace, gridSearchSpaceF] = MAPEliteGridAssign ...
        (disSearchSpace, gridSearchSpace, gridSearchSpaceF, targetGenome, fGenome);
    end
    evolution(1) = bestGenomaFitness;

    %gridSearchSpaceF
    if toPlot, MAPEliteVisualize(disSearchSpace, gridSearchSpaceF, 1,2), end

    % Iteration
    for idx = 1 : nbIterations
        % 1. Selection and offspring generation
        % ---- Random selection of elite within a cell in map
        while true
            % Strive to select an agent at a random cell, and repeat until
            % a proper one is found
            targetCell = randi(nbRegionsDim, 1, nbDimInt); % Creates a vector of random ints \in [1,nbSolvers = nbRegionsDim] for selecting a random cell among all available cells
            transfCellID = num2cell(targetCell);            
            parentGenome = gridSearchSpace{transfCellID{:}}; 
            if ~isempty(parentGenome), break, end % If agent exists, break
        end
                
        if ~isnan(parentGenome)  % Just for consistency check 
            % ---- Offspring generation
            % ---- ---- Crossover
            % ---- ---- Mutation
            childGenome = parentGenome;
            % ---- ---- ---- Original mutation 
            if mutationType == 1 
                % New code (IA - 20/05/2020):
                for targetID  = 1 : nbDimInt % Sweep every dimension (element in the sequence) and see if it mutates
                    if(rand < mutationRate)                             % If random is less than mutationRate...
                        childGenome(targetID) = randi(searchDomain(end)); % ...dimension changes to random value from searchDomain.
                    end
                end
                % ---- ---- ---- In case the child is the same as the parent:
                while childGenome == parentGenome  % If no mutation was done...
                    targetID = randi(nbDimInt); % ...enforce mutation of random element (dimension)...
                    childGenome(targetID) = randi(searchDomain(end)); % ...and change it to random value.
                end
            % ---- ---- ---- Five mutation operators      
            elseif mutationType == 2
                while childGenome == parentGenome 
                    mutationOperator = randperm(5,1);
                    switch mutationOperator 
                        case 1  % Single-Point Flip
                            pos = randperm(nbDimInt,1); 
                            childGenome(pos) = randperm(nbRegionsDim,1); 
                        case 2  % Neighbor-based Single-Point Flip
                            pos = randperm(nbDimInt,1);  
                            if pos == 1 % Left neighbor
                                neighborHeur(1,1) = childGenome(nbDimInt);
                            else 
                                neighborHeur(1,1) = childGenome(pos-1);
                            end
                            if pos == nbDimInt % Right neighbor 
                                neighborHeur(1,2) = childGenome(1);
                            else 
                                neighborHeur(1,2) = childGenome(pos+1); 
                            end
                            childGenome(pos) = neighborHeur(randperm(2,1)); 
                        case 4  % Neighbor-based Two-Point Flip
                            pos = randperm(nbDimInt,2); 
                            if pos(1) == 1        % Left neighbor - element 1 
                                neighborHeur(1,1) = childGenome(nbDimInt);
                            else 
                                neighborHeur(1,1) = childGenome(pos(1)-1);
                            end
                            if pos(1) == nbDimInt %  Right neighbor - element 1 
                                neighborHeur(1,2) = childGenome(1);
                            else 
                                neighborHeur(1,2) = childGenome(pos(1)+1); 
                            end
                            if pos(2) == 1       % Left neighbor - element 2 
                                neighborHeur2(1,1) = childGenome(nbDimInt);
                            else 
                                neighborHeur2(1,1) = childGenome(pos(2)-1);
                            end
                            if pos(2) == nbDimInt   % Right neighbor - element 2 
                                neighborHeur2(1,2) = childGenome(1);
                            else 
                                neighborHeur2(1,2) = childGenome(pos(2)+1); 
                            end
                            childGenome(pos(1)) = neighborHeur(randperm(2,1));
                            childGenome(pos(2)) = neighborHeur2(randperm(2,1));
                        case 3  % Single-Point Swap
                            pos = randperm(nbDimInt,2);
                            val1 = childGenome(pos(1));
                            val2 = childGenome(pos(2)); 
                            childGenome(pos(1)) = val2;
                            childGenome(pos(2)) = val1;
                        case 5  % Two-Point Swap 
                            pos = randperm(nbDimInt,4); 
                            val1 = childGenome(pos(1));
                            val2 = childGenome(pos(2));
                            val3 = childGenome(pos(3));
                            val4 = childGenome(pos(4)); 
                            childGenome(pos(1)) = val2;
                            childGenome(pos(2)) = val1;
                            childGenome(pos(3)) = val4;
                            childGenome(pos(4)) = val3;
                    end
                end 
            end
            
            % Old code (pending verify and deletion):
            %         for i = 1 : nbRegionsDim
            %             targetID = nbRegionsDim;   % CAREFUL: Check this!
            %             if(rand < mutationRate)                             % If random is less than mutationRate,
            %                 childGenome(targetID) = randi(searchDomain(2)); % dimension changes at random from the searchDomain.
            %             end
            %         end
            %         % ---- ---- ---- In case the child is the same as the parent.
            %         if childGenome == parentGenome
            %             targetID = randi(nbRegionsDim);
            %             childGenome(targetID) = randi(searchDomain(2));     %It mutates a dimension at random.
            %         end
            
            
            
            
            
            % 2. Offspring evaluation and allocation
            % ---- Evaluation of generated offspring
            [fGenome,bestGenoma,bestGenomaFitness,bestIterations] = performance(testHH,instances,nbInstances,...
                childGenome,bestGenoma,bestGenomaFitness,normalization,selectedType,bestIterations,idx+nbInitialGenomes);
            % ---- Offspring allocation into grid
            [disSearchSpace, gridSearchSpace, gridSearchSpaceF] = MAPEliteGridAssign ...
                (disSearchSpace, gridSearchSpace, gridSearchSpaceF, childGenome, fGenome);
            % ---- Historical data preservation
            evolution(idx+1) = bestGenomaFitness;
        else
            warning('NaN cell selected!')
        end
    end
    
        
    % Store details about the performed procedure
    elapsedTime = toc(timerID);
    stoppingFlags = struct('iterationFlag', true);
    details = struct('elapsedTime',elapsedTime, ...
        'functionEvaluations',idx+nbInitialGenomes, ...
        'performedIterations',idx, ...
        'procedureEvolution',evolution, ...
        'stoppingCriteria',stoppingFlags);
    
    %gridSearchSpaceF
    if toPlot, MAPEliteVisualize(disSearchSpace, gridSearchSpaceF, 1,2), end    
end

function [fitness,bestGenoma,bestGenomaFitness,bestIterations] = performance(testHH,instances,nbInstances,...
                            genoma,bestGenoma,bestGenomaFitness,normalization,selectedType,bestIterations,iter)
    nbSteps = length(genoma); 
    testHH.setModel(genoma,selectedType);  
    % ---- Solve the instanceSet using the genoma
    solvedInstances = solveInstanceSet(testHH,instances);
    fitness = 0; 
    % ---- Sum of the fitness 
    for idp = 1 : nbInstances
        if normalization == 1
            sumItems = sum(testHH.trainingInstances{1,idp}.instanceItems,'all');  
            fitness = fitness + (solvedInstances{1,idp}.solution.fitness / sumItems); 
        else
            fitness = fitness + solvedInstances{1,idp}.solution.fitness;
        end
    end
    fitness = fitness/nbInstances;
    % ---- Save the best value in each run 
    if fitness < bestGenomaFitness 
        bestGenomaFitness = fitness; 
        bestGenoma = genoma; 
    end
    % ---- Save the best value of each iteration
    bestIterations(iter,1:nbSteps) = bestGenoma; 
    bestIterations(iter,nbSteps+1) = bestGenomaFitness; 
end