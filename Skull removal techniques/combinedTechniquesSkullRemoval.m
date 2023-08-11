function [ImageSkullRemoved] = combinedTechniquesSkullRemoval(ImageRegistered, thold, patients, directory, ...
    SAVE, workspaceFolder, suffix_workspace, isNIfTI, ISLISTOFDIR, SAVE_AS_TIFF, saveImageRegisteredFolder, ...
    maskRegisteredFolder, NEW_SKULLSTRIPPING, CONVERT_TO_HU, CONVERT_TO_DOUBLE, CROP_VALUES, isFAKE)
% ANOTHERSKULLREMOVALTECHINIQUE 
%   Function to remove the skull from the images of the patients

suffixsave = ".png";
if SAVE_AS_TIFF
    suffixsave = ".tiff";
end

ImageSkullRemoved = cell(1,length(ImageRegistered));
save_prefix = '03_BrainExtraction.';

minval = [];
maxval = [];
for patient=patients
    [fname,folderPath,p_id] = getFilenameFromPatient(patient, workspaceFolder, save_prefix, directory, ISLISTOFDIR);
    [fname_snr,~,~] = getFilenameFromPatient(patient, workspaceFolder, "afterskull_SNR.", directory, ISLISTOFDIR);
    
    if strcmp(folderPath,"") % == there is no patient 
        clearvars ImageRegistered{patient}
        ImageSkullRemoved{patient} = [];
        continue
    end
    
    %% If exists, get the patient and calculate the SNR
    disp("Extracting brain from patient: " + p_id);
    if exist(fname, 'file')==2
        load(fname);
        ImageSkullRemoved{patient} = patImage;
        clearvars ImageRegistered{patient}
        if ~exist(fname_snr, 'file') 
            SNR = [];
            for s = 1:length(ImageSkullRemoved{patient})
                for i = 1:length(ImageSkullRemoved{patient}{s})
                    signal = mean(ImageSkullRemoved{patient}{s}{i}(:));
                    noise = std(ImageSkullRemoved{patient}{s}{i}(:));
                    if noise==0 % empty mask
                        continue
                    end
                    SNR = [SNR; signal/noise];
                end
            end
            SNR = mean(SNR);
            save(fname_snr,'SNR','-v7.3');
        end
        continue
    end

    %% save image registered
    if ~strcmp(saveImageRegisteredFolder, "") && ~isfolder(strcat(saveImageRegisteredFolder,"/",p_id))
        mkdir(strcat(saveImageRegisteredFolder,"/",p_id))
        for k=1:length(ImageRegistered{patient})
            slice = num2str(k);
            if length(slice) == 1
                slice = strcat('0', slice);
            end
            mkdir(strcat(saveImageRegisteredFolder,"/",p_id,"/",slice))
            for i=1:length(ImageRegistered{patient}{k})
                index = num2str(i);
                if i<10
                    index = strcat("0", num2str(i));
                end
                image_name = strcat(saveImageRegisteredFolder,"/",p_id,"/",slice,"/",index,suffixsave);
                imwrite(mat2gray(ImageRegistered{patient}{k}{i}),image_name);
            end
        end
    end
        
    ImageSkullRemoved{patient} = cell(1,length(ImageRegistered{patient}));
    skullStripList = double(zeros([size(ImageRegistered{patient}{1}{1}),length(ImageRegistered{patient})])); 
    
    info = struct();
    for slice=1:length(ImageRegistered{patient})
        ImageSkullRemoved{patient}{slice} = cell(1,length(ImageRegistered{patient}{slice}));
        
        nElem = length(ImageRegistered{patient}{slice});
        sizeimg = size(ImageRegistered{patient}{slice}{nElem});
        
%             normalisert = cell(1, nElem);
%             mid = cell(1, nElem);
%             Mask = cell(1, nElem);
        tmp_mask = zeros(sizeimg);
        ttp_mask = zeros(sizeimg(1)*sizeimg(2),nElem);
        
        for image=1:nElem
            Im_in = ImageRegistered{patient}{slice}{image};
%                 normalisert{image} = (img_norm(Im_in, 0, 65535));
%                 mid{image} = histeq(normalisert{image});
            
            if ~isNIfTI && ~isFAKE
                
                if ~ISLISTOFDIR % old patients
                    if isempty(fieldnames(info))
                        if patient<9
                            folderPath = strcat(directory,'PA0',num2str(patient),'/ST000000/SE000001/');
                        else
                            if patient == 9
                                folderPath = strcat(directory,'PA0',num2str(patient),'/ST000000/SE000000/');
                            else
                                folderPath = strcat(directory,'PA',num2str(patient),'/ST000000/SE000000/');
                            end
                        end
                        
                        i = image+(slice-1)*nElem;
                        if i<11
                            info = dicominfo(strcat(folderPath,'IM00000',num2str(i-1)));
                        elseif i<101
                            info = dicominfo(strcat(folderPath,'IM0000',num2str(i-1)));
                        else
                            info = dicominfo(strcat(folderPath,'IM000',num2str(i-1)));
                        end
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
                
                %% convert each pixels' image into a HU!!
                if CONVERT_TO_HU
                    % convert to double to correctly accept the RescaleIntercept values
                    Im_in = double(Im_in) * info.RescaleSlope + info.RescaleIntercept;
                    if CONVERT_TO_DOUBLE
                       Im_in = im2double(Im_in); 
                    end
                end
            end
            
            % do the skull stripping following the code from this
            % article: https://doi.org/10.1016/j.cmpb.2019.04.030
            if NEW_SKULLSTRIPPING
                if image==1
                    skullStripList(:,:,slice) = Im_in;
                end
                ImageSkullRemoved{patient}{slice}{image} = Im_in;
            else
                if image==1
                    thres_hu = 160;
                end
                [ImageSkullRemoved{patient}{slice}{image},tmp_mask,thres_hu] = testRemoveSkull(Im_in, tmp_mask, image, thres_hu);

                minval(end+1) = min(ImageSkullRemoved{patient}{slice}{image},[],"all");
                maxval(end+1) = max(ImageSkullRemoved{patient}{slice}{image},[],"all");
                
                if isNIfTI || isFAKE
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

                % save the mask for each slice of a patient
                if isunix && ~strcmp(maskRegisteredFolder, "") && image==1
                    mkdir(strcat(maskRegisteredFolder,p_id));
                    sk = num2str(slice);
                    if length(sk) == 1
                        sk = strcat('0', sk);
                    end
                    imwrite(double(tmp_mask),strcat(maskRegisteredFolder,p_id,"/",sk,".png"))
                end
            end
        end
                    
        if isNIfTI || isFAKE
            name = num2str(patient);
            if length(name) == 1
                name = strcat('0', name);
            end
            imgidx = num2str(slice);
            if length(imgidx) == 1
                imgidx = strcat('0', imgidx);
            end 
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
    
    % do the skull stripping following the code from this
    % article: https://doi.org/10.1016/j.cmpb.2019.04.030
    if NEW_SKULLSTRIPPING
        if CONVERT_TO_HU
            %% HU for skull --> https://www.ahajournals.org/doi/pdf/10.1161/STROKEAHA.115.009250
            CTP_Thr = 400; 
        else
            CTP_Thr = 1424;
            if isNIfTI
                CTP_Thr = 1100;
            end
        end
        % the algorithm accepts threshold values for HU
        count = 0;
        err_count = 0;
        brainList = [];
        if isFAKE % different approach is data are generating from gans
            skullStripList(skullStripList<25) = 0;
            if patient==3
            % skullStripList(skullStripList>140) = 255;
                brainList(:,:,1:51) = SkullStripping(skullStripList(:,:,1:51),100);
                brainList(:,:,52:99) = SkullStripping(skullStripList(:,:,52:99),100);
                brainList(:,:,100:size(skullStripList,3)) = SkullStripping(skullStripList(:,:,100:end),100);
            elseif patient==4
                brainList(:,:,1:150) = SkullStripping(skullStripList(:,:,1:150),125);
                brainList(:,:,151:size(skullStripList,3)) = SkullStripping(skullStripList(:,:,151:end),110);
            else
                brainList(:,:,1:150) = SkullStripping(skullStripList(:,:,1:150),100);
                brainList(:,:,151:size(skullStripList,3)) = SkullStripping(skullStripList(:,:,151:end),105);
            end
        else
        while count == err_count && CTP_Thr<3000 && CTP_Thr>0
            try 
                brainList = SkullStripping(skullStripList,CTP_Thr);
            catch
                if patient>=82 && patient~=89
                    CTP_Thr = CTP_Thr-5;
                else
                    CTP_Thr = CTP_Thr+5;
                end
                err_count = err_count + 1;
            end
            count = count + 1;
            disp(CTP_Thr);
        end
        end

        for brainIdx = 1:size(brainList,3)
            % minor fixes on the skullStripping function
%             if isFAKE
%                 brainmasks = ~double(brainList(:,:,brainIdx));
%             else
                brainmasks = bwareafilt(imfill(double(brainList(:,:,brainIdx)), 'holes')>0,10);
%             end
            cc = bwconncomp(brainmasks);
            BP = regionprops(brainmasks,'Circularity','Centroid');
            centroid = zeros(1,numel(BP));
            for n=1:numel(BP)
                centroid(n) = BP(n).Centroid(2);
            end
            idx = find([centroid] > 100); 
            brainmask = ismember(labelmatrix(cc),idx);
            % for each timepoint
            for z =1:nElem
                min_thresh = 0;
                ImageSkullRemoved{patient}{brainIdx}{z} = double(ImageSkullRemoved{patient}{brainIdx}{z}) .* double(brainmask);
                
%                     % back has the minimum value from the background(WITH HU -1024)
%                     % remove everything except the brain, add the minimum value for the original images.
                if CONVERT_TO_HU
                    min_thresh = -1024;
                    back = double(~brainmask).*min_thresh;
                    ImageSkullRemoved{patient}{brainIdx}{z} = ImageSkullRemoved{patient}{brainIdx}{z} + back;
                end
                
                if CROP_VALUES
                    ImageSkullRemoved{patient}{brainIdx}{z}(ImageSkullRemoved{patient}{brainIdx}{z}>CTP_Thr+200) = CTP_Thr+200;
                end
                
                if ~isNIfTI && ~isFAKE
                    check_img = ImageSkullRemoved{patient}{brainIdx}{z}(ImageSkullRemoved{patient}{brainIdx}{z}>=min_thresh+500);
                    outliers = 0;
                    if ~isempty(check_img)
                        while ~isempty(check_img)
                            z_min = min(check_img,[],"all");
                            if sum(sum(check_img==z_min))>3 || outliers>20 || z_min==0 % check if there are at least 3 pixel with that min val or there are more than 20 outliers
                                minval(end+1) = z_min;
                                break
                            else 
                                outliers = outliers+sum(sum(check_img==z_min));
                                check_img = check_img(check_img~=z_min);
                            end
                        end
                        maxval(end+1) = max(ImageSkullRemoved{patient}{brainIdx}{z},[],"all");
                    end
                else 
                    minval(end+1) = min(ImageSkullRemoved{patient}{brainIdx}{z},[],"all");
                    maxval(end+1) = max(ImageSkullRemoved{patient}{brainIdx}{z},[],"all");
                end
                
                if ~strcmp(maskRegisteredFolder, "")
                    mkdir(strcat(maskRegisteredFolder,p_id));
                    sk = num2str(brainIdx);
                    if length(sk) == 1
                        sk = strcat('0', sk);
                    end
                    imwrite(brainmask,strcat(maskRegisteredFolder,p_id,"/",sk,".png"))
                end
            end
        end
    end

    if SAVE
        patImage = ImageSkullRemoved{patient};
        save(fname,'patImage','-v7.3')

        fileID = fopen(strcat(workspaceFolder,'minval.txt'),'a');
        fprintf(fileID,'%s %5.2f\n',p_id, min(minval(:)));
        fclose(fileID);
        fileID = fopen(strcat(workspaceFolder,'maxval.txt'),'a');   
        fprintf(fileID,'%s %5.2f\n',p_id, max(maxval(:)));
        fclose(fileID);

        clearvars ImageRegistered{patient}; % minval maxval
    end
    close all;
end
