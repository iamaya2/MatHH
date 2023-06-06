classdef JSSPInstance < handle & deepCopyThis 
    % JSSPInstance   Class definition for creating instances of the JSSP
    %  Each object of this class represents a problem instance (set of jobs
    %  that must be scheduled).
    % 
    %  JSSPInstance Properties:
    %   nbJobs - Number of jobs within the instance
    %   nbMachines - Number of machines associated with the instance
    %   status - Instance status (text). Can be: Undefined (empty), Pending, Solved
    %   instanceData - JSSPJob array with the original (unsolved) instance
    %   pendingData - JSSPJob array with what remains of the instance
    %   features - Vector with the current feature values of the instance
    %   rawInstanceData - Hyper-matrix containing the raw data of the original (unsolved) instance
    %   updatingData - Hyper-matrix with updated rawData, according to the activities that has been already scheduled
    %   jobRegister - Vector with one element per job. Indicates the number
    %   of activities that has been scheduled for each job.
    % 
    %  JSSPInstance Dependant Properties:
    %   upcomingActivities - JSSPActivity array with the first activity from each job
    %
    %  JSSPInstance Methods:
    %   JSSPInstance(instanceData) - Constructor
    %   gettingFeatures(obj, varargin) - Method for calculating values of features 1:5
    %   scheduleJob(obj, jobID) - Schedules the next (upcoming) activity of
    %   the given job
    %   reset(obj) - Resets the instance to the original (unsolved) state
    %   plot(obj, varargin) - Plots the current solution (schedule) of the
    %   instance
    %   disp(obj, varargin) - Prints instance information    
    %
    
    properties
        nbJobs % Number of jobs within the instance
        nbMachines % Number of machines associated with the instance
        status = 'Undefined'; % Instance status (text). Can be: Undefined (empty), Pending, Solved
        solution % JSSPSchedule object with the current solution
        instanceData % JSSPJob array with the original instance
        pendingData % JSSPJob array with what remains of the instance
        features = []; % Vector with the current feature values of the instance
        updatingData % Hyper-matrix with updated rawData, according to the activities that has been already scheduled
        jobRegister % Vector with one element per job. Indicates the number of activities that has been scheduled for each job.
        rawInstanceData % Hyper-matrix containing the raw data of the original (unsolved) instance
    end
    
    properties (Dependent)
        upcomingActivities % JSSPActivity array with the first activity from each job
    end
    
    % ----- ---------------------------------------------------- -----
    %                       Methods
    % ----- ---------------------------------------------------- -----
    methods
        % ----- ---------------------------------------------------- -----
        % Constructor
        % ----- ---------------------------------------------------- -----
        function instance = JSSPInstance(instanceData, varargin)
            % JSSPInstance Constructor for creating the instance object
            %  - Inputs:
            %     instanceData - nbJobs*nbMachines*2 array. First layer:
            %     Processing times. Second layer: Machine sequence
            %  - Outputs:
            %      instance - The JSSPInstance object
            instance.instanceData = JSSPJob();
            instance.pendingData = JSSPJob(); 
            instance.solution = JSSPSchedule();
            if nargin > 0
                if isnumeric(instanceData) % If given raw data:
                [instance.nbJobs, ~] = size(instanceData(:,:,1));
                instance.nbMachines = max(max(instanceData(:,:,2)));
                instance.instanceData(instance.nbJobs) = ...
                    JSSPJob(instanceData(end,:,2),instanceData(end,:,1),instance.nbJobs);
                instance.pendingData(instance.nbJobs) = ...
                    JSSPJob(instanceData(end,:,2),instanceData(end,:,1),instance.nbJobs);
                for idx = 1 : instance.nbJobs-1
                    instance.instanceData(idx) = ...
                        JSSPJob(instanceData(idx,:,2),instanceData(idx,:,1),idx);
                    instance.pendingData(idx) = ...
                        JSSPJob(instanceData(idx,:,2),instanceData(idx,:,1),idx);
                end
                
                elseif isa(instanceData,'JSSPJob') % if given JSSPJob objects (should support jobs with different lengths)
                    nbJobs = length(instanceData);
                    if ~isempty(varargin)
                        nbMachines = varargin{1}; % Given as extra parameter 
                    else
                        allActivities = [instanceData.activities];
                        allMachineIDs = [allActivities.machineID];
                        nbMachines = max(allMachineIDs); % Inferred from data
                    end
                    instance.nbJobs = nbJobs;
                    instance.nbMachines = nbMachines;
                    instance.instanceData(nbJobs) = JSSPJob(); % Initialize array size
                    instance.pendingData(nbJobs) = JSSPJob(); % Initialize array size
                    
                    nbOperationsPerJob = nan(1,nbJobs); % temp fix
                    
                    for idx = nbJobs : -1 : 1% create a deep copy of each job
                        instanceData(idx).deepCopy(instance.instanceData(idx));
                        instanceData(idx).deepCopy(instance.pendingData(idx));
                        
                        nbOperationsPerJob(idx) = length(instanceData(idx).activities); % temp fix
                    end
                    
                    % Temp fix for allowing jobs with different lengths
                    % (wip)
                    nbOperations = max(nbOperationsPerJob); % max number of operations in any job of this instance
                    rawData = zeros(nbJobs,nbOperations,2);
                    for idx  = 1 : nbJobs
                        thisJobProcTimes = [instance.instanceData(idx).activities.processingTime];
                        thisJobMachOrders = [instance.instanceData(idx).activities.machineID];
                        thisJobNbOps = length(thisJobProcTimes);
                        rawData(idx,1:thisJobNbOps,1) = thisJobProcTimes;
                        rawData(idx,1:thisJobNbOps,2) = thisJobMachOrders;
                    end
                    instanceData = rawData; % Warning: overwrites input job data. Should be improved.
                    
                else
                    callErrorCode(102); % Invalid input
                end
                
                % Common process
                instance.status = 'Pending';
                instance.solution = JSSPSchedule(instance.nbMachines, instance.nbJobs);                
                instance.rawInstanceData = instanceData; % May give trouble when using JSSPJob objects
                instance.updatingData = instanceData;  % May give trouble when using JSSPJob objects
%                 for i=1:size(instanceData(:,:,1)) % this should be moved up to the branch for the raw data, or modified to be generic
                for i=1:instance.nbJobs % testing this out to make it general
                    instance.jobRegister(i)=0;
                end
                instance.gettingFeatures(true); % Defines initial feature values
            end
        end
        
        
        % ----- ---------------------------------------------------- -----
        % Calculate Features
        % ----- ---------------------------------------------------- -----
        
        function allFeatures = calculateFeature(obj, featureIDs)
            nbFeaturesToCalculate = length(featureIDs);
            allFeatures = nan(1,nbFeaturesToCalculate);
            for idx = 1 : nbFeaturesToCalculate
                thisFeatureValue = normalizeFeature( CalculateFeature(obj, featureIDs(idx)), featureIDs(idx) );
                allFeatures(idx) = thisFeatureValue;
            end
            obj.features = allFeatures;
        end
        
        
        function features = gettingFeatures(obj,varargin)
            % gettingFeatures   Method for calculating feature values
            %  This method has variable input arguments, organized as
            %  follows:
            %   1 - Normalization flag for the features (defaults to false)
            %  Returns a vector with five elements, corresponding to
            %  values of the first five features
            if nargin>1 
                toNormalize=varargin{1};
            else 
                toNormalize=false;
            end
            
            if toNormalize==true
                for x=1:5
                    features(x)=normalizeFeature(CalculateFeature(obj,x),x);
                end
            else
                for x=1:5
                    features(x)=CalculateFeature(obj,x);
                end
            end
            
            obj.features = features;
        end
        
        % ----- ---------------------------------------------------- -----
        % Job scheduler
        % ----- ---------------------------------------------------- -----
        function scheduleJob(obj, jobID)
            % scheduleJob   Schedules the next (upcoming) activity of the given job
            %  This method receives a job ID and schedules its next
            %  activity. It does not return anything since the JSSPInstance object
            %  itself is updated.
            obj.jobRegister(jobID)=obj.jobRegister(jobID)+1;
            obj.updatingData(jobID,obj.jobRegister(jobID),1)=0;
            obj.updatingData(jobID,obj.jobRegister(jobID),2)=0;
            
            jts = obj.pendingData(jobID); % Job to schedule
            ts = obj.solution.getTimeslot(jts); % Timeslot
            obj.solution.scheduleJob(jts, ts);
%             obj.gettingFeatures(true); % toDo: Find a better update method
            for idx = 1 : length(obj.pendingData)
                if ~isempty(obj.pendingData(idx).activities)
                    return
                end
            end
            obj.status = 'Solved';
            %obj.solution.schedule, [jts.activities.machineID; jts.activities.processingTime], obj.solution.plot();
        end
        
        % ----- ---------------------------------------------------- -----
        % Instance reset
        % ----- ---------------------------------------------------- -----
        function reset(obj)
            % reset   Resets the instance to the original (unsolved) state            
            for idx = 1 : obj.nbJobs                
                obj.pendingData(idx) = ...
                    JSSPJob(obj.rawInstanceData(idx,:,2),obj.rawInstanceData(idx,:,1),idx);
            end
            obj.status = 'Pending';
            obj.solution = JSSPSchedule(obj.nbMachines, obj.nbJobs);
            obj.updatingData=obj.rawInstanceData;
            for i=1:size(obj.rawInstanceData(:,:,1),1)
                    obj.jobRegister(i)=0;
            end
%             obj.gettingFeatures(true);
%             [~, rawInstanceData] = createJSSPInstanceFromInstance(obj);
        end
        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
        function featureValues = getFeatureVector(obj, varargin)
             if isempty(varargin)
                featureValues = obj.calculateFeature(1:length(JSSP.problemFeatures));
            else
                featureValues = obj.calculateFeature(varargin{1});
            end
        end
   
        function makespan = getSolutionPerformanceMetric(obj)
            makespan = obj.solution.getSolutionPerformanceMetric();
        end
        
        function plot(obj, varargin)
            % plot   Plots the current solution (schedule) of the instance
            disp('Not yet fully implemented...')
            obj.solution.plot()
        end
        
        function infoTxt = disp(obj, varargin)
            % disp    Prints and returns instance information
            % This method prints basic instance information, including the
            % instance status and the raw instance data. It also returns
            % this information (as a char array for fprintf), in case it 
            % is required for post-processing.
            
%             pTimes = nan(obj.nbJobs,obj.nbMachines);
%             mOrder = pTimes;
%             for idx = 1 : obj.nbJobs
%                 pTimes(idx,:) = [obj.instanceData(idx).activities.processingTime];
%                 mOrder(idx,:) = [obj.instanceData(idx).activities.machineID];
%             end
        if strcmp(obj.status,"Undefined")
            infoTxt = 'Undefined Instance\n';            
        else
            infoTxt = sprintf('-----------------------------------------------------------------------\n');
            infoTxt = [infoTxt sprintf('Description of the current instance state:\n')];
            infoTxt = [infoTxt sprintf('-----------------------------------------------------------------------\n')];
            infoTxt = [infoTxt sprintf('\tStatus: %s\n', obj.status)];
            infoTxt = [infoTxt sprintf('\tSize: %d jobs and %d operations\n', obj.nbJobs, length(obj.instanceData))];
            infoTxt = [infoTxt sprintf('\tNumber of available machines: %d\n', obj.nbMachines)];
            infoTxt = [infoTxt '\tProcessing times (P):\n'];
            infoTxt = [infoTxt evalc('disp(obj.rawInstanceData(:,:,1))')];
            infoTxt = [infoTxt '\tMachine orderings (M):\n'];
            infoTxt = [infoTxt evalc('disp(obj.rawInstanceData(:,:,2))')];            
            infoTxt = [infoTxt evalc('disp(obj.solution)')];            
        end
        fprintf(infoTxt)
        end
        % ----- ---------------------------------------------------- -----
        % Methods for dependent properties
        % ----- ---------------------------------------------------- -----
        function activities = get.upcomingActivities(obj)
            % get.upcomingActivities   Updates the vector of activities that must be scheduled next for each job.
            if isempty(obj.pendingData(end).activities)
                activities(obj.nbJobs) = JSSPActivity;
            else
                activities(obj.nbJobs) = obj.pendingData(end).activities(1);
            end
            for idx = 1 : obj.nbJobs-1
                if isempty(obj.pendingData(idx).activities)
                    activities(idx) = JSSPActivity;
                else
                    activities(idx) = obj.pendingData(idx).activities(1);
                end                
            end
        end
    end
end