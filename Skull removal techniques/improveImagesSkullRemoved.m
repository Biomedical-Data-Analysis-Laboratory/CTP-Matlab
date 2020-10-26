function ImageSkullRemovedFiltered = improveImagesSkullRemoved(ImageSkullRemoved, patients, SAVE, workspaceFolder, ...
    suffix_workspace, SAVE_INTERMEDIATE_STEPS, saveRegisteredFolder, previousNumPatiens, SAVE_AS_TIFF, OLD_PREPROC_STEPS)
% IMPROVEIMAGESSKULLREMOVED
%   Function that enhance the contrast in the images without the skull
%   in order to augment the different values in the pixels.


if SAVE_INTERMEDIATE_STEPS  
    ImageAdjust = cell(1,length(ImageSkullRemoved));
    if OLD_PREPROC_STEPS
        ImageHistEq = cell(1,length(ImageSkullRemoved));
        ImageNormalize = cell(1,length(ImageSkullRemoved));
    end
end
ImageSkullRemovedFiltered = cell(1,length(ImageSkullRemoved));

for patient=patients
    tic
    if SAVE_INTERMEDIATE_STEPS
        ImageAdjust{patient} = cell(1,length(ImageSkullRemoved{patient}));
        if OLD_PREPROC_STEPS
            ImageHistEq{patient} = cell(1,length(ImageSkullRemoved{patient}));
            ImageNormalize{patient} = cell(1,length(ImageSkullRemoved{patient}));
        end
    end
    ImageSkullRemovedFiltered{patient} = cell(1,length(ImageSkullRemoved{patient}));

    for slice=1:length(ImageSkullRemoved{patient})
        if SAVE_INTERMEDIATE_STEPS  
            ImageAdjust{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            if OLD_PREPROC_STEPS
                ImageHistEq{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
                ImageNormalize{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            end
        end
        ImageSkullRemovedFiltered{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));

        for image=1:length(ImageSkullRemoved{patient}{slice})
            Im_in = ImageSkullRemoved{patient}{slice}{image};

%                 VERY OLD PRE-PROCESSING STEPS (master thesis --> 06/2019)
%                 Iblur1 = imgaussfilt(Im_in,2);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = histeq(Iblur1);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = (img_norm(ImageSkullRemovedFiltered{patient}{slice}{image}, 0, 65535));

            if SAVE_INTERMEDIATE_STEPS  
                if OLD_PREPROC_STEPS
                    %% USED IN ACM-BCB2020 paper (03/2020): 
                    %histogram equalization with 256 level of gray 
                    ImageAdjust{patient}{slice}{image} = imadjust(Im_in);
                    ImageHistEq{patient}{slice}{image} = histeq(ImageAdjust{patient}{slice}{image},256); 
                    ImageNormalize{patient}{slice}{image} = img_norm(ImageHistEq{patient}{slice}{image}, 0, 65535);
                    ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageNormalize{patient}{slice}{image});
                else 
                    %% current contrast enhancement steps (08/2020) 
                    ImageAdjust{patient}{slice}{image} = imadjust(Im_in);
                    ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageAdjust{patient}{slice}{image});
                end
            else
                %% USED IN ACM-BCB2020 paper (03/2020): 
                % histogram equalization with 256 level of gray 
                if OLD_PREPROC_STEPS
                    ImageSkullRemovedFiltered{patient}{slice}{image} = histeq(ImageSkullRemovedFiltered{patient}{slice}{image},256);
                    ImageSkullRemovedFiltered{patient}{slice}{image} = img_norm(ImageSkullRemovedFiltered{patient}{slice}{image}, 0, 65535); 
                    ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageSkullRemovedFiltered{patient}{slice}{image});
                else
                    %% current contrast enhancement steps (08/2020) 
                    if sum(Im_in,'all')==0 % if everything is black
                        ImageSkullRemovedFiltered{patient}{slice}{image} = Im_in;
                        continue
                    end

                    ImageSkullRemovedFiltered{patient}{slice}{image} = imadjust(Im_in);
                    ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageSkullRemovedFiltered{patient}{slice}{image});
                end
            end
        end
    end
    disp(strcat("Patient: ", num2str(patient)));
    toc
end

if SAVE_INTERMEDIATE_STEPS    
    saveRegisteredImages(ImageAdjust, saveRegisteredFolder, patients, "04_imadjust", previousNumPatiens, false, "", SAVE_AS_TIFF);
    suffix_adapthisteq = "05_adapthisteq";
    if OLD_PREPROC_STEPS
        saveRegisteredImages(ImageHistEq, saveRegisteredFolder, patients, "05_histeq", previousNumPatiens, false, "", SAVE_AS_TIFF);
        saveRegisteredImages(ImageNormalize, saveRegisteredFolder, patients, "06_img_norm", previousNumPatiens, false, "", SAVE_AS_TIFF);
        suffix_adapthisteq = "07_adapthisteq";
    end
    saveRegisteredImages(ImageSkullRemovedFiltered, saveRegisteredFolder, patients, suffix_adapthisteq, previousNumPatiens, false, "", SAVE_AS_TIFF);
end

if SAVE
    save(strcat(workspaceFolder, 'ImageSkullRemovedFiltered', suffix_workspace, '.mat'),'ImageSkullRemovedFiltered','-v7.3');
end
 
end



