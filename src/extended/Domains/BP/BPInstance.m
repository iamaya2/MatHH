%% BPInstance   Class for creating Balanced Partition problem instances.
%
% An instance can be created from the following sources: 
% 
%  1. Numeric vector. User provides an array of values and an ID for the
%                     instance. 
%  2. Vector of BPItem objects. Same as before but using an array of BPItem
%                              objects as the first argument.
%  3. Another BPInstance. In this case the user must only provide an already
%                         created object and the method returns a deep copy of such an instance.
classdef BPInstance < handle & deepCopyThis
    properties        
        currentFeatures = NaN; % Vector of current feature values
        ID = NaN ; % Scalar for differentiating among instances
        items = BPItem(); % A vector with all BPItem objects
        load = 0; % Scalar with the current total load of this instance
        maxLoad = 0; % Scalar with the max total load of the instance
        nbItems = 0; % Number of elements within the instance
        solution = BPSolution(); % A solution object for the BP problem
    end
    
    methods
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = BPInstance(varargin)            
            if nargin > 0
                if isnumeric(varargin{1}) % just the values and ID
                    givenValues = varargin{1};
                    nbToCreate = length(givenValues);
                    obj.items(nbToCreate) = BPItem(givenValues(end),nbToCreate);
                    for idx = 1 : nbToCreate-1
                        obj.items(idx) = BPItem(givenValues(idx),idx);
                    end
                    obj.ID = varargin{2};
                elseif isa(varargin{1},'BPItem') % from vector of BPItem
                    obj.items = varargin{1};
                    obj.ID = varargin{2};                    
                elseif isa(varargin{1},'BPInstance') % from another BPInstance
                    obj = BPInstance();
                    varargin{1}.cloneProperties(obj);
                    return
                else
                    error('Invalid data for constructor. Aborting!')
                end
                obj.updateLength();
                obj.updateLoad();
                obj.maxLoad = obj.load;
                obj.solution.sets = [BPSet(obj.items,1) BPSet(2)];
                obj.getFeatureVector();
            end
        end
        
        % ---- ------------------------ ----
        % ---- FEATURE-RELATED METHODS ----
        % ---- ------------------------ ---- 
        function calculateFeature(obj,featureIDs)
            nbFeaturesToCalculate = length(featureIDs);
            allFeatures = nan(1,nbFeaturesToCalculate);
            for idx = 1 : nbFeaturesToCalculate
                switch featureIDs(idx)
                    case 1
                        thisFeatureValue = obj.getBalanceRatio();
                    otherwise
                        error('Feature ID not defined. Aborting!')
                end
                allFeatures(idx) = thisFeatureValue;
            end
            obj.currentFeatures = allFeatures;
        end
        
        function featValue = getBalanceRatio(obj)
            featValue = obj.solution.sets(1).load / obj.maxLoad;
        end
        
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ---- 
        function getFeatureVector(obj, varargin)
            % getFeatureVector   Method for calculating features associated
            % with the whole instance. Receives a single optional input with the ID
            % of the feature to be calculated: 
            %
            % * 1: Ratio of Set 1 / All items
            %
            % If no input is given, getFeatureVector calculates all the available
            % features.
            if isempty(varargin)
                obj.calculateFeature(1:length(BP.problemFeatures));
            else
                obj.calculateFeature(varargin{1});
            end
        end
        
        function updateLength(obj, varargin)
            % updateLength   Method for updating the length of the current
            % instance. Has two operating modes. If no arguments are given, the
            % 'length' command is used to calculate the whole vector. It
            % can also receive the number of elements to increase, and it
            % would simply add that ammount to the current length. Note
            % that the first one always provide the correct value but it
            % could reduce performance when multiple updates are required.
            % The other approach should be faster, but is prone to error if
            % the user is not careful. 
            if nargin == 1
                obj.nbItems = length(obj.items);
            else
                obj.nbItems = obj.nbItems + varargin{1};
            end
        end
        
        function updateLoad(obj, varargin)
            % updateLoad   Method for updating the laod of the current
            % instance. Has two operating modes. If no arguments are given, the
            % load is calculated by summing the load of the whole vector. It
            % can also receive the load to increase, and it
            % would simply add that ammount to the current load. Note
            % that the first one always provide the correct value but it
            % could reduce performance when multiple updates are required.
            % The other approach should be faster, but is prone to error if
            % the user is not careful. 
            if nargin == 1
                obj.load = sum([obj.items.load]);
            else
                obj.load = obj.load + varargin{1};
            end
        end
    end
end