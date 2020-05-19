function saveRegisteredImages(NewImageRegistered, saveRegisteredFolder, patients, suffix, previousNumPatiens, newIDFormat, directory, GROUP)
%SAVEREGISTEREDIMAGES Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 8
        GROUP = 1;
    end

    for p=patients
        if strcmp(directory{1,p},"") % don't save if there is no folder path
            continue
        end
        
        if newIDFormat
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
% %                     rmdir(strcat(fold.folder,"\",fold.name,"\"),'s');
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
                name = num2str(k);
                if length(name) == 1
                    name = strcat('0', name);
                end
                
                if GROUP
                    mkdir(subFolder, char(name));
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
                    
                    if GROUP
                        image_name = char(strcat(subFolder, name, "/", index, tmp_suffix, ".png"));
                        imwrite(mat2gray(NewImageRegistered{p}{k}{i}),image_name);
                    else
                        image_name = char(strcat(subFolder, index, tmp_suffix, ".png"));
                        imwrite(mat2gray(NewImageRegistered{p}{i}),image_name);
                    end
                end
            end
        end
    end
end

