%% BPSolution   Class for creating Balanced Partition problem solutions.
%
% A solution can be created from the following sources: 
% 
%  1. Another BPSolution. In this case the user must only provide an already
%                         created object and the method returns a deep copy of such solution.
classdef BPSolution < problemSolution
    properties
        sets; % Sets with the corresponding elements for the solution
    end
    
    methods
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = BPSolution(varargin)
            obj.sets = BPSet(); % Sets with the corresponding elements for the solution
            if nargin > 0
                if isa(varargin{1},'BPSolution') % From another solution
                    oldObj = varargin{1};
                    obj = BPSolution();
                    oldObj.deepCopy(obj);
                elseif isa(varargin{1},'BPSet') % Array of BPSet
                    allSets = varargin{1};
                    nbSets = length(allSets);
                    obj.sets(nbSets) = BPSet(); % Dummy set for allocation
                    for idx = 1 : nbSets
                        obj.sets(idx) = allSets(idx);
                    end
                else
                    callErrorCode(102) % Invalid input for constructor
                end                
            end
        end
        
        % ---- ------------------------ ----
        % ---- INHERITED METHODS ----
        % ---- ------------------------ ----        
        function newObj = clone(obj)
            % clone   Method that clones a BPSolution using the constructor
            % with the base object.
            newObj = BPSolution(obj);
        end
        
        function fitness = getSolutionPerformanceMetric(obj)
            % getSolutionPerformanceMetric   Method for returning the split
            % quality of the items w.r.t. both sets. 
            load1 = obj.sets(1).load;
            load2 = obj.sets(2).load;
            fitness = abs(load1-load2);
        end
        
        function metricName = getSolutionPerformanceMetricName(obj)
            metricName = 'Partition quality (Q)';
        end
        
    end
end