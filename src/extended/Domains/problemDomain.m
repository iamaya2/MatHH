classdef problemDomain < handle
    properties (Abstract, Constant)
        problemFeatures % Cell array with ID:Name format
        problemSolvers % Cell array with ID:Name format
        problemType % Strign for identifying the domain
    end
    
    methods (Abstract, Static)
        s = disp() % For providing a string with the full name of the domain
        stepHeuristic(instance, heurID, varargin) % For using a single heuristic for a single solution step
    end
end