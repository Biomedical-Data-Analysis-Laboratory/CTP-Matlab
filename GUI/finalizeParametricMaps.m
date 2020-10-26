function finalizeParametricMaps(app)
%FINALIZEPARAMETRICMAPS Summary of this function goes here
%   Detailed explanation goes here

finalizeFolder = "FINALIZE_PM/"; 
if isfield(app,'finalizeFolder') % use to change the finalize folder 
    finalizeFolder  = app.finalizeFolder;
end

use_suffix = "tree";
if isfield(app,'overrideSuffix') % use to change the suffix for the ML method
    use_suffix  = app.overrideSuffix;
end

option = 1;
if isfield(app,'option') % use to change the suffix for the ML method
    option = app.option;
end

colorbarPointY = 436;

brain_color = 85;
penumbra_color = brain_color*2;
core_color = 255;

if ispc % windows
    wb = uiprogressdlg(app.GUIAutomaticManualAnnotationsUIFigure,'Title','Please Wait',...
        'Message',strcat("Finalizing the parametric maps in", finalizeFolder, "..."));
end

if isstring(app.mainSavepath)
    app.mainSavepath = convertStringsToChars(app.mainSavepath);
end

% create the directory to contain the finalize parametric maps
if ~isfolder(strcat(app.mainSavepath,finalizeFolder))
    mkdir(strcat(app.mainSavepath,finalizeFolder))
end

if isstring(app.patientspath)
    app.patientspath = convertStringsToChars(app.patientspath);
end

n_patients = numel(dir(app.patientspath))-2;
count = 1;

for patientFold = dir(app.patientspath)'
    % exclude the previous folders and the patients already analyzed by Kathinka.
    if ~strcmp(patientFold.name, '.') && ~strcmp(patientFold.name, '..')
        
    if ispc % windows
        wb.Value = count/n_patients;
        wb.Message = strcat("Analyzing patient: ", num2str(count), "/", num2str(n_patients));
        count = count + 1;
    else
        disp(patientFold.name);
    end
    
    %% enter here if the option is > 1 or the patient ID is different from Kathinka's annotations 
    if (~strcmp(patientFold.name, 'CTP_01_057') && ~strcmp(patientFold.name, 'CTP_01_059') && ~strcmp(patientFold.name, 'CTP_01_066') ...
            && ~strcmp(patientFold.name, 'CTP_01_068') && ~strcmp(patientFold.name, 'CTP_01_071') && ~strcmp(patientFold.name, 'CTP_01_073') ...
            && ~strcmp(patientFold.name, 'CTP_00_002') && ~strcmp(patientFold.name, 'CTP_00_006') && ~strcmp(patientFold.name, 'CTP_00_007') ...
            && ~strcmp(patientFold.name, 'CTP_00_009')) || option>1 
        
        for subfold = dir(patientFold.folder + "/" + patientFold.name)'
            processMIP = false; % flag to process MIP folder only if there are annotations
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')
                for pm_fold = dir(subfold.folder + "/" + subfold.name)'
                    if ~strcmp(pm_fold.name, '.') && ~strcmp(pm_fold.name, '..')
                        if strcmp(pm_fold.name, "Annotations")
                            annot_folder = dir(pm_fold.folder + "/" + pm_fold.name);
                            n_elem = numel(annot_folder)-2;
                            
                            if n_elem > 0 % there is something in the annotations folder
                                processMIP = true;
                                
                                if isfolder(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                                    delete(strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/*"));
                                end
                                
                                name_indices = contains({annot_folder.name},use_suffix);
                                % go here only if we have some indices that
                                % correspond to the suffix
                                for image = flip(annot_folder(name_indices)')
                                    if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                        if ~isfolder(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                                            mkdir(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                                        end
                                        
                                        tmp_imgname = split(image.name,"_");
                                        id = convertCharsToStrings(tmp_imgname{end-1});
                                        type_annot = tmp_imgname{end};

                                        img = imread(image.folder+"/"+image.name);

                                        new_annotationImage_name = strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",id,".tiff");
                                        if isfile(new_annotationImage_name)
                                            % the image already exist
                                            blank_img = imread(new_annotationImage_name);
                                            if contains(type_annot,"core")
                                                blank_img = double(logical(blank_img).*penumbra_color);
                                            end
                                        else
                                            blank_img = zeros(size(img,1));
                                        end

                                        if contains(type_annot,"penumbra")
                                            color = penumbra_color;
                                            blank_img = double(blank_img) + double(logical(img).*color);
                                        elseif contains(type_annot,"core")
                                            color = core_color;
                                            blank_img = double(blank_img) + double(logical(img & blank_img).*color);
                                        end


                                        mapped_blank = im2uint16(blank_img./256);

                                        imwrite(mapped_blank,new_annotationImage_name);
                                    end
                                end
                            end
                        elseif strcmp(pm_fold.name,"MIP") || isfield(app,'realpatientspath')
                            if processMIP
                                if isfield(app,'realpatientspath')
                                    pmfold = pm_fold.folder;
                                    mip_folder = dir(replace(pmfold,app.patientspath,app.realpatientspath) + "/MIP");
                                else
                                    mip_folder = dir(pm_fold.folder + "/" + pm_fold.name);
                                end
                                
                                for image = mip_folder' 
                                    if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                        id = image.name;
                                        id = replace(id,".png",".tiff");
                                        
                                        new_annotationImage_name = strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",id);
                                        
                                        if isfile(new_annotationImage_name)
                                            tmp_img = rgb2gray(imread(strcat(image.folder+"/"+image.name)));
                                            tmp_img(tmp_img==tmp_img(1,1)) = 0; % put all the elements equal the right-top pixel = 0
                                            mip_img = ~imfill(logical(tmp_img),'holes');
                                               
                                            mip_img = double(~mip_img) .* brain_color; % new brain color
                                            
                                            mip_img(:,colorbarPointY:end) = 0; % remove F in the bottom right
                                            % remove the text in the top of the image (if exists)
                                            mip_img = ~bwareaopen(~mip_img, 60);
                                            mip_img = double(mip_img) .* brain_color; % new brain color
                                            
                                            blank_img = imread(new_annotationImage_name); 
                                            % change the color the part where
                                            % penumbra and core are oerlapping
                                            % to only core!
%                                             blank_img(blank_img==(penumbra_color+core_color)) = core_color;
                                        
%                                             final = (double(mip_img).*0)+double(blank_img);
                                            
                                            mask_final = im2uint16(mip_img./256);
                                            mask_final = mask_final .* im2uint16(xor(mask_final,blank_img)./65535);
                                            
                                            final = mask_final+blank_img;

                                            imwrite(final,new_annotationImage_name);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            if processMIP
                break
            end
        end
    else
        % here we have the annotations made by Kathinka
        
        for subfold = dir(patientFold.folder + "/" + patientFold.name)'
            processMIP = false; % flag to process MIP folder only if there are annotations
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')
                for pm_fold = dir(subfold.folder + "/" + subfold.name)'
                    if ~strcmp(pm_fold.name, '.') && ~strcmp(pm_fold.name, '..')
                        if strcmp(pm_fold.name, "Annotations")
                            annot_folder = dir(pm_fold.folder + "/" + pm_fold.name);
                            n_elem = numel(annot_folder)-2;
                            
                            if n_elem > 0 % there is something in the annotations folder
                                processMIP = true;
                            end
                            if ~isfolder(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                                mkdir(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                            else 
                                delete(strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/*"));
                            end
                                
                            for image = annot_folder'
                                if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                    img = imread(image.folder+"/"+image.name);
                                    if ndims(img)==3
                                        img = rgb2gray(img);
                                    end
                                    
                                    id = convertCharsToStrings(replace(image.name,".png",""));
                                    new_annotationImage_name = strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",id,".tiff");
                                    
                                    % convert the old colors to the new ones
                                    img(img==0) = brain_color;
                                    img(img==255) = 0;
                                    img(img>=20 & img<=80) = penumbra_color;
                                    img(img>=120 & img<=160) = core_color;
                                    
                                    imwrite(imfill(im2uint16(img)),new_annotationImage_name);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    end
end

end

