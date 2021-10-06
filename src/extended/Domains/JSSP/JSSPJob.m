classdef JSSPJob < handle
    % JSSPJob   Class for creating job objects for the JSSP
    %  Objects of this class are mainly given by a set of JSSPActivity
    %  objects. 
    %
    %   JSSPJob Properties:
    %      activities - Vector of JSSPActivity objects that must be
    %      scheduled to complete the job
    %      jobID - An ID given to the job as to differentiate it from
    %      others
    %      lastScheduledActivity - JSSPActivity that was scheduled last
    %      lastScheduledTime - Time instant in which the
    %      lastScheduledActivity was assigned
    %
    %   JSSPJob Dependent Properties:
    %      nbActivities - Amount of activities yet to be scheduled
    %
    %   JSSPJob Methods:
    %      JSSPJob(machIDs, procTimes, jobID) - Constructor
    %      popActivity(obj) - Removes the upcoming activity of the job
    %      updateLastActivity(obj, activity, timeslot) - Updates related information
    %      get.nbActivities(obj) - Calculates dependent property
    %      nbActivities
    %      
    properties       
        activities = JSSPActivity(nan,nan); % The activities to schedule (the order of machines to be scheduled and the processing times of the operations performed by each machine)
        jobID = nan; % An ID given to the job as to differentiate it from others
        lastScheduledActivity % JSSPActivity that was scheduled last
        lastScheduledTime = 0; % Time instant in which the lastScheduledActivity was assigned
    end
    
    properties (Dependent)
        nbActivities % Amount of activities yet to be scheduled
    end
    
    methods
        function jobObj = JSSPJob(machIDs, procTimes, jobID) 
            % JSSPJob   Constructor
            %  This function receives machIDs and procTimes from the class
            %  object JSSPActivity, and creates the corresponding job
            if nargin > 0        
                nbAct = length(machIDs); 
                jobObj.activities(nbAct) = JSSPActivity(machIDs(end),procTimes(end)); 
                for idx = 1 : nbAct-1
                    %This loop will save in the object Job the activities
                    %to process (the machine to schedule and the time it
                    %will be operating)
                    jobObj.activities(idx) = JSSPActivity(machIDs(idx),procTimes(idx));
%                     jobObj.activities(idx).machineID = machID(idx);
%                     jobObj.activities(idx).processingTime = procTime(idx);                
                end                
%                 jobObj.activities = JSSPActivity(machIDs,procTimes);
                jobObj.jobID = jobID; %The order in which jobs will be scheduled
            end
        end
        
        function poppedActivity = popActivity(obj)
            % popActivity - Removes the upcoming activity of the job
            %  This function gets the next activity to be scheduled and
            %  eliminates it from the agenda. 
            poppedActivity = obj.activities(1);
            obj.activities = obj.activities(2:end);
        end
        
        function updateLastActivity(obj, activity, timeslot)
            % updateLastActivity   Updates information related to the
            % last updated activity
            obj.lastScheduledActivity = activity;
            obj.lastScheduledTime = timeslot;
        end
        
        function nbActivities = get.nbActivities(obj)
            % get.nbActivities   Calculates dependent property associated with the number of activities to schedule
            nbActivities = length(obj.activities);
        end
        
        
    end
end