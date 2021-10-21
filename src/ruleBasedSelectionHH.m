classdef ruleBasedSelectionHH < selectionHH
    % ruleBasedSelectionHH   Class definition for Rule-based selection hyper-heuristics    
    %  This class allows the creation of Rule-based selection
    %  hyper-heuristics (RBSHH) objects that can be used for solving
    %  combinatorial optimization problems. Most properties are inherited 
    %  from the selectionHH superclass. 
    %
    %  ruleBasedSelectionHH Properties:     
    %
    %   nbRules - Number of rules for the HH
    %   nbFeatures - Number of features for the HH
    %   nbSolvers - Number of available solvers for the HH
    % 	featurevalues - Vector containing the current feature values. To-Do: Remove this if unused
    %   featureIDs - Vector with the ID of the features that the model uses
    %   heuristicVector - TO-DEL? Stores information about heuristic usage (not yet implemented)    
    %   HHRules - TO-DO: Complete description
    %   instances - Stores information returned by getInstances
    %
    %  ruleBasedSelectionHH Methods: 
    %
    %   ruleBasedSelectionHH(Rules, targetProblem) - Constructor
    %   assignFeatures(obj, featureArray) - Method for assigning the feature IDs that the HH shall use
    %   clone(obj) - Method for cloning the HH
    %   getInstances(obj, instanceType, varargin) -
    %   getClosestRule(obj, instance) -
    %   getRouletteRule(obj, instance, type) -
    %   getRule(obj, instance, type) -
    %   evaluateCandidateSolution(obj, solution, varargin) -
    %   initializeModel(obj, nbRules, nbFeatures, nbSolvers) -
    %   setDescription(obj, description) -
    %   setModel(obj, model) -
    %   solveInstance(obj, instance) -
    %   step(obj, instance) -
    %   solveInstanceSet_noCloning(obj, instances) -
    %   setInstances(obj, instanceType, instances) -
    %   splitInstances(obj, trainRatio) -
    %   test(obj) -
    %   train(obj, criterion, varargin) -
    %    
    properties
    % Most properties are inherited from the selectionHH superclass. Only
    % the following properties are specific to this class:     
    nbRules         = NaN; % Number of rules for the HH
    nbFeatures      = NaN; % Number of features for the HH
    nbSolvers       = NaN; % Number of available solvers for the HH
	featurevalues % Vector containing the current feature values. To-Do: Remove this if unused
    featureIDs % Vector with the ID of the features that the model uses
    heuristicVector % Stores information about heuristic usage (not yet implemented)
    HHRules % TO-DO: Complete description
    instances % Stores information returned by getInstances
%     description            % shows training method, and instances used    
    end
    
    properties (Dependent)
        % TO-DO: Put any dependent properties here (calculated on-the-fly)
    end
    
    % ----- ---------------------------------------------------- -----
    %                       Methods
    % ----- ---------------------------------------------------- -----
    methods
        % ----- ---------------------------------------------------- -----
        % Constructor
        % ----- ---------------------------------------------------- -----
        function obj = ruleBasedSelectionHH(Rules, targetProblem)            
            % Function for creating a rule-based selection hyper-heuristic
            obj.hhType = 'Rule-based';
            obj.targetProblemText = targetProblem;
            if nargin >= 1
                obj.nbRules = Rules;
            end
            if nargin ==2
                obj.assignProblem(targetProblem)
                % ------------------------------------------------------
                % Changed this...                
%                 for x=1:length(obj.availableFeatures)
%                     obj.featureIDs(x)=x;
%                 end
                % For this:
                obj.assignFeatures(1:length(obj.availableFeatures)); % Assigns all features by default
                % Test and delete the commented code if everything is OK...
                % ------------------------------------------------------
                obj.initializeModel(Rules,obj.nbFeatures, obj.nbSolvers);
            end
%             obj.description = "description unset";
        end              
        
		function assignFeatures(obj,featureArray)
            % Method for assigning the feature IDs that the HH shall use
             obj.featureIDs = featureArray;
             obj.nbFeatures = length(featureArray);
        end
        
        % ----- ---------------------------------------------------- -----
        % Other methods (sort them alphabetically)
        % ----- ---------------------------------------------------- -----

        function newHH = clone(obj)
            newHH = ruleBasedSelectionHH(obj.nbRules, obj.targetProblemText);            
            newHH.nbFeatures        = obj.nbFeatures; % Number of features for the HH
            newHH.nbSolvers         = obj.nbSolvers; % Number of available solvers for the HH
            newHH.featurevalues     = obj.featurevalues; % Vector containing the current feature values. To-Do: Remove this if unused
            newHH.featureIDs        = obj.featureIDs; % Vector with the ID of the features that the model uses            
            newHH.HHRules           = obj.HHRules; % TO-DO: Complete description
            newHH.instances         = obj.instances; % Stores information returned by getInstances
            newHH.trainingInstances = obj.trainingInstances;
            newHH.testingInstances  = obj.testingInstances;
            newHH.performanceData   = obj.performanceData;
            newHH.status            = obj.status;
            newHH.trainingMethod    = obj.trainingMethod;
            newHH.value             = obj.value;
        end
        
        % ----- Instance seeker
        function allinstances = getInstances(obj, instanceType, varargin)
            % GETINSTANCES  Method for extracting one kind of instances from the model (not yet implemented)
            %  instanceType: String containing the kind of instances that
            %  will be extracted. Can be: Training, Testing
            
            % ------------------------------------------------------
%             The following code is commented because should be unused.
%             Test and if everything works, delete this block:
%              switch  lower(instanceType)              
%                 case 'preliminary'
%                     addpath(genpath('InstanceRepository/PreliminaryInstances'))
%                     if nargin == 3 
%                         ChoseInstances=varargin{1};
%                     else 
%                        warning("Must choose one of three kind of preliminary instances: 1 - LPTvsSPT, 2 - SPTvsLPT, 3 - Random");
%                        ChoseInstances=input("Write the kind of preliminary instances to load");
%                     end
% %                     disp(ChoseInstances) 
%                     switch ChoseInstances 
%                         case 1
%                             for idx=1:30
%                                 address="JSSPInstanceJ3M4T10T210Rep"+num2str(idx)+"LPTvsSPT.mat";
%                                 JSSPInstance = {};
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=JSSPInstance{1};
%                             end
%                         case 2
%                             for idx=1:30
%                                 address="JSSPInstanceJ3M4T10T210Rep"+num2str(idx)+"SPTvsLPT.mat";
%                                 JSSPInstance = {};
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=JSSPInstance{1};
%                             end
%                         case 3    
%                             for idx=1:30
%                                 address="JSSPInstanceJ3M4T10T210Rep"+num2str(idx)+"MPAvsLPA.mat";
%                                 cell = {}; 
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=cell{1};
%                             end
%                         case 4    
%                             for idx=1:30
%                                 address="JSSPInstanceJ3M4T10T210Rep"+num2str(idx)+"LPAvsMPA.mat";
%                                 cell = {}; 
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=cell{1};
%                             end
%                         case 5    
%                             for idx=1:45
%                                 address="JSSPInstanceJ3M4T10T210Rep"+num2str(idx)+"Random.mat";
%                                 %JSSPInstance = {}; 
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=generatedInstance;
%                             end     
%                         case 6
%                             for idx=1:30
%                                 address=["GeneratedJSSPInstance_2020_May_27_19_04_33_3jobs_4machs_Inst"+num2str(idx)+".mat"];
%                                 instance = {};
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=instance;
%                             end
%                         case 7
%                             for idx=1:30
%                                 address=["JSSPInstanceJ3M4T10T210Rep"+num2str(idx)+"AllvsMPA.mat"];
%                                 instance = {};
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=instance;
%                             end    
%                         otherwise
%                             warning("Selected preliminary instance kind is not defined, program will load 30 random instances by default")
%                             for idx=1:30
%                                 address="GeneratedJSSPInstance_2020_May_27_19_04_33_3jobs_4machs_Inst"+num2str(idx)+".mat";
%                                 instance = {};
%                                 load(address)
% %                                 allinstances{idx}=import(address);
%                                 allinstances{idx}=instance;
%                             end    
%                     end
%                  rmpath(genpath('InstanceRepository/PreliminaryInstances'))
%                 otherwise
%                     warning("defined instance Types: {'preliminary'}")
%                     
%              end 
%              obj.instances=allinstances;
%              % ------------------------------------------------------
        end  
        
        
        % ----- Rule selector for the model
        function closestRule = getClosestRule(obj, instance)
            % INITIALIZEMODEL  Method for generating a random solution for
            % the current hh model
            % --------------- ANALYZE/IMPROVE THIS CODE ------------
			switch obj.problemType
                case 'JSSP'  
                    for f=1:obj.nbFeatures
                        featureValues(f)=normalizeFeature(CalculateFeature(instance, obj.featureIDs(f)),obj.featureIDs(f));
                    end
                    instance.features=featureValues;
          end          
		  %allDistances = dist2(obj.value(:,1:end-1),repmat(instance.features,obj.nbRules,1));
            for i = 1:size(obj.value,1)
      
                  dist(i)  = sqrt(sum((obj.value(i,1:end-1) - instance.features) .^ 2));
            end 
            [~, closestRule] = min(dist);
            %disp(dist)
		  
		  % --------------- CONFLICTING VERSION: ------------
            %allDistances = distRadialKernel(obj.value(:,1:end-1),repmat(instance.features,obj.nbRules,1));
%             allDistances = dist2(obj.value(:,1:end-1),repmat(instance.features,obj.nbRules,1));
            %[~, closestRule] = min(allDistances);            
        end 
        
        function selectedRule = getRouletteRule(obj, instance, type)
            % getRouletteRule  Method for selecting a rule. Uses a
            % probability based on the distance of each rule to the current
            % state. Closest rule = highest probability. Considers
            % different types of roulettes:
            %   raw: Base roulette-wheel selection
            %   exponentialRanking: Roulette based on the exponential
            %   rankings of entries
            
            allDistances = 1./distRadialKernel(obj.value(:,1:end-1),repmat(instance.features,obj.nbRules,1));
%             allDistances = 1./dist2(obj.value(:,1:end-1),repmat(instance.features,obj.nbRules,1));
            if any(allDistances==Inf), selectedRule = find(allDistances==Inf,1); return, end
            % Handle various kinds
            switch lower(type)
                case 'raw'
                    allValues = allDistances;
                case 'exponentialranking'
                    m = 100; % Change this and put it as parameter
                    rankings = tiedrank(allDistances)-1;
                    allValues = m*(rankings/(length(rankings)-1)).^(m-1);
                otherwise
                    error("Desired roulette behavior not yet supported. Aborting!")
            end
            % Roulette wheel selection
            relativeContribution = allValues ./ sum(allValues);
            randomShot = rand();
            for idx = 1 : length(relativeContribution)
                if randomShot <= sum(relativeContribution(1:idx))
                    selectedRule = idx;
                    break
                end
            end   
            if ~exist('selectedRule','var')
                error("The selected rule is invalid!")
            end
        end 
        
        function selectedRule = getRule(obj, instance, type)
            switch type
                case 1 % Traditional (Euclidean - shortest)
                    selectedRule = obj.getClosestRule(instance);
                case 2 % Roulette (Euclidean-based)
                    selectedRule = obj.getRouletteRule(instance,'exponentialRanking');
                otherwise
                    error("Invalid type of rule! Aborting!!!")
            end
        end
        
        % Tests a given hh model (candidate) to see if it is good. Requires
        % that the new model preserves the number of rules and features
        function fitness = evaluateCandidateSolution(obj, solution, varargin)
		if length(varargin)==1 
                instances = varargin{1};
            else
                instances = obj.trainingInstances;
            end
            switch obj.problemType
                case 'JSSP'
                    
                    currentModel = reshape(solution, obj.nbRules, obj.nbFeatures+1);
                    currentModel(:,end) = round(currentModel(:,end)); % Translates to action IDs 
                    obj.setModel(currentModel)
                  
                    SolvedInstances=obj.solveInstanceSet(instances);
                    fitness=0;
                    %fitness = sum([obj.instances.solution.makespan]);
                     for i=1:length(instances)
                         fitness=fitness + SolvedInstances{i}.solution.makespan;
                         %instances{i}.reset
                     end
                      
                    
                otherwise     
            currentModel = reshape(solution, obj.nbRules, obj.nbFeatures+1);
            currentModel(:,end) = round(currentModel(:,end)); % Translates to action IDs 
            obj.setModel(currentModel)
			disp(obj.value)
            solvedInstances = obj.solveInstanceSet(obj.trainingInstances);
            allInstances  = [solvedInstances{:}];
            fitness = sum([allInstances.fitness]);
			end
        end
        
        % ----- Model initializer
        function initializeModel(obj, nbRules, nbFeatures, nbSolvers)
            % INITIALIZEMODEL  Method for generating a random solution for
            % the current hh model
            obj.value = [rand(nbRules, nbFeatures) randi(nbSolvers,[nbRules, 1])];
            obj.nbRules = nbRules; 
            obj.nbFeatures = nbFeatures;
            obj.nbSolvers = nbSolvers;
        end 
		
%         function initializeModel_one_to_one(obj, nbRules, nbFeatures, nbSolvers)
%             % INITIALIZEMODEL  Method for generating a random solution for
%             % the current hh model
%              
%             Heuristic_selector = ["MaxProfit" "MinWeight" "ProfitWeightRatio" "Markovitz"];
%             obj.featurevalues = rand(nbRules, nbFeatures);
%             obj.value = [obj.featurevalues Heuristic_selector'];
%             obj.nbRules = nbRules; 
%             obj.nbFeatures = nbFeatures;
%             obj.nbSolvers = nbSolvers;
%         end 
        
% --------------- This must be UPDATED ASAP -------------
% --------------- This method should NOT be commented -------------
        % ----- Print overloader for disp()
%         function printExtraData(obj)            
%             fprintf('\tCurrent model:       \n\t')
%             modelString = repmat('\t%.4f', 1, obj.nbFeatures+1);
%             modelString = [modelString '\n\t'];
%             fprintf(modelString, obj.value')
%             fprintf('\n');
%         end

        function setDescription(obj, description)
            obj.description = description
            disp(obj.description)
        end
		                
        
        % ----- Model setter
        function setModel(obj, model)
            % SETMODEL  Method for setting the hh model to a fixed matrix
            obj.value = model;
            [obj.nbRules, obj.nbFeatures] = size(model); 
            obj.nbFeatures = obj.nbFeatures -1; % Fix for the action column
            %obj.nbSolvers = max(model(:,end)); % At least the max action
        end 
                
        % ----- Hyper-heuristic solver
        %function instance = solveInstance(obj, instance)
		function [SolvedInstance, performanceData] = solveInstance(obj, instance)
            % SOLVEINSTANCE  Method for solving a single instance with the current version of the HH (not yet implemented)           
			
            performanceData = {};
			% --------------- This must be UPDATED ASAP -------------
			counter = 1;
            
            
            heuristicVector2=[]; % se necesita modificar para tener el historial de todas las heuristicas sobre todas las instancias
            while ~strcmp(instance.status, 'Solved')                
                activeRule = obj.getClosestRule(instance);
                heuristicID = obj.value(activeRule,end);
                stepData = struct('featureValues', instance.features,...
                                    'selectedSolver', heuristicID,...
                                    'solution', instance.solution.clone());
                performanceData = [performanceData stepData];
                heuristicVector2(counter) = heuristicID;
                counter = counter +1;
                obj.targetProblem.stepHeuristic(instance, heuristicID);
                %instance.stepInstance(heuristicID);
            end     
            %disp(heuristicVector)
            obj.heuristicVector=heuristicVector2;
            SolvedInstance = instance;
            stepData = struct('featureValues', instance.features,...
                'selectedSolver', NaN,...
                'solution', instance.solution);
            performanceData = [performanceData stepData]; % Values associated to the solved instance
			
			% --------------- CONFLICTING VERSION: ------------
%            ruleType = 2; % to-change: put this as a general property
 %           while ~strcmp(instance.status, 'Solved')
  %              activeRule = obj.getRule(instance, ruleType);
   %             heuristicID = obj.value(activeRule,end);
    %            obj.targetProblem.stepHeuristic(instance, heuristicID);
     %       end            
        end 
        
		
		function Instance = step(obj, instance)
            % SOLVEINSTANCE  Method for solving a single instance with the current version of the HH (not yet implemented)            
%             logOp=false; 
%             for i=1:length(instance.jobRegister)
%                 if instance.jobRegister(i)>0
%                     logOp=true;
%                 end
%             end
%             
%             if logOp==false;
%                 counter=1;
%             else
%                 counter = counter +1;
%             end
            
           % disp(counter)
            
            heuristicVector2=[]; % se necesita modificar para tener el historial de todas las heuristicas sobre todas las instancias
            
                activeRule = obj.getClosestRule(instance);
                heuristicID = obj.value(activeRule,end);
               % heuristicVector2(counter) = heuristicID;
                %counter = counter +1;
                obj.targetProblem.stepHeuristic(instance, heuristicID);
                %instance.stepInstance(heuristicID);
              
            %disp(heuristicVector2)
            %obj.heuristicVector=heuristicVector2;
            Instance = instance;
        end 
        
        
        function solveInstanceSet_noCloning(obj,instances)
            for i=1:length(instances)
                obj.solveInstance(instances{i})
            end
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
			
			nbTR = round(length(obj.instances)*trainRatio);
            nbTS = length(obj.instances)-nbTR;
            if trainRatio==1 
                TS=nan;
            elseif trainRatio==0
                TR=nan;
            end
            for x=1:nbTR 
                TR(x)=obj.instances(x);
            end 
            
            for x=nbTR+1:length(obj.instances)
                TS(x-nbTR)=obj.instances(x);
                
            end
            
            obj.trainingInstances=TR;
            obj.testingInstances=TS;
            
        end 
        
        % ----- Hyper-heuristic tester
        function fitness = test(obj, varargin)
            % TEST  Method for running the HH on the testing instances (not yet implemented)
            instances=[];
            if nargin==2 
                instances=varargin{1};
            else
                instances=obj.testingInstances;
            end
             SolvedInstances=obj.solveInstanceSet(instances);
                    fitness=0;
                    %fitness = sum([obj.instances.solution.makespan]);
                     for i=1:length(instances)
                         fitness=fitness + SolvedInstances{i}.solution.makespan;
                         %instances{i}.reset
                     end
                     
                     
        end
        
        % ----- Hyper-heuristic trainer        
%         function [position,fitness,details] = train(obj, criterion, parameters)
        function [position,fitness,details] = train(obj, criterion, varargin)
            % TRAIN  Method for training the HH (not yet implemented)
            %   criterion: Type of criterion that will be used for stopping training (e.g. iteration or stagnation)
            %   parameters: Parameters associated to the stopping criterion (e.g. nbIter or the deltas and such)
            %
            %   See also DISP (ignore that).
            
            % ------------- THIS MUST BE SOLVED ASAP -------------
            switch criterion
                case 1 %number of iterations
                    if length(varargin) >= 1, maxIter = varargin{1}; else, maxIter =100; end
                    if length(varargin) >= 2, populationSize = varargin{2}; else, populationSize =15; end
                    if length(varargin) >= 3, selfConf = varargin{3}; else,  selfConf=2; end %must be an array of two elements
                    if length(varargin) >= 4, globalConf = varargin{4}; else, globalConf=2.5; end
                    if length(varargin) >= 5, unifyFactor = varargin{5}; else, unifyFactor=0.25; end
                    if length(varargin) == 6, visualMode = varargin{6}; else,visualMode=false; end
                    % Test run using UPSO
                    nbSearchDimensionsFeatures  = obj.nbRules*obj.nbFeatures;
                    nbSearchDimensionsActions   = obj.nbRules;
                    fh = @(x)obj.evaluateCandidateSolution(x,obj.trainingInstances); % Evaluates a given solution
                    flimFeatures = repmat([0 1], nbSearchDimensionsFeatures, 1 ); % First features, then actions
                    flimActions  = repmat([1 obj.nbSolvers], nbSearchDimensionsActions, 1);
                    flim = [flimFeatures; flimActions];
                    
                    % UPSO properties definition
                    properties = struct('visualMode', visualMode, 'verboseMode', true, ...
                        'populationSize', populationSize, 'maxIter', maxIter, 'maxStagIter', maxIter, ...
                        'selfConf', selfConf, 'globalConf', globalConf, 'unifyFactor', unifyFactor);
                    % Call to the optimizer
                    [position,fitness,details] = UPSO2(fh, flim, properties);
                    obj.evaluateCandidateSolution(position,obj.trainingInstances);
                    obj.status = 'Trained'
                otherwise
                    error("a criterion must be set: 1.-number of iterations")
            end
            
            % ------------- CONFLICTING VERSION BELOW: -------------
            
            %            % Test run using UPSO
            %           nbSearchDimensionsFeatures  = obj.nbRules*obj.nbFeatures;
            %          nbSearchDimensionsActions   = obj.nbRules;
            %         fh = @(x)obj.evaluateCandidateSolution(x); % Evaluates a given solution
            %        flimFeatures = repmat([0 1], nbSearchDimensionsFeatures, 1 ); % First features, then actions
            %       flimActions  = repmat([1 obj.nbSolvers], nbSearchDimensionsActions, 1);
            %      flim = [flimFeatures; flimActions];
            
            %    % UPSO properties definition
            %     properties = struct('visualMode', true, 'verboseMode', true, ...
            %        'populationSize', 15, 'maxIter', 50, 'maxStagIter', 100, ...
            %        'selfConf', 2, 'globalConf', 2.5, 'unifyFactor', 0.25);
            %    % Call to the optimizer
            %    [position,fitness,details] = UPSO2(fh, flim, properties);
            %    obj.evaluateCandidateSolution(position);
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
    end
end