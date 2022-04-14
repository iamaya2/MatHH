classdef ruleBasedSelectionHHMulti < ruleBasedSelectionHH
%     ruleBasedSelectionHHMulti   -   Class definition for multilayered HHs
%
%   This class inherits major functionality from the ruleBasedSelectionHH
%   class, and overloads as few methods as possible, in order to reach
%   multi-layered functionality. 
%
%   See also: ruleBasedSelectionHH
    properties
        % Number of layers for the HH. Defaults to 1.
        nbLayers = 1; 
        
        % Array of internal multi-layered HHs.
        %   Defaults to a HH with a single rule (i.e. a heuristic).
        innerHHs = NaN; 
    end
    
    methods
        % ----- ---------------------------------------------------- -----
        % Constructor
        % ----- ---------------------------------------------------- -----
        function obj = ruleBasedSelectionHHMulti(varargin)
            callErrorCode(0); % WIP
            
            obj = obj@ruleBasedSelectionHH(varargin{:}); % this must be tested. Should create basic HH with props
            defaultNbLayers = 2;       
            defaultInnerHHs = ruleBasedSelectionHH(struct('nbRules',1)); 
            if nargin >=1 
                props = varargin{1};                
                if ~isfield(props,'nbLayers'), props.nbLayers = defaultNbLayers; end
                if ~isfield(props,'innerHHs'), props.innerHHs = defaultInnerHHs; end
%                 if ~isfield(props,'nbRules'), props.nbRules = defaultNbRules; end                
%                 if ~isfield(props,'selectedFeatures'), props.selectedFeatures = defaultFeatures; end
%                 if ~isfield(props,'selectedSolvers'), props.selectedSolvers = defaultSolvers; end                
%                 if ~isfield(props,'targetProblemHandle'), props.targetProblemHandle = defaultProblemHandle; end
                obj.initializeParameters(props);
            end
            obj.initializeModel(obj.nbRules);
        end
        
        % ----- ---------------------------------------------------- -----
        % Own methods
        % ----- ---------------------------------------------------- -----
        function initializeParameters(obj, props)
            %  initializeParameters  -  Method for initializing the object.
            %
            %    If the number of layers equals 1, then the inner HHs are
            %    set as void, since it represents a traditional HH.
            %    
            %    Inputs:
            %      props - Struct with all the internal fields of the object.
            %               Should be used through the constructor, since
            %               the latter checks for missing values and adds default
            %               values, if required.
            obj.nbLayers = props.nbLayers;
            if obj.nbLayers == 1, obj.innerHHs = []; else, obj.innerHHs = props.innerHHs; end
%             obj.nbRules = props.nbRules;            
%             obj.assignProblem(props.targetProblemHandle);
%             obj.assignFeatures(props.selectedFeatures);
%             obj.assignSolvers(props.selectedSolvers);
        end
        
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
        function actionID = getRuleAction(obj,ruleID,instance)
            % getRuleAction  -  Method for returning the heuristic to use
            %
            %  This method recursively iterates into the layers until
            %  arriving at the innermost selector, where a heuristic is to
            %  be selected. 
            %
            %   Inputs:
            %     ruleID - Scalar with the index of the rule which action
            %     will be selected.
            %     instance - Instance object that is being analyzed.
            %
            %   Outputs:
            %     actionID - Scalar with the ID of the heuristic to use.
            %            
            if obj.nbLayers == 1
                actionID = obj.value(ruleID,end); % First action (a.k.a traditional HH)
            else
                innerHHID = obj.value(ruleID,end);
                innerHH = obj.innerHHs(innerHHID);
                newRuleID = innerHH.getClosestRule(instance);
                actionID = innerHH.getRuleAction(newRuleID, instance);
            end
        end
        
    end
end