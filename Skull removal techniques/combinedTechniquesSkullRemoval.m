function ImageSkullRemoved = combinedTechniquesSkullRemoval(ImageRegistered, thold, patients, directory, ...
    SAVE, workspaceFolder, suffix_workspace, isNIfTI, ISLISTOFDIR, SAVE_AS_TIFF, saveRegisteredFolder)
% ANOTHERSKULLREMOVALTECHINIQUE 
%   Function to remove the skull from the images of the patients

    if nargin < 11
        saveRegisteredFolder = "";
    end

    suffixsave = ".png";
    if SAVE_AS_TIFF
        suffixsave = ".tiff";
    end
    
    ImageSkullRemoved = cell(1,length(ImageRegistered));

    for patient=patients
        
        disp(strcat("Patient: ", num2str(patient)));
        
        if patient==82
            disp("here");
        end
        
        ImageSkullRemoved{patient} = cell(1,length(ImageRegistered{patient}));
        for slice=1:length(ImageRegistered{patient})
            ImageSkullRemoved{patient}{slice} = cell(1,length(ImageRegistered{patient}{slice}));
            
            nElem = length(ImageRegistered{patient}{slice});
%             normalisert = cell(1, nElem);
%             mid = cell(1, nElem);
%             Mask = cell(1, nElem);
            tmp_mask = zeros(512,512);
%             ttp_mask = zeros(512,512) * -inf;
            ttp_mask = zeros(512*512,nElem);
            
            for image=1:nElem
                Im_in = ImageRegistered{patient}{slice}{image};
%                 normalisert{image} = (img_norm(Im_in, 0, 65535));
%                 mid{image} = histeq(normalisert{image});
                
                if ~isNIfTI
                    info = struct();
                    
                    if ~ISLISTOFDIR % old patients
                        if patient<9
                            folderPath = ([directory 'PA0' num2str(patient) '/ST000000/SE000001/']);
                        else
                            if patient == 9
                                folderPath = ([directory 'PA0' num2str(patient) '/ST000000/SE000000/']);
                            else
                                folderPath = ([directory 'PA' num2str(patient) '/ST000000/SE000000/']);
                            end
                        end
                        
                        i = image+(slice-1)*nElem;
                        if i<11
                            info = dicominfo([folderPath 'IM00000' num2str(i-1)]);
                        elseif i<101
                            info = dicominfo([folderPath 'IM0000' num2str(i-1)]);
                        else
                            info = dicominfo([folderPath 'IM000' num2str(i-1)]);
                        end
                    else % new patients 
                        folderPath = directory{patient};
                        for dicomFile = dir(folderPath)'
                            if ~strcmp(dicomFile.name, '.') && ~strcmp(dicomFile.name, '..')
                                info = dicominfo(fullfile(dicomFile.folder, dicomFile.name));
                                break
                            end
                        end     
                    end
                    
                    % convert each pixels' image into a HU
                    Im_in = int16(Im_in) * info.RescaleSlope + info.RescaleIntercept;
                end
                
                [ImageSkullRemoved{patient}{slice}{image},tmp_mask] = testRemoveSkull(Im_in, tmp_mask, image);
                
                if isNIfTI
                    
                    ttp_mask(:,image) = ImageSkullRemoved{patient}{slice}{image}(:);
                    % get the pixels for the ttp mask
%                     for row=1:size(Im_in,1)
%                         for col=1:size(Im_in,2)
%                             ttp_mask(row,col) = max(ttp_mask(row,col), ImageSkullRemoved{patient}{slice}{image}(row,col));
%                             if ImageSkullRemoved{patient}{slice}{image}(row,col) == ttp_mask(row,col) && ImageSkullRemoved{patient}{slice}{image}(row,col)>0
%                                 ttp(row,col) = image;
%                             end
%                         end
%                     end
                end
                % [~,Mask{image}] = removeSkull2(Im_in,'sym2',thold,patient,slice,image);

                %% agreement on the skull removal regions
%                 if eq(image, length(ImageRegistered{patient}{slice}))
%                     tmpMask = zeros(size(Mask{image}));
%                     for x=1:length(Mask)
%                         tmpMask = tmpMask + Mask{x};
%                         Mask{x} = [];
%                     end
%                     Mask{image} = tmpMask>length(ImageRegistered{patient}{slice})/2+1;
%                 end
            end
            
            if isNIfTI
                name = num2str(patient);
                if length(name) == 1
                    name = strcat('0', name);
                end
                imgidx = num2str(slice);
                if length(imgidx) == 1
                    imgidx = strcat('0', imgidx);
                end
                
                ttpFolder = strcat(saveRegisteredFolder,"/PA",name,"/TTP/");
                if ~isfolder(ttpFolder)
                    mkdir(ttpFolder)
                end
                
                [~,indices] = max(ttp_mask, [], 2);
                ttp = reshape(indices,[512 512]);
                ttp = imgaussfilt(ttp);
                imwrite(im2uint16(ttp./nElem), strcat(ttpFolder,imgidx,suffixsave));                                    
                
            end
            
%             Mask = Mask(~cellfun('isempty',Mask));
%             %% RESHAPE THE MASKS AND PRE-PROCESSED IMAGES
%             B = repmat(Mask,1, length(mid)); %repmat(Mask,1, 30); % Repeat mask for all 30 time-series.
% 
%             B = reshape(B,[1,length(ImageRegistered{patient}{slice})]);
%             mid = reshape(mid,[1,length(ImageRegistered{patient}{slice})]);
% 
%             %% APPLY MASKS TO PRE-PROCESSED IMAGES.
%             for j = 1:length(ImageRegistered{patient}{slice})
%                 ImageSkullRemoved{patient}{slice}{j} = bsxfun(@times, mid{1,j}, cast(B{1,j}, 'like', mid{1,j}));
%             end
        end
        close all;
    end

    if SAVE
        save(strcat(workspaceFolder, 'ImageSkullRemoved', suffix_workspace, '.mat'),'ImageSkullRemoved','-v7.3');
    end
 
end



