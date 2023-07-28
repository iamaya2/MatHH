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
%  #|𝑤 |𝑝
% ------------
%  1|4  |40
%  2|7  |42
%  3|5  |25
%  4|3  |12
allItems = [KPItem(40,4,1),...
            KPItem(42,7,2),...
            KPItem(25,5,3),...
            KPItem(12,3,4)];
toy01 = KPInstance(allItems, 10);

% Instance 2:
% ------------
%  #|𝑤 |𝑝
% ------------
%  1|10  |100
%  2|7  |63
%  3|8  |56
%  4|4  |12
allItems = [KPItem(100,10,1),...
            KPItem(63,7,2),...
            KPItem(56,8,3),...
            KPItem(12,4,4)];
toy02 = KPInstance(allItems, 16);

%% Save instances
if toSave
    instanceKind = 'Toy\';
    save([matInstancePath instanceKind 'Toy01.mat'],"toy01")
    save([matInstancePath instanceKind 'Toy02.mat'],"toy02")
end