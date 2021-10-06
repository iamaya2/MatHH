classdef JSSPActivity < handle
    % JSSPActivity   Class for creating activity objects
    %  Each object of this class represents a component (task) that must be
    %  carried out in order to complete a job of the JSSP instance. So, it
    %  contains information about the activity itself and about the machine
    %  where it must be scheduled.
    %
    %  JSSPActivity Properties:
    %   machineID - Information about the machine (its ID) where the
    %   activity must be scheduled.
    %   processingTime - Ammount of time units that the activity requires
    %   for completion, i.e., its processing time.
    %   isScheduled - Boolean flag indicating whether the activity has been
    %   already scheduled (e.g. when solving the instance).
    %   startTime - Number indicating the time instant at which the
    %   activity starts (when it has been scheduled).
    %
    %  JSSPActivity Dependant Properties:
    %   endTime - Time instant at which the activity ends (=startTime +
    %   processingTime).
    %
    %  JSSPActivity Methods:
    %   JSSPActivity - Constructor. Receives two elements: the machine ID
    %   and the processing time.
    %    
    %  See also: JSSPJOB, JSSPMACHINE
    properties
        machineID %This property contains a vector with the order in which machines will be scheduled
        processingTime = nan;%This property contains a vector with the processing times of the operations within every job
        isScheduled = false;
        startTime = nan;
    end
    
    properties (Dependent)
        endTime;
    end
    
    methods
        function activityObj = JSSPActivity(machID, procTime)
            % JSSPActivity   Constructor. Receives ID and processing time.
            %  This method should work properly if given vectors of IDs
            %  and processing times. In this case, it should return a
            %  vector of JSSPActivity objects.
            if nargin > 0
                nbAct = length(machID);
%                 activityObj(nbAct) = activityObj; % Leave this here just in
%                 case something breaks with the update
                activityObj(nbAct) = JSSPActivity(); % Dummy activity for reserving memory
                for idx = 1 : nbAct
%                     activityObj(idx) = activityObj; % Leave this here just in
%                 case something breaks with the update
                    activityObj(idx) = JSSPActivity();
                    activityObj(idx).machineID = machID(idx);
                    activityObj(idx).processingTime = procTime(idx);                
                end                
            end
        end
        
        function endTime = get.endTime(obj)
            % get.endTime   Method for calculating the dependent property
            % endTime.
            endTime = obj.startTime + obj.processingTime;
        end
    end
end