% Class definition for selection hyper-heuristics
%   performanceData - Cell array containing performance data. Contains one
%   element per instance. Each one of these elements is another cell array
%   that contains performance data at each step of the solution. 
%   See TEST for more information.
classdef selectionHH < handle
    % ----- ---------------------------------------------------- -----
    %                       Properties
    % ----- ---------------------------------------------------- -----
    properties
        availableFeatures            ; % String vector of features that can be used for analyzing the problem state
        availableSolvers             ; % String vector of solvers (heuristics) that can be used for tackling each problem state
        hhType          = 'Undefined'; % Type of HH that will be used. Can be: Undefined (when new), Rule-based, Sequence-based, or others (pending update)
        lastSolvedInstances = NaN    ; % Property with the instances solved in the last call to the solveInstanceSet method.
        oracle                       ; % Structure with oracle information. See GETORACLE method for more details.
        performanceData                % Information about the performance on the test set.
		problemType     = 'Undefined'; % Problem type name
        status          = 'New'; % HH status. Can be: New, Trained
        targetProblem   = 'Undefined'; % Problem domain for the HH. Can be: Undefined (when new), JSSP, or others (pending update)        
        targetProblemText = 'Undefined'; % Problem domain for the HH. Can be: Undefined (when new), JSSP, or others (pending update)        
        testingInstances             ; % Instances used for testing. Vector of instances of the targetProblem		
        testingPerformance           ; % Structure with a vector containing the final solutions achieved for each instance of the training set. Also contains the accumulated performance data (over all instances) and the statistical data (across instances)
        trainingInstances            ; % Instances used for training. Vector of instances of the targetProblem        
        trainingMethod  = 'Undefined'; % Training approach that will be used. Can be: Undefined (when new), UPSO, or others (pending update)
        trainingParameters = NaN;       % Structure with the parameters associated to the training method (for running) 
        trainingPerformance          ; % Same as testingPerformance, but for the training set
        trainingSolution             ; % Data for the best solution provided by the last training stage
        trainingStats   = NaN        ; % Statistical parameters of the last training batch, as reported by the training method
        value           = 'Undefined'; % Values for the HH. Can be: Undefined (when new) or take a value depending on the type. For rule-based it is the selector matrix; for sequence-based is the sequence vector                
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
        function obj = selectionHH(varargin)
            % Function for creating a raw selection hyper-heuristic            
%             addpath(genpath('..\')) % This line should be moved from here and put into the main code
            obj.trainingStats = struct('elapsedTime',NaN,'functionEvaluations',NaN,'performedIterations',NaN,'stoppingCriteria',NaN);
            obj.oracle = struct('isReady',false,'lastPerformance',NaN,'lastInstanceSolutions',NaN, 'lastBestSolvers', NaN, 'unsolvedInstances', NaN);
            if nargin > 0
                if isa(varargin{1},'selectionHH')
                    obj = selectionHH();
                    varargin{1}.cloneProperties(obj);
                end
            end
        end              
        

        
        % ----- ---------------------------------------------------- -----
        % Other methods (sort them alphabetically)
        % ----- ---------------------------------------------------- -----

        % ----- Model initializer
        function assignProblem(obj, problemType, varargin)
            % ASSIGNPROBLEM  Method for linking the HH with a given problem
            % domain tailored to specific parameters (work in progress)
            %  problemType: Problem that will be linked (e.g. JSSP)
            %  varargin:    Put parameters associated to the problem (e.g. #
            %               machines and jobs)
            switch lower(problemType)
                case 'balanced partition'
                    dummyProblem = BalancedPartition(); % Temp: Just to select a random instance
%                     obj.targetProblem = dummyProblem.problemType;
                    obj.targetProblem = dummyProblem;
                    obj.availableSolvers = dummyProblem.problemSolvers;
                case 'job shop scheduling'
                    dummyProblem= JSSP();
                    obj.targetProblem = dummyProblem;
                    obj.availableSolvers = dummyProblem.problemSolvers;
                    obj.availableFeatures = dummyProblem.problemFeatures;
                    obj.nbFeatures=length(obj.availableFeatures);
                    obj.nbSolvers=length(obj.availableSolvers);
                    obj.problemType="JSSP";
				otherwise
                    error('Problem %s has not been implemented yet!', problemType)
            end
        end 
        
        % ----- Deep copy
        function cloneProperties(oldHH, newHH)
            % cloneProperties   Method for moving the selectionHH
            % properties. Automatically sweeps all properties           
            propertySet = properties(oldHH);
            for idx = 1:length(propertySet) 
                newHH.(propertySet{idx}) = oldHH.(propertySet{idx});
            end
        end
        
        % ----- Instance seeker
        function getInstances(obj, instanceType)
            % GETINSTANCES  Method for extracting one kind of instances from the model (not yet implemented)
            %  instanceType: String containing the kind of instances that
            %  will be extracted. Can be: Training, Testing
            
        end 
        
        function allMetrics = getSolversUsed(obj,selectedInstance)
            thisInstance = obj.performanceData{selectedInstance};
            selectedSteps = [thisInstance{:}];
            allMetrics = [selectedSteps.selectedSolver];
        end
        % ----- Model initializer
        function initializeModel(obj)
            % INITIALIZEMODEL  Method for generating a random solution for
            % the current hh model (not yet implemented)
            
        end 
        
        % ----- Instance loader
        function loadInstances(obj, varargin)
            % LOADINSTANCES  Method for loading instances into the hh (work
            % in progress)            
            switch lower(obj.targetProblem.problemType)
                case 'balanced partition'
                    switch length(varargin)
                        case 1
                            instanceID = varargin{1}; 
                            dummyProblem = BPInstance(instanceID); % Temp: Just to select a random instance
                        case 4 
                            dummyProblem = BalancedPartition.generateRandomInstances(varargin{2}, varargin{3}, varargin{4});
                        case 5 % Generate random instance
                            switch lower(varargin{1})
                                case 'g' % Generate random instance
                                    dummyProblem = BalancedPartition.generateRandomInstances(varargin{2}, varargin{3}, varargin{4}, varargin{5});
                                case 'l' % Load saved instances
                                    dummyProblem = BalancedPartition.loadSavedInstances(varargin{2}, varargin{3}, varargin{4}, varargin{5});
                            end
                        otherwise
                            warning('No valid case given. Selecting a random base instance!')
                            instanceID = randi(3);                             
                            dummyProblem = BPInstance(instanceID); % Temp: Just to select a random instance
                    end 
                        
%                     if length(varargin) >= 1, instanceID = varargin{1}; else, instanceID = randi(3); end 
                    
                    obj.trainingInstances = dummyProblem;
                otherwise
                    error('Problem %s has not been implemented yet!', obj.targetProblem)
            end
            
        end 
        
        
        function plotFitnessEvolution(obj)
            figure
            plot(obj.trainingStats.procedureEvolution.fitness.raw);
            xlabel('Iteration')
            ylabel('Fitness')
        end
        
        function [fH, aH] = plotSolution(obj, selectedInstance, selectedStep)
            % PLOTSOLUTION  Method for plotting the solution of a given
            % instance at a given step. Use 'end' as a step to plot the
            % final solution. Returns figure and axes handle
            if strcmpi(selectedStep,'end')
                [fH, aH] = obj.performanceData{selectedInstance}{end}.solution.plot();
            else
                [fH, aH] = obj.performanceData{selectedInstance}{selectedStep}.solution.plot();
            end
        end
        
        function fA = plotSolutionEvolution(obj, selectedInstance)
            % PLOTSOLUTIONEVOLUTION  Method for plotting the evolution of the solution performance indicator
            % (e.g. makespan for the JSSP) of a given instance. Returns axes handle.            
            thisInstance = obj.performanceData{selectedInstance};
            nbSteps = length(thisInstance);
            allMetrics = nan(1,nbSteps);
            for idx = 1 : nbSteps
                allMetrics(idx) = thisInstance{idx}.solution.getSolutionPerformanceMetric();
            end             
            plot(allMetrics)
            xlabel('Steps')
            ylabel(thisInstance{1}.solution.getSolutionPerformanceMetricName())
            fA = gca;
        end
        
        function fA = plotSolverUsage(obj,selectedInstance)
            % PLOTSOLVERUSAGE   Method for plotting the solver used at each
            % step of the solution for a given instance. Returns axes
            % handle.
            allMetrics = obj.getSolversUsed(selectedInstance);
            plot(allMetrics)
            xlabel('Steps')
            ylabel('Solver selected')
            fA = gca;
        end
        
        function fA = plotSolverUsageDistribution(obj,selectedInstance)
            % PLOTSOLVERUSAGEDISTRIBUTION   Method for plotting the distribution 
            % of solvers used at each step of the solution for a given instance. Returns axes
            % handle.            
            allMetrics = obj.getSolversUsed(selectedInstance);
            histogram(allMetrics)            
            xlabel('Solver selected')
            ylabel('Frequency')
            fA = gca;
        end
        
        function [fA, fV] = plotSolverUsageDistributionMulti(obj,selectedInstances, varargin)
            % PLOTSOLVERUSAGEDISTRIBUTIONMULTI   Method for plotting the distribution 
            % of solvers used at each step of the solution for multiple instances. 
            % Optional input: Accumulation flag. True: Pie chart with
            % accumulated information; False (default): violinplot with distribution
            % per instance. 
            %
            % Returns axes and violin/pie handles.            
            toAccumulate = false;
            nbInstances = length(selectedInstances);
            nbSteps = length(obj.performanceData{1});
            allMetrics = nan(nbSteps,nbInstances);
            for idx = 1 : nbInstances
                allMetrics(:,idx) = obj.getSolversUsed(selectedInstances(idx));
            end
            if length(varargin) == 1, toAccumulate = varargin{1}; end
            if toAccumulate                
                existingIDs = unique(allMetrics);
                IDUsage = zeros(1,length(existingIDs));
                allLabels = cell(1,length(existingIDs));
                for idx = 1:length(existingIDs)
                    IDUsage(idx) = sum(sum(allMetrics==existingIDs(idx)));
                    allLabels{idx} = ['H_' num2str(existingIDs(idx))];
                end
                fV = pie(IDUsage, allLabels);
            else
                fV = violinplot(allMetrics);
                xlabel('Instances')
                xticklabels({selectedInstances})
                ylabel('Solver selected')
            end
            fA = gca;
        end
        
        function fA = plotStepSolutionDistribution(obj, selectedStep)
            % plotStepSolutionDistribution  Method for plotting the distribution
            % of the solution performance indicator (e.g. makespan for the JSSP)
            % for all instances at a given step. Returns axes handle.                        
            nbInstances = length(obj.performanceData);            
            allMetrics = nan(1,nbInstances);
            if strcmpi(selectedStep,'end'), selectedStep = length(obj.performanceData{1}); end
            for idx = 1 : nbInstances
                allMetrics(idx) = obj.performanceData{idx}{selectedStep}.solution.getSolutionPerformanceMetric();
            end             
            histogram(allMetrics)            
            xlabel(obj.performanceData{1}{1}.solution.getSolutionPerformanceMetricName())
            ylabel('Frequency')
            fA = gca;
        end
        
        function [fA,vH] = plotStepSolutionDistributionComparison(obj, selectedSteps)
            % plotStepSolutionDistributionComparison  Method for plotting the distribution
            % of the solution performance indicator (e.g. makespan for the JSSP)
            % for all instances at selected steps, using violins. 
            % Returns axes and violinplot handles.                        
            nbInstances = length(obj.performanceData);     
            nbStepComparisons = length(selectedSteps);
            allMetrics = nan(nbInstances, nbStepComparisons);            
            for idx = 1 : nbInstances
                for idy = 1 : nbStepComparisons
                    allMetrics(idx,idy) = obj.performanceData{idx}{selectedSteps(idy)}.solution.getSolutionPerformanceMetric();
                end
            end             
            vH = violinplot(allMetrics);            
            xlabel('Selected steps')
            xticklabels({selectedSteps})
            ylabel(obj.performanceData{1}{1}.solution.getSolutionPerformanceMetricName())
            fA = gca;
        end
        
        
        % ----- Instance asigner
        function setInstances(obj, instanceType, instances)
            % SETINSTANCES  Method for assigning one kind of instances to the model (not yet implemented)
            %  instanceType: String containing the kind of instances that
            %                will be extracted. Can be: Training, Testing
            %  instances:    Cell array with the instances that will be
            %                assigned
            
        end 
                
        % ----- Hyper-heuristic solver
        function solveInstance(obj, instance)
            % SOLVEINSTANCE  Method for solving a single instance with the current version of the HH (not yet implemented)
            
        end 
        
        function solvedInstances = solveInstanceSet(obj, instanceSet)
            % SOLVEINSTANCESET  Method for solving a given set of instances with the current version of the HH            
            nbInstances = length(instanceSet);
            if nbInstances == 0, error('No training instances have been assigned yet. Aborting!'); end
            solvedInstances{nbInstances} = obj.targetProblem.createDummyInstance();
            for idx = 1 : nbInstances
                instance = obj.targetProblem.cloneInstance(instanceSet{idx});
                [solvedInstances{idx}, perfData] = obj.solveInstance(instance);
                obj.performanceData{idx} = perfData;
            end         
            obj.lastSolvedInstances = solvedInstances;
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
        function test(obj)
            % TEST  Method for running the HH on the testing instances (not yet implemented)
            
        end
        
        % ----- Hyper-heuristic trainer        
        function train(obj, criterion, parameters)
            % TRAIN  Method for training the HH (not yet implemented)
            %   criterion: Type of criterion that will be used for stopping training (e.g. iteration or stagnation)
            %   parameters: Parameters associated to the stopping criterion (e.g. nbIter or the deltas and such)
            %
            %   See also DISP (ignore that).
        end        
        

        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
%         function plot(obj, varargin)
%             disp('Not yet fully implemented...')
%             obj.solution.plot()
%         end
%         
        function disp(obj, varargin)
            if strcmp(obj.status,'New')
                warning('The hyper-heuristic has not been trained yet!')
            end
            obj.printCommonData();
            obj.printExtraData();
            obj.printModel();
        end

        % ----- ---------------------------------------------------- -----
        % Methods for dependent properties
        % ----- ---------------------------------------------------- -----
%         function resultingData = get.propertyName(obj)
%             % Define here dependent properties
%         end

        % ----- ---------------------------------------------------- -----
        % Extra methods (mainly those that will be overloaded by children)
        % ----- ---------------------------------------------------- -----
        
        function compareVsOracle(obj, instanceSet, varargin)
            % compareVsOracle  Method for comparing the current HH against
            % the Oracle. Default: uses all available solvers. Optional
            % input: vector with solver IDs that will be used for the
            % Oracle.
            % To be coded by the end user.
            warning('This method must be implemented by the end user for each model. Nothing will be run here')
        end
        
        function [oraclePerformance, individualSolutions, lastBestSolvers] = getOracle(obj, instanceSet)
            % GETORACLE  Method for calculating the Oracle. This method
            % must use each available solver to solve instanceSet. It must
            % return the overall performance of the Oracle (scalar) and the
            % performance for each instance (vector), as well as the ID of 
            % the best solvers. Finally, it must set the
            % oracle property within the HH, which is a struct with the
            % following fields: 
            %  - isReady: Boolean indicating whether a Oracle has been
            %  already calculated
            %  - lastPerformance: Same as overall oracle performance
            %  - lastInstanceSolutions: Same as performance for each            
            %  instance
            %  - lastBestSolvers: Same as the ID of best solvers
            %  - unsolvedInstances: A copy of the instances used for the
            %  oracle
            %
            % To be coded by the end user.
            warning('This method must be implemented by the end user for each model')
            oraclePerformance = nan;
            individualSolutions = nan(1, length(instanceSet));
            lastBestSolvers = individualSolutions;
            obj.oracle = struct('isReady',true,'lastPerformance',oraclePerformance,'lastInstanceSolutions',individualSolutions,...
                'lastBestSolvers',lastBestSolvers,'unsolvedInstances', instanceSet);
        end
        
        function metric = getSolutionPerformanceMetric(obj)
            % GETSOLUTIONPERFORMANCEMETRIC  Method for returning the
            % performance metric of a solution. Must be overloaded for each
            % domain. To be coded by the end user.
            warning('This method must be implemented by the end user for each domain')
            metric = nan;
        end
        
        function metric = getSolutionPerformanceMetricName(obj)
            % GETSOLUTIONPERFORMANCEMETRICNAME  Method for returning the
            % string of the performance metric of a solution. Must be overloaded for each
            % domain. To be coded by the end user.
            warning('This method must be implemented by the end user for each domain')
            metric = 'metric';
        end
        
        function printCommonData(obj)
            % Define here dependent properties
            fprintf('Displaying information about the %s HH:\n', obj.status)
            if strcmp(obj.targetProblem, 'Undefined')
                fprintf('\tTarget problem:      Undefined\n')
            else
                fprintf('\tTarget problem:      %s\n', obj.targetProblem.problemType)
            end
            fprintf('\tType:                %s\n', obj.hhType)
            fprintf('Training information:\n')
            fprintf('\tMethod:     %s\n', obj.trainingMethod)
            fprintf('\tNumber of instances: %d (training) | %d (testing)\n', length(obj.trainingInstances), length(obj.testingInstances))            
            fprintf('\tParameters:\n')
            disp(obj.trainingParameters)
            fprintf('\tPerformance achieved:\t%.2f\n', obj.trainingPerformance)
            fprintf('\tTime taken:\t%.2f\n', obj.trainingStats.elapsedTime)
            fprintf('\tEvaluations taken:\t%d\n', obj.trainingStats.functionEvaluations)
            fprintf('\tIterations performed:\t%d\n', obj.trainingStats.performedIterations)
            fprintf('\tStatus of stop criteria:\n')
            disp(obj.trainingStats.stoppingCriteria)
        end
        
        function printCommonPerformanceData(obj, selectedInstance, selectedStep)
            fprintf('Displaying performance data for instance %d in step %d:\n', selectedInstance, selectedStep)
            fprintf('\tSolver selected at this step:\t%d\n', obj.performanceData{selectedInstance}{selectedStep}.selectedSolver)
        end
        
        function printExtraData(obj)
            % Replace this with the HH specific information            
            fprintf('To be overloaded by each specific HH model...\n')
        end
        
        function printModel(obj)
            % Replace this with the HH specific information            
            fprintf("\tCurrent model:\n")
            disp(obj.value)
        end
        
        function printExtraPerformanceData(obj, selectedInstance, selectedStep)
            % Overload this method with HH-specific performance data
            disp("Overload this method with HH-specific performance data...")
        end
        
        function printPerformanceData(obj, selectedInstance, selectedStep)
            obj.printCommonPerformanceData(selectedInstance, selectedStep);
            obj.printExtraPerformanceData(selectedInstance, selectedStep);
        end
        
    end
end