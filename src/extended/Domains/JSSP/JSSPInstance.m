classdef JSSPInstance < handle
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
        instanceData = JSSPJob(); % JSSPJob array with the original instance
        pendingData = JSSPJob(); % JSSPJob array with what remains of the instance
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
        function instance = JSSPInstance(instanceData)
            % JSSPInstance Constructor for creating the instance object
            %  - Inputs:
            %     instanceData - nbJobs*nbMachines*2 array. First layer:
            %     Processing times. Second layer: Machine sequence
            %  - Outputs:
            %      instance - The JSSPInstance object
            if nargin > 0
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
                instance.status = 'Pending';
                instance.solution = JSSPSchedule(instance.nbMachines, instance.nbJobs);                
                instance.rawInstanceData = instanceData;
                instance.updatingData = instanceData;
                for i=1:size(instanceData(:,:,1))
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
        
        function plot(obj, varargin)
            % plot   Plots the current solution (schedule) of the instance
            disp('Not yet fully implemented...')
            obj.solution.plot()
        end
        
        function disp(obj, varargin)
            % disp    Prints instance information
            % This method prints basic instance information, including the
            % instance status and the raw instance data.
            
%             pTimes = nan(obj.nbJobs,obj.nbMachines);
%             mOrder = pTimes;
%             for idx = 1 : obj.nbJobs
%                 pTimes(idx,:) = [obj.instanceData(idx).activities.processingTime];
%                 mOrder(idx,:) = [obj.instanceData(idx).activities.machineID];
%             end
        if strcmp(obj.status,"Undefined")
            fprintf('Undefined Instance\n')
        else
            fprintf('Processing times (P):\n')
            disp(obj.rawInstanceData(:,:,1))
            fprintf('Machine orderings (M):\n')
            disp(obj.rawInstanceData(:,:,2))
        end
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