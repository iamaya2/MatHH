function [NextActivity] = JSSPHeurSPT (instance)
 [~,NextActivity] = min([instance.upcomingActivities.processingTime]);
end