close all
warning('off','all')

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\Luca\';

folder = 'D:\SUS2020_v2\';
register_folder = 'D:\Preprocessed-SUS2020_v2\';
patientsFolder = dir(fullfile(folder, '*/'));
workspaceFolder = strcat(register_folder, 'Workspace_2/');
rawDataFolder = strcat(register_folder, 'Parametric_Maps/');

if ~isfolder(rawDataFolder)
    mkdir(rawDataFolder);
end
if ~isfolder(workspaceFolder)
    mkdir(workspaceFolder);
end

%% main function
getMAINinfo(patientsFolder,rawDataFolder,workspaceFolder)




