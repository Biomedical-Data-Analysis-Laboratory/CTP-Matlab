close all
clc
warning off
%% -------------------------------------------------------------
%% WINDOWS
if ispc 
    USER = 'C:\Users\';
%     USER = strcat(USER, 'Luca\');
    USER = strcat(USER, '2921329\');
elseif isunix
    %% UNIX
    USER = "/home/stud/lucat/";
elseif ismac
    %% APPLE
    USER = '/Users/lucatomasetti/';
end
%% -------------------------------------------------------------
%% LOCAL VARIABLE SYSYEM
if isunix
    HOME = strcat(USER, "Matlab/");
else
    HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger\Luca\');
    folder = strcat(HOME, 'PhD\');
    matlabFolder = strcat(folder, 'MATLAB_CODE/');
end
%% -------------------------------------------------------------
%% Run patients in unix server
if isunix
% args.patients = double(17); 
% args.directory = "/home/prosjekt/PerfusionCT/StrokeSUS/SUS2020_v2/Without vessel occlusion/"; 
% args.annotatedImagesFolder = "";
% args.saveRegisteredFolder = strcat(HOME, 'FINAL_TIFF_HU_v2_NEW/');
% args.saveForVISUALFolder = strcat(HOME, 'FINAL_TIFF_HU_v1_NEW/');
% args.maskRegisteredFolder = strcat(HOME, 'MASK_HU_NEW/');
% args.workspaceFolder = strcat(HOME, 'Workspace/'); 
% args.finalSaveFolder = args.saveRegisteredFolder;
    
    args.patients = double(1:155); % [2,6,7,9]; 
    args.directory = "/home/prosjekt/PerfusionCT/";
    args.annotatedImagesFolder = "";
    PerfusionCT_folder = "/home/prosjekt/PerfusionCT/StrokeSUS/NORMALIZED_FRAMES_NEW/";
    args.saveImageRegisteredFolder = strcat(PerfusionCT_folder, 'IMAGE_REGISTERED/');
    args.saveContrastEnhancementFolder = strcat(PerfusionCT_folder, 'FINAL_Najm_');
    args.saveRegisteredFolder = strcat(PerfusionCT_folder, 'FINAL_Najm_v14/');
    args.saveForVISUALFolder = strcat(PerfusionCT_folder, 'FINAL_Najm_v13/');
    args.maskRegisteredFolder = strcat(PerfusionCT_folder, 'MASKS/');
    args.workspaceFolder = strcat(HOME, 'Workspace_NORM/'); 
    args.MRIFolder = strcat(args.directory, "StrokeSUS/DWI/FINAL_DWI/");
    args.finalSaveFolder = args.saveRegisteredFolder;
    args.suffix_workspace = "";
    args.newIDFormat = true; % false
    
    load(strcat(HOME, 'Workspace/', 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
    allInforCTP = struct2cell(allInfoValuesPERFUSIONCT5);
    args.DICOMfolders = allInforCTP(2,:); % 2=index of filename !!! 
% 
    %% remove patients not to use
    args.patients(129) = []; % 02_052
    args.patients(126) = []; % 02_049
    args.patients(123) = []; % 02_046
    args.patients(77) = []; % 01_077
    args.patients(54) = []; % 01_054
    
%% -------------------------------------------------------------
    %% ISLES 2018
% %     flag = 'TRAINING/'; % TESTING
% %     ISLES2018Folder = "/home/prosjekt/PerfusionCT/StrokeSUS/ISLES2018/";
% %     args.annotatedImagesFolder = "";
% %     args.directory = strcat(ISLES2018Folder, flag);
% %     args.patients = double(1:94); % 94/62 for training/testing
% %     args.additionalFlag = ""; % "_second" "_last"
% %     args.saveRegisteredFolder = strcat(ISLES2018Folder, 'Processed_', flag, "_test");
% %     args.saveForVISUALFolder = strcat(ISLES2018Folder, '_Processed_', flag, "_test");
% %     args.saveContrastEnhancementFolder = strcat(args.saveRegisteredFolder, 'FINAL_');
% %     args.workspaceFolder = strcat(ISLES2018Folder, 'Workspace_3/'); 
% %     args.finalSaveFolder = strcat(args.saveForVISUALFolder, "FINAL/");
% %     args.suffix_workspace = "_training"; %"_testing"
% %     args.isNIfTI = 1;
% %     args.isISLES2018 = 1;
% %     args.newIDFormat = false;
% %     args.MRIFolder = "";
% %     args.saveImageRegisteredFolder = "";
end

%% -------------------------------------------------------------
%% ORIGINAL 10 PATIENTS from the Mac
% args.patients = double(1:11);
% args.directory = strcat(USER, 'Desktop/uni-stavanger/PerfusionCT/');
% args.annotatedImagesFolder = ""; % strcat(USER, 'OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/');
% args.saveRegisteredFolder = strcat(folder, 'Patients/Registered_images/'); %strcat(matlabFolder, 'Registered_images_2/');
% args.workspaceFolder = strcat(matlabFolder, 'Workspace/'); 
% args.finalSaveFolder = strcat(args.saveRegisteredFolder, "FINAL/");
%% -------------------------------------------------------------
%% SUS 2020 (original 11 patients)
% args.patients = [7,9]; % [2,6,7,9]
% args.directory = 'D:\SUS2020\';
% register_folder = 'D:\Preprocessed-SUS2020_v2\';
% args.annotatedImagesFolder = "";
% args.saveRegisteredFolder = strcat(register_folder, 'Registered_images/');
% args.workspaceFolder = strcat(register_folder, 'Workspace_TIFF_RAW/'); %  'Workspace_TIFF/');
% args.finalSaveFolder = strcat(register_folder, "FINAL_TIFF_RAW/"); % "FINAL_TIFF/");
% args.suffix_workspace = "_old_patients";
%% -------------------------------------------------------------
%% SUS 2020_v2
if ispc  
    %% -------------------------------------------------------------
    %% ISLES 2018
%     flag = 'TESTING/'; % TRAINING
%     ISLES2018Folder = "D:/ISLES2018/";
%     args.annotatedImagesFolder = "";
%     args.directory = strcat(ISLES2018Folder, flag);
%     args.patients = double(1:62); % 94/62 for training/testing
%     args.additionalFlag = ""; % "_second" "_last"
%     args.saveRegisteredFolder = strcat(ISLES2018Folder, 'Processed_', flag);
%     args.saveForVISUALFolder = strcat(ISLES2018Folder, '_Processed_', flag);
%     args.saveContrastEnhancementFolder = strcat(args.saveRegisteredFolder, 'FINAL_');
%     args.workspaceFolder = strcat(ISLES2018Folder, 'Workspace_3/'); 
%     args.finalSaveFolder = strcat(args.saveForVISUALFolder, "FINAL/");
%     args.suffix_workspace = "_testing"; %"_testing"
%     args.isNIfTI = 1;
%     args.isISLES2018 = 1;
%     args.newIDFormat = false;
%     args.MRIFolder = "";
%     args.saveImageRegisteredFolder = "";
    %% -------------------------------------------------------------
    %% SUS 2020 (original 11 patients)
% % %     args.patients = [1]; 
% % %     args.directory = 'D:\SUS2020_v2\';
% % %     register_folder = 'D:\Preprocessed-SUS2020_v2\TEST\';
% % %     args.annotatedImagesFolder = "";
% % %     args.saveImageRegisteredFolder = strcat(register_folder, 'IMAGE_REGISTERED/');
% % %     args.saveContrastEnhancementFolder = strcat(register_folder, 'TEST_v0/');
% % %     args.saveRegisteredFolder = strcat(register_folder, 'TEST_v2/');
% % %     args.saveForVISUALFolder = strcat(register_folder, 'TEST_v1/');
% % %     args.maskRegisteredFolder = strcat(register_folder, 'MASK_HU_NEW/');
% % %     args.workspaceFolder = strcat(register_folder, 'Workspace_RAW_TIFF/'); %  'Workspace_TIFF/');
% % %     args.MRIFolder = strcat(register_folder, "FINAL_DWI/");
% % %     args.finalSaveFolder = args.saveRegisteredFolder; 
% % %     args.suffix_workspace = "";
% % %     
% % % %     args.patients = 1:152; 
% % %     load(strcat(args.workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
% % %     allInforCTP = struct2cell(allInfoValuesPERFUSIONCT5);
% % %     args.DICOMfolders = allInforCTP(2,:); % 2=index of filename !!! 
% % % 
% % %     args.newIDFormat = true;
% % %     args.isFAKE = false;
    %% -------------------------------------------------------------
    %% -------------------------------------------------------------
    %% SUS 2020 (original 11 patients)
    args.patients = [7,9]; %[14,38,46,88]; 
    args.directory = 'D:\SUS2019\'; % 'D:\SUS2020_v2\';
    register_folder = 'D:\NORMALIZED_NEW\'; % 'D:\GAN\'; 

    % args.patients = [1]; %[14,38,46,88]; 
    % args.directory = 'D:\GAN\Dataset\';
    % register_folder = 'D:\GAN\'; 
    % args.isFAKE = true;
    
%     register_folder = strcat(folder,'master thesis GANs\Processed\');
    args.annotatedImagesFolder = "";
    args.saveImageRegisteredFolder = strcat(register_folder, 'IMAGE_REGISTERED/');
    args.saveContrastEnhancementFolder = strcat(register_folder, 'TEST_v0/');
    args.saveRegisteredFolder = strcat(register_folder, 'TEST_v2/');
    args.saveForVISUALFolder = strcat(register_folder, 'TEST_v1/');
    args.maskRegisteredFolder = strcat(register_folder, 'MASK_HU_NEW/');
    args.workspaceFolder = strcat(register_folder, 'Workspace/'); %  'Workspace_TIFF/');
    args.MRIFolder = strcat(register_folder, "FINAL_DWI/");
    args.finalSaveFolder = args.saveRegisteredFolder; 
    args.suffix_workspace = "";
    
% %     load(strcat(args.workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
% %     allInforCTP = struct2cell(allInfoValuesPERFUSIONCT5);
% %     args.DICOMfolders = allInforCTP(2,:); % 2=index of filename !!! 

    args.newIDFormat = false;
end

%% -------------------------------------------------------------
%% flag
args.INITIAL_STEP = 1;
args.save = 1;
args.SAVE_INTERMEDIATE_STEPS = false;
args.SAVE_AS_TIFF = true;
args.NEW_SKULLSTRIPPING = true;

%% careful with ALL of these!!
args.CROP_VALUES = false;
args.NO_REGISTRATION = false;
args.CONVERT_TO_HU = true;
args.CONVERT_TO_DOUBLE = true;
args.OLD_PREPROC_STEPS = false;
args.CONSTRASTENHANCEMENT = true;
args.IMGADJUST = [0,1];
args.GAMMA = [0.5];
args.HISTEQ = [0,1]; 
args.ZSCORE = [0];

%% -------------------------------------------------------------
%% create folders, if necessary
if ~isfolder(args.saveRegisteredFolder)
    mkdir(args.saveRegisteredFolder)
end

if isunix
    % set the new matlab path and all its subfolders
    addpath(genpath(strcat(HOME, "REPOSITORY/")));
    addpath(args.saveRegisteredFolder);
    addpath(args.saveForVISUALFolder);
    if isfield(args, "maskRegisteredFolder")
        addpath(args.maskRegisteredFolder);
    end
    addpath(args.workspaceFolder);
end
%% -------------------------------------------------------------
%% start!
MAIN_PREPROCESSING(args);

%% use to plot the timepoints
% plotTimePoints(args);
