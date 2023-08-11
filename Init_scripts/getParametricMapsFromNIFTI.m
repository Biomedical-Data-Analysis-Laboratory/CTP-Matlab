clear;
close all force;

%% LOCAL SYSYEM
flag = 'TESTING/'; % TESTING
ISLES2018Folder = "D:/ISLES2018/";

args.directory = strcat(ISLES2018Folder, flag); 
args.patients = double(1:62);
args.saveRegisteredFolder = strcat(ISLES2018Folder, 'Processed_', flag); % "NEW_"
args.workspaceFolder = strcat(ISLES2018Folder, 'Workspace_2/'); 
args.groundTruth_folder = "" ; % strcat(args.saveRegisteredFolder, 'Binary_Ground_Truth/'); %strcat(args.saveRegisteredFolder, 'Binary_Ground_Truth/'); % strcat(args.saveRegisteredFolder, 'Manual_annotations/');

%% flags
args.save = 0;
args.isNIfTI = 1;
args.isISLES2018 = 1;
args.justinfo = 0;
args.previousPatients = 0;
args.SAVE_AS_TIFF = true;
args.BINARY_GT = false; % to save the ground truth as binary images
args.overrideJump = true;

args.folders_subnames = "4DPWI"; % ["CT.", "CBF", "CBV", "MTT", "Tmax", "OT"];
args.suffix_workspace = "_nifti_ISLES2018_PM";

if strcmp(flag,'TESTING/')
    args.suffix_workspace = strcat(args.suffix_workspace, '_testing');
end

for subname_idx = 1:length(args.folders_subnames)
    subname = args.folders_subnames(subname_idx);
    images = extractNIfTIImagesISLES2018(args.directory, args.save, args.workspaceFolder, ...
        args.suffix_workspace, subname, 1, args.saveRegisteredFolder, args.groundTruth_folder, ...
        args.justinfo, args.SAVE_AS_TIFF, args.BINARY_GT, args.overrideJump);
%     saveRegisteredImages(images, args.saveRegisteredFolder, args.patients, "", args.previousPatients, 0);
end