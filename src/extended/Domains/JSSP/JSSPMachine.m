classdef JSSPMachine < handle
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
        activities = JSSPActivity;
        jobList
    end
    
    properties (Dependent)
        emptyRangeInMachine % Returns matrix with empty slots within the machine
        makespan % Returns current machine makespan (total time)
    end
    
    methods
        function obj = JSSPMachine()
            % JSSPMachine   Constructor 
            % Machine initializes to default values
            
            % Empty on purpose
        end
        
        function newMachine = clone(obj)
            % clone   Method for cloning a machine
            newMachine = JSSPMachine();
            newMachine.activities = obj.activities;
            newMachine.jobList = obj.jobList;
        end
        
        function ranges = get.emptyRangeInMachine(obj)
            % get.emptyRangeInMachine   Returns matrix with empty slots
            % within the machine
            ranges = [0 sort([obj.activities(:).endTime]); sort([obj.activities(:).startTime]) obj.makespan];
        end
        
        function makespan = get.makespan(obj)
            % get.makespan   Returns current machine makespan (total time)
            makespan = max([obj.activities.endTime]);
        end
    end
end