%% KP_instanceConverter - File converter for the KP domain
% This file can be used to read base txt files and transform them into
% usable KPInstance objects so that they can be used with the framework
%% Cleanup
% clc
clear
close all
%% Paths and general variables
% Common data
basepath = '..\..\..\';
matInstancePath = [basepath '..\..\BaseInstances\Knapsack\files\mat\'];
txtInstancePath = [basepath '..\..\BaseInstances\Knapsack\files\txt\'];
toSave = true; % Flag for defining if instances will be stored on disk
toBruteForce = true; % Flag for defining if instance must be brute-forced 

% Dataset-specific data
% Brute-forceable (for debugging and testing)
allDatasets = {...
                'Kreher';
               };

% % Brute-forceable (use Alienware since it will take quite some time)
% allDatasets = {'GA_Generated';...
%                 'Kreher';
%                 'LowDim';...
%                 'Mix50\Test1';...
%                 'Mix50\Test2';
%                 'Mix50\Training';
%                 'Pisinger_Hard\20';
%                 'Random'};
%
% Not brute-forceable (due to size)
% allDatasets = {'Pisinger_Hard\50';
%                 'Pisinger_Hard\100';
%                 'Pisinger_Hard\200'};

%% Loads required packages
addpath(basepath); % Adds root folder (without subfolders)
addpath([basepath 'extended\Domains\']); % Adds common domain classes (abstract)
addpath(genpath([basepath 'extended\Domains\KP'])); % Adds KP domain functionality
addpath(genpath([basepath 'extended\Utils'])); % Adds assorted utilities

%% Main process
for idx = 1:length(allDatasets)
    thisDataset = allDatasets{idx};
    fprintf('Processing %s dataset... ', thisDataset)
    allFiles = readInstanceFolder([txtInstancePath thisDataset '\']);
    nbFiles = length(allFiles);
    fprintf('Done! Found %d instances...\n', nbFiles)
    allInstances = cell(1,nbFiles); % Allocate memory
    for idy = 1 : nbFiles
        fprintf('\tConverting instance %d/%d... ', idy, nbFiles)
        thisFile = allFiles{idy};
        allInstances{idy} = processInstance([txtInstancePath ...
                                            thisDataset '\' thisFile]);        
        fprintf('Done!\n')
    end
    
        % Brute-force instances
    if toBruteForce
        bestSolutionPerInstance = KP_instanceBruteForceSolver(allInstances);    
        for idy = 1 : nbFiles
            allInstances{idy}.bestSolution = bestSolutionPerInstance(idy);
        end
    end

    % Save instances
    if toSave  
        fullSavingPath = [matInstancePath thisDataset];
        fprintf('Saving %s dataset...\n', thisDataset)
        testSearch = dir(fullSavingPath);
        if isempty(testSearch)
            fprintf('\tFolder %s does not exist! Creating folder ... ', thisDataset)
            mkdir(fullSavingPath); % Creates folder if necessary
            fprintf('Success!\n')
        end
        save([fullSavingPath '\instanceDataset.mat'],"allInstances");        
        fprintf('Saving complete!\n')
    end
end

%% Extra functions
% Instance processor
function instanceObject = processInstance(instanceFilename)    
    rawData = readmatrix(instanceFilename, 'FileType','text');
    nbItems = rawData(1,1);
    kpCapacity = rawData(1,2);
    itemData = rawData(2:end,:); % c1 = weight; c2 = profit
    allItems(nbItems) = KPItem(itemData(end,2), itemData(end,1), nbItems);
    for idx = 1 : nbItems-1
        allItems(idx) = KPItem(itemData(idx,2), itemData(idx,1), idx);
    end
    instanceObject = KPInstance(allItems, kpCapacity);
end

% Dir reader
function allFilenames = readInstanceFolder(folderPath)
    rawFilenames = dir(folderPath);
    usableFilenames = rawFilenames(3:end);
    allFilenames = {usableFilenames.name};
end
