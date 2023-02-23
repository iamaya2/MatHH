classdef problemSolution < handle & deepCopyThis
    %   problemSolution  -  Abstract class for defining solution objects
    %
    % This abstract class contains the minimum methods and properties that
    % must be included within the definition of a new solution object for a given problem domain.
    % It has no abstract properties.   
    %
    % problemSolution Methods
    %   Non-static:
    %     newObj = clone(oldObj)                             - For duplicating objects. Consider using deepCopy inherited method
    %     fitness = getSolutionPerformanceMetric(obj)        - Returns the performance metric for the problem domain (e.g. makespan, profit, etc.)
    %     metricName = getSolutionPerformanceMetricName(obj) - Returns a string with the name of the performance metric, mainly for visualization purposes
    %
    % See also: ProblemDomain, problemInstance       
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