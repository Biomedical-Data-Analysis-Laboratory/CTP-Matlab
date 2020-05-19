function ImageSkullRemovedFiltered = improveImagesSkullRemoved(ImageSkullRemoved, patients, SAVE, workspaceFolder, suffix_workspace, SAVE_INTERMEDIATE_STEPS, saveRegisteredFolder, previousNumPatiens)
% IMPROVEIMAGESSKULLREMOVED
%   Function that enhance the contrast in the images without the skull
%   in order to augment the different values in the pixels.

    ImageAdjust = cell(1,length(ImageSkullRemoved));
    ImageHistEq = cell(1,length(ImageSkullRemoved));
    ImageNormalize = cell(1,length(ImageSkullRemoved));
    ImageSkullRemovedFiltered = cell(1,length(ImageSkullRemoved));

    for patient=patients
        ImageAdjust{patient} = cell(1,length(ImageSkullRemoved{patient}));
        ImageHistEq{patient} = cell(1,length(ImageSkullRemoved{patient}));
        ImageNormalize{patient} = cell(1,length(ImageSkullRemoved{patient}));
        ImageSkullRemovedFiltered{patient} = cell(1,length(ImageSkullRemoved{patient}));
        
        for slice=1:length(ImageSkullRemoved{patient})
            ImageAdjust{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            ImageHistEq{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            ImageNormalize{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            ImageSkullRemovedFiltered{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            
            for image=1:length(ImageSkullRemoved{patient}{slice})
                Im_in = ImageSkullRemoved{patient}{slice}{image};
                
%                 Iblur1 = imgaussfilt(Im_in,2);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = histeq(Iblur1);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = (img_norm(ImageSkullRemovedFiltered{patient}{slice}{image}, 0, 65535));

                ImageAdjust{patient}{slice}{image} = imadjust(Im_in);
                ImageHistEq{patient}{slice}{image} = histeq(ImageAdjust{patient}{slice}{image},1024);
                ImageNormalize{patient}{slice}{image} = img_norm(ImageHistEq{patient}{slice}{image}, 0, 65535);
                ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageNormalize{patient}{slice}{image});
            end
        end
    end
    
    if SAVE_INTERMEDIATE_STEPS    
        saveRegisteredImages(ImageAdjust, saveRegisteredFolder, patients, "04_imadjust", previousNumPatiens);
        saveRegisteredImages(ImageHistEq, saveRegisteredFolder, patients, "05_histeq", previousNumPatiens);
        saveRegisteredImages(ImageNormalize, saveRegisteredFolder, patients, "06_img_norm", previousNumPatiens);
        saveRegisteredImages(ImageSkullRemovedFiltered, saveRegisteredFolder, patients, "07_adapthisteq", previousNumPatiens);
    end

    if SAVE
        save(strcat(workspaceFolder, 'ImageSkullRemovedFiltered', suffix_workspace, '.mat'),'ImageSkullRemovedFiltered','-v7.3');
    end
 
end



