%% BPITEM   Class for creating item objects for the Balanced Partition problem.
%
% An item can be created from the following sources: 
% 
%  1. Raw data. In this case the user must provide two values. The first
%  one is the cost (load) of such item. The second one is a numeric ID for
%  differentiating one object from another.
%  2. Another BPItem. In this case the user must only provide an already
%  created object and the method returns a deep copy of such an item.
classdef BPItem < handle
    properties
        ID = NaN; % Scalar for identification
        inSet = NaN; % Scalar with the set ID in which this item is located
        load = NaN; % Scalar representing the cost (load) of this item        
    end
    
    methods
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = BPItem(varargin)            
            if nargin > 0
                if isnumeric(varargin{1})
                    obj.load = varargin{1};
                    obj.ID = varargin{2};
                elseif isa(varargin{1},'BPItem')
                    obj = BPItem();
                    varargin{1}.cloneProperties(obj);
                else
                    error('Invalid data for constructor. Aborting!')
                end
            end
        end
        
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ----
        function assignToSet(obj, setID)
            % assignToSet   Method for assigning the BPItem to a set. The
            % user must provide a scalar with the ID of the set in which
            % this item will be placed.
            obj.inSet = setID;
        end
        
        function cloneProperties(oldItem, newItem)
            % cloneProperties   Method for deep cloning the BPItem
            % properties. Automatically sweeps all properties           
            propertySet = properties(oldItem);
            for idx = 1:length(propertySet) 
                newItem.(propertySet{idx}) = oldItem.(propertySet{idx});
            end
        end
    end
end