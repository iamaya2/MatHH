%% BPSet   Class for creating set objects for the Balanced Partition problem.
%
% A set can be created from the following sources: 
% 
%  1. Vector of BPItem objecs. In this case the user must provide two values. The first
%  one is the vector of BPItem objects. The second one is a numeric ID for
%  differentiating one set from another.
%  2. Another BPSet. In this case the user must only provide an already
%  created object and the method returns a deep copy of such a set.
classdef BPSet < handle & deepCopyThis
    properties
        elements = []; % Vector of BPItem objects within the set
        ID = NaN ; % Scalar for differentiating among sets
        load = 0; % Scalar with the total load of this set
        nbElements = 0; % Number of elements within the set
    end
    
    methods
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = BPSet(varargin)            
            if nargin > 0
                if isa(varargin{1},'BPItem') % from vector of BPItem
                    obj.elements = varargin{1};
                    obj.ID = varargin{2};
                    for thisItem = obj.elements
                        thisItem.assignToSet(obj.ID);
                    end                    
                    obj.updateLength();
                    obj.updateLoad();                    
                elseif isa(varargin{1},'BPSet') % from another BPSet
                    obj = BPSet();
                    varargin{1}.cloneProperties(obj);
                elseif isnumeric(varargin{1}) % just the ID
                    obj.ID = varargin{1};
                else
                    error('Invalid data for constructor. Aborting!')
                end
            end
        end
        
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ----        
        function cloneProperties(oldSet, newSet)
            % cloneProperties   Method for deep cloning the BPSet
            % properties. Automatically sweeps all properties           
            propertySet = properties(oldSet);
            for idx = 1:length(propertySet) 
                newSet.(propertySet{idx}) = oldSet.(propertySet{idx});
            end
        end
        
        function donateItem(obj,itemToMove,newSet)
            % donateItem   Method for sending a BPItem to another BPSet.
            %
            % This method requires the BPItem that will be moved, and a 
            % BPSet to receive the object.
            newSet.receiveItem(itemToMove);
            obj.removeItem(itemToMove);
        end
        
        function currentFeatures = getFeatureVector(obj, varargin)
            % getFeatureVector   Method for calculating features associated
            % with the BPSet. Receives a single optional input with the ID
            % of the feature to be calculated: 
            %
            % * 0: ??
            %
            % If no input is given, getFeatureVector calculates all the available
            % features.
            currentFeatures = NaN;
            callErrorCode(0); % WIP Err code
        end
        
        function receiveItem(obj,itemToMove)
            % receiveItem   Method for receiving an item from another BPSet.
            % 
            % This method requires the BPItem that will be put into the
            % set. Updates the length and total load accordingly.
            obj.elements = [obj.elements itemToMove];
            obj.updateLength(1);
            obj.updateLoad(itemToMove.load);
            itemToMove.assignToSet(obj.ID);
        end
        
        function removeItem(obj,itemToMove)
            % removeItem   Method for removing an item from the BPSet.
            % 
            % This method requires the BPItem that will be removed from the
            % set, e.g. after donating it to another one. Updates the length 
            % and total load accordingly.
            itemID = find(obj.elements == itemToMove, 1); % Moves at most one item
            if isempty(itemID)
                error('The requested BPItem cannot be found within BPSet %d. Check that contents match. Aborting!', obj.ID)
            else
                obj.elements = [obj.elements(1:itemID-1) obj.elements(itemID+1:end)];
                obj.updateLength(-1);
                obj.updateLoad(-itemToMove.load);
            end            
        end
   
        function updateLength(obj, varargin)
            % updateLength   Method for updating the length of the current
            % set. Has two operating modes. If no arguments are given, the
            % 'length' command is used to calculate the whole vector. It
            % can also receive the number of elements to increase, and it
            % would simply add that ammount to the current length. Note
            % that the first one always provide the correct value but it
            % could reduce performance when multiple updates are required.
            % The other approach should be faster, but is prone to error if
            % the user is not careful. 
            if nargin == 1
                obj.nbElements = length(obj.elements);
            else
                obj.nbElements = obj.nbElements + varargin{1};
            end
        end
        
        function updateLoad(obj, varargin)
            % updateLoad   Method for updating the laod of the current
            % set. Has two operating modes. If no arguments are given, the
            % load is calculated by summing the load of the whole vector. It
            % can also receive the load to increase, and it
            % would simply add that ammount to the current load. Note
            % that the first one always provide the correct value but it
            % could reduce performance when multiple updates are required.
            % The other approach should be faster, but is prone to error if
            % the user is not careful. 
            if nargin == 1
                obj.load = sum([obj.elements.load]);
            else
                obj.load = obj.load + varargin{1};
            end
        end
        
    end
end