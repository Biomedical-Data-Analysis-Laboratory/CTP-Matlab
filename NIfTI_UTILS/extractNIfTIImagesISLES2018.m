function ImageRegistered = extractNIfTIImagesISLES2018(directory, SAVE, workspaceFolder, suffix_workspace, subname, SAVE_IMAGES, save_folder, groundTruth_folder)
%EXTRACTNIFTIIMAGES Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin < 6
        SAVE_IMAGES = 0;
        if nargin < 7
            save_folder = "";
            if nargin < 8
                groundTruth_folder = "";
            end
        end
    end
    
    if SAVE_IMAGES && ~strcmp(save_folder, "")
        mkdir(save_folder);
    end

    equalSign = char(61);
    mappingFileID = fopen(strcat(directory,'mapping.txt'), 'r');
    mappingFile = textscan(mappingFileID,['%s' equalSign '%s' '%u']);
       
    for elem=1:numel(mappingFile{1,1})
%         id_pat = mappingFile{1,1}{elem};
%         id_pat = str2double(id_pat(end-3:end-2));
        suffix_folder = strcat(mappingFile{1,2}{elem},"_", num2str(mappingFile{1,3}(elem)));
        id_pat = mappingFile{1,3}(elem); % IN ORDER NOT TO COMPACT THEM TOGETHER
        
        patientFolder = dir(strcat(directory, suffix_folder));
        
        name = num2str(id_pat);
        if length(name) == 1
            name = strcat('0', name);
        end
        
        if SAVE_IMAGES && ~strcmp(save_folder, "")
            mkdir(strcat(save_folder,"/PA",name));
        end
        
        for subfold = patientFolder'
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')
                if contains(convertCharsToStrings(subfold.name), subname) % check the right folder based on the 'subname'
                    
                    if SAVE_IMAGES && ~strcmp(save_folder, "")
                        mkdir(strcat(save_folder,"/PA",name,"/",subname));
                    end
                    if SAVE_IMAGES && ~strcmp(groundTruth_folder, "")
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
                    for k=1:n_slices
                        for i=1:count
                            cur_k = k;
                            
                            if size(infor.ImageSize,2)>3
                                ImageRegistered{id_pat}{cur_k}{i} = uint16(V(:,:,k,i));
                            else
                                ImageRegistered{id_pat}{cur_k}{i} = uint16(V(:,:,i));
                            end
                            
                            if SAVE_IMAGES && ~strcmp(save_folder, "")
                                imgidx = num2str(i);
                                if length(imgidx) == 1
                                    imgidx = strcat('0', imgidx);
                                end
                                imwrite(mat2gray(ImageRegistered{id_pat}{cur_k}{i}), strcat(save_folder,"/PA",name,"/",subname,"/", imgidx, ".png"));  
                                
                                if strcmp(subname, "MTT")
                                    brain = imfill((ImageRegistered{id_pat}{cur_k}{i}>0)*1, 'holes');
                                    imwrite(brain, strcat(groundTruth_folder,"/PA",name,"/",imgidx,".png"));
                                end
                                if strcmp(subname, "OT")
                                    brain = double(imread(strcat(groundTruth_folder,"/PA",name,"/",imgidx,".png")));
                                    gt = (ImageRegistered{id_pat}{cur_k}{i}==1)*155;
                                    back = (ImageRegistered{id_pat}{cur_k}{i}==0)*255;
                                    final = brain + gt + back;
                                    final(final==510) = 1;
                                    final(final==410) = 150;
                                    imwrite(mat2gray(final), strcat(groundTruth_folder,"/PA",name,"/",imgidx,".png"));                                    
                                end
                            end
                        end
                    end
                end
            end
        end
        
    end
    
    if SAVE
        save(strcat(workspaceFolder, 'Image', suffix_workspace, '_', subname, '.mat'),'ImageRegistered','-v7.3')
    end
end

