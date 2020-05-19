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
function MAIN_PREPROCESSING(args)
    %% 0 - Arguments 
    directory = args.directory; % Directory of the images
    patients = args.patients; % Array of patients to process
    annotatedImagesFolder = args.annotatedImagesFolder; % Directory of the annotated images
    saveRegisteredFolder = args.saveRegisteredFolder; % Directory for saving the final registered images
    workspaceFolder = args.workspaceFolder; % Directory to save and load the workspaces
    previousNumPatiens = 0;
    INITIAL_STEP = args.INITIAL_STEP; % start from this step!
    %% flags
    ISLISTOFDIR = 0; 
    SAVE = args.save; % Save the workspace? (1=yes, 0=no)
    isNIfTI = 0; % flag for the NIfTI format
    isISLES2018 = 0; % flag for the ISLES2018 dataset
    newIDFormat = false;
    SAVE_INTERMEDIATE_STEPS = args.SAVE_INTERMEDIATE_STEPS; % flag to save the intermediate steps and to load the intermediate images if they are already saved
    suffix_workspace = "";
    
    %% optional field
    if isfield(args, 'isNIfTI')
        isNIfTI = args.isNIfTI;
    end
    if isfield(args, 'isISLES2018')
        isISLES2018 = args.isISLES2018;
    end
    if isfield(args, 'newIDFormat')
        newIDFormat = args.newIDFormat;
    end
    if isfield(args, "DICOMfolders") % var containing the folderS with the DICOM images (extracted with extractINFOfromNewPatients.m
        directory = args.DICOMfolders;
        ISLISTOFDIR = 1;
    end
    if isfield(args, "previousNumPatiens") % var containing the number of patients to add when creating the new folders
        previousNumPatiens = args.previousNumPatiens;
    end
    if isNIfTI
        suffix_workspace = suffix_workspace + "_nifti";
    end
    if isISLES2018
        suffix_workspace = suffix_workspace+ "_ISLES2018";
    end
    %% -------------------------------------------------------------
    mkdir(workspaceFolder)
    %% 1 - Rearrange the images of all the patients
    if INITIAL_STEP >= 1
        if ~isNIfTI
            disp("Rearrange images...");
            tic
            if INITIAL_STEP == 1
                INITIAL_STEP = INITIAL_STEP + 1;
                if exist(strcat(workspaceFolder, 'Image', suffix_workspace, '.mat'), 'file') == 2
                    load(strcat(workspaceFolder, 'Image', suffix_workspace, '.mat'));
                else
                    Image = rearrangeImages(directory, ISLISTOFDIR, patients, SAVE, workspaceFolder, suffix_workspace);

                    if SAVE_INTERMEDIATE_STEPS
                        suffix = "01_orig";
                        saveRegisteredImages(Image, saveRegisteredFolder, patients, suffix, previousNumPatiens, newIDFormat, directory);
                    end
                end
            end

            toc

            %% -------------------------------------------------------------
            %% 2 - Image regitration
            if INITIAL_STEP == 2
                INITIAL_STEP = INITIAL_STEP + 1;
                disp("Register images...");
                tic     
                if exist('ImageRegistered','var')==0 && exist(strcat(workspaceFolder, 'ImageRegistered', suffix_workspace, '.mat'), 'file') == 2
                    load(strcat(workspaceFolder, 'ImageRegistered', suffix_workspace, '.mat'))
                else
                    ImageRegistered = reg_ct(directory, ISLISTOFDIR, Image, patients, 1, SAVE, workspaceFolder, '', suffix_workspace);

                    if SAVE_INTERMEDIATE_STEPS
                        suffix = "02_registration";
                        saveRegisteredImages(ImageRegistered, saveRegisteredFolder, patients, suffix, previousNumPatiens, newIDFormat, directory);
                    end
                end
                toc
            end
        end % only if the images are in DICOM format
    end
    %% -------------------------------------------------------------
    %% 3 - Skull removal
    if INITIAL_STEP == 3
        INITIAL_STEP = INITIAL_STEP +0.5;
        disp("Remove skulls...");
        tic

        thold = 9;
        if isNIfTI && isISLES2018
            if exist(strcat(workspaceFolder, 'Image', suffix_workspace, '_4dPWI.mat'), 'file') == 2
                load(strcat(workspaceFolder, 'Image', suffix_workspace, '_4dPWI.mat'))
            else
                ImageRegistered = extractNIfTIImagesISLES2018(directory, SAVE, workspaceFolder, suffix_workspace, "4DPWI");

                if SAVE_INTERMEDIATE_STEPS
                    suffix = "01_orig";
                    saveRegisteredImages(ImageRegistered, saveRegisteredFolder, patients, suffix, previousNumPatiens, newIDFormat, directory);
                end
            end
        end
    % %     load(strcat(workspaceFolder, 'ImageRegistered', suffix_workspace, '.mat'));
    % %     tmpImgReg = load(strcat(workspaceFolder, 'ImageRegistered_newp', suffix_workspace, '.mat'));
    % %     tmpImgReg = tmpImgReg.ImageRegistered(~cellfun('isempty',tmpImgReg.ImageRegistered));
    % %     ImageRegistered = cat(2, ImageRegistered, tmpImgReg);

        %% various skull removal technique...
        if exist('ImageSkullRemoved','var')==0 && exist(strcat(workspaceFolder, 'ImageSkullRemoved', suffix_workspace, '.mat'), 'file') == 2
            load(strcat(workspaceFolder, 'ImageSkullRemoved', suffix_workspace, '.mat'))
        else
            ImageSkullRemoved = combinedTechniquesSkullRemoval(ImageRegistered, thold, patients, SAVE, workspaceFolder, suffix_workspace);
    % %         ImageSkullRemoved = anotherSkullRemovalTechnique(ImageRegistered, patients, SAVE, workspaceFolder);
    % %         ImageSkullRemoved = generalSkullRemoval(ImageRegistered, patients, SAVE, workspaceFolder);
            if SAVE_INTERMEDIATE_STEPS
                suffix = "03_skullremoval";
                saveRegisteredImages(ImageSkullRemoved, saveRegisteredFolder, patients, suffix, previousNumPatiens, newIDFormat, directory);
            end
        end
        toc
    end
    
    %% -------------------------------------------------------------
    %% 3.5 - Improve the brain images
    if INITIAL_STEP == 3.5
        INITIAL_STEP = INITIAL_STEP + 0.5;
        disp("Contrast enhancement...");
        tic
        if exist('ImageSkullRemovedFiltered','var')==0 && exist(strcat(workspaceFolder, 'ImageSkullRemovedFiltered', suffix_workspace, '.mat'), 'file') == 2
            load(strcat(workspaceFolder, 'ImageSkullRemovedFiltered', suffix_workspace, '.mat'));
        else
            ImageSkullRemovedFiltered = improveImagesSkullRemoved(ImageSkullRemoved, patients, SAVE, workspaceFolder, suffix_workspace, SAVE_INTERMEDIATE_STEPS, saveRegisteredFolder, previousNumPatiens);
        end
        toc
    end
    %% -------------------------------------------------------------
    %% 4&5 - Image registration with the images without skull and the manually annotated images.
    if INITIAL_STEP == 4 || INITIAL_STEP == 5
        INITIAL_STEP = 6;
        disp("Register images again with manual annotations...");
        tic
        if exist('ImageSkullRemovedFiltered','var')==0 && exist(strcat(workspaceFolder, 'ImageSkullRemovedFiltered', suffix_workspace, '.mat'), 'file') == 2
            load(strcat(workspaceFolder, 'ImageSkullRemovedFiltered', suffix_workspace, '.mat'));
        end

        if annotatedImagesFolder ~= ""
            NewImageRegistered = registerAnnotated(directory, ISLISTOFDIR, ImageSkullRemovedFiltered, annotatedImagesFolder, patients, SAVE, workspaceFolder, suffix_workspace);
        else 
            NewImageRegistered = ImageSkullRemovedFiltered;
        end
        toc
    end
    %% -------------------------------------------------------------
    %% 6 - Save the images
    if INITIAL_STEP == 6
        disp("Save images...");
        tic

        if annotatedImagesFolder ~= "" && exist('NewImageRegistered','var')==0 && exist(strcat(workspaceFolder, 'NewImageRegistered', suffix_workspace, '.mat'), 'file') == 2
            load(strcat(workspaceFolder, 'NewImageRegistered', suffix_workspace, '.mat'));
        end

        suffix = "";
        if isfield(args, 'finalSaveFolder')
            saveRegisteredFolder = args.finalSaveFolder;
            mkdir(saveRegisteredFolder)
        end

        saveRegisteredImages(NewImageRegistered, saveRegisteredFolder, patients, suffix, previousNumPatiens, newIDFormat, directory);
        toc 
    end
end
