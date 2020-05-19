function ImageSkullRemoved = combinedTechniquesSkullRemoval(ImageRegistered, thold, patients, SAVE, workspaceFolder, suffix_workspace)
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

                [~,Mask{image}] = removeSkull2(Im_in,'sym2',thold,patient);

                % agreement on the skull removal regions
                if eq(image, length(ImageRegistered{patient}{slice}))
                    tmpMask = zeros(size(Mask{image}));
                    for x=1:length(Mask)
                        tmpMask = tmpMask + Mask{x};
                        Mask{x} = [];
                    end
                    Mask{image} = tmpMask>length(ImageRegistered{patient}{slice})/2+1;
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
        save(strcat(workspaceFolder, 'ImageSkullRemoved', suffix_workspace, '.mat'),'ImageSkullRemoved','-v7.3');
    end
 
end



