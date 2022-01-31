%% BPSolution   Class for creating Balanced Partition problem solutions.
%
% A solution can be created from the following sources: 
% 
%  1. Another BPSolution. In this case the user must only provide an already
%                         created object and the method returns a deep copy of such solution.
classdef BPSolution < handle & deepCopyThis
    properties
        sets = []; % Sets with the corresponding elements for the solution
    end
    
    methods
        function obj = BPSolution(varargin)
            if nargin > 0
                oldObj = varargin{1};
                obj = BPSolution();
                oldObj.cloneProperties(obj);
            end
        end
    end
end