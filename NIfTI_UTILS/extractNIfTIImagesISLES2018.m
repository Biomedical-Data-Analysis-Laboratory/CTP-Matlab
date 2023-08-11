function [ImageRegistered,info] = extractNIfTIImagesISLES2018(directory, SAVE, workspaceFolder, suffix_workspace, ...
    subname, SAVE_IMAGES, save_folder, groundTruth_folder, justinfo, SAVE_AS_TIFF, BINARY_GT, overrideJump)
%EXTRACTNIFTIIMAGES Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin<12
        overrideJump = false;
    end
    if nargin < 11
        BINARY_GT = false;
    end
    if nargin < 10
        SAVE_AS_TIFF = false;
    end
    if nargin < 9
        justinfo = 0;
    end
    if nargin < 8
        groundTruth_folder = "";
    end
    if nargin < 7
        save_folder = "";
    end
    if nargin < 6
        SAVE_IMAGES = 0;
    end
    
    if SAVE_IMAGES && ~strcmp(save_folder, "") && ~isfolder(save_folder)
        mkdir(save_folder);
    end

    equalSign = char(61);
    mappingFileID = fopen(strcat(directory,'mapping.txt'), 'r');
    mappingFile = textscan(mappingFileID,['%s' equalSign '%s' '%u']);
    
    ImageRegistered = cell(1,numel(mappingFile{1,1}));
    info = struct();
    slice_array = [];
    
    suffixsave = ".png";
    if SAVE_AS_TIFF
        suffixsave = ".tiff";
    end
    
    save_prefix = '01_Extract.';
    
    for elem=1:numel(mappingFile{1,1})
        suffix_folder = strcat(mappingFile{1,2}{elem},"_", num2str(mappingFile{1,3}(elem)));
        id_pat = mappingFile{1,3}(elem); % IN ORDER NOT TO COMPACT THEM TOGETHER
        
        patientFolder = dir(strcat(directory, suffix_folder));
        
        name = num2str(id_pat);
        if length(name) == 1
            name = strcat('0', name);
        end
        
        fname = workspaceFolder + convertCharsToStrings(save_prefix) + name + suffix_workspace + ".mat";
        if exist(fname, 'file')==2 && ~overrideJump
            load(fname);
            ImageRegistered{id_pat} = patImage;
            continue
        end
        
        if SAVE_IMAGES && ~strcmp(save_folder, "") && ~isfolder(strcat(save_folder,"/PA",name))
            mkdir(strcat(save_folder,"/PA",name));
        end
        
        append_nslice = true;
        
        for subfold = patientFolder'
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')
                if contains(convertCharsToStrings(subfold.name), subname) % check the right folder based on the 'subname'
                    
                    if SAVE_IMAGES && ~strcmp(save_folder, "") && ~isfolder(strcat(save_folder,"/PA",name,"/",subname))
                        mkdir(strcat(save_folder,"/PA",name,"/",subname));
                    end
                    if SAVE_IMAGES && ~strcmp(groundTruth_folder, "") && ~isfolder(strcat(groundTruth_folder,"/PA",name,"/"))
                        mkdir(strcat(groundTruth_folder,"/PA",name,"/"));
                    end
                    
                    filename = strcat(subfold.folder,'/',subfold.name,'/',subfold.name,'.nii');
                    V = niftiread(filename);
                    infor = niftiinfo(filename);
                    
                    % set the i and k differently if the image has 4D 
                    if size(infor.ImageSize,2)>3
                        count = infor.ImageSize(4);
                        n_slices = infor.ImageSize(3);
                    else
                        count = infor.ImageSize(3);
                        n_slices = 1; 
                    end
                    
                    if justinfo % just gathering information about the image
                        info(elem).slices = count;
                        info(elem).SpaceUnits = infor.SpaceUnits;
                        info(elem).PixelDimensions = infor.PixelDimensions;
                        info(elem).slice_end = infor.raw.slice_end;
                        info(elem).slice_start = infor.raw.slice_start;
                        info(elem).slice_code = infor.raw.slice_code;
                        info(elem).slice_duration = infor.raw.slice_duration;
                    else
                        
                        if append_nslice
                            slice_array = [slice_array, infor.ImageSize(3)]; % populate the array containing the number of slices for each patient
                            append_nslice = false;
                        end
                        
                        ImageRegistered{id_pat} = cell(1,n_slices);
                        for k=1:n_slices
                            ImageRegistered{id_pat}{k} = cell(1,count);
                            for i=1:count
                                %% take the correct image based on the dimension 
                                if size(infor.ImageSize,2)>3
                                    ImageRegistered{id_pat}{k}{i} = V(:,:,k,i); %imresize(int16(V(:,:,k,i)),[512,512]);
                                else
                                    ImageRegistered{id_pat}{k}{i} = V(:,:,i); %imresize(int16(V(:,:,i)),[512,512]);
                                end

                                %% save the images
                                if SAVE_IMAGES && ~strcmp(save_folder, "")
                                    imgidx = num2str(i);
                                    if length(imgidx) == 1
                                        imgidx = strcat('0', imgidx);
                                    end
                                    % mat2gray normalize the image range [0,1]
                                    imwrite(mat2gray(ImageRegistered{id_pat}{k}{i}), strcat(save_folder,"/PA",name,"/",subname,"/", imgidx, suffixsave));  
    
                                    % save the ground truth is the folder is defined
                                    if ~strcmp(groundTruth_folder,"")
                                        if BINARY_GT 
                                            if strcmp(subname, "OT")
                                                imwrite(mat2gray(ImageRegistered{id_pat}{k}{i}), strcat(groundTruth_folder,"/PA",name,"/", imgidx, suffixsave));  
                                            end
                                        else

                                            if strcmp(subname, "MTT")
                                                brain = imfill((ImageRegistered{id_pat}{k}{i}>0)*1, 'holes');
                                                imwrite(brain, strcat(groundTruth_folder,"/PA",name,"/",imgidx,suffixsave));
                                            end

                                            if strcmp(subname, "OT")
                                                brain = double(imread(strcat(groundTruth_folder,"/PA",name,"/",imgidx,suffixsave)));
                                                gt = (ImageRegistered{id_pat}{k}{i}==1)*500;
                                                back = (ImageRegistered{id_pat}{k}{i}==0)*0;
                                                final = brain + gt + back;
                                                final(final==255) = 85; % convert the brain mask to the right color
                                                final(final==755) = 255; % convert the brain+core into the right color
                                                %final = imrotate(final, 90); % rotate the image
                                                imwrite(im2uint16(final./256), strcat(groundTruth_folder,"/PA",name,"/",imgidx,suffixsave));                                    
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if SAVE
                            patImage = ImageRegistered{id_pat};
                            save(fname,'patImage','-v7.3')
                        end
                        
                    end
                end
            end
        end
        
    end
    
    if SAVE
        % save(strcat(workspaceFolder, 'Image', suffix_workspace, '_', subname, '.mat'),'ImageRegistered','-v7.3')
        save(strcat(workspaceFolder, 'slice_array', suffix_workspace, '_', subname, '.mat'),'slice_array','-v7.3')
        if justinfo
            save(strcat(workspaceFolder, 'info', suffix_workspace, '_', subname, '.mat'),'info','-v7.3')
        end
    end
end

