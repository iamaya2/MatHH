classdef problemInstance < handle & deepCopyThis
    properties (Abstract)
        features % Current feature values of the instance
        solution % Solution object (able to store partial and full solutions)
        status % Current status of the instance (Undefined, Pending, Solved)
    end
    
    methods (Abstract)
       featureValues = getFeatureVector(obj, varargin) % Updates and return feature values, given a set of feature IDs
    end
    
    methods
        function fitness = getSolutionPerformanceMetric(obj)
            % getSolutionPerformanceMetric   Method for returning the
            % performance metric of the solution object associated with
            % this instance. Requires no inputs.
            fitness = obj.solution.getSolutionPerformanceMetric();
        end
    end
end