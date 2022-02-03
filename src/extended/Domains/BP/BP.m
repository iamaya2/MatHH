classdef BP < problemDomain
    properties (Constant)
        problemFeatures = {'0:Set1Ratio'};
        problemSolvers = {'0:MAX', '1:MIN'};
        problemType = 'BP';
    end
    
    methods (Static)
        % ---- ------------------------ ----
        % ---- INHERITED METHODS ----
        % ---- ------------------------ ----
        function newInstance = cloneInstance(oldInstance)
            newInstance = BPInstance(oldInstance);
        end
        
        function dummyInstance = createDummyInstance()
            dummyInstance = BPInstance();
        end
        
        function s = disp()
            % disp   Method that returns a string with the full name of the
            % BP domain.
            s = sprintf('Balanced Partition Problem');
        end
        
        function instanceSet = loadInstanceSet(setID)
            % loadInstanceSet  Method for loading a set of provided
            % instances. Requires a single input (setID) and returns a cell
            % array with the set of loaded instances.
            %
            % The following sets are available:
            %
            % \--------------------------------------------\
            % |    SetID    |  Bits | Elements | Instances |
            % \--------------------------------------------\
            % | rand5E2B    |    2  |     5    |     10    |
            % | rand5E8B    |    8  |     5    |     10    |
            % | rand25E4B   |    4  |    25    |    200    |
            % | rand25E25B  |   25  |    25    |    200    |
            % | rand25E50B  |   50  |    25    |    200    |
            % | rand40E4B   |    4  |    40    |    200    |
            % | rand40E25B  |   25  |    40    |    200    |
            % | rand40E50B  |   50  |    40    |    200    |
            % | rand100E10B |   10  |   100    |     10    |
            % \--------------------------------------------\                       
            thisFolder = fileparts(which('BP'));
            oldDir = cd(thisFolder);
            switch lower(setID)
                case 'rand5e2b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\5Elements\2Bits\instanceDataset.mat';
                case 'rand5e8b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\5Elements\8Bits\instanceDataset.mat';
                case 'rand25e4b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\25Elements\4Bits\instanceDataset.mat';
                case 'rand25e25b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\25Elements\25Bits\instanceDataset.mat';
                case 'rand25e50b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\25Elements\50Bits\instanceDataset.mat';
                case 'rand40e4b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\40Elements\4Bits\instanceDataset.mat';
                case 'rand40e25b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\40Elements\25Bits\instanceDataset.mat';
                case 'rand40e50b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\40Elements\50Bits\instanceDataset.mat';
                case 'rand100e10b'
                    datasetPath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\mat\Random\100Elements\10Bits\instanceDataset.mat';
                otherwise
                    callErrorCode(101)
            end
            load(datasetPath,'instanceDataset');
            instanceSet = instanceDataset;
            cd(oldDir);
        end
        
        function stepHeuristic(instance, heurID, varargin)
            % stepHeuristic   Method for executing a single solution step
            % in a Balanced Partition problem instance. Updates the
            % solution property of the given instance directly.
            %
            % -\ Inputs:
            % -\ ---\ instance: The instance that will be affected
            % -\ ---\ heurID: A numeric ID for the heuristic of interest:
            % -\ ---\ ---\ 1. MAX heuristic
            % -\ ---\ ---\ 2. MIN heuristic
            % -\ ---\ ---\ 3. MAX2 heuristic
            % -\ ---\ ---\ 4. MIN2 heuristic
            %
            % NOTE: This method applies the heuristic but does not update
            % the feature values, since they depend on the HH model. Use
            % the BPINSTANCE.GETFEATUREVECTOR method to force
            % the update.
            %
            % See also: HEURMAX, HEURMIN, HEURMAX2, HEURMIN2,
            % BPINSTANCE.GETFEATUREVECTOR
            switch heurID
                case 1
                    BP.heurMax(instance)
                case 2
                    BP.heurMin(instance)
                case 3
                    BP.heurMax2(instance)
                case 4
                    BP.heurMin2(instance)
                otherwise
                    callErrorCode(100);
            end            
        end
        
        % ---- ------------------------ ----
        % ---- HEURISTICS ----
        % ---- ------------------------ ---- 
        function heurMax(instance)
            % heurMax   Static method that moves the largest item in Set 1
            % into Set 2.
            % -\ Inputs:
            % -\ ---\ instance: The BP Instance that will be affected
            [~, itemID] = max(instance.getSetLoads(1));
            instance.moveItem(itemID,1,2); % Moves from Set 1 to Set 2
        end
        
        function heurMax2(instance)
            % heurMax2   Static method that moves the 2nd largest item in 
            % Set 1 into Set 2.
            % -\ Inputs:
            % -\ ---\ instance: The BP Instance that will be affected
            [~, sortedItemsID] = sort(instance.getSetLoads(1)); % ascending
            if length(sortedItemsID) == 1
                itemID = sortedItemsID(1);
            else
                itemID = sortedItemsID(end-1); % 2nd highest
            end
            instance.moveItem(itemID,1,2); % Moves from Set 1 to Set 2
        end
        
        
        function heurMin(instance)
            % heurMin   Static method that moves the smallest item in Set 1
            % into Set 2.
            % -\ Inputs:
            % -\ ---\ instance: The BP Instance that will be affected
            [~, itemID] = min(instance.getSetLoads(1));
            instance.moveItem(itemID,1,2); % Moves from Set 1 to Set 2
        end
        
        function heurMin2(instance)
            % heurMin2   Static method that moves the 2nd smallest item in 
            % Set 1 into Set 2.
            % -\ Inputs:
            % -\ ---\ instance: The BP Instance that will be affected
            [~, sortedItemsID] = sort(instance.getSetLoads(1)); % ascending
            if length(sortedItemsID) == 1
                itemID = sortedItemsID(1);
            else
                itemID = sortedItemsID(2); % 2nd smallest
            end
            instance.moveItem(itemID,1,2); % Moves from Set 1 to Set 2
        end
        
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ---- 
    end
end