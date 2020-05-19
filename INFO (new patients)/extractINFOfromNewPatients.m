close all
warning('off','all')

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\Luca\';

folder = strcat(USER,'Documents\SUS2020\');
register_folder = strcat(USER, 'Desktop\SUS2020\');
patientsFolder = dir(fullfile(folder, '*/'));
workspaceFolder = strcat(register_folder, 'Workspaces/');
rawDataFolder = strcat(register_folder, 'Parametric_Maps/');

mkdir(rawDataFolder);
mkdir(workspaceFolder);

%% main function
getMAINinfo(patientsFolder,rawDataFolder,workspaceFolder)




