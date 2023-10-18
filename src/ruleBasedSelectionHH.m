classdef ruleBasedSelectionHH < selectionHH
    % ruleBasedSelectionHH  -  Class definition for Rule-based selection hyper-heuristics    
    %  This class allows the creation of Rule-based selection
    %  hyper-heuristics (RBSHH) objects that can be used for solving
    %  combinatorial optimization problems. Most properties are inherited 
    %  from the selectionHH superclass. Check the doc file for a list of properties and methods.
    %  
    %  Recommended usage: 
    %    Define a structure with the properties of the RBSHH and pass it as
    %    an argument. The following fields are currently supported (default
    %    values given in parentheses):
    % 
    %       nbRules             (2)     - Number of rules   
    %       targetProblemHandle (@JSSP) - Function handle for the COP that will be tackled
    %       selectedFeatures    (All)   - Vector with the IDs of the features that will be used by the model    
    %       selectedSolvers     (All)   - Vector with the IDs of the solvers that will be used by the model    
    %
    %  Other usage modes:
    %    From another RBSHH - Pass the existing RBSHH as an argument and a
    %                           deep copy shall be returned.
    %    Empty shell - Use no arguments and an 'empty' RBSHH shall be
    %                   returned.
    %    Using several arguments - (deprecated) Pass several arguments in
    %                               order to return an old-style RBSHH. Not
    %                               recommended and prone to errors.
    %
    %  Example: 
    %   HH3Props = struct('nbRules',4,'targetProblemHandle', @JSSP, 'selectedFeatures',3:4,'selectedSolvers',[2 4]);
    %   HH3 = ruleBasedSelectionHH(HH3Props)
    % See also: selectionHH, JSSP
    
    %  ruleBasedSelectionHH Properties:     
    %    
    %   availableFeatures - Contains information about the features
    %   available to the HH for the problem domain it has been assigned
    %   to
    %   featureIDs - Vector with the ID of the features that the model uses
    %   nbFeatures - Integer with the number of features that the HH
    %   considers
    %   nbRules - Integer with the number of rules for the HH model
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
        % String vector of features that can be used for analyzing the 
        % problem state (problem dependent; see each COP for more details)    
        availableFeatures;         
        featureIDs % Vector with the ID of the features that the model uses
        nbFeatures      = NaN; % Number of features for the HH model
        nbRules         = NaN; % Number of rules for the HH model        
        
        % The following properties need some work: 

        heuristicVector % Stores information about heuristic usage (TO-DO: Change by method that scans performance data)
    end
      
    
    % ----- ---------------------------------------------------- -----
    %                       Methods
    % ----- ---------------------------------------------------- -----
    methods
        % ----- ---------------------------------------------------- -----
        % Constructor
        % ----- ---------------------------------------------------- -----
        function obj = ruleBasedSelectionHH(varargin)
            % Function for creating a rule-based selection hyper-heuristic.
            % Default values: 2 rules for the JSSP with all available
            % features.       
            % -\ Inputs: (pending update)
            % -\ ---\ targetProblem: function handle to static class of the
            %                        problem domain (e.g. JSSP, BP)
            obj.hhType = 'Rule-based'; % Always true
            targetProblemHandle = @JSSP;
            Rules = 2;  % Default number of rules
            defaultFeatures = true; % Flag for using default features
            defaultSolvers = true; % Flag for using default solvers
            isDeprecated = false; % Flag for supporting old scheme
            if nargin >= 1                  
                if isa(varargin{1},'ruleBasedSelectionHH') % From another HH
                    obj = ruleBasedSelectionHH();
                    varargin{1}.cloneProperties(obj);
                    return
                elseif isstruct(varargin{1})    % Pass arguments as a structure
                    props = varargin{1};
                    if isfield(props,'nbRules'), Rules = props.nbRules; end
                    if isfield(props,'targetProblemHandle'), targetProblemHandle = props.targetProblemHandle; end
                    if isfield(props,'selectedFeatures'), selectedFeatures = props.selectedFeatures; defaultFeatures = false; end
                    if isfield(props,'selectedSolvers'), selectedSolvers = props.selectedSolvers; defaultSolvers = false; end
                else                        % Given for compatibility with older code
                    warning('Using deprecated constructor. Consider changing to a structure-based approach...')
                    isDeprecated = true;
                    Rules = varargin{1};
                    if nargin >= 2, targetProblem = varargin{2}; end
                    if nargin >= 3, selectedFeatures = varargin{3}; defaultFeatures = false; end
                end
            end            
            obj.nbRules = Rules;
            if isDeprecated
                obj.assignProblem(targetProblem);  % old approach
            else                
                obj.assignProblem(targetProblemHandle); % new approach
            end
            if defaultFeatures, selectedFeatures = 1:length(obj.availableFeatures); end % Default: Use all features 
            if defaultSolvers, selectedSolvers = 1:length(obj.availableSolvers); end 
            obj.assignFeatures(selectedFeatures); 
            obj.assignSolvers(selectedSolvers); 
            obj.initializeModel(Rules);            
        end              
        		
        
        % ----- ---------------------------------------------------- -----
        % Other methods (sort them alphabetically)
        % ----- ---------------------------------------------------- -----

        function assignFeatures(obj,featureArray)
            % assignFeatures  Method for assigning the feature IDs that the
            % HH shall use. Requires a single input, which is a vector of
            % feature IDs (integers). Restores the initialization status of the HH
            % since it does not enforce reinitialization.
             obj.featureIDs = featureArray;
             obj.nbFeatures = length(featureArray);
             obj.hasInitialized = false;
        end
        
        function assignSolvers(obj, solverIDs)
            % assignSolvers  Method for defining a custom solver subset.
            % Requires a single input, which is a vector of solver IDs
            % (integers). Restores the initialization status of the HH
            % since it does not enforce reinitialization.
            obj.solverIDs = solverIDs;
            obj.nbSolvers = length(solverIDs);
            obj.hasInitialized = false;
        end
        
        function newHH = clone(obj)
            % clone   (deprecated) Method for providing a clone of a 
            % rule-based HH.
            %
            % Since it has been deprecated, please clone objects using the
            % constructor directly and passing the object to be cloned.
            callErrorCode(3) % Deprecated method            
            newHH = ruleBasedSelectionHH(obj);
        end
        
        % ----- Rule selector for the model
        function closestRule = getClosestRule(obj, instance)
            % GETCLOSESTRULE  Method for obtaining the rule (from the
            % selector) that is closest to the current state of the problem
            % (as indicated by the problem features in use). Receives a
            % single input, which is the instance to analyze.
            
            currentFeatures = instance.getFeatureVector(obj.featureIDs); 
            allDistances = dist2(obj.value(:,1:end-1),repmat(currentFeatures,obj.nbRules,1));
            [~, closestRule] = min(allDistances);

        end
        
        function performanceMetrics = getPerformanceDataMetrics(obj)
            % getPerformanceDataMetrics  Method that returns the final
            % performance metric values for each one of the instances
            % associated with performanceData.
            nbInstances = length(obj.performanceData);
            performanceMetrics = nan(nbInstances,1);
            for idx = 1 : nbInstances
                performanceMetrics(idx) = obj.performanceData{idx}{end}.solution.getSolutionPerformanceMetric();
            end
        end
        
        
        function selectedRule = getRouletteRule(obj, instance, type)
            % getRouletteRule  (WIP) Method for selecting a rule. Uses a
            % probability based on the distance of each rule to the current
            % state. Closest rule = highest probability. Considers
            % different types of roulettes:
            %   raw: Base roulette-wheel selection
            %   exponentialRanking: Roulette based on the exponential
            %   rankings of entries
            %
            % WIP: This method must be updated to reflect the possibility
            % of using traditional Euclidean distance, or the Radial one. 
            
            callErrorCode(0) % WIP message
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
        
        function heuristicID = getRuleAction(obj, ruleID)
            % getRuleAction   Method for returning the action ID of a given
            % rule. It corresponds to the last column of the selector. 
            %
            % Inputs:
            %    ruleID - Scalar between 1 and the number of rules that
            %    indicates the rule of interest (a.k.a. active or selected
            %    rule).
            %
            % Outputs:
            %    heuristicID - Scalar with the ID of the solver that must
            %    be used
            heuristicID = obj.value(ruleID, end); 
        end
        
        function stepData = getStepData(~, instance, heuristicID)
            % getStepData   Method for generating step data for partial
            % solutions. 
            %
            % Inputs:
            %    instance - Problem instance that is being solved
            %    heuristicID - ID of the heuristic that was chosen at this
            %    step, which comes from the getRuleAction method
            % 
            % Outputs:
            %    stepData - Structure with the information from this step
            
             stepData = struct('featureValues', instance.getCurrentFeatureValues(),...
                                    'selectedSolver', heuristicID,...
                                    'solution', instance.solution.clone()); 
        end
        
        function [fitness, solvedInstances] = evaluateCandidateSolution(obj, solution, varargin)
            % evaluateCandidateSolution   Method for testing a given
            % solution, to assess its quality. Requires that the new model 
            % preserves the number of rules and features.
            %
            % -\ Required inputs:
            % -\ ---\ solution: A vectorized solution model (as given by
            %                   an optimizer, e.g., UPSO)
            % -\ Optional inputs:
            % -\ ---\ instances: A set of instances for testing the model.
            %                    If no instances are given, the framework
            %                    uses those stored in the trainingInstances
            %                    property.
            % -\ Outputs:
            % -\ ---\ fitness: The fitness achieved by the given model.
            % -\ ---\ solvedInstances: A copy of the instances as solved by
            %                          the given model.
            if length(varargin)==1
                instances = varargin{1};
            else
                instances = obj.trainingInstances;
            end            
            currentModel = reshape(solution, obj.nbRules, obj.nbFeatures+1);
            currentSelection = round(currentModel(:,end)); % Ensures integer IDs
            currentModel(:,end) = obj.solverIDs(currentSelection); % Translates to the actual action IDs
            obj.setModel(currentModel) % Updates the HH object to reflect the current model
            solvedInstances = obj.solveInstanceSet(instances);
            fitness = 0;
            nbInstances = length(solvedInstances);
            for idx = 1 : nbInstances              
                thisInstance = solvedInstances{idx};
                fitness = fitness + thisInstance.getSolutionPerformanceMetric();
            end                        
        end
        
        % ----- Model initializer
        function initializeModel(obj, nbRules)
            % INITIALIZEMODEL  Method for generating a random solution for
            % the current hh model
            randSolverIDs = randi(obj.nbSolvers,[1,nbRules]);
            obj.value = [rand(nbRules, obj.nbFeatures) obj.solverIDs(randSolverIDs)'];
            obj.nbRules = nbRules;             
            obj.hasInitialized = true;
        end 
		
       
        function [fH2, fH] = plotFeatureMap(obj, instanceSet, opMode, varargin)
            % PLOTFEATUREMAP   Method for plotting the distribution of
            % feature values for a given set of instances, when solved with
            % the current HH model. The method enforces a contour of bins
            % to ensure that all values are included within the plot. So,
            % bins in the perimeter may represent out-of-bounds data.
            %
            % Required inputs: 
            % --- instanceSet: The set of instances that will be analyzed
            % --- opMode: Operating Mode ('initial','full','final'). A
            %             number with the ID of a solution step can also be given. This
            %             allows plotting the distribution of features at intermediate
            %             points of the solution.
            %
            % Optional inputs:
            % --- params: Structure with optional parameters for customizing 
            %             the plot. The following fields (default values)
            %             are implemented:
            % --- --- nbBins ([10 10]): Number of 'inner' bins (disregarding the
            %                           contour) along each dimension.
            % --- --- valMin ([0 0]): Lower bound for 'inner' bins along each
            %                         dimension.
            % --- --- valMax ([1 1]): Upper bound for 'inner' bins along each
            %                         dimension.
            % --- --- features ([1 2]): Positions within the feature vector
            %                           that will be plotted.
            %
            % --- doTrack: Boolean (flag) for indicating if individual
            %              feature changes (per instance) must be tracked. If true,
            %              requires the next parameter to indicate instance IDs.
            %
            % --- instID: ID (scalar or vector) with the numbers (IDs) of
            %             the instances that will be tracked.
            %
            % Returns: 
            % --- fH2: Figure handle to the surf figure for further processing.
            % --- fH:  Figure handle to the boxplot for further processing.
            
            % Initialization:
            allFeatureValues = [];
            nbInstances = length(instanceSet);            
            nbBins = [10 10];
            valMin = [0 0]; valMax = [1 1];            
            features = [1 2];
            doTrack = false;
            featID = nan;
            dataToPlot = [];
            
            % Parameter validation:
            if ~isempty(varargin)
                if isstruct(varargin{1})
                    params = varargin{1};
                    if isfield(params,'nbBins'), nbBins = params.nbBins; end
                    if isfield(params,'valMin'), valMin = params.valMin; end
                    if isfield(params,'valMax'), valMax = params.valMax; end
                    if isfield(params,'features'), features = params.features; end
                    
                    if islogical(varargin{2})
                        doTrack = varargin{2};
                        if doTrack
                            if isnumeric(varargin{3})
                                featID = varargin{3};
                            else
                                error('Optional argument must be an instance number for which to plot its feature track. Aborting!')
                            end
                        end
                    end
                elseif islogical(varargin{1})
                    obj.plotFeatureMap(instanceSet,opMode,struct(),varargin{:})
                    return
                else
                    error('First optional input is invalid. It must be either a structure with plotting parameters, or a logical (boolean) value. Aborting!')
                end
                
            end
            
            % Parameter calculation:
            innerBins1 = valMin(1) : (valMax(1)-valMin(1))/nbBins(1) : valMax(1);
            innerBins2 = valMin(2) : (valMax(2)-valMin(2))/nbBins(2) : valMax(2);
            binEdges1 = [-inf innerBins1 inf];
            binEdges2 = [-inf innerBins2 inf];
            
            % Data gathering:
            obj.solveInstanceSet(instanceSet); % Solve the instances
            for idx = 1 : nbInstances                 
                switch lower(opMode)
                    case 'initial'
                        currentData = obj.performanceData{idx}{1}.featureValues;
                    case 'final'
                        currentData = obj.performanceData{idx}{end}.featureValues;
                    case 'full'
                        nbSteps = length(obj.performanceData{idx});
                        currentData = nan(nbSteps,obj.nbFeatures);
                        for idy = 1 : nbSteps
                            currentData(idy,:) = obj.performanceData{idx}{idy}.featureValues;
                        end
                    otherwise
                        if isnumeric(opMode)
                            currentData = obj.performanceData{idx}{opMode}.featureValues;
                        else
                            error('Operating mode must be a step ID (integer) or one of: initial, final, full. Aborting!')
                        end
                end
                allFeatureValues = [allFeatureValues; currentData];                
                if doTrack && any(idx == featID)
                    dataToPlot(:,:,end+1) = currentData(:,features);                    
                end
            end
            
            % Data processing:
            firstFeature = allFeatureValues(:,features(1));
            secondFeature = allFeatureValues(:,features(2));

            figure, fH = histogram2(firstFeature, secondFeature, 'displaystyle', 'tile');
            fH.ShowEmptyBins = 'off';
            fH.XBinEdges = binEdges1;
            fH.YBinEdges = binEdges2;
            fH.Normalization = 'probability';
            
            % Surf post-processing
            histData = fH.Values;
            
            midPoints1 = mean( [innerBins1(1:end-1);innerBins1(2:end)] );
            midPoints2 = mean( [innerBins2(1:end-1);innerBins2(2:end)] );
            
            xPts = [valMin(1)-0.1 midPoints1 valMax(1)+0.1];
            yPts = [valMin(2)-0.1 midPoints2 valMax(2)+0.1];
            
            
            figure
            
            fH2 = surf(xPts,yPts,histData','edgecolor','none','facecolor','interp','FaceAlpha',0.65);
            set(gca,'View',[0 90])
            colorbar
            colormap(summer)
            grid off
            box on
            xlabel(['F_' num2str(features(1))])
            ylabel(['F_' num2str(features(2))])
            
            if doTrack
                for idx = 2 : size(dataToPlot,3)
                    obj.plotFeatureTrack(dataToPlot(:,:,idx));
                end
            end
            
        end
        
        function plotFeatureTrack(~, data)
            nbPts = length(data(:,1));
            hold on, 
            plot3(data(:,1),data(:,2),ones(nbPts,1),'k--')
            plot3(data(1,1),data(1,2),1,'rs','MarkerFaceColor','red','MarkerEdgeColor','black')
            plot3(data(end,1),data(end,2),1,'gd','MarkerFaceColor','green','MarkerEdgeColor','black')
        end
        
        function plotRules(obj, varargin)
            figure
            PlotRules(obj.value, varargin{:});
        end

        function allAreas = plotZones(obj, varargin)
            % PlotZones   Method for plotting a rule-based HH
            %  This method uses the current HH model to plot the regions 
            %  where each action is selected. By default, it plots against 
            %  the first two features of the model and uses a fixed number 
            %  of points, although behaviour can be altered with optional
            %  arguments.
            %
            %  -\ Optional inputs (default values):
            %  -\ ---\ points (0:0.01:1) - Vector with the points that will be evaluated (per dimension)
            %  -\ ---\ isEuclidean (true) - Flag indicating if Euclidean distance will be used
            %  -\ ---\ selectedFeatures (1:2) - Vector with two elements containing the IDs of the features
            %                                   (columns) to use when plotting
            %  -\ ---\ doRules (false) - Flag indicating if the rules should be plotted as well
            %
            %  -\ Returns:
            %  -\ ---\ allAreas - Vector with areas occuppied by each action
            %
            %  Example:
            %    HH1 = ruleBasedSelectionHH(); % Default HH with random model
            %    HH1.plotZones(); % Plot with default behaviour
            %    % Custom plot with area storage
            %    newPoints = 0:0.005:1; % Increased resolution
            %    customFeatures = [1 2]; % Same features as default            
            %    allAreas = HH1.plotZones(newPoints, true, customFeatures, true)            
            figure
            allAreas = PlotZones(obj.value, varargin{:});
        end
        
        function plotZones3D(obj, varargin)
            figure
            PlotZones3D(obj.value, varargin{:});
        end
        
        function printExtraPerformanceData(obj, selectedInstance, selectedStep)
            fprintf('\tFeature values at this step: ')
            fprintf('\t%.4f', obj.performanceData{selectedInstance}{selectedStep}.featureValues)
            fprintf('\n')
        end

        function setDescription(obj, description)
            obj.description = description;
            disp(obj.description)
        end
		                
        
        % ----- Model setter
        function setModel(obj, model)
            % SETMODEL  Method for setting the hh model to a fixed matrix
            % This method receives a single parameter, which is the matrix
            % corresponding to the new model. Beware that the number of
            % rules and features is inferred from the given model. So, the
            % HH can be set to a model with a different number of rules and
            % features.
            obj.value = model;
            [obj.nbRules, obj.nbFeatures] = size(model); 
            obj.nbFeatures = obj.nbFeatures -1; % Fix for the action column           
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
                heuristicID = obj.getRuleAction(activeRule); 
                %heuristicID = obj.value(activeRule,end); % Must change this by a getRuleAction method
                stepData = obj.getStepData(instance, heuristicID);
%                 stepData = struct('featureValues', instance.features,...
%                                     'selectedSolver', heuristicID,...
%                                     'solution', instance.solution.clone()); % Must change this by a getStepData method
                performanceData = [performanceData stepData];
                heuristicVector2(counter) = heuristicID;
                counter = counter +1;
                obj.targetProblem.stepHeuristic(instance, heuristicID);
                %instance.stepInstance(heuristicID);
            end     
            %disp(heuristicVector)
            obj.heuristicVector=heuristicVector2;
            SolvedInstance = instance;
            stepData = struct('featureValues', instance.getCurrentFeatureValues,...
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
        function [position,fitness,details] = train(obj, varargin)
            % TRAIN  Method for training the HH (not yet implemented)
            %   criterion: Type of criterion that will be used for stopping training (e.g. iteration or stagnation)
            %   parameters: Parameters associated to the stopping criterion (e.g. nbIter or the deltas and such)
            %
            %   See also DISP (ignore that).
                    
            % Default values:
            trainingMethod = 'UPSO';
            % --- For UPSO:
            maxIter = 100;
            populationSize = 15;
            selfConf = 2;
            globalConf = 2.5;
            unifyFactor = 0.25;
            visualMode = false;
            % --- For Map-Elites:
            normalization = 0;
            nbDimInt = 10;
            nbInitialGenomes = 6;
            nbIterations = 50;  % This may be overriden
            mutationRate = 0.3;
            repeatType = 1;
            
            if nargin > 1
                if isstring(varargin{1}) || ischar(varargin{1})
                    trainingMethod = varargin{1};
                    if length(varargin) == 2
                        if isstruct(varargin{2})
                            props = varargin{2};
                            if strcmpi(trainingMethod,'UPSO')
                                if isfield(props,'maxIter'), maxIter = props.maxIter; end
                                if isfield(props,'populationSize'), populationSize = props.populationSize; end
                                if isfield(props,'selfConf'), selfConf = props.selfConf; end
                                if isfield(props,'globalConf'), globalConf = props.globalConf; end
                                if isfield(props,'unifyFactor'), unifyFactor = props.unifyFactor; end
                                if isfield(props,'visualMode'), visualMode = props.visualMode; end
                            elseif strcmpi(trainingMethod,'MAP-Elites')
                                if isfield(props,'normalization'), normalization = props.normalization; end
                                if isfield(props,'nbDimInt'), nbDimInt = props.nbDimInt; end
                                if isfield(props,'nbInitialGenomes'), nbInitialGenomes = props.nbInitialGenomes; end
                                if isfield(props,'nbIterations'), nbIterations = props.nbIterations; end
                                if isfield(props,'mutationRate'), mutationRate = props.mutationRate; end
                                if isfield(props,'Type'), repeatType = props.Type; end
                            else
                                error('Training method not supported. Aborting!')
                            end
                        else
                            error('Parameters must be given as a structure. Aborting!')
                        end
                    end
                elseif isnumeric(varargin{1})
                    criterion = varargin{1};
                    switch criterion
                        case 1 %number of iterations
                            if length(varargin) >= 2, maxIter = varargin{2}; else, maxIter =100; end
                            if length(varargin) >= 3, populationSize = varargin{3}; else, populationSize =15; end
                            if length(varargin) >= 4, selfConf = varargin{4}; else,  selfConf=2; end %must be an array of two elements
                            if length(varargin) >= 5, globalConf = varargin{5}; else, globalConf=2.5; end
                            if length(varargin) >= 6, unifyFactor = varargin{6}; else, unifyFactor=0.25; end
                            if length(varargin) == 7, visualMode = varargin{7}; else,visualMode=false; end                            
                        otherwise
                            error("a criterion must be set: 1.-number of iterations")
                    end
                end
            else
                warning('No training parameters have been specified in the function call. Using default values...')
            end
            % Unify parameters and call the corresponding training method
            switch lower(trainingMethod)
                case 'upso'
                    % Range definition for each variable
                    nbSearchDimensionsFeatures  = obj.nbRules*obj.nbFeatures;
                    nbSearchDimensionsActions   = obj.nbRules;
                    fh = @(x)obj.evaluateCandidateSolution(x,obj.trainingInstances); % Evaluates a given solution
                    flimFeatures = repmat([0 1], nbSearchDimensionsFeatures, 1 ); % First features, then actions
                    flimActions  = repmat([1 obj.nbSolvers], nbSearchDimensionsActions, 1);
                    flim = [flimFeatures; flimActions];
                    
                    % UPSO properties
                    properties = struct('visualMode', visualMode, 'verboseMode', true, ...
                        'populationSize', populationSize, 'maxIter', maxIter, 'maxStagIter', maxIter, ...
                        'selfConf', selfConf, 'globalConf', globalConf, 'unifyFactor', unifyFactor);
                    
                    % Call to the optimizer
                    [position,fitness,details] = UPSO2(fh, flim, properties);
                    obj.evaluateCandidateSolution(position,obj.trainingInstances);
                    obj.status = 'Trained';
                    obj.trainingMethod = 'UPSO';
                    obj.trainingSolution = position;
                    obj.trainingParameters = properties;
                    obj.trainingPerformance = fitness;
                    obj.trainingStats = details;
                case 'map-elites'
                    error('Map-Elites have not been implemented yet for rule-based selection HHs. Aborting...')
                otherwise
                    error('Training method does not exist. Aborting...')
            end
        end
        

        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
%         function plot(obj, varargin)
%             disp('Not yet fully implemented...')
%             obj.solution.plot()
%         end
%         

        
        function outputMetrics = compareVsOracle(obj, instanceSet, varargin)
            % compareVsOracle  Method for comparing the current rule-based
            % HH against the Oracle. 
            %  Default: uses all available solvers. 
            %  Optional input: vector with solver IDs that will be used for the
            %                  Oracle.            
            nbInstances = length(instanceSet);
            obj.getOracle(instanceSet, varargin{:}); % Calculate the Oracle for this set of instances
            obj.solveInstanceSet(instanceSet); % Solve with the current HH
            oracleSolutions = obj.oracle.lastInstanceSolutions;
            HHSolutions = obj.getPerformanceDataMetrics();
            
            % Metrics calculation
            wholeMetrics = [oracleSolutions HHSolutions];
            meanMetrics = mean(wholeMetrics);
            winRatio = sum(oracleSolutions > HHSolutions) / nbInstances;
            tieRatio = sum(oracleSolutions == HHSolutions) / nbInstances;
            loseRatio = sum(oracleSolutions < HHSolutions) / nbInstances;
            
            % Plotting comparisons
            figure, histogram(obj.oracle.lastInstanceSolutions)
            hold on, histogram(obj.getPerformanceDataMetrics())
            legend({'Oracle','HH'})
            xlabel(obj.performanceData{1}{1}.solution.getSolutionPerformanceMetricName)
            ylabel('Frequency')
            
            % Output preparation
            outputMetrics = struct('instanceMetrics',wholeMetrics, 'meanMetrics', meanMetrics, ...
                                    'HHWinRatio', winRatio, 'HHTieRatio', tieRatio, 'HHLoseRatio', loseRatio);
        end
        
        function [oraclePerformance, individualSolutions, bestSolverPerInstance] = getOracle(obj, instanceSet, varargin)
            % GETORACLE  Method for calculating the Oracle using a
            % rule-based selection HH. By default, it compares against all
            % the available solvers (based on the domain class). Custom
            % solver IDs can be given as an optional input argument (as a
            % vector).
            %
            % The method creates a HH with a single rule targetting a given 
            % heuristic, which is used to solve the set of instances.
            % Then, it repeats for the remaining solvers. 
            % Afterward, it selects the best solution
            % for each instance and builds the Oracle with that
            % information. The method returns the average performance
            % and the performance for each solution. It also sets the oracle property.
            %
            % -\ Inputs:
            % -\ ---\ instanceSet: The set of instances to solve
            %
            % -\ Optional inputs:
            % -\ ---\ selectedSolvers: The ID of the solvers to use
            %
            % -\ Outputs:
            % -\ ---\ oraclePerformance: Average Oracle performance over
            %                            the set of instances
            % -\ ---\ individualSolutions: Vector with the performance
            %                            achieved for each instance
            % -\ ---\ bestSolverPerInstance: Vector with the ID of the best
            %                                solver for each instance
            dummyProps = struct('nbRules',1,'targetProblemHandle',obj.targetProblemHandle);
            dummyHH = ruleBasedSelectionHH(dummyProps);
            % Check if custom heuristic IDs were given:
            if length(varargin) == 1                % they were
                selectedSolvers = varargin{1};                
            else                                    % they were not
                selectedSolvers = 1:length(obj.targetProblem.problemSolvers);
            end
            nbClassSolvers = length(selectedSolvers);
            nbInstances = length(instanceSet);
            performanceAllSolvers = nan(nbInstances,nbClassSolvers);
            for idy = 1 : nbClassSolvers
                dummyHH.value(:,end) = selectedSolvers(idy);
                dummyHH.solveInstanceSet(instanceSet);
                performanceAllSolvers(:,idy) = dummyHH.getPerformanceDataMetrics();
            end
            [individualSolutions, bestSolversID] = min(performanceAllSolvers,[],2);
            bestSolverPerInstance = selectedSolvers(bestSolversID);
            oraclePerformance = mean(individualSolutions);            
            obj.oracle = struct('isReady',true,'lastPerformance',oraclePerformance,'lastInstanceSolutions',individualSolutions, ...
                'lastBestSolvers',bestSolverPerInstance', 'lastHeuristics', selectedSolvers, 'lastHeuristicSolutions', performanceAllSolvers, ...
                'unsolvedInstances', {instanceSet'});
        end
        
        function printExtraData(obj)
            % Rule-based Selection HH information
            fprintf('Model-specific information:\n')
            fprintf('\tNumber of rules:\t%d\n', obj.nbRules)
            fprintf('\tUsable features:\t%d ( ', obj.nbFeatures)
            fprintf(' %d ', obj.featureIDs)
            fprintf(' )\n')
            fprintf('\tUsable solvers:\t%d ( ', obj.nbSolvers)            
            fprintf(' %d ', obj.solverIDs)            
            fprintf(' )\n') 
            if ~obj.hasInitialized, callErrorCode(1); end
        end
        
        function printModel(obj)
            % printModel  -  Method for printing a RBSHH
            % This method formats and prints the selection matrix, using
            % proper headers.            
            fprintf("\nCurrent model:\n")
            T = table;
            T.RuleID = [1:obj.nbRules]';
            for idx = 1 : obj.nbFeatures
                eval(['T.F' num2str(obj.featureIDs(idx)) '= obj.value(:,idx);']);
            end
            T.HeuristicID = obj.value(:,end);
            disp(T)
        end

        
        % ----- ---------------------------------------------------- -----
        % Methods for dependent properties
        % ----- ---------------------------------------------------- -----
%         function resultingData = get.propertyName(obj)
%             % Define here dependent properties
%         end
    end
end