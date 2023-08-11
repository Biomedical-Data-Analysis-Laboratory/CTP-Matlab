function saveRegisteredImages(NewImageRegistered, saveRegisteredFolder, saveForVISUALFolder, patients, suffix, ...
    previousNumPatiens, newIDFormat, directory, SAVE_AS_TIFF, PREPROCESSING, GROUP, maskRegisteredFolder, ...
    CONVERT_TO_HU, CONVERT_TO_DOUBLE)
%SAVEREGISTEREDIMAGES Function to save the final registered images
%   The function creates the corresponding folders and subfolders.
%   Plus, it saves the images accordingly to the arguments flag (double,
%   HU, contrast enhancement, ...).

    if nargin < 14
        CONVERT_TO_DOUBLE = false;
    end
    if nargin < 13
        CONVERT_TO_HU = false;
    end
    if nargin < 12
        maskRegisteredFolder = "";
    end
    if nargin < 11
        GROUP = 1;
    end
    if nargin < 10
        PREPROCESSING = true;
    end
    if nargin < 9
        SAVE_AS_TIFF = false;
    end
    if nargin < 8
        directory = "";
    end
    
    if nargin < 7
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
       
        %% only go here if the folders are not created
        if ~isfolder(strcat(char(saveRegisteredFolder), char(newFolder))) && ~isfolder(strcat(char(saveForVISUALFolder), char(newFolder)))
        mkdir(strcat(char(saveRegisteredFolder), char(newFolder))); % patient folder "PA01/"
        mkdir(strcat(char(saveForVISUALFolder), char(newFolder))); % patient folder "PA01/"
        end
        subFolder = char(strcat(saveRegisteredFolder, newFolder, '/'));
        subVisualFolder = char(strcat(saveForVISUALFolder, newFolder, '/'));

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
        
        cellpatient = cell2mat([NewImageRegistered{p}{:,:}]);
        max_p = double(max(max(cellpatient)));
        min_p = double(min(min(cellpatient)));
        
        for k=1:n_slices
            slice = num2str(k);
            if length(slice) == 1
                slice = strcat('0', slice);
            end

            if GROUP
                mkdir(subFolder, char(slice));
                mkdir(subVisualFolder, char(slice));
                count = length(NewImageRegistered{p}{k});
            end

            plot_val = cell(512*512,count);
            
            for i=1:count
                index = num2str(i);
                if i<10
                    index = strcat("0", num2str(i));
                end

                tmp_suffix = suffix;
                if suffix ~= ""
                    tmp_suffix = strcat("_",suffix);
                end

                %% check how to save the images
                if ~SAVE_AS_TIFF
                    if GROUP
                        image_name = char(strcat(subFolder, slice, "/", index, tmp_suffix, ".png"));
                        image_name_visual = char(strcat(subVisualFolder, slice, "/", index, tmp_suffix, ".png"));
                    else
                        image_name = char(strcat(subFolder, index, tmp_suffix, ".png"));
                        image_name_visual = char(strcat(subVisualFolder, index, tmp_suffix, ".png"));
                    end

                    imwrite(im2uint16(NewImageRegistered{p}{k}{i}),image_name);
                    imwrite(mat2gray(NewImageRegistered{p}{k}{i}, [min_p,max_p]),image_name_visual);
                else
                    % write the time series of images as a .tiff image to maintain the uint16 format
                    if GROUP
                        image_name = char(strcat(subFolder, slice, "/", index, tmp_suffix, ".tiff"));
                        image_name_visual = char(strcat(subVisualFolder, slice, "/", index, tmp_suffix, ".tiff"));
                    else
                        image_name = char(strcat(subFolder, index, tmp_suffix, ".tiff"));
                        image_name_visual = char(strcat(subVisualFolder, index, tmp_suffix, ".tiff"));
                    end
                    
                    img = im2double(mat2gray(NewImageRegistered{p}{k}{i}, [min_p,max_p]));

                    %% save the raw image
                    if CONVERT_TO_HU
                        if CONVERT_TO_DOUBLE
                            % convert into range [0 1] after converting to
                            % [min_p 600] 600 is the crop value for the HU 
                           imwrite(im2double(mat2gray(NewImageRegistered{p}{k}{i}, [min_p 600])),image_name)
                        else
                            imwrite(im2uint16(NewImageRegistered{p}{k}{i}),image_name);
                        end
                    else 
                        imwrite(mat2gray(NewImageRegistered{p}{k}{i}),image_name)
                    end
                    imwrite(img,image_name_visual);
                    
                    for xx = 0:size(img,1)-1
                        for yy = 1:size(img,2)
                            plot_val{xx*size(img,1)+yy,i} = img(xx+1,yy);
                        end
                    end 
                end
            end
            
            % if ispc
            %     plotFolder = replace(saveForVISUALFolder, "FINAL_TIFF_", "PLOT_");
            %     mkdir(char(plotFolder))
            %     mkdir(char(plotFolder), char(newFolder)); 
            % 
            %     unique_plot_val = unique(cell2mat(plot_val),"rows");
            %     clear plot_val 
            %     rows = randi(size(unique_plot_val,1),50,1);
            %     f = figure('visible', 'off');
            %     plot(unique_plot_val(rows,:)')
            %     print(strcat(plotFolder,newFolder,"/",slice),'-djpeg')
            %     close(f)
            %     clear unique_plot_val 
            % end
        end
        
        % if ispc
        %     plotFolder = replace(saveForVISUALFolder, "FINAL_TIFF_", "PLOT_");
        %     a = reshape(cellpatient(cellpatient~=-1024),[],1);
        %     f = figure('visible', 'off');
        %     histogram(a)
        %     print(strcat(plotFolder,newFolder,"/pixelvals"),'-djpeg')
        %     close(f)
        %     clear a
        % end
        
        NewImageRegistered{p} = [];
    end
end

