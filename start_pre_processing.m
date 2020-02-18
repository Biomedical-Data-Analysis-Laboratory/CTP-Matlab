close all
warning off

%% UNIX SYSTEM
% root_folder = '/home/stud/lucat/';
% 
% args.directory = strcat(root_folder, 'Patients/');
% args.patients = double(2:11);
% args.annotatedImagesFolder = strcat(root_folder, 'CT_perfusion_markering_processed/CROPPED/');
% args.save = 1;
% args.saveRegisteredFolder = strcat(root_folder, 'Registered_images_3.0/');
% args.workspaceFolder = strcat(root_folder, 'Workspaces/');

%% APPLE
USER = '/Users/lucatomasetti/';
%% WINDOWS
% USER = 'C:\Users\';
% USER = strcat(USER, '2921329\');

%% LOCAL SYSYEM
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
folder = strcat(HOME, 'PhD/');
matlabFolder = strcat(folder, 'MATLAB_CODE/');
%args.directory = strcat(folder, 'Patients/');
args.directory = strcat(USER, 'Desktop/uni-stavanger/PerfusionCT/');
args.patients = double(1:16);
% args.annotatedImagesFolder = ""; 
args.annotatedImagesFolder = strcat(USER, 'Desktop/uni-stavanger/CT_perfusion_markering_processed/CROPPED/');
args.save = 1;
args.saveRegisteredFolder = strcat(USER, 'Desktop/Registered_images/'); %strcat(matlabFolder, 'Registered_images_2/');
args.workspaceFolder = strcat(matlabFolder, 'Workspace/'); 

mkdir(args.saveRegisteredFolder)

MAIN_PREPROCESSING(args);
