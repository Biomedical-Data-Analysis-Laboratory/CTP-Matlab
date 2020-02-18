function ImageSkullRemovedFiltered = improveImagesSkullRemoved(ImageSkullRemoved, patients, SAVE, workspaceFolder)
% IMPROVEIMAGESSKULLREMOVED
%   Function that enhance the contrasti in the images without the skull
%   in order to augment the different values in the pixels.

    ImageSkullRemovedFiltered = cell(1,length(ImageSkullRemoved));

    for patient=patients
        ImageSkullRemovedFiltered{patient} = cell(1,length(ImageSkullRemoved{patient}));
        for slice=1:length(ImageSkullRemoved{patient})
            ImageSkullRemovedFiltered{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            for image=1:length(ImageSkullRemoved{patient}{slice})
                Im_in = ImageSkullRemoved{patient}{slice}{image};
                
%                 Iblur1 = imgaussfilt(Im_in,2);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = histeq(Iblur1);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = (img_norm(ImageSkullRemovedFiltered{patient}{slice}{image}, 0, 65535));

                ImageSkullRemovedFiltered{patient}{slice}{image} = imadjust(Im_in);
                ImageSkullRemovedFiltered{patient}{slice}{image} = histeq(ImageSkullRemovedFiltered{patient}{slice}{image});
                ImageSkullRemovedFiltered{patient}{slice}{image} = img_norm(ImageSkullRemovedFiltered{patient}{slice}{image}, 0, 65535);
                ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageSkullRemovedFiltered{patient}{slice}{image});
            end
        end
    end

    if SAVE
        save(strcat(workspaceFolder, 'ImageSkullRemovedFiltered.mat'),'ImageSkullRemovedFiltered','-v7.3');
    end
 
end



