function NewImageRegistered = registerAnnotated(imageToRegister, annotatedImagesFolder, patients, SAVE, workspaceFolder)
%REGISTERANNOTATED 
%   Function to register the DICOM images, with the addition of the
%   manually annotated image.
    for patient=patients
        if patient < 12 % only 11 manual annotation patients
            if patient<10
                folderPath = ([annotatedImagesFolder '/Patient0' num2str(patient)]);
            else
                folderPath = ([annotatedImagesFolder '/Patient' num2str(patient)]);
            end

            elements = dir(folderPath);
            imagesName = {elements.name}';
            imagesName(ismember(imagesName,{'.','..', '.DS_Store'})) = [];

            for slice=1:numel(imagesName)
                annotatedImageColor = imread([folderPath '/' char(imagesName(slice))]);
                annotatedImageGray = uint16(rgb2gray(annotatedImageColor));

                % Crop the manually annotated image in order to have the same
                % size of the DICOM images
                [h, w] = size(imageToRegister{patient}{slice}{1});
                if h~=512 && w~=512
                    [oh, ow] = size(annotatedImageGray);
                    ratioH = oh/h;
                    annotatedImageGray = imresize(annotatedImageGray, [oh/ratioH ow/ratioH]);
                    annotatedImageGray = imcrop(annotatedImageGray, [floor((ow/ratioH - 512)/2) 0 w-1 (oh/ratioH)]);
                end

                % Insert the manually annotated image in the first posi
                imageToRegister{patient}{slice} = [{annotatedImageGray} imageToRegister{patient}{slice}];
            end     
        end
    end

    if SAVE
        save(strcat(workspaceFolder, 'NewImageSkullRemoved.mat'),'imageToRegister','-v7.3');
    end

    % Register the manually annotated images + the images without the skull
    NewImageRegistered = reg_ct(imageToRegister, patients, 0, SAVE, workspaceFolder, '_new');
    if SAVE
        save(strcat(workspaceFolder, 'NewImageRegistered.mat'),'NewImageRegistered','-v7.3');
    end
end

