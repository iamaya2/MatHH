%% File for manually generating instances
%% Cleanup
clc
clear
close all

%% Global variables
basepath = '..\..\..\';
matInstancePath = [basepath '..\..\BaseInstances\Knapsack\files\mat\'];
toSave = true; % Flag for defining if instances will be stored on disk

%% Loads required packages
addpath(basepath); % Adds root folder (without subfolders)
addpath([basepath 'extended\Domains\']); % Adds common domain classes (abstract)
addpath(genpath([basepath 'extended\Domains\KP'])); % Adds KP domain functionality
addpath(genpath([basepath 'extended\Utils'])); % Adds assorted utilities

%% Toy instances from PPT about HHs
% Instance 1:
% ------------
% Capacity: 10
% ------------
% Best solution: 
%    Profit: 65
%    Items (ID): {1,3} 
% ------------
% Solution given by heuristics:
%    Def
%       Profit: 65
%       Items (ID): {1,3}
%    MaP
%       Profit: 54
%       Items (ID): {2,4}
%    MiW
%       Profit: 52
%       Items (ID): {4,1}
%    MPW
%       Profit: 65
%       Items (ID): {1,3}
% ------------
%  #|𝑤 |𝑝
% ------------
%  1|4  |40
%  2|7  |42
%  3|5  |25
%  4|3  |12
% ------------
allItems = [KPItem(40,4,1),...
            KPItem(42,7,2),...
            KPItem(25,5,3),...
            KPItem(12,3,4)];
toy01 = KPInstance(allItems, 10);

% Instance 2:
% ------------
% Capacity: 16
% ------------
% Best solution: 
%    Profit: 119
%    Items (ID): {2,3}
% ------------
% Solution given by heuristics:
%    Def
%       Profit: 112
%       Items (ID): {1,4}
%    MaP
%       Profit: 112
%       Items (ID): {1,4}
%    MiW
%       Profit: 75
%       Items (ID): {4,2}
%    MPW
%       Profit: 112
%       Items (ID): {1,4}
% ------------
%  #|𝑤 |𝑝
% ------------
%  1|10  |100
%  2|7  |63
%  3|8  |56
%  4|4  |12
% ------------
allItems = [KPItem(100,10,1),...
            KPItem(63,7,2),...
            KPItem(56,8,3),...
            KPItem(12,4,4)];
toy02 = KPInstance(allItems, 16);


% Instance 3:
% ------------
% Capacity: 40
% ------------
% Best solution: 
%    Profit: 265
%    Items (ID): {1,2,3,4,5,8,10}
% ------------
% Solution given by heuristics:
%    Def
%       Profit: 195
%       Items (ID): {1,2,3,4,5,6,8}
%    MaP
%       Profit: 251
%       Items (ID): {10,8,2,1,7}
%    MiW
%       Profit: 191
%       Items (ID): {5,4,9,1,3,2,8}
%    MPW
%       Profit: 265
%       Items (ID): {1,5,10,8,2,3,4}
% ------------
%  #|𝑤 |𝑝
% ------------
%  1|4  |40
%  2|7  |42
%  3|5  |25
%  4|3  |12
%  5|1  |10
%  6|10 |10
%  7|11 |33
%  8|8  |56
%  9|3  |6 
%  10|10    |80
% ------------
allItems = [KPItem(40,4,1),...
            KPItem(42,7,2),...
            KPItem(25,5,3),...
            KPItem(12,3,4),...
            KPItem(10,1,5),...
            KPItem(10,10,6),...
            KPItem(33,11,7),...
            KPItem(56,8,8),...
            KPItem(6,3,9),...
            KPItem(80,10,10)];
toy03 = KPInstance(allItems, 40);

% Instance 4:
% ------------
% Capacity: 23
% ------------
% Best solution: 
%    Profit: 217
%    Items (ID): {1,3,8}
% ------------
% Solution given by heuristics:
%    Def
%       Profit: 171
%       Items (ID): {1,2,4}
%    MaP
%       Profit: 200
%       Items (ID): {1,5}
%    MiW
%       Profit: 131
%       Items (ID): {8,4,7,6}
%    MPW
%       Profit: 200
%       Items (ID): {1,5}
% ------------
%  #|𝑤 |𝑝
% ------------
%  1|10  |100
%  2|8  |56
%  3|9  |81
%  4|5  |15
%  5|10  |100
%  6|7 |35
%  7|5 |45
%  8|4  |36
% ------------
allItems = [KPItem(100,10,1),...
            KPItem(56,8,2),...
            KPItem(81,9,3),...
            KPItem(15,5,4),...
            KPItem(100,10,5),...
            KPItem(35,7,6),...
            KPItem(45,5,7),...
            KPItem(36,4,8)];
toy04 = KPInstance(allItems, 23);

%% Save instances
if toSave
    instanceKind = 'Toy\';
    save([matInstancePath instanceKind 'toy01.mat'],"toy01")
    save([matInstancePath instanceKind 'toy02.mat'],"toy02")
    save([matInstancePath instanceKind 'toy03.mat'],"toy03")
    save([matInstancePath instanceKind 'toy04.mat'],"toy04")
end