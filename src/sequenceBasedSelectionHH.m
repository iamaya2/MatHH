% Class definition for Sequence-based selection hyper-heuristics
% The constructor method supports the following modes:
%  sequenceBasedSelectionHH(HH): Creates a clone of HH (deep copy)
%  sequenceBasedSelectionHH(props): Creates a new HH using the properties 
%   defined by props. The following properties are supported: 
%   - length: Scalar with the size of the model (number of
%   steps). Default: 2
%   - model: Vector with one heuristic ID per step. Default:
%   random model
%   - position: Scalar with the initial location within the sequence.
%   Default: 1
%   - selectedSolvers: Vector with IDs of solvers available for
%   the HH. Default: [1 2]
%   - shift: Scalar with the shift (increase/decrease) that will be used
%   when taking steps within the sequence. Default: 1
%   - targetProblem: Domain that will be solved. Default: "job shop scheduling"
%   - type: Repetition type. Default: 1
classdef sequenceBasedSelectionHH < selectionHH
    % ----- ---------------------------------------------------- -----
    %                       Properties
    % ----- ---------------------------------------------------- -----
    properties
        % Most properties are inherited from the selectionHH superclass. Only
        % the following properties are specific to this class:
%        nbSolvers       = NaN;
        currentStep     = 1;
        currentInc      = 1;
        modelLength     = NaN;
        type            = 1; %Prefefined Pac-man
    end
    
    properties (Dependent)
        % TO-DO: Put any dependent properties here (calculated on-the-fly)
%         nbSequenceSteps   = NaN; % toDo: Remove this (check first)
    end
    
    % ----- ---------------------------------------------------- -----
    %                       Methods
    % ----- ---------------------------------------------------- -----
    methods
        % ----- ---------------------------------------------------- -----
        % Constructor
        % ----- ---------------------------------------------------- -----
        function obj = sequenceBasedSelectionHH(varargin)
            % sequenceBasedSelectionHH   Constructor method for the class
            obj.hhType = 'Sequence-based';
            obj.value  = [];
            
            targetProblem = "job shop scheduling"; % Default domain                       
            targetShift = 1; % Default shift
            targetLocation = 1; % Default location
            targetType = 1; % Default repeat type
            defaultSolvers = true; % Flag for using default solvers
            defaultModel = true; % Flag for using random initial model
            defaultLength = true;
            
            if nargin > 0
                if isa(varargin{1},'sequenceBasedSelectionHH') % Support for cloning directly from the constructor
                    obj = sequenceBasedSelectionHH();
                    varargin{1}.cloneProperties(obj);
                    return
                elseif isstruct(varargin{1})
                    props = varargin{1};        
                    if isfield(props,'length'), targetLength = props.length; defaultLength = false; end
                    if isfield(props,'model'), targetValue = props.model; defaultModel = false; end                    
                    if isfield(props,'position'), targetLocation = props.position; end                    
                    if isfield(props,'selectedSolvers'), selectedSolvers = props.selectedSolvers; defaultSolvers = false; end                    
                    if isfield(props,'shift'), targetShift = props.shift; end
                    if isfield(props,'targetProblem'), targetProblem = props.targetProblem; end                    
                    if isfield(props,'type'), targetType = props.type; end
                else
                    error('The current input is not currently supported. Try using a struct or another HH.')
                end
            end
            
            obj.targetProblemText = targetProblem;            
            obj.assignProblem(targetProblem) 
            obj.currentInc = targetShift;
            obj.currentStep = targetLocation;
            obj.type = targetType;
            
            % Check for default values
            if defaultModel
                if defaultLength, targetLength = 2; end
                if defaultSolvers, selectedSolvers = [1 2]; end               
                obj.initializeModel(targetLength, selectedSolvers); 
            else
                targetLength = length(targetValue);
                defaultLength = false; 
                obj.value = targetValue;
                if defaultSolvers, selectedSolvers = unique(targetValue); end
                obj.availableSolvers = selectedSolvers;                
                obj.modelLength = targetLength;
                obj.nbSolvers = length(selectedSolvers);                
            end 
        end
        
        
        
        % ----- ---------------------------------------------------- -----
        % Other methods (sort them alphabetically)
        % ----- ---------------------------------------------------- -----
        function evaluateCandidateSolution(obj, solution, instances)
            % evaluateCandidateSolution  Method for evaluating a candidate
            % solution. Does not consider normalization procedures.
            obj.setModel(solution,obj.type)
            solvedInstances = obj.solveInstanceSet(instances);
            fitness = 0;
            for idx=1:length(instances)
                fitness = fitness + solvedInstances{idx}.solution.fitness;                
            end
        end
        
        % ----- Instance seeker
        function getInstances(obj, instanceType)
            % GETINSTANCES  Method for extracting one kind of instances from the model (not yet implemented)
            %  instanceType: String containing the kind of instances that
            %  will be extracted. Can be: Training, Testing
            
        end 
        
        % ----- Step selector for the model
        function sequencePos = getNextStep(obj)
            % INITIALIZEMODEL  Method for generating a random solution for
            % the current hh model
            sequencePos = obj.currentStep;
            obj.currentStep = obj.currentStep + obj.currentInc;
            if obj.currentStep > obj.modelLength
                % Pac-Man way
                if obj.type == 1
                    obj.currentStep = 1;
                % Bounce
                elseif obj.Type == 2
                    obj.currentStep = obj.modelLength;    
                    obj.currentInc = -1;
                end
            elseif obj.currentStep == 0
                obj.currentStep = 1; 
                obj.currentInc = 1; 
            end
        end 
        
        % ----- Model initializer
        function initializeModel(obj, varargin)
            % INITIALIZEMODEL  Method for generating a random solution for
            % the current hh model
            if isempty(varargin)
                obj.initializeModel(obj.modelLength, obj.availableSolvers)
            elseif length(varargin) == 2
                obj.modelLength = varargin{1};
                obj.availableSolvers = varargin{2};
                obj.nbSolvers = length(obj.availableSolvers);
                randomIDs = randi(obj.nbSolvers,1,obj.modelLength);
                randomModel = obj.availableSolvers(randomIDs);
                obj.value = randomModel;
            else
                error('initializeModel cannot handle the requested number of parameters. Try with none or with two.')
            end            
        end 
        
        
        
        % ----- Model setter
        function setModel(obj, model, type)
            % SETMODEL  Method for setting the HH model to a fixed array
            obj.value = model;
            obj.type = type; 
            obj.availableSolvers = unique(model);
            obj.nbSolvers = length(obj.availableSolvers);
            obj.modelLength = length(model);
            obj.currentStep = 1;
%             obj.nbSolvers = max(model(:,end)); % At least the max action
        end 
                      
        % ----- Hyper-heuristic solver
        function [instance, performanceData] = solveInstance(obj, instance)
            % SOLVEINSTANCE  Method for solving a single instance with the current version of the HH (not yet implemented)            
            performanceData = {};
            while ~strcmp(instance.status, 'Solved')
                activeStep = obj.getNextStep();
                heuristicID = obj.value(activeStep);
                stepData = struct('selectedSolver', heuristicID,...
                                    'solution', instance.solution.clone());
                performanceData = [performanceData stepData];
                obj.targetProblem.stepHeuristic(instance, heuristicID);
%                 instance.stepHeuristic(heuristicID);
            end   
            obj.currentStep = 1; 
            obj.currentInc = 1;  
            stepData = struct('selectedSolver', NaN,...
                'solution', instance.solution);
            performanceData = [performanceData stepData]; % Values associated to the solved instance
        end         
        
                       
        % ----- Instance asigner
        function setInstances(obj, instanceType, instances)
            % SETINSTANCES  Method for assigning one kind of instances to the model (not yet implemented)
            %  instanceType: String containing the kind of instances that
            %                will be extracted. Can be: Training, Testing
            %  instances:    Cell array with the instances that will be
            %                assigned
            
        end 
                

        
        % ----- Instance splitter
        function splitInstances(obj, trainRatio)
            % SPLITINSTANCES  Method for separating loaded instances into
            % training and testing subsets (not yet implemented)
            %  trainRatio:  Percentage of instances that will be used for
            %  the training set
            %
            % NOTE: When giving the percentage, bear in mind that the
            % number of instances will be rounded to the closest integer.
            % For example, using trainRatio = 0.25 when the number of total
            % instances is 51 will deliver 13 training instances. Instead, if the
            % number of total instances is 49, then 12 training instances
            % will be provided.
            
        end 
        
        % ----- Hyper-heuristic tester
        function totalFitnessTest = test(obj, parameters)
            % TEST  Method for running the HH on the testing instances (not yet implemented)
            %   parameters: Parameters associated to the test (genomas)
            
            if ~isfield(parameters,'normalization') 
                parameters.normalization = 0;
            end
            if ~isfield(parameters,'genomas') 
                error('Missing genomas!');
            end
            if ~isfield(parameters,'Type') 
                parameters.Type = obj.Type;
            end
            
            genomas = parameters.genomas; 
            normalization = parameters.normalization;
            selectedType = parameters.Type; 
            testInstances = obj.trainingInstances; 
            nbInstances = length(testInstances); 
            nbRuns = size(genomas,1);  
            totalFitnessTest = zeros(nbRuns,1);
            
            for idx = 1 : nbRuns
                totalFitness = 0; 
                obj.setModel(genomas(idx,:),selectedType); 
                solvedInstances = solveInstanceSet(obj,testInstances); 
                for idn = 1 : nbInstances
                    if normalization == 1 
                        sumItems = sum(obj.trainingInstances{1,idn}.instanceItems,'all');
                        totalFitness = totalFitness + (solvedInstances{1,idn}.solution.fitness / sumItems);
                    else
                        totalFitness = totalFitness + solvedInstances{1,idn}.solution.fitness;
                    end
                end
                totalFitness = totalFitness/nbInstances; 
                totalFitnessTest(idx,1) = totalFitness; 
            end
        end
        
        % ----- Hyper-heuristic trainer        
        function [bestGenoma,bestGenomaFitness,details] = train(obj, varargin)
            % TRAIN  Method for training the sequence-based HH
            %   By default, this method uses MAP-Elites (ME) for training.
            %   This can be overriden by using a first optional input with
            %   the name of the desired training method (e.g. UPSO). Other
            %   optional inputs are: 
            %    - (toDo) criterion: Type of criterion that will be used for stopping training (e.g. iteration or stagnation)
            %    - parameters: Structure with parameters associated with
            %    ME. Any parameter can be omitted and default values will be used for it. 
            %
            %      Implemented fields (default value):             
            %           *mutationRate (0.3): Mutation rate for the sequence             
            %           *mutationType (1): Set of mutation operators to
            %           use. 1: Traditional. 2: Set of 5 operators.
            %           *nbDimInt (10): Number of dimensions in the search
            %           domain (steps of the sequence)
            %           *nbInitialGenomes (6): Number of initial search agents
            %           *nbIterations (50): Number of iterations to train for            
            %           *nbRegionsDim (5): Number of divisions (slots)
            %           along each dimension of the search domain.
            %           *normalization (0): Flag indicating whether to normalize fitness data 
            %           *searchDomain (1:5): Array of feasible values for
            %           each dimension of the search domain.
            %
            %   If no parameters are specified, the HH trains using default
            %   parameters, based on the method (user-defined or default).
            
            
            % Data validation
            trainingMethod = 'MAP-Elites'; % Default method for this HH
            if nargin > 1
                if isstring(varargin{1}) || ischar(varargin{1}) % Method given
                    trainingMethod = varargin{1};
                    if length(varargin) >= 2
                        if isstruct(varargin{2})
                            parameters = varargin{2};
                        else
                            warning('Second input parameter must be a structure with training parameters, which was not provided. Using default values...')
                            parameters = struct();
                        end
                    else
                        warning('A structure with training parameters was not given. Using default values...')
                        parameters = struct();
                    end
                elseif isstruct(varargin{1}) % Default method with custom parameters
                    parameters = varargin{1};
                else
                    error('First input parameter must be either a string with a training method or a structure with training parameters. Aborting!')
                end
            else
                warning('No training parameters have been specified in the function call. Using default values...')
                parameters = struct();
            end
            
            % HH and MAP-Elites (ME)
            % ME parameters definition
            % ---- Fixed parameters
            parameters.nbInstances = length(obj.trainingInstances);             
            instances = obj.trainingInstances;
            
            % ---- Check and set default parameters as necessary
            if ~isfield(parameters,'mutationRate'), parameters.mutationRate = 0.3; end            
            if ~isfield(parameters,'mutationType'), parameters.mutationType = 1; end
            if ~isfield(parameters,'nbDimInt'), parameters.nbDimInt = 10; end
            if ~isfield(parameters,'nbInitialGenomes'), parameters.nbInitialGenomes = 6; end
            if ~isfield(parameters,'nbIterations'), parameters.nbIterations = 50; end
            if ~isfield(parameters,'nbRegionsDim'), parameters.nbRegionsDim = 5; end
            if ~isfield(parameters,'normalization'), parameters.normalization = 0; end
            if ~isfield(parameters,'searchDomain'), parameters.searchDomain = [1 2 3 4 5]; end
            if ~isfield(parameters,'type'), parameters.type = obj.type; end % toDo: Check this ASAP. Should not be here since it is an obj parameter and not a training parameter
            
            % Call the optimizer 
            [bestGenoma, bestGenomaFitness, ~, details] = MAP_Elites_v2(obj, instances, parameters); 
            
            % Information update within the HH
            obj.evaluateCandidateSolution(bestGenoma,obj.trainingInstances);
            obj.status = 'Trained';
            obj.trainingMethod = 'MAP-Elites';
            obj.trainingSolution = bestGenoma;
            obj.trainingParameters = parameters; % toDo: Update
            obj.trainingPerformance = bestGenomaFitness;
            obj.trainingStats = details;
        end        
        

        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
%         function plot(obj, varargin)
%             disp('Not yet fully implemented...')
%             obj.solution.plot()
%         end

        % ----- Print overloader for disp()
        function printExtraData(obj)
            % printExtraData   Method for printing information specific to
            % sequence-based HH models. 
            fprintf('Model-specific information:\n')
            fprintf('\tNumber of steps:\t%d\n', obj.modelLength)
            fprintf('\tCurrent position in the sequence:\t%d\n', obj.currentStep)
            fprintf('\tCurrent shift per step:\t%d\n', obj.currentInc)
            fprintf('\tRepetition type:\t%d\n', obj.type)
            fprintf('\tUsable solvers: \t%d\t[',obj.nbSolvers)
            fprintf(' %d ', obj.availableSolvers)            
            fprintf(']\n')
        end
%         

        % ----- ---------------------------------------------------- -----
        % Methods for dependent properties
        % ----- ---------------------------------------------------- -----
%         function resultingData = get.propertyName(obj)
%             % Define here dependent properties
%         end

%         function resultingData = get.nbSequenceSteps(obj)
%             % Define here dependent properties
%             resultingData = length(obj.value);
%         end
    end
end