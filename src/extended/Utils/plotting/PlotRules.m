function PlotRules(Rules, varargin)
% PlotRules   Function for plotting the rules of a rule-based selection HH


% Common parameters
ActionMarkerVec = ["o" "s" "d" "h" ">" "p"];
nbMarkers = length(ActionMarkerVec);
toGrayscale = false;
rX = 1; rY = 2;
plotColormap = @(x) hsv(x);

forCIM = false;

if length(varargin) >= 1
    selectedFeatures = varargin{1};
    rX = selectedFeatures(1);
    rY = selectedFeatures(2);
    if length(varargin) >= 2
        toGrayscale = varargin{2};
        if length(varargin) >= 3
            plotColormap = varargin{3};
        end
    end
end

RuleX = Rules(:,rX);
RuleY = Rules(:,rY);
Action = Rules(:,end);

% allColors = [0 0 0; 1 1 0; 0 1 0; 1 0 0; 0 0 1; 1 0 1;];
% allColors = [0 0 0; 0.85 0 0; 0 0 0.85; 0.85 0 0.85; 0.75 * ones(1,3);  0.5 * ones(1,3);];
maxActionID = max(Action);
allColors = plotColormap(maxActionID);


for idx = 1 : length(RuleX)
    if forCIM, ActionSize = 5; else, ActionSize = 15; end
    if toGrayscale
        ActionMarker = "h";        
        switch (Action(idx))            
            case 1
                ActionColor = [0 0 0];
            case 2
                ActionColor = 0.5 * ones(1,3);
            case 3
                ActionColor = 1 * ones(1,3);
        end
    else
        selectedAction = Action(idx);
        if selectedAction >= 0
            tempAction = mod(selectedAction,nbMarkers);
            ActionMarker = ActionMarkerVec(tempAction+1); 
        end
        ActionColor = allColors(Action(idx),:);
%         switch selectedAction
%             case 0
%                 ActionColor = [0 0 0];
%                 %        case 1
%                 %          if forCIM, ActionSize -= 1; ActionColor = [0.8 0 0]; else, ActionSize -= 3; ActionColor = 0.5 * ones(1,3); end
%                 %        case 2
%                 %          if forCIM, ActionColor = [0 0 0.8]; else, ActionColor = 0.75 * ones(1,3); end
%             case 1
%                 if forCIM, ActionSize = ActionSize - 1; ActionColor = [0.8 0 0]; else, ActionSize = ActionSize - 3; ActionColor = [0.75 0 0]; end
%             case 2
%                 if forCIM, ActionColor = [0 0 0.8]; else, ActionColor = [0 0 0.75]; end
%                 
%             case 3
%                 if forCIM, ActionColor = [0 0.8 0]; else, ActionColor = 1.0 * ones(1,3); end
%             case -1
%                 ActionMarker = "^";
%                 ActionColor = [0.7 0 0.7] .* ones(1,3);
%             otherwise
%                 ActionColor = [0 0 0];
%         end
    end
    
    plot(RuleX(idx), RuleY(idx), ActionMarker,'MarkerSize', ActionSize, 'Color', 0.0*ones(1,3),'LineWidth',0.5,...
        'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', ActionColor);
    hold on
end
end