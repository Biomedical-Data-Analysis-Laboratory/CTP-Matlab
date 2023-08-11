function ImageSkullRemovedFiltered = improveImagesSkullRemoved(ImageSkullRemoved, patients, SAVE, workspaceFolder, saveContrastEnhancementFolder, ...
    suffix_workspace, SAVE_INTERMEDIATE_STEPS, saveRegisteredFolder, previousNumPatiens, saveForVISUALFolder, directory, ISLISTOFDIR, SAVE_AS_TIFF, ...
    OLD_PREPROC_STEPS, HISTEQ, IMGADJUST, GAMMA, ZSCORE, CONVERT_TO_HU, CROP_VALUES, isFAKE)
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
save_prefix = '04_ContrastEnhanchement.';

suffix = ".tiff";
if ~SAVE_AS_TIFF
    suffix = ".png";
end

fileID = fopen(strcat(workspaceFolder,'minval.txt'),'r');
if fileID~=-1 && ~isFAKE
    minvaltxt = fscanf(fileID, "%*s %f");
    fclose(fileID);
    minvaltxt = minvaltxt(2,:);
    minDS = min(minvaltxt(:));
    fileID = fopen(strcat(workspaceFolder,'maxval.txt'),'r');
    maxvaltxt = fscanf(fileID, "%*s %f");
    fclose(fileID);
    maxvaltxt = maxvaltxt(2,:);
    maxDS = max(maxvaltxt(:));
else
    minDS = -100;
end

for ia = IMGADJUST
for he = HISTEQ
for zs = ZSCORE
for patient=patients
    tic
    
    [fname,folderPath,p_id] = getFilenameFromPatient(patient, workspaceFolder, save_prefix, directory, ISLISTOFDIR);
    [fname_snr,~,~] = getFilenameFromPatient(patient, workspaceFolder, "aftercontrast_SNR.", directory, ISLISTOFDIR);
    
    disp(strcat("Patient: ", p_id, " - IA: ", num2str(ia), " - HE: ", num2str(he), " - ZS: ", num2str(zs)));
       
    constrastFolder = "v20/";
    if ia && he && zs
        constrastFolder = strcat("v21-",num2str(GAMMA),"/");
    elseif ia && he
        constrastFolder = strcat("v22-",num2str(GAMMA),"/");
    elseif ia && zs
        constrastFolder = strcat("v23-",num2str(GAMMA),"/");
    elseif he && zs 
        constrastFolder = "v24/";
    elseif ia
        constrastFolder = strcat("v25-",num2str(GAMMA),"/");
    elseif he
        constrastFolder = "v26/";
    elseif zs
        constrastFolder = "v27/";
    end
        
    % change the subfolder name and create it
    fname = replace(fname, workspaceFolder, strcat(workspaceFolder,suffix_workspace,constrastFolder));
    mkdir(strcat(workspaceFolder,suffix_workspace,constrastFolder));
    
    if strcmp(folderPath,"") % == there is no patient 
        ImageSkullRemovedFiltered{patient} = [];
        continue
    end
    if exist(fname, 'file')==2
        load(fname);
        ImageSkullRemovedFiltered{patient} = patImage;
        % ImageSkullRemoved{patient} = [];
        if ~exist(fname_snr, 'file') 
            SNR = [];
            for s = 1:length(ImageSkullRemovedFiltered{patient})
                for i = 1:length(ImageSkullRemovedFiltered{patient}{s})
                    signal = mean(ImageSkullRemovedFiltered{patient}{s}{i}(:));
                    noise = std(ImageSkullRemovedFiltered{patient}{s}{i}(:));
                    if noise==0 % empty mask
                        continue
                    end
                    SNR = [SNR; signal/noise];
                end
            end
            SNR = mean(SNR);
            save(fname_snr,'SNR','-v7.3');
        end
        if ~SAVE_INTERMEDIATE_STEPS
            continue
        end
    end
    
    if SAVE_INTERMEDIATE_STEPS
        ImageAdjust{patient} = cell(1,length(ImageSkullRemoved{patient}));
        if OLD_PREPROC_STEPS
            ImageHistEq{patient} = cell(1,length(ImageSkullRemoved{patient}));
            ImageNormalize{patient} = cell(1,length(ImageSkullRemoved{patient}));
        end
    end
    ImageSkullRemovedFiltered{patient} = cell(1,length(ImageSkullRemoved{patient}));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    index = 1;
    limit = 0;
    if CONVERT_TO_HU
        limit = - 1024;
    end
    % take the max value from all the images
    max_idx = cell(1,length(ImageSkullRemoved{patient})*30);
    min_idx = cell(1,length(ImageSkullRemoved{patient})*30);
    for slice=1:length(ImageSkullRemoved{patient})
        ImageSkullRemovedFiltered{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
        for image=1:length(ImageSkullRemoved{patient}{slice})
            max_idx{index} = max(ImageSkullRemoved{patient}{slice}{image}(:));
            
            if CROP_VALUES
                % cut the gap between the background values and the min value
                brainmask = bwareafilt(imfill(ImageSkullRemoved{patient}{slice}{image}>limit, 'holes')>0,10);
                backmask = ~brainmask .* (minDS-10);
                ImageSkullRemoved{patient}{slice}{image} = (brainmask.*ImageSkullRemoved{patient}{slice}{image})+backmask;
                ImageSkullRemoved{patient}{slice}{image}(ImageSkullRemoved{patient}{slice}{image}<minDS-10) = minDS-10;
            end
            min_idx{index} = min(ImageSkullRemoved{patient}{slice}{image}(:));
            index = index+1;
        end
    end
    % extract the max pixel value, then find the corresponding slice and
    % image indeces    
    [max_val,index_max_val] = max(cell2mat(max_idx(:)));
    [min_val,~] = min(cell2mat(min_idx(:)));
    
    max_slice = fix(index_max_val/length(ImageSkullRemoved{patient}{slice}))+1;
    max_image = rem(index_max_val,length(ImageSkullRemoved{patient}{slice}));
    if max_image==0
        max_image = length(ImageSkullRemoved{patient}{slice});
    end
    
    % rescale into range [0 1] from the range --> [min_val max_val]
    ImageSkullRemovedFiltered{patient}{max_slice}{max_image} = double(rescale(ImageSkullRemoved{patient}{max_slice}{max_image}, 'InputMin', min_val, 'InputMax', max_val));
            
    % Gamma correction == GAMMA
    if ia
        ImageSkullRemovedFiltered{patient}{max_slice}{max_image} = imadjust(ImageSkullRemovedFiltered{patient}{max_slice}{max_image},[0 1], [0 1], GAMMA);
    end
    % perform histogram equalization 
    if he
        limit = 0;
        if CONVERT_TO_HU
            limit = - 1024;
        end
        % get the transform map of the brain alone
        [~, transformMap] = histeq(ImageSkullRemovedFiltered{patient}{max_slice}{max_image}(ImageSkullRemovedFiltered{patient}{max_slice}{max_image}~=0),65535); 
        
        ImageSkullRemovedFiltered{patient}{max_slice}{max_image} = histeq(ImageSkullRemovedFiltered{patient}{max_slice}{max_image}, transformMap);
            
        max_max = max(max(ImageSkullRemovedFiltered{patient}{max_slice}{max_image}));
        min_min = min(min(ImageSkullRemovedFiltered{patient}{max_slice}{max_image}));
        ImageSkullRemovedFiltered{patient}{max_slice}{max_image} = (ImageSkullRemovedFiltered{patient}{max_slice}{max_image}-min_min)./(max_max-min_min);
        
%         mask = bwareafilt(imfill(ImageSkullRemoved{patient}{max_slice}{max_image}>limit, 'holes')>0,10);
%         ImageSkullRemovedFiltered{patient}{max_slice}{max_image} = mask.*ImageSkullRemovedFiltered{patient}{max_slice}{max_image};
    end
    % useful for zero mean and unit variance   
    if zs
        tmp_img = ImageSkullRemovedFiltered{patient}{max_slice}{max_image};
        ImageSkullRemovedFiltered{patient}{max_slice}{max_image} = reshape(zscore(tmp_img(:)),size(tmp_img,1),size(tmp_img,2));
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% contrast enhancement
    max_idx2 = cell(1,length(ImageSkullRemoved{patient})*30);
    min_idx2 = cell(1,length(ImageSkullRemoved{patient})*30);
    index = 1;
    for slice=1:length(ImageSkullRemoved{patient})
        if SAVE_INTERMEDIATE_STEPS  
            ImageAdjust{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            if OLD_PREPROC_STEPS
                ImageHistEq{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
                ImageNormalize{patient}{slice} = cell(1,length(ImageSkullRemoved{patient}{slice}));
            end
        end
        
        for image=1:length(ImageSkullRemoved{patient}{slice})
            Im_in = ImageSkullRemoved{patient}{slice}{image};

%                 VERY OLD PRE-PROCESSING STEPS (master thesis --> 06/2019)
%                 Iblur1 = imgaussfilt(Im_in,2);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = histeq(Iblur1);
%                 ImageSkullRemovedFiltered{patient}{slice}{image} = (img_norm(ImageSkullRemovedFiltered{patient}{slice}{image}, 0, 65535));

            if OLD_PREPROC_STEPS
                %% USED IN ACM-BCB2020 paper (03/2020): 
                %histogram equalization with 256 level of gray 
                if SAVE_INTERMEDIATE_STEPS
                    ImageSkullRemovedFiltered{patient}{slice}{image} = histeq(Im_in,256);
                    ImageSkullRemovedFiltered{patient}{slice}{image} = img_norm(ImageSkullRemovedFiltered{patient}{slice}{image}, 0, 65535); 
                    ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageSkullRemovedFiltered{patient}{slice}{image});
                else
                    ImageAdjust{patient}{slice}{image} = imadjust(Im_in);
                    ImageHistEq{patient}{slice}{image} = histeq(ImageAdjust{patient}{slice}{image},256); 
                    ImageNormalize{patient}{slice}{image} = img_norm(ImageHistEq{patient}{slice}{image}, 0, 65535);
                    ImageSkullRemovedFiltered{patient}{slice}{image} = adapthisteq(ImageNormalize{patient}{slice}{image});
                end
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% current contrast enhancement steps (05/2021) 
                if sum(Im_in,'all')==0 % if everything is black
                    ImageSkullRemovedFiltered{patient}{slice}{image} = Im_in;
                    continue
                end
                
                if image~=max_image || slice~=max_slice
                    Im_in = rescale(Im_in,'InputMin',min_val,'InputMax',max_val);
                    if ia
                        Im_in = imadjust(Im_in, [0 1], [0 1], GAMMA);
                    end
                    if he
                        limit = 0;
                        if CONVERT_TO_HU
                            limit = -1024;
                        end
                        
                        RR=zeros(size(Im_in));
                        mapping_val = (0:255)/255;
                        for e = 1:length(transformMap)-1
                            RR(Im_in>=mapping_val(e) & Im_in<=mapping_val(e+1)) = transformMap(e);
                        end
                        Im_in=RR;
                    end 
                    if zs
                        Im_in = reshape(zscore(Im_in(:)),size(Im_in,1),size(Im_in,2));
                    end
                    
                    ImageSkullRemovedFiltered{patient}{slice}{image} = Im_in;
                end
            end
            min_idx2{index} = min(ImageSkullRemovedFiltered{patient}{slice}{image}(:));
            max_idx2{index} = max(ImageSkullRemovedFiltered{patient}{slice}{image}(:));
            index = index+1;
        end
    end
    
    %% save everything
    [min_min,~] = min(cell2mat(min_idx2(:)));
    [max_max,~] = max(cell2mat(max_idx2(:)));
    for slice=1:length(ImageSkullRemoved{patient})
        sk = num2str(slice);
        if length(sk) == 1
            sk = strcat('0', sk);
        end
        for image=1:length(ImageSkullRemoved{patient}{slice})
            idx = num2str(image);
            if length(idx) == 1
                idx = strcat('0', idx);
            end
            if SAVE
                mkdir(strcat(saveContrastEnhancementFolder,constrastFolder,p_id)) % patient folder
                mkdir(strcat(saveContrastEnhancementFolder,constrastFolder,p_id,"/",sk)) % slice folder
                image_name = strcat(saveContrastEnhancementFolder,constrastFolder,p_id,"/",sk,"/",idx,suffix);
                imwrite(mat2gray(ImageSkullRemovedFiltered{patient}{slice}{image},[min_min max_max]),image_name);
            end
        end
    end
    
    if SAVE
        patImage = ImageSkullRemovedFiltered{patient};
        save(fname,'patImage','-v7.3')
    end
    
    toc
end
end
end
end

if SAVE_INTERMEDIATE_STEPS    
    suffix_adapthisteq = "05_adapthisteq";
    if OLD_PREPROC_STEPS
        saveRegisteredImages(ImageAdjust, saveRegisteredFolder, saveForVISUALFolder, patients, "04_imadjust", previousNumPatiens, false, "", SAVE_AS_TIFF);
        saveRegisteredImages(ImageHistEq, saveRegisteredFolder, saveForVISUALFolder, patients, "05_histeq", previousNumPatiens, false, "", SAVE_AS_TIFF);
        saveRegisteredImages(ImageNormalize, saveRegisteredFolder, saveForVISUALFolder, patients, "06_img_norm", previousNumPatiens, false, "", SAVE_AS_TIFF);
        suffix_adapthisteq = "07_adapthisteq";
    end
    saveRegisteredImages(ImageSkullRemovedFiltered, saveRegisteredFolder, saveForVISUALFolder, patients, suffix_adapthisteq, previousNumPatiens, false, "", SAVE_AS_TIFF);
end

% change the variable to the set that was used as input! necessary for the
% saveRegisteredImages function later on
if ~OLD_PREPROC_STEPS
    ImageSkullRemovedFiltered = ImageSkullRemoved;
end

end

