function ImageSkullRemoved = anotherSkullRemovalTechnique(ImageRegistered, patients, SAVE, workspaceFolder)
% ANOTHERSKULLREMOVALTECHINIQUE 
%   Function to remove the skull from the images of the patients

    ImageSkullRemoved = cell(1,length(ImageRegistered));

    for patient=patients
        ImageSkullRemoved{patient} = cell(1,length(ImageRegistered{patient}));
        for slice=1:length(ImageRegistered{patient})
            ImageSkullRemoved{patient}{slice} = cell(1,length(ImageRegistered{patient}{slice}));
            
            nElem = length(ImageRegistered{patient}{slice});
            normalisert = cell(1, nElem);
            mid = cell(1, nElem);
            temp_normalisert = cell(1, nElem);
            temp_mid = cell(1, nElem);
            filt = cell(1, nElem);
            Mask = cell(1, nElem);
            
            for image=1:length(ImageRegistered{patient}{slice})
                Im_in = ImageRegistered{patient}{slice}{image};
                normalisert{image} = (img_norm(Im_in, 0, 65535));
                mid{image} = histeq(normalisert{image});
                
%                 figure("Name","img"), imshow(Im_in, []);
%                 figure("Name","norm"), imshow(normalisert{image}, []);
%                 figure("Name", "eq"), imshow(mid{image}, []);

                %% SPECIAL TREATMEANT FOR THE FIRST TIME-SERIES
                if eq(image, 1) 
                    temp_normalisert{image} = (img_norm(Im_in, 0, 4090));
                    temp_mid{image} = histeq(temp_normalisert{image});
                    filt{image} = imgaussfilt(temp_mid{image},3);
                    
                    figure("Name","tmpnorm"), imshow(temp_normalisert{image}, []);
                    figure("Name","tmp mid"), imshow(temp_mid{image}, []);
                    figure("Name","filt"), imshow(filt{image}, []);
                    
                    % tFMean is slow, but for some patients, it returns better masks.
                    [P, Mask{image}] =  regiongrowing(filt{image}, [250,250],'tfmean', 'tfsimiplify','tfFillHoles'); 
                    figure, imshow(Mask{image}, []);
                end
            end
            Mask = Mask(~cellfun('isempty',Mask));
            %% RESHAPE THE MASKS AND PRE-PROCESSED IMAGES
            B = repmat(Mask,1, length(mid)); %repmat(Mask,1, 30); % Repeat mask for all 30 time-series.

            B = reshape(B,[1,length(ImageRegistered{patient}{slice})]);
            mid = reshape(mid,[1,length(ImageRegistered{patient}{slice})]);

            %% APPLY MASKS TO PRE-PROCESSED IMAGES.
            for j = 1:length(ImageRegistered{patient}{slice})
                Bilde{1,j} = bsxfun(@times, mid{1,j}, cast(B{1,j}, 'like', mid{1,j}));
                ImageSkullRemoved{patient}{slice}{j} = Bilde{1,j};
            end
        end
    end

    if SAVE
        save(strcat(workspaceFolder, 'ImageSkullRemoved.mat'),'ImageSkullRemoved','-v7.3');
    end
 
end



