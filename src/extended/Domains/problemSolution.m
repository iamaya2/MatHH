classdef problemSolution < handle & deepCopyThis
    properties (Abstract)
        
    end
    
    methods (Abstract)
       newObj = clone(oldObj); % For duplicating objects. Consider using deepCopy method
       fitness = getSolutionPerformanceMetric(obj); % Returns the performance metric for the problem domain (e.g. makespan, profit, etc.)
       metricName = getSolutionPerformanceMetricName(obj);
    end
    
%     methods
%         
%     end
end