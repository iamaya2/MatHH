classdef KPInstance < problemInstance
    properties
        % Inherited (Abstract)
        bestSolution;
        features % Dictionary. Key: Feature ID. Value: Feature value
        nbFeatures = NaN;
        solution;
        status = 'Undefined';        
        % Own (Extra)
        % --- Base properties
        items; % List of KPItems within the instance
        capacity = NaN; % Knapsack capacity
        % --- Memory-related properties
        memory  % Matrix for storing historical feature values 
        memorySize = 1; % Number of historical feature values to preserve
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
                        % Memory-related code
                        if nargin > 3 % user gave memory size
                            obj.memorySize = varargin{4};
                        end
                    else % If no IDs are given, default to all
                        selectedIDs = KP.problemFeatures.keys;
                    end
                    obj.updateFeatureValues(selectedIDs);
                    obj.nbFeatures = obj.features.numEntries;                    
                    obj.solution = KPSolution(KPKnapsack(obj.capacity,1));
                    % Memory-related code
                    obj.memory = nan(obj.memorySize, length(selectedIDs));
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
            % This method returns the feature values of the current instance
            % object. Refer to the domain class for information about
            % available features. 
            % 
            % Input: -- None -- 
            %
            % Output: 
            %   featureValues - Vector with the value of each feature
            %    available to the instance.
            %
            % See also: KP, KPINSTANCE.UPDATEFEATUREVALUES,
            % KPINSTANCE.GETCURRENTFEATUREVALUES, KPINSTANCE.SETFEATURES

            % Just a precaution in case something has not been initialized
            if ~obj.features.isConfigured
                if nargin == 2
                    selectedKeys = varargin{1};
                else
                    selectedKeys = obj.features.keys;
                end
                obj.updateFeatureValues(selectedKeys);
            end
            featureValues(1,:) = obj.getCurrentFeatureValues(); % To ensure shape            
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
            
            % Update feature values            
            % --- Historical data
            % --- --- Older values
            for idx = obj.memorySize : -1 : 2
                obj.memory(idx,:) = obj.memory(idx-1,:);
            end                        
            obj.memory(1,:) = obj.getCurrentFeatureValues();
            obj.updateFeatureValues(obj.features.keys)

            % Validate if the instance has been completely solved
            if isempty(obj.items)
                obj.status = "Solved";
            else
                obj.status = "Pending";
            end
        end

        function setFeatures(obj, featureIDs)
            % setFeatures   Method for redefining the set of features
            % available for the instance. Should be used by HHs to customize
            % instances so that they only contain features of interest.
            obj.features = dictionary();
            obj.updateFeatureValues(featureIDs);
            obj.nbFeatures = obj.features.numEntries;
        end

        % ---- ------------------------ ----
        % ---- MEMORY-RELATED METHODS ----
        % ---- ------------------------ ----

        function setMemorySize(obj, newSize)
            % setMemorySize   This method resets the memory of the
            % instance and changes it to a new size. It reinitializes the
            % memory to NaN values, but the rest of the instance is
            % unaffected.
            obj.memorySize = newSize;
            obj.memory = nan(newSize, obj.nbFeatures);
        end
        
        % ---- ------------------------ ----
        % ---- SUPPORT (INNER) METHODS ----
        % ---- ------------------------ ----
        function featureValues = getCurrentFeatureValues(obj)
            % getCurrentFeatureValues   Returns a vector with the current
            % feature values
            selectedKeys = obj.features.keys;
            featureValues = nan(size(selectedKeys));
            for idx = 1 : length(selectedKeys)
                thisKey = selectedKeys(idx); 
                featureValues(idx) = obj.features(thisKey);
            end
        end

        function updateFeatureValues(obj, selectedKeys)
            % updateFeatureValues   Update the feature values of the
            % instance for the given set of IDs.                                   
            for thisKey = selectedKeys(:)' % Forces sorted row vector
                thisFeatureCell = KP.problemFeatures(thisKey); % Returns cell array
                thisFeature = thisFeatureCell{1}; % Get the function handle from cell
                obj.features(thisKey) = thisFeature(obj);                
            end            
        end
        

    end
end