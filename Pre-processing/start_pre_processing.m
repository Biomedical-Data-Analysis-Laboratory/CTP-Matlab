close all
warning off
%% -------------------------------------------------------------
%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS
USER = 'C:\Users\';
USER = strcat(USER, 'Luca\');
% USER = strcat(USER, '2921329\');
%% -------------------------------------------------------------
%% LOCAL VARIABLE SYSYEM
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
folder = strcat(HOME, 'PhD/');
matlabFolder = strcat(folder, 'MATLAB_CODE/');
%% -------------------------------------------------------------
%% ORIGINAL 10 PATIENTS
% args.patients = double(1:11);
% args.directory = strcat(USER, 'Desktop/uni-stavanger/PerfusionCT/');
% args.annotatedImagesFolder = ""; % strcat(USER, 'OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/');
% args.saveRegisteredFolder = strcat(folder, 'Patients/Registered_images/'); %strcat(matlabFolder, 'Registered_images_2/');
% args.workspaceFolder = strcat(matlabFolder, 'Workspace/'); 
% args.finalSaveFolder = strcat(args.saveRegisteredFolder, "FINAL/");
%% -------------------------------------------------------------
%% ISLES 2018
% flag = 'TESTING/'; % 'TRAINING/'
% ISLES2018Folder = strcat(USER, 'Desktop/ISLES2018/');
% args.directory = strcat(ISLES2018Folder, flag);
% args.patients = double(1:62); % 94 for training
% args.annotatedImagesFolder = "";
% args.saveRegisteredFolder = strcat(ISLES2018Folder, 'NEW_', flag);
% args.workspaceFolder = strcat(matlabFolder, 'Workspace/'); 
% args.finalSaveFolder = strcat(args.saveRegisteredFolder, "FINAL/");
% args.isNIfTI = 1;
% args.isISLES2018 = 1;
%% -------------------------------------------------------------
%% SUS 2020
% args.patients = double(100:132); % double(1:132);
% args.directory = 'D:\';
% register_folder = strcat(USER, 'Desktop\SUS2020\');
% args.annotatedImagesFolder = "";
% args.saveRegisteredFolder = strcat(register_folder, 'Registered_images/');
% args.workspaceFolder = strcat(register_folder, 'Workspaces/');
% load(strcat(args.workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
% allInforCTP = struct2cell(allInfoValuesPERFUSIONCT5);
% args.DICOMfolders = allInforCTP(2,:); % 2=index of filename !!! 
% args.finalSaveFolder = strcat(register_folder, "FINAL/");
% args.previousNumPatiens = 11;
%% -------------------------------------------------------------
%% SUS 2020_v2
args.patients = [22,44,64,65,66,68,69,71,72,73,74,111,116,118,120,122,123,124,125,126,140];
args.directory = 'D:\SUS2020_v2\';
register_folder = strcat(USER, 'Desktop\SUS2020_v2\');
args.annotatedImagesFolder = "";
args.saveRegisteredFolder = strcat(register_folder, 'Registered_images/');
args.workspaceFolder = strcat(register_folder, 'Workspace/');
load(strcat(args.workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
allInforCTP = struct2cell(allInfoValuesPERFUSIONCT5);
args.DICOMfolders = allInforCTP(2,:); % 2=index of filename !!! 
args.finalSaveFolder = strcat(register_folder, "FINAL/");
args.newIDFormat = true;

%% -------------------------------------------------------------
%% flags
args.INITIAL_STEP = 2;
args.save = 1;
args.SAVE_INTERMEDIATE_STEPS = false;
%% -------------------------------------------------------------
%% create folders, if necessary
mkdir(args.saveRegisteredFolder)
%% -------------------------------------------------------------
%% start!
MAIN_PREPROCESSING(args);
