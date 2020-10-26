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
%% ORIGINAL 10 PATIENTS from the Mac
% args.patients = double(1:11);
% args.directory = strcat(USER, 'Desktop/uni-stavanger/PerfusionCT/');
% args.annotatedImagesFolder = ""; % strcat(USER, 'OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/');
% args.saveRegisteredFolder = strcat(folder, 'Patients/Registered_images/'); %strcat(matlabFolder, 'Registered_images_2/');
% args.workspaceFolder = strcat(matlabFolder, 'Workspace/'); 
% args.finalSaveFolder = strcat(args.saveRegisteredFolder, "FINAL/");
%% -------------------------------------------------------------
%% ISLES 2018
% flag = 'TRAINING/'; % TESTING
% ISLES2018Folder = "D:/ISLES2018/";
% args.directory = strcat(ISLES2018Folder, flag);
% args.patients = double(80:94); % 94/62 for training/testing
% args.additionalFlag = "_last"; % "_second" "_last"
% args.saveRegisteredFolder = strcat(ISLES2018Folder, 'NEW_', flag);
% args.workspaceFolder = strcat(ISLES2018Folder, 'Workspace/'); 
% args.finalSaveFolder = strcat(args.saveRegisteredFolder, "FINAL_TIFF/");
% args.suffix_workspace = ""; % "_testing";
% args.isNIfTI = 1;
% args.isISLES2018 = 1;
% args.newIDFormat = false;
%% -------------------------------------------------------------
%% SUS 2020 (original 11 patients
% args.patients = [6]; 
% args.directory = 'D:\SUS2020\';
% register_folder = 'D:\Preprocessed-SUS2020_v2\';
% args.annotatedImagesFolder = "";
% args.saveRegisteredFolder = strcat(register_folder, 'Registered_images/');
% args.workspaceFolder = strcat(register_folder, 'Workspace_TIFF/'); 
% args.finalSaveFolder = strcat(register_folder, "FINAL_TIFF/");
% args.suffix_workspace = "_old_patients";
%% -------------------------------------------------------------
%% SUS 2020_v2
args.patients = 105; %double(1:155); 
args.directory = 'D:\SUS2020_v2\';
register_folder = 'D:\Preprocessed-SUS2020_v2\';
args.annotatedImagesFolder = "";
args.saveRegisteredFolder = strcat(register_folder, 'Registered_images/');

% args.workspaceFolder = strcat(register_folder, 'Workspace/');
% args.workspaceFolder = strcat(register_folder, 'Workspace_v02/');
args.workspaceFolder = strcat(register_folder, 'Workspace_TIFF/');

load(strcat(args.workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
allInforCTP = struct2cell(allInfoValuesPERFUSIONCT5);
args.DICOMfolders = allInforCTP(2,:); % 2=index of filename !!! 

% args.finalSaveFolder = strcat(register_folder, "FINAL/");
% args.finalSaveFolder = strcat(register_folder, "FINAL_v02/");
args.finalSaveFolder = strcat(register_folder, "FINAL_TIFF/");
args.suffix_workspace = "";
args.newIDFormat = true;

%% -------------------------------------------------------------
%% flag
args.INITIAL_STEP = 3; % start from 3 for the nifti format
args.save = 1;
args.SAVE_INTERMEDIATE_STEPS = false;
args.SAVE_AS_TIFF = true;
% careful with this!
args.OLD_PREPROC_STEPS = false;

%% -------------------------------------------------------------
%% create folders, if necessary
mkdir(args.saveRegisteredFolder)
%% -------------------------------------------------------------
%% start!
% MAIN_PREPROCESSING(args);

%% use to plot the timepoints
plotTimePoints(args);
