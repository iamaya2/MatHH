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
        activityID = NaN; % Property for linking this activity with its position within a job
        machineID %This property contains a vector with the order in which machines will be scheduled
        processingTime = NaN;%This property contains a vector with the processing times of the operations within every job
        isScheduled = false;
        startTime = NaN;
        endTime = NaN;
    end
    
%     properties (Dependent)
% 
%     end
    
    methods
        function activityObj = JSSPActivity(machID, procTime, varargin)
            % JSSPActivity   Constructor. Receives machine ID and processing time.
            %  This method should work properly if given vectors of IDs
            %  and processing times. In this case, it should return a
            %  vector of JSSPActivity objects. A third parameter (optional)
            %  can be given to define an inner activity ID. 
            if nargin > 0                
                nbAct = length(machID);
                if nargin == 3, allIDs = varargin{1}; else, allIDs = nan(1,nbAct); end
%                 activityObj(nbAct) = activityObj; % Leave this here just in
%                 case something breaks with the update
                activityObj(nbAct) = JSSPActivity(); % Dummy activity for reserving memory
                for idx = 1 : nbAct
%                     activityObj(idx) = activityObj; % Leave this here just in
%                 case something breaks with the update
                    activityObj(idx) = JSSPActivity();
                    activityObj(idx).machineID = machID(idx);
                    activityObj(idx).processingTime = procTime(idx);                
                    activityObj(idx).activityID = allIDs(idx);
                end                
            end
        end
        
        function endTime = updateEndTime(obj)
            % updateEndTime   Method for updating the endTime property
            endTime = obj.startTime + obj.processingTime;
            obj.endTime = endTime;
        end
       
    end
end