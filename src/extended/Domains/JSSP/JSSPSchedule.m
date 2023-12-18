classdef JSSPSchedule < handle & deepCopyThis % Only one schedule should be around
    % JSSPSchedule   Class for handling schedule objects for the JSSP
    %  This class represents a schedule object with the information of
    %  machines and activities that have been scheduled. The schedule is
    %  given by an array of JSSPMachine objects.
    %
    %   JSSPSchedule Properties: 
    %      nbMachines - number of machines
    %      schedule - Matrix of scheduled activities. Rows: Machines. Columns: Activities
    %      nbMaxJobs - Number of maximum jobs
    %      schColorMap - Colormap used for differentiating jobs within the schedule
    %
    %   JSSPSchedule Dependent Properties: 
    %      makespan - The time taken to complete all jobs
    %
    %   JSSPSchedule Methods:
    %      JSSPSchedule(nbMachines, nbMaxJobs) - Constructor. Creates an empty schedule
    %      getTimeslot(obj, targetJob) - Seeks a valid time for slotting the job with the given ID
    %      scheduleJob(obj, targetJob, timeslot) - Schedule upcoming activity of job with given ID at the given time slot
    %      plot(obj, varargin) - Plots the schedule representation
    %      get.makespan(obj) - Returns the makespan of the current schedule
        
    properties               
        nbMachines % number of machines
        nbMaxJobs = NaN; % Number of maximum jobs
        makespan = NaN; % Time taken to complete all jobs
        schedule; % Matrix of scheduled activities. Rows: Machines. Columns: Scheduled activities        
        schColorMap % Colormap used for differentiating jobs within the schedule       
    end        
    
    properties (Dependent)
        fitness % Mask for the makespan (for compatibility)
    end
    
    methods
        % ----- ---------------------------------------------------- -----
        % Constructor
        % ----- ---------------------------------------------------- -----
        function jobObj = JSSPSchedule(nbMachines, nbMaxJobs)
            % JSSPSchedule   Constructor for creating an empty schedule
            %  This function assign to the object job the number of machines
            %  avaiable and creates an empty schedule of size equal to the
            %  number of machines
            jobObj.schedule = JSSPMachine();
            if nargin > 0                
                jobObj.nbMachines = nbMachines;
                jobObj.nbMaxJobs = nbMaxJobs;
                jobObj.schedule(nbMachines,1) = JSSPMachine; % Empty column of actitivities
                for idx = 1 : nbMachines - 1
                    jobObj.schedule(idx,1) = JSSPMachine; % Empty column of actitivities
                end
%                 jobObj.schColorMap = [.92 .97 .97; parula(nbMaxJobs)];
                jobObj.schColorMap = [parula(nbMaxJobs)];
            end
        end
        
        % ----- ---------------------------------------------------- -----
        % General methods
        % ----- ---------------------------------------------------- -----
        function newSchedule = clone(obj)
            % clone   Method for cloning the object so they are independent
            
            % new version: 
            newSchedule = JSSPSchedule(obj.nbMachines, obj.nbMaxJobs);
            obj.deepCopy(newSchedule);
            
            % old version
%             newSchedule = JSSPSchedule(obj.nbMachines, obj.nbMaxJobs);
%             for idx = 1 : newSchedule.nbMachines
%                 newSchedule.schedule(idx,1) = obj.schedule(idx,1).clone(); % Empty column of actitivities
%             end
%             newSchedule.schColorMap = obj.schColorMap;
%             newSchedule.makespan = obj.makespan;
        end
        
        %function timeIndex = getTimeslot(obj, machineID, activityLength)            
        function timeIndex = getTimeslot(obj, targetJob)            
            % getTimeslot   Seeks a valid time for slotting the job with the given ID
            if isempty([targetJob.activities.machineID])
                error('Error! Job has been completely scheduled... Aborting!')                
            end
            machineID = targetJob.activities(1).machineID;
            activityLength = targetJob.activities(1).processingTime;
            selectedMachine = obj.schedule(machineID); % Machine object
            currMakespan = obj.makespan;            
            if isnan(currMakespan) % Fix for when the schedule is too young
                timeIndex = 0;
                return
            elseif targetJob.lastScheduledTime > currMakespan % Expansion required
                timeIndex = targetJob.lastScheduledTime;
                return
            else                
                fixedStart = targetJob.lastScheduledTime; % Search starting point                               
                emptyRanges =  selectedMachine.emptyRangeInMachine;                
                availableGaps = diff(emptyRanges);
                validGaps = find(availableGaps >= activityLength);
                if isempty(validGaps)
                    timeIndex = max(emptyRanges(1,end),fixedStart); % Pending update. This should consider the empty gap at the end, if it exists
                else
                    candidateTimes = emptyRanges(1,validGaps);
                    candidateGaps  = availableGaps(validGaps);
                    for idx = 1 : length(candidateTimes)
                        testTime = candidateTimes(idx);
                        if testTime >= fixedStart
                            timeIndex = testTime; % time is earliest and valid
                            return                 % stop searching
                        else
                            timeShift = fixedStart - testTime;                             
                            if candidateGaps(idx) - timeShift >= activityLength
                                timeIndex = testTime+timeShift; % time is earliest and still valid
                                return                          % stop searching
                            end
                        end
                    end
                    timeIndex = max(emptyRanges(1,end),fixedStart); % no valid gap found
                end                                               
            end
        end
        
        
        function scheduleJob(obj, targetJob, timeslot)
            % scheduleJob   Schedule upcoming activity of job with given ID at the given time slot
            selectedActivity = targetJob.popActivity();
            machineID = selectedActivity.machineID;            
            obj.schedule(machineID).scheduleJob(selectedActivity, targetJob.jobID, timeslot);
            targetJob.updateLastActivity(selectedActivity, selectedActivity.endTime);
            
            % Update makespan
            if isnan(obj.makespan) || obj.schedule(machineID).makespan > obj.makespan
                obj.makespan = obj.schedule(machineID).makespan;
            end
        end
        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
        function makespan = getSolutionPerformanceMetric(obj)
            % GETSOLUTIONPERFORMANCEMETRIC   Returns the performance metric
            % of a solution for the JSSP, i.e. the makespan of the
            % schedule. Overloads method from SELECTIONHH.
            makespan = obj.makespan;
        end
        
        function metricName = getSolutionPerformanceMetricName(obj)
            % GETSOLUTIONPERFORMANCEMETRICNAME   Returns the JSSP string. 
            % Overloads method from SELECTIONHH.
            metricName = 'Makespan';
        end
        
        function disp(obj, varargin)            
            if nargin == 2, toPlot = varargin{1}; else, toPlot = false; end            
            fprintf("-----------------------------------------------------------------------\n")
            fprintf("Displaying information about the current solution (schedule object):\n")
            fprintf("-----------------------------------------------------------------------\n")
            fprintf("\tMachines:\t%d\n",obj.nbMachines);
            fprintf("\tJobs to schedule:\t%d\n",obj.nbMaxJobs);
%             fprintf("\tJobs scheduled:\t%d\n",obj.nbCurrJobs); % ToDo: implement property
            fprintf("\tMakespan:\t%d\n",obj.makespan);
            fprintf("-----------------------------------------------------------------------\n")
            fprintf("\nJob information per machine:\n")
            for idx = 1 : obj.nbMachines
                fprintf("%d. ",idx);
                disp(obj.schedule(idx));
            end
            fprintf("-----------------------------------------------------------------------\n")
            if toPlot, obj.plot(); end % Plots the schedule, if desired
        end
        
        function [fH, aH] = plot(obj, varargin)
            % plot    Plots the schedule representation. Returns figure and
            % axes handle          
            fH = figure; colormap(obj.schColorMap)
            axis([-0.1 obj.makespan+0.1 -obj.nbMachines-0.1 0.1])
            set(gca,'CLim',[1 obj.nbMaxJobs]);            
            colorbar('Ticks', 1:obj.nbMaxJobs) % Create colorbar
            box on
            hold on            
            for idM = 1 : obj.nbMachines %length(obj.schedule)
                eachMachine = obj.schedule(idM);
                if ~isempty(eachMachine.jobList)
                    for idx = 1 : length([eachMachine.activities])
                        eachActivity = eachMachine.activities(idx);
                        boxwidth = eachActivity.processingTime;
                        rectangle('Position', [eachActivity.startTime -eachActivity.machineID boxwidth 1], ...
                            'FaceColor', obj.schColorMap(eachMachine.jobList(idx),:))
                    end
                end
            end            
            xlabel('Time units')
            ylabel('Machine ID')
            set(gca,'YTickLabel', num2cell(obj.nbMachines:-1:1), 'YTick', -obj.nbMachines+0.5:-0.5)
            aH = gca;     
        end
        
        % ----- ---------------------------------------------------- -----
        % Methods for dependent properties
        % ----- ---------------------------------------------------- -----
        function fitness = get.fitness(obj)
            fitness = obj.makespan;
        end
        
    end
end