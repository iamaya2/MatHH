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
        performanceData                % Information about the performance on the test set.
		problemType     = 'Undefined'; % Problem type name
        status          = 'New'; % HH status. Can be: New, Trained
        targetProblem   = 'Undefined'; % Problem domain for the HH. Can be: Undefined (when new), JSSP, or others (pending update)        
        targetProblemText = 'Undefined'; % Problem domain for the HH. Can be: Undefined (when new), JSSP, or others (pending update)        
        testingInstances             ; % Instances used for testing. Vector of instances of the targetProblem		
        testingPerformance           ; % Structure with a vector containing the final solutions achieved for each instance of the training set. Also contains the accumulated performance data (over all instances) and the statistical data (across instances)
        trainingInstances            ; % Instances used for training. Vector of instances of the targetProblem        
        trainingMethod  = 'Undefined'; % Training approach that will be used. Can be: Undefined (when new), UPSO, or others (pending update)
        trainingParameters           ; % Parameters associated to the training method (for running)
        trainingPerformance          ; % Same as testingPerformance, but for the training set
        trainingStats                ; % Statistical parameters of the last training batch, as reported by the training method
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
        function obj = selectionHH()
            % Function for creating a raw selection hyper-heuristic            
%             addpath(genpath('..\')) % This line should be moved from here and put into the main code
            if nargin > 0
                % Put something here in case a constructor is required...
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
        
        % ----- Instance seeker
        function getInstances(obj, instanceType)
            % GETINSTANCES  Method for extracting one kind of instances from the model (not yet implemented)
            %  instanceType: String containing the kind of instances that
            %  will be extracted. Can be: Training, Testing
            
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
            solvedInstances{nbInstances} = obj.targetProblem.createDummyInstance();
            for idx = 1 : nbInstances
                instance = obj.targetProblem.cloneInstance(instanceSet{idx});
                [solvedInstances{idx}, perfData] = obj.solveInstance(instance);
                obj.performanceData{idx} = perfData;
            end            
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
        end

        % ----- ---------------------------------------------------- -----
        % Methods for dependent properties
        % ----- ---------------------------------------------------- -----
%         function resultingData = get.propertyName(obj)
%             % Define here dependent properties
%         end

        % ----- ---------------------------------------------------- -----
        % Extra methods 
        % ----- ---------------------------------------------------- -----
        function printCommonData(obj)
            % Define here dependent properties
            fprintf('Displaying information about the %s HH:\n', obj.status)
            if strcmp(obj.targetProblem, 'Undefined')
                fprintf('\tTarget problem:      Undefined\n')
            else
                fprintf('\tTarget problem:      %s\n', obj.targetProblem.problemType)
            end
            fprintf('\tType:                %s\n', obj.hhType)
            fprintf('\tTraining method:     %s\n', obj.trainingMethod)
            fprintf('\tNumber of instances: %d (training) | %d (testing)\n', length(obj.trainingInstances), length(obj.testingInstances))
        end
        
        function printExtraData(obj)
            % Replace this with the HH specific information
            %fprintf('\tCurrent model:       %s\n', obj.value)
            disp("Current method:")
            disp(obj.value)
        end
        
    end
end