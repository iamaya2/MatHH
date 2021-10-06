function [NextActivity] = JSSPHeurLPA (instance)
nbPending = size(instance.pendingData,2);
remainingAct = nan(1,nbPending);
for x=1:nbPending
    nbActivities = size(instance.pendingData(x).activities,2);
    if nbActivities ~= 0
        remainingAct(x) = nbActivities;
    end
end
[~,NextActivity]=min(remainingAct);
end