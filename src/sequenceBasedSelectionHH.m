% Class definition for Rule-based selection hyper-heuristics
classdef sequenceBasedSelectionHH < selectionHH
    % ----- ---------------------------------------------------- -----
    %                       Properties
    % ----- ---------------------------------------------------- -----
    properties
        % Most properties are inherited from the selectionHH superclass. Only
        % the following properties are specific to this class:
        nbSolvers       = NaN;
        currentStep     = 1;
        currentInc      = 1;
        modelLength     = NaN;
        Type            = 1; %Prefefined Pac-man
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
            % sequenceBasedSelectionHH Method for creating a sequence-based
            % selection hyper-heuristic. 
            % Supported modes: 
            % sequenceBasedSelectionHH(HH): Creates a clone of HH (deep
            % copy)
            % sequenceBasedSelectionHH(props): Creates a new HH using the
            % properties defined by props. The following properties are
            % supported: 
            %   - length: Scalar with the size of the model (number of
            %   steps). Default: 2
            %   - model: Vector with one heuristic ID per step. Default:
            %   random model
            %   - selectedSolvers: Vector with IDs of solvers available for
            %   the HH. Default: [1 2]
            %   - targetProblem: Domain that will be solved. Default: "job shop scheduling"
            obj.hhType = 'Sequence-based';
            obj.value  = [];
            
            targetProblem = "job shop scheduling"; % Default domain                       
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
                    if isfield(props,'selectedSolvers'), selectedSolvers = props.selectedSolvers; defaultSolvers = false; end                    
                    if isfield(props,'targetProblem'), targetProblem = props.targetProblem; end                    
                else
                    error('The current input is not currently supported. Try using a struct or another HH.')
                end
            end
            
            obj.targetProblemText = targetProblem;            
            obj.assignProblem(targetProblem)            
            
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
            if obj.currentStep > obj.nbSequenceSteps
                % Pac-Man way
                if obj.Type == 1
                    obj.currentStep = 1;
                % Bounce
                elseif obj.Type == 2
                    obj.currentStep = obj.nbSequenceSteps;    
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
        
        % ----- Print overloader for disp()
        function printExtraData(obj)            
            fprintf('\tCurrent model:       \n\t')
            fprintf('\t%d', obj.value)
            fprintf('\n');
        end
        
        % ----- Model setter
        function setModel(obj, model, Type)
            % SETMODEL  Method for setting the hh model to a fixed matrix
            obj.value = model;
            obj.Type = Type; 
            obj.nbSolvers = max(model(:,end)); % At least the max action
        end 
                      
        % ----- Hyper-heuristic solver
        function instance = solveInstance(obj, instance)
            % SOLVEINSTANCE  Method for solving a single instance with the current version of the HH (not yet implemented)            
            while ~strcmp(instance.status, 'Solved')
                activeStep = obj.getNextStep();
                heuristicID = obj.value(activeStep);
                obj.targetProblem.stepHeuristic(instance, heuristicID);
%                 instance.stepHeuristic(heuristicID);
            end   
            obj.currentStep = 1; 
            obj.currentInc = 1;             
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
                        totalFitness = totalFitness + (solvedInstances{1,idn}.fitness / sumItems);
                    else
                        totalFitness = totalFitness + solvedInstances{1,idn}.fitness;
                    end
                end
                totalFitness = totalFitness/nbInstances; 
                totalFitnessTest(idx,1) = totalFitness; 
            end
        end
        
        % ----- Hyper-heuristic trainer        
        function [bestGenoma,bestGenomaFitness,bestIterations] = train(obj, criterion, parameters)
            % TRAIN  Method for training the HH
            %   criterion: Type of criterion that will be used for stopping training (e.g. iteration or stagnation)
            %   parameters: Parameters associated to the optimizer
            %               (nbInstances, nbRegionsDim, nbRegionsInt, nbInitialGenomes,
            %               nbIterations, searchDomain, mutationRate, normalization). 
            
            % HH and MAP-Elites
            
            % MAP-Elites parameters definition
            % ---- Constant parameters
            parameters.nbInstances = length(obj.trainingInstances); 
            parameters.nbRegionsDim = 5; 
            parameters.searchDomain = [1 2 3 4 5];
            parameters.mutationType = 1; 
            instances = obj.trainingInstances;
            
            % ---- Default parameters             
            if ~isfield(parameters,'normalization') 
                parameters.normalization = 0;
            end
            if ~isfield(parameters,'nbDimInt') 
                parameters.nbDimInt = 10;
            end
            if ~isfield(parameters,'nbInitialGenomes') 
                parameters.nbInitialGenomes = 6;
            end
            if ~isfield(parameters,'nbIterations') 
                parameters.nbIterations = 50;
            end
            if ~isfield(parameters,'mutationRate') 
                parameters.mutationRate = 0.3;
            end
            if ~isfield(parameters,'Type') 
                parameters.Type = obj.Type;
            end
            
            % Call the optimizer 
            [bestGenoma,bestGenomaFitness,bestIterations] = MAP_Elites_v2(obj, instances, parameters); 
        end        
        

        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
%         function plot(obj, varargin)
%             disp('Not yet fully implemented...')
%             obj.solution.plot()
%         end
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