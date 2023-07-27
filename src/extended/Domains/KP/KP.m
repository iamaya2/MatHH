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
            % stepHeuristic   (WIP) For using a single heuristic for a
            % single solution step.
            if heurID < max(KP.problemSolvers.keys) % Validate ID
                selectedHeuristic = KP.problemSolvers{heurID}; % Get handle
                selectedHeuristic(instance); % Apply heuristic
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
            callErrorCode(0)

        end

        function heurMaP(instance)
            callErrorCode(0)  
        end

        function heurMiW(instance)
            callErrorCode(0)
        end

        function heurMPW(instance)
            callErrorCode(0)
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
            callErrorCode(0)
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
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featMNPRI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featMNWRI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featSNPRI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featSNWRI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        % --- For packed items
        function featureValue = featANPPI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featANWPI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featNWPCPI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featMNPPI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featMNWPI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featSNPPI (instance)
            callErrorCode(0)
            featureValue = nan;
        end

        function featureValue = featSNWPI (instance)            
            callErrorCode(0)
            featureValue = nan;
        end

        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ---- 
    end
end