%% KPKnapsack   Class for defining knapsacks for the Knapsack Problem
%
% A KPKnapsack can be created in the following ways:
%
% 1. From numeric data. In this case the user must provide two elements.
%                       The first one is the capacity of the knapsack. The
%                       second one is the ID for this knapsack.
%
% 2. From another KPKnapsack. In this case the user only needs to provide an
%                         object and the class returns a deep copy of it.
classdef KPKnapsack < handle & deepCopyThis
    properties
        ID = NaN; % Identifier of this knapsack
        capacity = NaN; % Capacity (limit) of the knapsack
        currentWeight = 0; % Weight taken by the items currently packed 
        currentProfit = 0; % Profit given by the items currently packed 
        items = KPItem.empty(1,0); % Array to contain the items packed into this knapsack
        isUsable = true; % Used for validating if the knapsack is valid
        nbItems = 0; % Number of items within the knapsack
    end
    
    methods  
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = KPKnapsack(varargin)
            if nargin > 0
                if isnumeric(varargin{1}) % From numeric data
                    obj.capacity = varargin{1};                    
                    obj.ID = varargin{2};                    
                    obj.checkValidity();
                elseif isa(varargin{1},'KPKnapsack') % From another KPKnapsack
                    oldObj = varargin{1};
                    obj = KPKnapsack();
                    oldObj.deepCopy(obj);
                else
                    callErrorCode(102);
                end
            end
        end        
        
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ----
        function checkValidity(obj)
            % checkValidity   Method for determining if the knapsack is
            % valid (has free capacity). It sets the isUsable property and
            % requires no inputs. If the knapsack is overloaded, it also
            % displays a warning.
            %
            % Note: Matlab adds a reserved property callid isValid for
            % assessing if a handle object is valid. So, that property
            % cannot be used in this method.
            if obj.currentWeight > obj.capacity
                warning('The capacity of knapsack %d has been exceeded!',obj.ID)
                obj.isUsable = false;
            elseif obj.currentWeight == obj.capacity
                obj.isUsable = false; % No warning since it is OK.
            else
                obj.isUsable = true;
            end
        end
        
        function packItem(obj, thisItem)
            % packItem  Method for packing items within a KPKnapsack object.
            % Requires a single input, which is a KPItem object.
            % Automatically updates the knapsack length (number of
            % elements), the current weight and the status of the KPItem. 
            obj.items = [obj.items thisItem];
            obj.updateCurrentWeight(thisItem.weight);
            obj.updateCurrentProfit(thisItem.profit);
            obj.updateLength(1);
            thisItem.donePacking();
            obj.checkValidity();
        end
        
        function unpackItem(obj, thisItem)
            % unpackItem  Method for unpacking items within a KPKnapsack object.
            % Requires a single input, which is a KPItem object.
            % Automatically updates the knapsack length (number of
            % elements), the current weight and the status of the KPItem. 
            itemID = find(obj.items == thisItem, 1); % Moves at most one item
            if isempty(itemID)
                error('The requested KPItem cannot be found within KPKnasack %d. Check that contents match. Aborting!', obj.ID)
            else
                obj.items = [obj.items(1:itemID-1) obj.items(itemID+1:end)];
                obj.updateCurrentWeight(-thisItem.weight);
                obj.updateCurrentProfit(-thisItem.profit);
                obj.updateLength(-1);
                thisItem.doneUnpacking();
                obj.checkValidity();
            end            
        end
        
        function updateCurrentWeight(obj, varargin)
            % updateCurrentWeight   Method for updating current weight of
            % the knapsack. Has two operating modes. If no arguments are given,
            % the weight of all object is summed up. It can also receive 
            % the ammount to increase/decrease.
            % 
            % Note that the first one always provide the correct value but it
            % could reduce performance when multiple updates are required.
            % The other approach should be faster, but is prone to error if
            % the user is not careful. 
            if nargin == 1
                obj.currentWeight = sum([obj.items.weight]);
            else
                obj.currentWeight = obj.currentWeight + varargin{1};
            end
        end
        
        function updateCurrentProfit(obj, varargin)
            % updateCurrentProfit   Method for updating current profit of
            % the knapsack. Has two operating modes. If no arguments are given,
            % the profit of all items is summed up. It can also receive 
            % the ammount to increase/decrease.
            % 
            % Note that the first one always provide the correct value but it
            % could reduce performance when multiple updates are required.
            % The other approach should be faster, but is prone to error if
            % the user is not careful. 
            if nargin == 1
                obj.currentProfit = sum([obj.items.profit]);
            else
                obj.currentProfit = obj.currentProfit + varargin{1};
            end
        end
        
        
        function updateLength(obj, varargin)
            % updateLength   Method for updating current number of items in
            % the knapsack. Has two operating modes. If no arguments are given,
            % the whole vector is analized. It can also receive the ammount
            % to increase/decrease.
            % 
            % Note that the first one always provide the correct value but it
            % could reduce performance when multiple updates are required.
            % The other approach should be faster, but is prone to error if
            % the user is not careful. 
            if nargin == 1
                obj.nbItems = length(obj.items);
            else
                obj.nbItems = obj.nbItems + varargin{1};
            end
        end
        
    end
end