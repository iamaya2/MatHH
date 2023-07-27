classdef problemDomain < handle
    %   problemDomain  -  Abstract class for defining problem domains
    %
    % This abstract class contains the minimum methods and properties that
    % must be included within the definition of a new problem domain.
    %
    % problemDomain Properties
    %   Constants:
    %     problemFeatures - Cell array with strings for identifying the existing features, following the ID:Name per entry
    %     problemSolvers  - Cell array with strings for identifying the existing solvers, following the ID:Name per entry
    %     problemType     - String for identifying the problem domain
    %
    %   Example
    %    The following code considers a single feature and two available
    %    solvers, for a class called BP:
    %
    %     classdef BP < problemDomain
    %     properties (Constant)
    %         problemFeatures = {'1:Set2Ratio'};
    %         problemSolvers = {'1:MAX', '2:MIN'};
    %         problemType = 'BP';
    %     end
    %
    % problemDomain Methods
    %   Static:
    %     newInstance = cloneInstance(oldInstance)  - For indirect instance duplication
    %     dummyInstance = createDummyInstance()     - Returns an empty instance (just for memory allocation)
    %     s = disp()                                - For providing a string with the full name of the domain
    %     instanceSet = loadInstanceSet(setID)      - For easy instance loading
    %     stepHeuristic(instance, heurID, varargin) - For using a single heuristic for a single solution step     
    %
    % See also: ProblemInstance, problemSolution
    properties (Abstract, Constant)
        problemFeatures % Dictionary with ID:Handle format (requires R2022b)
        problemSolvers % Dictionary with ID:Handle format (requires R2022b)
        problemType % String for identifying the domain
    end
    
    methods (Abstract, Static)
        newInstance = cloneInstance(oldInstance) % For indirect instance duplication
        dummyInstance = createDummyInstance() % Returns an empty instance (just for memory allocation)
        s = disp() % For providing a string with the full name of the domain
        instanceSet = loadInstanceSet(setID) % For easy instance loading
        stepHeuristic(instance, heurID, varargin) % For using a single heuristic for a single solution step        
    end
end