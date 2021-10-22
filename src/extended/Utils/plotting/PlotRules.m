function PlotRules(Rules, varargin)
% PlotRules   Function for plotting the rules of a rule-based selection HH


% Common parameters
ActionMarkerVec = ["o" "s" "d" "h" ">" "p" "+" "*"];
toGrayscale = false;
rX = 1; rY = 2;

forCIM = false;

if length(varargin) >= 1
    selectedFeatures = varargin{1};
    rX = selectedFeatures(1);
    rY = selectedFeatures(2);
    if length(varargin) >= 2
        toGrayscale = varargin{2};
    end
end

% Outdated
% switch (nargin)
%     case 1
%         ColorID = -1;
%         toGrayscale = false;
%         ActionMarkerVec = ["o" "s" "d" "h" ">" "p" "+" "*"];
%     case 2
%         ColorID = -1;
%         toGrayscale = false;
%         ActionMarkerVec = repmat(varargin{1}, size(Rules,1), 1);
%     case 3
%         ColorID = varargin{1};
%         toGrayscale = varargin{2};
%     case 4
%         ColorID = varargin{1};
%         toGrayscale = varargin{2};        
% end

allColors = [0 0 0; 1 1 0; 0 1 0; 1 0 0; 0 0 1; 1 0 1;];


RuleX = Rules(:,rX);
RuleY = Rules(:,rY);
Action = Rules(:,end);
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
        if selectedAction >= 0, ActionMarker = ActionMarkerVec(selectedAction+1); end
        ActionColor = allColors(Action(idx)+1,:);
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