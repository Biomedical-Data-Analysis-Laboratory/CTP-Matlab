%% -------------------------------------
%% INITIALIZE PRE_PROCESSING: 
% 1) Rearrange the images
% 2) Register the images
% 3) Remove the skull
% 3.5) Improve the brain images
% 4) Get the manually annotated images 
% 5) Register the images again (including the manually annotated images)
% 6) Save the images
%% -------------------------------------
function output = MAIN_PREPROCESSING(args)
    %% 0 - Arguments 
    directory = args.directory; % Directory of the images
    ISLISTOFDIR = 0; 
    patients = args.patients; % Array of patients to process
    annotatedImagesFolder = args.annotatedImagesFolder; % Directory of the annotated images
    SAVE = args.save; % Save the workspace? (1=yes, 0=no)
    saveRegisteredFolder = args.saveRegisteredFolder; % Directory for saving the final registered images
    workspaceFolder = args.workspaceFolder; % Directory to save and load the workspaces
    
    if isfield(args, "DICOMfolders")
        directory = args.DICOMfolders;
        ISLISTOFDIR = 1;
    end
        
    mkdir(workspaceFolder)
    
    %% 1 - Rearrange the images of all the patients
    Image = rearrangeImages(directory, ISLISTOFDIR, patients, SAVE, workspaceFolder);
%     %% 2 - Image regitration
% %    load(strcat(workspaceFolder, 'Image.mat'));
%     ImageRegistered = reg_ct(Image, patients, 1, SAVE, workspaceFolder, '');
%     %% 3 - Skull removal 
    load(strcat(workspaceFolder, 'ImageRegistered.mat'));
    tmpImgReg = load(strcat(workspaceFolder, 'ImageRegistered_newp.mat'));
    tmpImgReg = tmpImgReg.ImageRegistered(~cellfun('isempty',tmpImgReg.ImageRegistered));
    ImageRegistered = cat(2, ImageRegistered, tmpImgReg);
     ImageSkullRemoved = combinedTechniquesSkullRemoval(ImageRegistered, patients, SAVE, workspaceFolder);
%     ImageSkullRemoved = anotherSkullRemovalTechnique(ImageRegistered, patients, SAVE, workspaceFolder);
%     ImageSkullRemoved = generalSkullRemoval(ImageRegistered, patients, SAVE, workspaceFolder);
%     %% 3.5 - Improve the brain images
%       load(strcat(workspaceFolder, 'ImageSkullRemoved.mat'));
    ImageSkullRemovedFiltered = improveImagesSkullRemoved(ImageSkullRemoved, patients, SAVE, workspaceFolder);
%     %% 4&5 - Image registration with the images without skull and the manually annotated images.
%     load(strcat(workspaceFolder, 'ImageSkullRemovedFiltered.mat'));
%     if annotatedImagesFolder ~= ""
%         NewImageRegistered = registerAnnotated(ImageSkullRemovedFiltered, annotatedImagesFolder, patients, SAVE, workspaceFolder);
%     else 
        NewImageRegistered = ImageSkullRemovedFiltered;
%     end
    %% 6 - Save the images
%     load(strcat(workspaceFolder, 'NewImageRegistered.mat'));
    saveRegisteredImages(NewImageRegistered, saveRegisteredFolder, patients);

    output = 1;
end
