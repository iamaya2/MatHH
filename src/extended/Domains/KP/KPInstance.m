classdef KPInstance < problemInstance
    properties
        % Inherited (Abstract)
        bestSolution;
        features % Dictionary. Key: Feature ID. Value: Feature value
        nbFeatures = NaN;
        solution;
        status = 'Undefined';        
        % Own (Extra)
        items; % List of KPItems within the instance
        capacity = NaN; % Knapsack capacity
    end
    
    methods
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = KPInstance(varargin)
            % KPInstance   Method for creating an instance
            %
            % This method receives variable inputs, depending on the kind
            % of usage desired. An instance can be created from: 
            %
            %  Another KPInstance. In this case, a deep copy of the
            %    instance is returned.
            %
            %  A vector of KPItem objects. In this case, a shallow copy of each item
            %    is assigned to the KPInstance object. This approach
            %    requires a second input, which stands for the capacity of
            %    the knapsack. A third input (optional) can be used to
            %    define the feature IDs that the instance considers. If no
            %    information is provided, all the available features are
            %    used by default.
            %
            % See also: KPITEM
            obj.bestSolution = KPSolution(); % initialize best solution holder
            obj.features = dictionary();
            obj.solution = KPSolution(); % initializes solution
            obj.items = KPItem.empty;
            if nargin > 0
                oldObj = varargin{1};
                if isa(oldObj,'KPInstance') % from another instance
                    obj = KPInstance();
                    oldObj.deepCopy(obj);
                elseif isa(oldObj, 'KPItem') % from base data
                    obj.items = oldObj; % Shallow copy of items
                    obj.capacity = varargin{2}; % requires a capacity...
                    if nargin > 2 % ... and feature IDs
                        % User defined:
                        selectedIDs = varargin{3}; 
                    else % If no IDs are given, default to all
                        selectedIDs = KP.problemFeatures.keys;
                    end
                    obj.getFeatureVector(selectedIDs);
                    obj.nbFeatures = obj.features.numEntries;                    
                    obj.solution = KPSolution(KPKnapsack(obj.capacity,1));
                else
                    callErrorCode(102); % Invalid input
                end
            end
        end
        
        % ---- ------------------------ ----
        % ---- INHERITED METHODS ----
        % ---- ------------------------ ----
        function featureValues = getFeatureVector(obj, varargin)
            % getFeatureVector   Returns a vector with feature values
            %
            % This method receives a vector of featureIDs that are used to
            % calculate specific feature values of the current instance
            % object. Refer to the domain class for information about
            % available features. 
            % 
            % Input:
            %   featureID - Vector of integer values that represent the
            %    ID of the features that the instance considers. Note that
            %    they may differ from the whole set of feature IDs, since
            %    not all IDs may be required at any single moment. If no
            %    input is given, all the current features are updated.
            %
            % Output: 
            %   featureValues - Vector with the value of each feature
            %    available to the instance.
            %
            % See also: KP
            if nargin == 2
                selectedKeys = varargin{1};
            else
                selectedKeys = obj.features.keys;
            end
            featureValues = nan(size(selectedKeys));
            idx = 1;
            for thisKey = selectedKeys(:)' % Force row vector
                thisFeatureCell = KP.problemFeatures(thisKey); % Returns cell array
                thisFeature = thisFeatureCell{1}; % Get the function handle from cell
                obj.features(thisKey) = thisFeature(obj);
                featureValues(idx) = obj.features(thisKey);
                idx = idx + 1;
            end
%             featureValues = obj.features.values;
        end
    
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ----
        function weightValues = getWeightRemainingItems(obj)            
            % getWeightRemainingItems   Returns a vector with the weight of
            % remaining items (those not analyzed yet)
            weightValues = [obj.items.weight];
        end

        function profitValues = getProfitRemainingItems(obj)            
            % getProfitRemainingItems   Returns a vector with the profit of
            % remaining items (those not analyzed yet)
            profitValues = [obj.items.profit];
        end

        function weightValues = getWeightPackedItems(obj)            
            % getWeightPackedItems   Returns a vector with the weight of
            % packed items (those within the knapsack)
            weightValues = [obj.solution.knapsack.items.weight];
        end

        function profitValues = getProfitPackedItems(obj)            
            % getProfitPackedItems   Returns a vector with the profit of
            % packed items (those within the knapsack)
            profitValues = [obj.solution.knapsack.items.profit];
        end

        function weightValues = getWeightDiscardedItems(obj)            
            % getWeightDiscardedItems   Returns a vector with the weight of
            % discarded items (those that did not fit the knapsack)
            weightValues = [obj.solution.discarded.weight];
        end

        function profitValues = getProfitDiscardedItems(obj)            
            % getProfitDiscardedItems   Returns a vector with the profit of
            % discarded items (those that did not fit the knapsack)
            profitValues = [obj.solution.discarded.profit];
        end

        function attemptToPack(obj, thisItem)
            % attemptToPack  Method for processing an item
            % 
            % Requires a single input: the KPItem to process. If the item
            % fits within the knapsack, it is added to the solution.
            % Otherwise, it is added to the array of discarded KPItems. 
            %
            % See also: KPKnapsack, KPItem
            currentKP = obj.solution.knapsack;
            if currentKP.currentWeight + thisItem.weight <= currentKP.capacity
                % It fits
                currentKP.packItem(thisItem);
            else
                % It does not fit
                obj.solution.discarded = [obj.solution.discarded thisItem];
                thisItem.doneUnpacking();
                thisItem.doneProcessing();                
            end
            thisID = find(obj.items == thisItem, 1); % Find at most 1 item
            obj.items = [obj.items(1:thisID-1) obj.items(thisID+1:end)]; % Remove it
            
            % Validate if the instance has been completely solved
            if isempty(obj.items)
                obj.status = "Solved";
            else
                obj.status = "Pending";
            end
        end

        
        % ---- ------------------------ ----
        % ---- SUPPORT (INNER) METHODS ----
        % ---- ------------------------ ----
        
        

    end
end