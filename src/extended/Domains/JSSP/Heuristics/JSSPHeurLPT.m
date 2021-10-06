function [nextActivity] = JSSPHeurLPT (instance)
 [~,nextActivity] = max([instance.upcomingActivities.processingTime]);
end
