classdef JSSPMachine < handle & deepCopyThis
    % JSSPMachine   Class for creating machine objects for the JSSP
    %  This class creates the objects in which the JSSPActivity objects of
    %  JSSPJob objects will be scheduled.
    %
    %   JSSPMachine Properties:
    %      activities - Vector of JSSPActivity objects scheduled in this
    %      machine object
    %      jobList - 
    %
    %   JSSPMachine Dependent Properties:
    %      emptyRangeInMachine - Returns matrix with empty slots within the machine
    %      makespan % Returns current machine makespan (total time)
    %   
    %   All JSSPMachine Methods are for dependent properties.
    properties
        activities
        makespan = NaN; % Current machine makespan (total time)
        jobList
    end
    
    properties (Dependent)
        emptyRangeInMachine % Returns matrix with empty slots within the machine
    end
    
    methods
        function obj = JSSPMachine()
            % JSSPMachine   Constructor 
            % Machine initializes to default values
            
            % Initializes 'activities' so that it targets a different
            % memory reference
            obj.activities = JSSPActivity();
        end
        
        function newMachine = clone(obj)
            % clone   Method for cloning a machine
            
            %old version (both activities target same obj)
%             newMachine = JSSPMachine();
%             newMachine.activities = obj.activities;
%             newMachine.jobList = obj.jobList;
%             newMachine.makespan = obj.makespan;

            % new version
            newMachine = JSSPMachine();
            obj.deepCopy(newMachine);            
        end
        
        
        % Testing...
        function scheduleJob(obj, selectedActivity, jobID, timeslot)
            % scheduleJob   Schedule upcoming activity of job with given ID at the given time slot                        
            selectedActivity.startTime = timeslot;
            selectedActivity.updateEndTime();
            if isempty(obj.makespan) || isnan(obj.makespan)
                obj.activities = selectedActivity; % First activity
                obj.jobList = jobID;
                obj.makespan = selectedActivity.endTime; 
            else
                obj.activities = [obj.activities selectedActivity]; % Other activities
                obj.jobList = [obj.jobList jobID];
                if selectedActivity.endTime > obj.makespan
                    obj.makespan = selectedActivity.endTime;
                end
            end
            selectedActivity.isScheduled = true; % Activity successfully scheduled
        end
        
        
        
        function ranges = get.emptyRangeInMachine(obj)
            % get.emptyRangeInMachine   Returns matrix with empty slots
            % within the machine
            ranges = [0 sort([obj.activities(:).endTime]); sort([obj.activities(:).startTime]) obj.makespan];
        end
        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
        function disp(obj, varargin)     
            fprintf("Job (activity) scheduled in this machine:")
            fprintf("\t%d (%d)", [obj.jobList; [obj.activities(:).activityID]]);
            fprintf("\tMakespan: %.2f\n", obj.makespan);
        end

    end
end