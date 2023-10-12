classdef problemInstance < handle & deepCopyThis
    %   problemInstance  -  Abstract class for defining problem instances
    %
    % This abstract class contains the minimum methods and properties that
    % must be included within the definition of a new instance model for a given problem domain.
    %
    % problemInstance Properties
    %   Variables:
    %     features - Vector with the current feature values of the instance
    %     solution - Solution object (able to store partial and full solutions), which likely extends the 
    %                problemSolution abstract class.
    %     status   - String representing the current status of the instance (Undefined, Pending, Solved)    
    %
    %   Example
    %    The following code defines the properties of a problem instance class that initializes the 
    %    feature vector to NaN: 
    %
    % classdef BPInstance < problemInstance
    %     properties        
    %       % Required by the abstract class:
    %           features = NaN;             % Vector of current feature values    
    %           solution;    % A solution object for the BP problem (initialize in constructor)
    %           status = 'Undefined';       % Initial status of the instance
    %       % Additional properties for this particular problem domain:
    %           ID = NaN ;                  % Scalar for differentiating among instances
    %           items;           % A vector with all BPItem objects (initialize in constructor)
    %           load = 0;                   % Scalar with the current total load of this instance
    %           maxLoad = 0;                % Scalar with the max total load of the instance
    %           nbItems = 0;                % Number of elements within the instance
    %     end
    %
    % problemInstance Methods
    %   Non-static:
    %     featureValues = getFeatureVector(obj, varargin) - Updates and return feature values, given a set of feature IDs
    %
    % See also: ProblemDomain, problemSolution    
    properties (Abstract)
        bestSolution % A solution object with the information about the best solution (if available)
        features % Dictionary with ID:Value format (requires R2022b)          
        nbFeatures % Number of features that the instance considers. Equal to length(features)
        solution % Solution object (able to store partial and full solutions)
        status % Current status of the instance (Undefined, Pending, Solved)
    end
    
    methods (Abstract)
       featureValues = getFeatureVector(obj, varargin) % Updates and return feature values, given a set of feature IDs
    end
    
    methods
        function fitness = getSolutionPerformanceMetric(obj)
            % getSolutionPerformanceMetric   Method for returning the
            % performance metric of the solution object associated with
            % this instance. Requires no inputs.
            fitness = obj.solution.getSolutionPerformanceMetric();
        end

        function solvedStatus = hasBeenSolved(obj)
            % hasBeenSolved   Method for assessing whether the
            % problemInstance object has been completely solved. Requires
            % no inputs. Returns true if the instance is solved and false
            % otherwise.
            solvedStatus = false;
            if strcmp(obj.status,'Solved'), solvedStatus = true; end
        end        
    end
end