%% File for manually generating instances
%% Cleanup
clc
clear
close all

%% Loads required packages
basepath = '..\..\..\';
addpath(basepath); % Adds root folder (without subfolders)
addpath([basepath 'extended\Domains\']); % Adds common domain classes (abstract)
addpath(genpath([basepath 'extended\Domains\KP'])); % Adds KP domain functionality
addpath(genpath([basepath 'extended\Utils'])); % Adds assorted utilities

%% Toy instances from PPT about HHs
% Instance 1