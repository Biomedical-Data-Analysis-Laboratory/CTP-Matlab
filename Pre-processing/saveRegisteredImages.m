function saveRegisteredImages(NewImageRegistered, saveRegisteredFolder, patients, suffix, ...
    previousNumPatiens, newIDFormat, directory, SAVE_AS_TIFF, GROUP)
%SAVEREGISTEREDIMAGES Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 9
        GROUP = 1;
    end
    if nargin < 8
        SAVE_AS_TIFF = false;
    end
    if nargin < 7
        directory = "";
    end
    if nargin < 6
        newIDFormat = false;
    end

    for p=patients
        disp(strcat("Patient: ", num2str(p)));
        if newIDFormat
            if strcmp(directory{1,p},"") % don't save if there is no folder path
                continue
            end
            newFolder = extractBetween(directory{1,p}, strfind(directory{1,p}, "CTP_"), strfind(directory{1,p}, "CTP_")+9);
        else
            if (p+previousNumPatiens)<10
                newFolder = strcat("PA0", num2str(p+previousNumPatiens));
            else
                newFolder = strcat("PA", num2str(p+previousNumPatiens));
            end
        end
        status = mkdir(char(saveRegisteredFolder), char(newFolder)); % patient folder "PA01/"
        
        if status 
            subFolder = char(strcat(saveRegisteredFolder, newFolder, '/'));
            
% %             for fold = dir(subFolder)'
% %                 if ~strcmp(fold.name, '.') && ~strcmp(fold.name, '..') && ...
% %                         ~strcmp(fold.name, 'Tmax') && ~strcmp(fold.name, 'CBF') && ~strcmp(fold.name, 'MTT') && ...
% %                         ~strcmp(fold.name, 'CBV') && ~strcmp(fold.name, 'OT')
% %                     rmdir(strcat(fold.folder,"/",fold.name,"/"),'s');
% %                 end
% %             end
            
%             n_slices = length(NewImageRegistered{p});
            count = length(NewImageRegistered{p});
            n_slices = 1;

            % if we group (4D images) then we need another loop
            if GROUP
                n_slices = length(NewImageRegistered{p});
            end
            
            for k=1:n_slices
                slice = num2str(k);
                if length(slice) == 1
                    slice = strcat('0', slice);
                end
                
                if GROUP
                    mkdir(subFolder, char(slice));
                    count = length(NewImageRegistered{p}{k});
                end
                
                for i=1:count
                    index = num2str(i);
                    if i<10
                        index = strcat("0", num2str(i));
                    end

                    tmp_suffix = suffix;
                    if suffix ~= ""
                        tmp_suffix = strcat("_",suffix);
                    end
                    
                    if ~SAVE_AS_TIFF
                        if GROUP
                            image_name = char(strcat(subFolder, slice, "/", index, tmp_suffix, ".png"));
                        else
                            image_name = char(strcat(subFolder, index, tmp_suffix, ".png"));
                        end
                        
                        imwrite(mat2gray(NewImageRegistered{p}{k}{i}),image_name);
                    else
                        % write the time series of images as a .tiff image
                        % to maintain the uint16 format
                        if GROUP
                            image_name = char(strcat(subFolder, slice, "/", index, tmp_suffix, ".tiff"));
                        else
                            image_name = char(strcat(subFolder, index, tmp_suffix, ".tiff"));
                        end
                        
                        img = im2uint16(NewImageRegistered{p}{k}{i});
                        div = 1;
                        if length(unique(img))<1000 % only black pixels
                            div = 256;
                        end

                        imwrite(img./div,image_name);
                    end
                end
            end
        end
    end
end

