clc
clear 
close all

%% Loads required packages
addpath('..\..\..\'); % Adds root folder (without subfolders)
addpath(genpath('..\..\Domains\')); % Adds all domains functionality
addpath(genpath('..\..\Utils')); % Adds assorted utilities

%% Folders to process
basePath = '..\..\..\..\..\BaseInstances\BalancedPartition\files\csv\Random\';
allFolder = {[basePath '5Elements\2Bits\'];...
                [basePath '5Elements\8Bits\'];...
                [basePath '25Elements\4Bits\'];...
                [basePath '25Elements\25Bits\'];...
                [basePath '25Elements\50Bits\'];...
                [basePath '40Elements\4Bits\'];...
                [basePath '40Elements\25Bits\'];...
                [basePath '40Elements\50Bits\'];...
                [basePath '100Elements\10Bits\']...
                };

%% Main code
nbFolders = length(allFolder);
for idx = 1 : nbFolders
    thisFolder = allFolder{idx};
    generateInstanceFromCSV(thisFolder);
end
fprintf('\nAll done!\n')