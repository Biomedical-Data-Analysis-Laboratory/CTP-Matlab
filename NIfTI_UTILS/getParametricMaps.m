close all
warning off

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS
USER = 'C:\Users\';
USER = strcat(USER, 'Luca\');
% USER = strcat(USER, '2921329\');

%% LOCAL SYSYEM
flag = 'TRAINING/'; % 'TESTING/'
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
folder = strcat(HOME, 'PhD/');
matlabFolder = strcat(folder, 'MATLAB_CODE/');
ISLES2018Folder = "D:/ISLES2018/";

args.directory = strcat(ISLES2018Folder, flag); 
args.patients = double(1:63);
args.saveRegisteredFolder = strcat(ISLES2018Folder, 'NEW_', flag);
args.workspaceFolder = strcat(matlabFolder, 'Workspace/'); 
args.groundTruth_folder = strcat(args.saveRegisteredFolder, 'Ground Truth/');

%% flags
args.save = 1;
args.isNIfTI = 1;
args.isISLES2018 = 1;
args.SAVE_INTERMEDIATE_STEPS = true;
args.previousPatients = 0;

args.folders_subnames = ["CBF", "CBV", "MTT", "Tmax", "OT"];
args.suffix_workspace = "_nifti_ISLES2018";

for subname_idx = 1:length(args.folders_subnames)
    subname = args.folders_subnames(subname_idx);
    images = extractNIfTIImagesISLES2018(args.directory, args.save, args.workspaceFolder, args.suffix_workspace, subname, 1, args.saveRegisteredFolder, args.groundTruth_folder);
%     saveRegisteredImages(images, args.saveRegisteredFolder, args.patients, "", args.previousPatients, 0);
end