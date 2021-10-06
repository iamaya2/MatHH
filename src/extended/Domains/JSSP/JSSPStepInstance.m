%% Function for stepping instance with heuristics
% 1: LPT
% 2: SPT
% 3: MPA
% 4: LPA
function [] = JSSPStepInstance (instance, heurID, varargin)
toPlot = false;
if nargin == 3, toPlot = varargin{1}; end
if heurID==1
    NextActivity =JSSPHeurLPT(instance);
elseif heurID==2
    NextActivity =JSSPHeurSPT(instance); 
elseif heurID==3
    NextActivity =JSSPHeurMPA(instance);
elseif heurID==4
    NextActivity =JSSPHeurLPA(instance);
else 
    disp("The Heuristic ID is not in the database")
    return 
end
    instance.scheduleJob(NextActivity)
if toPlot==true 
instance.plot
end
end