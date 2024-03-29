classdef KPSolution < problemSolution
% KPSolution   Class for creating Knapsack Problem solutions.
%
% A solution can be created from the following sources: 
% 
%  1. Another KPSolution. In this case the user must only provide an already
%                         created object and the method returns a deep copy of such solution.    
%  2. A given KPKnapsack. In this case the user provides the KPKnapsack
%                         object and the method returns a KPSolution based
%                         on this object. 
    properties
        knapsack % Cannot be initialized here since it will assign the same object to all instances
        discarded % Cannot be initialized here since it will assign the same object to all instances
    end
    
    methods
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = KPSolution(varargin)
            obj.knapsack = KPKnapsack(); % Dummy knapsack for storing the solution
            obj.discarded = KPItem.empty; % Empty vector of KPItems
            if nargin > 0
                if isa(varargin{1},'KPSolution') % From another solution
                    oldObj = varargin{1};
                    oldObj.deepCopy(obj);
                elseif isa(varargin{1},'KPKnapsack') % A given knapsack object
                    baseKP = varargin{1};
                    baseKP.deepCopy(obj.knapsack);
                else
                    callErrorCode(102) % Invalid input for constructor
                end                
            end
        end
        
        % ---- ------------------------ ----
        % ---- INHERITED METHODS ----
        % ---- ------------------------ ----        
        function newObj = clone(obj)
            % clone   Method that clones a KPSolution using the constructor
            % with the base object.
            newObj = KPSolution(obj);
        end
        
        function fitness = getSolutionPerformanceMetric(obj)
            % getSolutionPerformanceMetric   Method for returning the
            % negative of the profit yielded by the knapsack object. The
            % negative value is used since the optimization/training
            % procedure considers a minimization problem.
            fitness = -obj.knapsack.currentProfit;
            obj.knapsack.checkValidity(); % displays warning if not valid
        end
                
        
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ----        
        
    end

    methods (Static)
        % ---- ------------------------ ----
        % ---- INHERITED METHODS ----
        % ---- ------------------------ ----           
        function metricName = getSolutionPerformanceMetricName()
            % getSolutionPerformanceMetricName   Method that returns a
            % string with the name of the performance metric for this
            % domain. In this case, it returns 'Profit'. This string can be
            % used for plots and alike.
            metricName = 'Profit';
        end
    end
end