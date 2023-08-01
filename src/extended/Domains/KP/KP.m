classdef KP < problemDomain
    properties (Constant)
        % Dictionary with ID:Handle format (requires R2022b). Entries:
        % 1: Average Normalized Profit of Remaining Items (ANPRI)
        % 2: Average Normalized Weight of Remaining Items (ANWRI)
        % 3: Normalized Weight-Profit Correlation of Remaining Items (NWPCRI)
        % 4: Median Normalized Profit of Remaining Items (MNPRI)
        % 5: Median Normalized Weight of Remaining Items (MNWRI)
        % 6: Standard dev. Normalized Profit of Remaining Items (SNPRI)
        % 7: Standard dev. Normalized Weight of Remaining Items (SNWRI)
        % 8: Average Normalized Profit of Packed Items (ANPPI)
        % 9: Average Normalized Weight of Packed Items (ANWPI)
        % 10: Normalized Weight-Profit Correlation of Packed Items (NWPCPI)
        % 11: Median Normalized Profit of Packed Items (MNPPI)
        % 12: Median Normalized Weight of Packed Items (MNWPI)
        % 13: Standard dev. Normalized Profit of Packed Items (SNPPI)
        % 14: Standard dev. Normalized Weight of Packed Items (SNWPI)
        problemFeatures = dictionary(1:14, ...
            {@(inst) KP.featANPRI(inst), @(inst) KP.featANWRI(inst), ...
            @(inst) KP.featNWPCRI(inst), ...
            @(inst) KP.featMNPRI(inst), @(inst) KP.featMNWRI(inst), ...
            @(inst) KP.featSNPRI(inst), @(inst) KP.featSNWRI(inst), ...
            @(inst) KP.featANPPI(inst), @(inst) KP.featANWPI(inst), ...
            @(inst) KP.featNWPCPI(inst), ...
            @(inst) KP.featMNPPI(inst), @(inst) KP.featMNWPI(inst), ...
            @(inst) KP.featSNPPI(inst), @(inst) KP.featSNWPI(inst), ...
            });

        % Dictionary with ID:Handle format (requires R2022b). Entries:
        % 1: Default order
        % 2: Max Profit
        % 3: Min Weight
        % 4: Max Profit / Weight
        problemSolvers = dictionary(1:4,...
            {@(inst) KP.heurDef(inst), @(inst) KP.heurMaP(inst), ...
            @(inst) KP.heurMiW(inst), @(inst) KP.heurMPW(inst)});
        
        % String for identifying the domain
        problemType = 'KP';
    end
    
    methods (Static)
        % ---- ------------------------ ----
        % ---- INHERITED METHODS ----
        % ---- ------------------------ ----
        function newInstance = cloneInstance(oldInstance)
            % cloneInstance   Method for duplicating an existing instance (deep
            % copy).
            newInstance = KPInstance(oldInstance);
        end

        function dummyInstance = createDummyInstance()
            % createDummyInstance   Method that returns an empty instance (for memory allocation)
            dummyInstance = KPInstance();
        end

        function s = disp() 
            % disp   Method that returns a string with the full name of the domain
            s = sprintf('0/1 Knapsack Problem');
        end

        function instanceSet = loadInstanceSet(setID) 
            % loadInstanceSet   (WIP) For easy instance loading. Not yet
            % implemented.
            callErrorCode(0)
        end

        function stepHeuristic(instance, heurID, varargin) 
            % stepHeuristic   (WIP) Uses a given heuristic for a single step.
            %
            %  This method validates the given ID and throws an error if it
            %  is not. Afterward, it applies the given heuristic for a
            %  solution step and validates if the problem instance has been
            %  completed. 
            if heurID <= max(KP.problemSolvers.keys) % Validate ID
                selectedHeuristicCell = KP.problemSolvers(heurID); % Get handle
                selectedHeuristic = selectedHeuristicCell{1};
                selectedHeuristic(instance); % Apply heuristic
                % Validate if the instance has been completely solved
                if isempty(instance.items)
                    instance.status = "Solved";
                else
                    instance.status = "Pending";
                end
            else
                callErrorCode(100)
            end
        end

        % ---- ------------------------ ----
        % ---- HEURISTICS ----
        % ---- ------------------------ ---- 
        function heurDef(instance)
            % heurDef   Default heuristic
            % This heuristic tries to pack items in the order provided by
            % the instance (i.e., the default ordering). 
            % 
            % Input: The instance to modify
            % Output: None (the object is modified directly)
            %
            % See also: KP.problemSolvers            
            instance.attemptToPack(instance.items(1))
        end

        function heurMaP(instance)
            % heurMaP   Max Profit heuristic
            % This heuristic tries to pack items with the highest profit
            % first.
            % 
            % Input: The instance to modify
            % Output: None (the object is modified directly)
            %
            % See also: KP.problemSolvers              
            allProfits = [instance.items.profit];
            [~,itemID] = max(allProfits);
            instance.attemptToPack(instance.items(itemID));
        end

        function heurMiW(instance)
            % heurMiW   Min Weight heuristic
            % This heuristic tries to pack items with the lowest weight
            % first.
            % 
            % Input: The instance to modify
            % Output: None (the object is modified directly)
            %
            % See also: KP.problemSolvers              
            allWeights = [instance.items.weight];
            [~,itemID] = min(allWeights);
            instance.attemptToPack(instance.items(itemID));
        end

        function heurMPW(instance)
            % heurMPW   Max Profit per Weight heuristic
            % This heuristic tries to pack items with the highest profit
            % per weight ratio first.
            % 
            % Input: The instance to modify
            % Output: None (the object is modified directly)
            %
            % See also: KP.problemSolvers              
            allPWRatios = [instance.items.profit] ./ [instance.items.weight];
            [~,itemID] = max(allPWRatios);
            instance.attemptToPack(instance.items(itemID));
        end

        % ---- ------------------------ ----
        % ---- FEATURES ----
        % ---- ------------------------ ----
        % --- For remaining items
        function featureValue = featANPRI (instance)
            % featANPRI   Method for calculating the ANPRI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getProfitRemainingItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = mean(allData) / max(allData);
            end
        end

        function featureValue = featANWRI (instance)            
            % featANWRI   Method for calculating the ANWRI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getWeightRemainingItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = mean(allData) / max(allData);
            end
        end

        function featureValue = featNWPCRI (instance)            
            % featNWPCRI   Method for calculating the NWPCRI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allWeights = instance.getWeightRemainingItems();
            allProfits = instance.getProfitRemainingItems();
            nbItems = length(allWeights);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                corrMatrix = corrcoef(allWeights,allProfits);
                featureValue = corrMatrix(1,2); % Coefficient (crossed interaction)
                featureValue = featureValue/2 + 0.5; % Normalization
            end
        end

        function featureValue = featMNPRI (instance)         
            % featMNPRI   Method for calculating the MNPRI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getProfitRemainingItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = median(allData) / max(allData);
            end
        end

        function featureValue = featMNWRI (instance)
            % featMNWRI   Method for calculating the MNWRI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getWeightRemainingItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = median(allData) / max(allData);
            end
        end

        function featureValue = featSNPRI (instance)
            % featSNPRI   Method for calculating the SNPRI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getProfitRemainingItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 0; % Default value since one item yields 0 also
            else
                featureValue = std(allData) / max(allData);
            end
        end

        function featureValue = featSNWRI (instance)
            % featSNWRI   Method for calculating the SNWRI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getWeightRemainingItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 0; % Default value since one item yields 0 also
            else
                featureValue = std(allData) / max(allData);
            end
        end

        % --- For packed items
        function featureValue = featANPPI (instance)            
            % featANPPI   Method for calculating the ANPPI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getProfitPackedItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = mean(allData) / max(allData);
            end
        end

        function featureValue = featANWPI (instance)
            % featANWPI   Method for calculating the ANWPI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getWeightPackedItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = mean(allData) / max(allData);
            end
        end

        function featureValue = featNWPCPI (instance)
            % featNWPCPI   Method for calculating the NWPCPI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allWeights = instance.getWeightPackedItems();
            allProfits = instance.getProfitPackedItems();
            nbItems = length(allWeights);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                corrMatrix = corrcoef(allWeights,allProfits);
                featureValue = corrMatrix(1,2); % Coefficient (crossed interaction)
                featureValue = featureValue/2 + 0.5; % Normalization
            end
        end

        function featureValue = featMNPPI (instance)
            % featMNPPI   Method for calculating the MNPPI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getProfitPackedItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = median(allData) / max(allData);
            end
        end

        function featureValue = featMNWPI (instance)
            % featMNWPI   Method for calculating the MNWPI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getWeightPackedItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 1; % Default value since one item yields 1 also
            else
                featureValue = median(allData) / max(allData);
            end
        end

        function featureValue = featSNPPI (instance)
            % featSNPPI   Method for calculating the SNPPI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getProfitPackedItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 0; % Default value since one item yields 0 also
            else
                featureValue = std(allData) / max(allData);
            end
        end

        function featureValue = featSNWPI (instance)            
            % featSNWPI   Method for calculating the SNWPI feature
            % Input: Current instance
            % Output: Feature value
            %
            % See also: KP.problemFeatures
            allData = instance.getWeightPackedItems();
            nbItems = length(allData);
            if nbItems == 0
                featureValue = 0; % Default value since one item yields 0 also
            else
                featureValue = std(allData) / max(allData);
            end
        end

        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ---- 
    end
end