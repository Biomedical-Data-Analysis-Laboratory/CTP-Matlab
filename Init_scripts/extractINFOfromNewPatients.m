close all
warning('off','all')

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\Luca\';
USER = 'C:\Users\2921329\';
%% UNIX
if isunix 
    USER = "/home/stud/lucat/";
    folder = "/home/prosjekt/PerfusionCT/StrokeSUS/SUS2020_v2/"; % "/Users/lucatomasetti/Desktop/CTP_new parametric maps_17 patients/"; 
    register_folder = strcat(USER,"Matlab/" ); % "/Users/lucatomasetti/OneDrive - Universitetet i Stavanger/Luca/PhD/MATLAB_CODE/";
    workspaceFolder = strcat(register_folder, 'Workspace_1/');
    rawDataFolder = strcat(register_folder, 'Parametric_Maps/');
else 
    folder = 'D:\SUS2020_v2\';
    register_folder = 'D:\Preprocessed-SUS2020_v2\';
    workspaceFolder = strcat(register_folder, 'Workspace_RAW_TIFF/');
    rawDataFolder = strcat(register_folder, 'Parametric_Maps/');
end

patientsFolder = dir(fullfile(folder, '*/')); % */

if ~isfolder(rawDataFolder)
    mkdir(rawDataFolder);
end
if ~isfolder(workspaceFolder)
    mkdir(workspaceFolder);
end

% set the new matlab path and all its subfolders
addpath(genpath(strcat(register_folder,"REPOSITORY/")));

%% main function
getMAINinfo(patientsFolder,rawDataFolder,workspaceFolder)





