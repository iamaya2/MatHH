%   UNIFIED PARTICLE SWARM OPTIMISATION ALGORITHM
%   Version 3.0
%                                                              
%   Coded by Jorge M. Cruz-Duarte
%   j.m.cruzduarte@ieee.org
%   June the 8th, 2019
%
% =====================================================================================
% INPUT ARGUMENTS:
% =====================================================================================
%
% * objectiveFunction   - The minimisation problem to be solved. It must be a script 
%                         or handle function. This parameter is mandatory.
%
% * popInitRange        - Simple boundaries of the search space. It must be a 
%                         NUMBER_OF_VARIABLES-times-2 matrix where the first and 
%                         second columns are the lower and upper boundaries per 
%                         dimension (row), respectively. If it is not provided, it 
%                         is defined as [-1,1;-1,1] assuming two dimensions, and the 
%                         par.simpleConstraints = false, for an unconstrained search.
%
% * par (optional):     - Parameter for running the algorithm.
%
%   General parameters
%   ------------------
%   verboseMode         - Additional details about what the algorithm is doing 
%                         are printed. It must be boolean. The default is true.
%   populationSize      - Number of agents conforming the population. It must be 
%                         an integer greater than 1. The default is 
%                         min(100,10*NUMBER_OF_VARIABLES).
%   simpleConstraints   - Define if the search space is constrained by the provided
%                         boundaries in popInitRange. It must be boolean. The default 
%                         is true.
%   randomSeed          - It is the seed for the random number generator. It must be 
%                         a real a non-negative integer. If a negative number is 
%                         provided, the default value, 'SHUFFLE', is chosen.
%   previousPopulation  - Allows an external population to be used as the initial 
%                         population. If previousPopulation is not provided, then the 
%                         method initialise the population. It must be a 
%                         NUMBER_OF_VARIABLES-times-POPULATION_SIZE matrix.
%   knownMin            - Provides the known minimum value for stopping the algorithm
%                         The default value is -INF.
%   maxIter             - Maximum number of iteratios. It must be a non-negative 
%                         integer. The default value is 1000.
%   maxStagIter         - Maximum number of stagnated iterations. It must be a 
%                         non-negative integer. The default value is min(30,0.1*maxIter).
%   stagTol             - Stagnation tolerance value for the stopping criteria. 
%                         It must be positive. The default value is 0.1.
%   funcTol             - Function variation tolerance for the stopping criteria. 
%                         It must be positive. The default value is 1e-12.
%   solTol              - Solution variation tolerance for the stopping criteria. 
%                         It must be positive. The default value is 1e-16.
%   fitnessLimit        - Fitness threshold value (using the provided known minimum 
%                         value, if it is finite and real). It must be positive. 
%                         The default value is 1e-6.
%
%   PSO specific parameters
%   -----------------------
%   selfConf            - PSO's self-confidence coefficient. It must be a real greater 
%                         than 0. The default value is 2.0.
%   globalConf          - PSO's global-confidence coefficient. It must be a real greater 
%                         than 0. The default value is 2.5.
%   kappaFactor         - PSO's factor for constriction factor calculation. It must be 
%                         a real greater than 0. The default value is 1.
%   phiFactor           - PSO's factor for constriction factor calculation. It must be 
%                         a real greater than 0. The default value is given by
%                         SELF_CONFIDENCE + GLOBAL_CONFIDENCE.
%   chiFactor           - PSO's constriction factor calculation. It must be a real 
%                         greater than 0. The default value is given by
%                         2*KAPPA / ABS ( 2 - PHI - SQRT( PHI^2 - 4*PHI ) ).
%   initialVelMode      - Defines how velocities are initialised. It must be a string
%                         such as 'rand' or 'zero'. The default is 'rand'.
%
%   
%   UPSO specific parameters
%   ------------------------
%   unifyFactor         - UPSO's Unification factor. It must be a real between [0,1].
%                         The default value is 0.5.
%   neighbourhood       - Population neighbourhood topology. It must be a binary
%                         POPULATION_SIZE-times-POPULATION_SIZE matrix. The default 
%                         value is the matrix of a (3-neighbours) ring topology.
%
% =====================================================================================
% OUTPUT ARGUMENTS:
% =====================================================================================
%
% * globalBestPosition  - Global best position is a NUMBER_OF_VARIABLES-vector 
%                         containing the latest best solution found.
% * globalBestFitness   - Global best fitness is the objectiveFunction evaluated in 
%                         globalBestPosition.
% * details:            - Details of the performed procedure.
%
%   Fields of details
%   -----------------
%   elapsedTime         - Overall procedure elapsed time in seconds.
%   functionEvaluations - Total performed evaluations number
%   performedIterations - Total iteration number
%   procedureEvolution: - A structure with information about the algorithm
%                         performance per interation.
%
%       Fields of procedureEvolution 
%       ----------------------------
%       solution        - A NUMBER_OF_VARIABLES-times-NUMBER_OF_ITERATIONS matrix 
%                         which contains the best position found per iteration.
%       fitness         - Structure with information about the fitness improvement per 
%                         iteration.
%
%           Fields of fitness 
%           -----------------
%           raw         - A NUMBER_OF_ITERATIONS vector which contains the best fitness 
%                         values found per iteration.
%           mean        - A NUMBER_OF_ITERATIONS vector which contains the average value
%                         of best fitness values found until the corresponding iteration.
%           stdv        - A NUMBER_OF_ITERATIONS vector which contains the standard 
%                         deviation value of best fitness values found until the 
%                         corresponding iteration.
%
%   stoppingFlags:      - A structure with the latest values of the stopping flags of 
%                         criteria
%
%       Fields of stoppingFlags 
%       -----------------------
%       iterationFlag   - Criterion 1: Has iteration counter reached the maximum number?
%       fitnessLimitFlag- Criterion 2: Has the best fitness reached the fitness limit?
%       stagWindowFlag  - Criterion 3: Is the procedure stagnated? Checking fitness window
%       stagStatFlag    - Criterion 4: Is the procedure stagnated? Checking fitness stats
%
% =====================================================================================
% EXAMPLE OF USE:
% =====================================================================================
%
% % Define an objective function
%   func = @(x) norm(x)^2;
%
% % Run the method setting a three dimensional problem
%   [position,fitness,details] = UPSO(func, ones(3,1)*[-10 10],struct('visualMode',true))
%
function [globalBestPosition,globalBestFitness,details, varargout] = ...
    UPSO2(objectiveFunction, popInitRange, par)

% - Check Inputs
if nargin < 3
    % Initialise the parameter struct with default values
    par = struct();
    if nargin < 2
        % Set an arbitrary and unconstrained search space
        par.simpleConstraints = false;
        popInitRange = [-1,1;-1,1];
        if nargin < 1
            % Stop the programe
            error('ObjectiveFunction must be provided!');
        end
    end
end

% - Check Outputs
% Check whic call was made
if nargout > 3
    hasInner = true; allInternals = struct();
else
    hasInner = false;
end

%% Verbose mode starting up

% Check if verbose mode is activated
if ~isfield(par,'verboseMode'), par.verboseMode = true; end

% [M1] Verbose output: Starting message
if par.verboseMode
    % Define a function for messages level 1
    verbMsg1 = @(token,string) fprintf('\n[%10s] %s\n',token,string);
    
    % Define a function for messages level 2
    verbMsg2 = @(string) fprintf('%s... %s\n',blanks(9),string);
    
    % Print the initial messages
    verbMsg1(datestr(now,'HH:MM:SS'),[mfilename,' starts...']);
    verbMsg2('Inputs and outputs checked!');
end

% Check if visual mode is activated
if ~isfield(par,'visualMode'), par.visualMode = false; 
else
    % Initialise the figure to plot the fitness visualisation
    fitnessEvolutionFig = figure('Name',[mfilename,' - Fitness Visualisation'],...
        'Color','White');
    axesFig = axes('NextPlot','Add');
end

%% Initialise Generic Parameters

% Number of Variables or Dimensions
par.numberVariables = size(popInitRange,1);

% Number of agents
if ~isfield(par,'populationSize')
    par.populationSize = min(100,10*par.numberVariables);
end

% Simple constraints activation
if ~isfield(par,'simpleConstraints'), par.simpleConstraints = true; end

% Set the random number generator
rng('shuffle');
if isfield(par,'randomSeed')
    if par.randomSeed < 0, rng(par.randomSeed); end
end

% Check if an initial distribution is provided
if ~isfield(par,'previousPopulation'), previousPopFlag = false; 
else, previousPopFlag = true;  end

% Known Minimal Value (default = -inf)
if ~isfield(par,'knownMin'), par.knownMin = -inf; end

% Maximum number of iterations
if ~isfield(par,'maxIter'), par.maxIter = 1000; end

% Maximum number of stagnated iterations
if ~isfield(par,'maxStagIter'), par.maxStagIter = min(30,0.1*par.maxIter); end

% Stagnation tolerance value
if ~isfield(par,'stagTol'), par.stagTol = 0.1; end

% Function tolerance value
if ~isfield(par,'funcTol'), par.funcTol = 1e-3; end

% Function tolerance value
if ~isfield(par,'solTol'), par.solTol = 1e-6; end

% Fitness Limit (only if Known Minimal Value is not equal to -inf)
if ~isfield(par,'fitnessLimit'), par.fitnessLimit = 1e-6; end

%% Initialise Specific Parameters

% - UPSO parameters

% Unification factor
if ~isfield(par,'unifyFactor'), par.unifyFactor = 0.5; end

% - PSO parameters

% Self-confidence coefficient
if ~isfield(par,'selfConf'), par.selfConf = 2.0; end

% Global-confidence coefficient
if ~isfield(par,'globalConf'), par.globalConf = 2.5; end

% Kappa factor for the Constriction factor calculation
if ~isfield(par,'kappaFactor'), par.kappaFactor = 1; end

% Phi factor for the Constriction factor calculation
if ~isfield(par,'phiFactor')
    par.phiFactor = par.selfConf + par.globalConf;
end

% Constriction factor
if ~isfield(par,'chiFactor')
    chiFactor = 2*par.kappaFactor/abs(2 - par.phiFactor ...
        - sqrt(par.phiFactor^2 - 4*par.phiFactor));
end

% Velocity mode
if ~isfield(par,'initialVelMode'), par.initialVelMode = 'rand'; end

% [M2] Verbose output: Parameters have been initialised
if par.verboseMode
    if nargin < 3, verbMsg2('Default parameters initialised:');
    else, verbMsg2('Parameters initialised:'); end
    fprintf('\n');disp(par); 
end

%% Initialise the algorithm variables

% Define the topology for neighbours (ring topology)
if ~isfield(par,'neighbourhood')
    neighbours = diag(ones(par.populationSize,1)) + ...
        diag(ones(par.populationSize - 1,1),1) + ...
        diag(ones(par.populationSize - 1,1),-1) + ...
        diag(ones(1), par.populationSize - 1) + ...
        diag(ones(1),(1 - par.populationSize));
else
    neighbours = par.neighbourhood;
end
neighbours(neighbours == 0) = nan;
if par.verboseMode, verbMsg2('Neighbours established'); end

% Create an initial population distributed along the Search Space
[currentPopulation,currentVelocity,par.populationSize] = ...
    InitialisePopulation('rand');

% Adjust the search space boundaries in matrix form
lowerBound = repmat(popInitRange(:,1),1,par.populationSize);
upperBound = repmat(popInitRange(:,2),1,par.populationSize);
if par.verboseMode, verbMsg2('Search space adjusted'); end

% Calculate the initial fitness values
currentEvaluatedFunction = EvalFunction();

% Store the particular best positions
particularBestPositions     = currentPopulation;
particularBestFitness       = currentEvaluatedFunction;
if par.verboseMode,verbMsg2('Particular best fitness values determined');end

% Set the iteration and stagnation counters
iteration           = 1;

% Find the best neighbour position
neighbourBestPositions = particularBestPositions;
UpdateNeighbourBest();

% Find the global best position and its fitness value
UpdateGlobalBest()

% Initialise additional information
if hasInner, varargout{1} = allInternals(g); end

% Preallocate the evolution register
evolution.fitness.raw   = nan(1,par.maxIter + 1);
evolution.fitness.mean  = nan(1,par.maxIter + 1);
evolution.fitness.stdv  = nan(1,par.maxIter + 1);
evolution.solution      = nan(par.numberVariables,par.maxIter + 1);

% Initialise the evolution register
UpdateEvolutionStats();

% Set the criteria flags as false
criteria = false;

% [M1] Verbose Output: Initialisation completed and Main Procedure stars
if par.verboseMode,verbMsg2('Initialisation completed!');end

%% Main proceduce: Unified Particle Swarm Optimisation (UPSO)
% - Start a time counter
timerVal = tic;

% - Repeat the following process till criteria becomes true
while ~criteria
    % Update the iteration counter
    iteration = iteration + 1;
    
    % Update the particle positions
    UnifiedParticleSwarmUpdating();
    
    % Check if the DiscoveryProbrticle is inside the search sDiscoveryProbce
    SimpleConstraints(par.simpleConstraints);
    
    % Evaluate objective function in new positions
    currentEvaluatedFunction = EvalFunction();
    
    % Update the particular best positions
    UpdateParticularBest();
    
    % Update the best neighbour position
    UpdateNeighbourBest();
    
    % Store the previous best solution
    previousBestFitness = globalBestFitness;
    
    % Update the global best position
    UpdateGlobalBest();
    
    % Update the evolution register
    UpdateEvolutionStats();
    
    % Update the criteria flag
    [criteria,stoppingFlags] = UpdateCriteria();    
end

% End the time counter
elapsedTime = toc(timerVal);

% Rescale the globalBestPosition to the original problem domain
globalBestPosition = RescaleVariables(globalBestPosition);

% Print results (if so)
if par.verboseMode
    verbMsg1(datestr(now,'HH:MM:SS'),['Process completed! Elapsed time: ',...
        sprintf('%.3f s',elapsedTime)]);
    solString = sprintf('%.6g, ',globalBestPosition);
    verbMsg2(['Best solution found: x = [',solString(1:end-2),']''']); 
    verbMsg2(sprintf('Best fitness found: f(x) = %.10g.',globalBestFitness)); 
end

% Store details about the performed procedure
details = struct('elapsedTime',elapsedTime, ...
    'functionEvaluations',iteration*(par.populationSize + 1), ...
    'performedIterations',iteration, ...
    'procedureEvolution',evolution, ...
    'stoppingCriteria',stoppingFlags);

%% Definition of functions used by this algorithm

% ------------------------------------------------------------------------
% Function for the initial population distribution
% ------------------------------------------------------------------------

    function [InitialPopulation,InitialVelocity,NewPop] = ...
            InitialisePopulation(kindOf)
        
        if ~previousPopFlag 
            % Calculate the initial positions, y (in [0,1])
            if nargin < 1, kindOf = 'rand'; end
            switch kindOf
                case 'grid' %                                       [to revise]
                    % Find points per dimensions and fix the population (if so)
                    [InitialPopulation,NewPop] = ...
                        gridDistribution(par.numberVariables,par.populationSize);
                    if par.verboseMode
                        verbMsg2('Population positions uniformly initialised');
                    end
                otherwise
                    NewPop = par.populationSize;
                    InitialPopulation = rand(par.numberVariables,NewPop);
                    if par.verboseMode
                        verbMsg2('Population positions randomly initialised');
                    end
            end
        else % if an initial population is provided
            InitialPopulation = par.previousPopulation;
            if par.verboseMode
                verbMsg2('Initial positions changed by previous positions');
            end
        end
        
        switch par.initialVelMode
            case 'rand'
                MaxVelocity = (popInitRange(:,2) - popInitRange(:,1));
                InitialVelocity   = ...
                    repmat(-MaxVelocity,1,par.populationSize) + ...
                    repmat(2*MaxVelocity,1,par.populationSize) .* ...
                    rand(par.numberVariables,par.populationSize);
                if par.verboseMode
                    verbMsg2('Population velocities randomly initialised'); 
                end
            otherwise % 'zero'
                InitialVelocity   = zeros(par.numberVariables,...
                    par.populationSize);
                if par.verboseMode
                    verbMsg2('Population velocities zero initialised'); 
                end
        end
        
        % Show message (if so)
        if par.verboseMode, verbMsg2('Population initialised'); end
    end

% ------------------------------------------------------------------------
% Function for rescaling the variables
% ------------------------------------------------------------------------

    function [RescaledVar] = RescaleVariables(Vars)
        % Create the Synthesis equation to transform y (in [0,1]) to x
        %   (in [lower,upper]). Both x and y are numOfVar--times--PopSize
        
        % Define the boundaries for each dimension
        %PopInitRange    = [min(PopInitRange,[],2) max(PopInitRange,[],2)];
        
        % Variables can be one agent or the entire population, then the
        % function returns one vector or a matrix.
        if size(Vars,2) == par.populationSize
            RescaledVar = lowerBound + Vars.*(upperBound - lowerBound);
        else
            RescaledVar = lowerBound(:,1) + ...
                Vars.*(upperBound(:,1) - lowerBound(:,1));
        end
    end

% ------------------------------------------------------------------------
% Function for the objective function evaluation
% ------------------------------------------------------------------------

    function EvaluatedFunction = EvalFunction()
        % Check if it is the first evaluation
        if ~exist('EvaluatedFunction','var')
            EvaluatedFunction = nan(par.populationSize,1);
        end
        
        % Rescale the population values to the problem's domain
        rescaledPopulation = RescaleVariables(currentPopulation);
        
        % Evaluate each agent's position into the objective function
        for AgentId = 1 : par.populationSize
            if hasInner
                [EvaluatedFunction(AgentId), innerSol, innerDetails] = ...
                    objectiveFunction(rescaledPopulation(:,AgentId));
                allInternals(AgentId) = struct('solution',innerSol, ...
                    'details', innerDetails);
            else
                EvaluatedFunction(AgentId) = ...
                    objectiveFunction(rescaledPopulation(:,AgentId));
            end
        end
        
        % Show message (if so)
%         if par.verboseMode, verbMsg2('Fitness values determined'); end
    end

% ------------------------------------------------------------------------
% Function for updating the global best position
% ------------------------------------------------------------------------

    function UpdateGlobalBest()
        % Check if previousBestFitness exists
        if ~exist('previousBestFitness','var'), ...
                previousBestFitness = inf; end
        
        % Find the lowest fitness value and its index
        [globalBestFitness,bestFitnessId] = min(particularBestFitness);
        
        % Update the corresponding position (if so)
        if globalBestFitness < previousBestFitness
            globalBestPosition = particularBestPositions(:,bestFitnessId);
        else
            globalBestFitness = previousBestFitness;
        end
        
        % Show message (if so)
        if par.verboseMode
            verbMsg1(sprintf('Step %5d',iteration),...
                sprintf('Global best fitness updated: %.4g',globalBestFitness));
        end
    end

% ------------------------------------------------------------------------
% Function for updating the neighbour best position
% ------------------------------------------------------------------------

    function UpdateNeighbourBest()
        % Find the lowest fitness value per neighbourhood
        [~,neigInds] = min(repmat(particularBestFitness,1, ....
            par.populationSize).*neighbours);
        
        % Update the neighbour best position
        neighbourBestPositions = particularBestPositions(:,neigInds);
        
        % Show message (if so)
%         if par.verboseMode
%             verbMsg2('Neighbour best fitness values updated');
%         end
    end

% ------------------------------------------------------------------------
% Function for updating the particular best position
% ------------------------------------------------------------------------

    function UpdateParticularBest()
        % Check if new positions are better than previous ones
        improvingCond = logical(ones(par.numberVariables,1)* ...
            (currentEvaluatedFunction < particularBestFitness)');
        
        % Update only the improved ones
        particularBestPositions(improvingCond) = currentPopulation(improvingCond);
        particularBestFitness = min(currentEvaluatedFunction, ...
            particularBestFitness);
        
        % Show message (if so)
%         if par.verboseMode
%             verbMsg2('Particular best fitness values updated');
%         end
    end

% ------------------------------------------------------------------------
% Function for the unified particle swarm updating
% ------------------------------------------------------------------------

    function UnifiedParticleSwarmUpdating()
        % Determine components of global velocities (G) / base PSO
        globalVelocity = chiFactor*(currentVelocity + ...
            par.selfConf*rand(par.numberVariables,par.populationSize).* ...
            (particularBestPositions - currentPopulation) + ...
            par.globalConf*rand(par.numberVariables,par.populationSize).*...
            (repmat(globalBestPosition,1,par.populationSize) - ...
            currentPopulation));
        
        % Determine components of local velocities (L) / UPSO 1st component
        localVelocity = chiFactor*(currentVelocity + ...
            par.selfConf*rand(par.numberVariables,par.populationSize).* ...
            (particularBestPositions - currentPopulation) + ...
            par.globalConf*rand(par.numberVariables,par.populationSize).*...
            (neighbourBestPositions  - currentPopulation));
        
        % Update the current velocities                / UPSO 2nd component
        newVelocities = par.unifyFactor*globalVelocity + ...
            (1 - par.unifyFactor)*localVelocity;
        
        % Check if these new velocities are finites
        tfValid = all(isfinite(newVelocities), 1);
        currentVelocity(:,tfValid) = newVelocities(:,tfValid);
        
        % Update the position for each particle
        newPositions = currentPopulation + currentVelocity;
        
        % Check if these new positions are finites
        tfValid = isfinite(newPositions);
        currentPopulation(tfValid) = newPositions(tfValid);
        
        % Show message (if so)
%         if par.verboseMode
%             verbMsg2('The swarm moved (positions updated)');
%         end
    end

% ------------------------------------------------------------------------
% Function for the simple constraints verification
% ------------------------------------------------------------------------

    function SimpleConstraints(activation)
        if activation == true
            % Check lower boundaries
            currentPopulation(currentPopulation < 0) = 0;
            currentVelocity(currentPopulation < 0) = 0;
            
            % Check upper boundaries
            currentPopulation(currentPopulation > 1) = 1;
            currentVelocity(currentPopulation > 1) = 0;
            
            % Show message (if so)
%             if par.verboseMode, verbMsg2('Constraints verified'); end
        end
    end

% ------------------------------------------------------------------------
% Function for the solution evaluation
% ------------------------------------------------------------------------

    function UpdateEvolutionStats()
        % Store the current best position and fitness value
        evolution.fitness.raw(iteration)    = globalBestFitness;
        evolution.solution(:,iteration)     = globalBestPosition;
        
        if iteration <= 1
            % Initialise the fitness mean and standard deviation values
            evolution.fitness.mean(iteration)   = globalBestFitness;
            evolution.fitness.stdv(iteration)   = nan; % Can be commented
            
        else
            % Determine the fitness mean and standard deviation values
            evolution.fitness.mean(iteration)   = ...
                mean(evolution.fitness.raw(1:iteration));
            evolution.fitness.stdv(iteration)   = ...
                std(evolution.fitness.raw(1:iteration));
            
            % Add the current best fitness value to the stagnation window
            evolution.fitnessStagWin(1+mod(iteration-1,par.maxStagIter)) = ...
                globalBestFitness;
        end
        
        % Visualisation mode
        if par.visualMode
            clf(axesFig);
            
            % Plot fitness raw values
            plot(axesFig,evolution.fitness.raw(1:iteration),'-r','LineWidth',1);
            % Plot fitness mean values
            plot(axesFig,evolution.fitness.mean(1:iteration),'--b','LineWidth',1); 
            % Plot fitness mean +/- st. dev. values
            plot(axesFig,evolution.fitness.mean(1:iteration) + par.stagTol*...
                evolution.fitness.stdv(1:iteration),'--c','LineWidth',1);
            plot(axesFig,evolution.fitness.mean(1:iteration) - par.stagTol*...
                evolution.fitness.stdv(1:iteration),'--c','LineWidth',1,...
                'HandleVisibility','off');
            
% - to plot the stagnation sub-criterion
%             plot(axesFig,evolution.fitness.stdv(1:iteration),'-r','LineWidth',1,...
%                 'HandleVisibility','off');
%             plot(axesFig,abs(evolution.fitness.raw(1:iteration) - ...
%                 evolution.fitness.mean(1:iteration)),'--k','LineWidth',1,...
%                 'HandleVisibility','off');
            
            % Set properties of graph
            %ylabel('Best Fitness','Interpreter','LaTeX','FontSize',12);
            xlabel('Iteration','Interpreter','LaTeX','FontSize',12);
            leg = legend('$$ f(\vec{x}_*)$$, Best fitness values',...
                '$$\mu_f $$, Mean of $$f(\vec{x}_*)$$',...
                '$$ \mu_f \pm \epsilon \sigma_f$$, Variation of $$f(\vec{x}_*)$$'); 
            set(leg,'Interpreter','LaTeX','FontSize',12);
            set(axesFig,'LineWidth',1.0,'TickLabelInterpreter','LaTeX',...
                'FontSize',12,'XLim',[0 iteration+1],'Box','On');
            getframe(fitnessEvolutionFig);
        end
        
    end

% ------------------------------------------------------------------------
% Function for the criteria evaluation
% ------------------------------------------------------------------------

    function [criteria,stoppingFlags] = UpdateCriteria()
        
        % Criterion 1: Has the iteration counter reached the maximum number?
        stoppingFlags.iterationFlag = iteration >= par.maxIter;
        
        % Criterion 2: Has the best fitness reached the fitness limit?
        if isfinite(par.knownMin)
            stoppingFlags.fitnessLimitFlag = abs(par.knownMin - ...
                globalBestFitness) < par.fitnessLimit;
        else
            stoppingFlags.fitnessLimitFlag = false;
        end
        
        % Criteria 3 and 4: Is the procedure stagnated?
        if iteration > par.maxStagIter
            % The max value of best fitness is chosen
            maxBestFitnessWindow = evolution.fitness.raw(iteration - ...
                par.maxStagIter + 1);
            % Fitness change is calculated
            fitnessChange = abs(maxBestFitnessWindow - globalBestFitness)/...
                max(1,abs(globalBestFitness));
            
           % The position corresponding to such max best fitness value
           maxBestPositionWindow = evolution.solution(:, iteration - ...
                par.maxStagIter + 1);
            % Position change is calculated
           solutionChange = norm(maxBestPositionWindow - globalBestPosition)/...
                max(1,norm(globalBestFitness));
        else
            fitnessChange = Inf;
            solutionChange = Inf;
        end        
        
        % -> Criterion 3: Check stagnation using a window of changes
        stoppingFlags.stagWindowFlag = (fitnessChange < par.funcTol) && ...
            (solutionChange < par.solTol);
        
        % -> Criterion 4: Check stagnation using statistics
        stoppingFlags.stagStatFlag = (abs(globalBestFitness - ...
            evolution.fitness.mean(iteration)) < ...
            par.stagTol*evolution.fitness.stdv(iteration));
        
%         disp(fitnessChange < par.funcTol)
%         disp(solutionChange < par.solTol)
%         disp(abs(evolution.fitness.raw(iteration) - evolution.fitness.mean(iteration)))
%         disp(evolution.fitness.stdv(iteration))
            
        % Summary of criteria
        criteria = stoppingFlags.iterationFlag || stoppingFlags.fitnessLimitFlag || ...
            stoppingFlags.stagWindowFlag || stoppingFlags.stagStatFlag;
        
        
        % Show message (if so)
        if par.verboseMode
            if ~criteria, verbMsg2('Criteria checked! Process continues');
            else
                verbMsg2('Criteria checked! Process stops because:');
                if stoppingFlags.iterationFlag
                    verbMsg2('(Criterion 1) Maximum iteration number has been reached');
                end
                if stoppingFlags.fitnessLimitFlag
                    verbMsg2('(Criterion 2) Best fitness limit has been reached');
                end
                if stoppingFlags.stagWindowFlag
                    verbMsg2('(Criterion 3) Procedure has been stagnated by window check');
                end
                if stoppingFlags.stagStatFlag
                    verbMsg2('(Criterion 4) Procedure has been stagnated by stat check');
                end
            end
        end
    end

end
