function finalizeParametricMaps(app)
%FINALIZEPARAMETRICMAPS Summary of this function goes here
%   Detailed explanation goes here

finalizeFolder = "FINALIZE_PM/";
colorbarPointY = 436;
penumbra_color = 76;
core_color = 150;


wb = uiprogressdlg(app.GUIAutomaticManualAnnotationsUIFigure,'Title','Please Wait',...
    'Message',strcat("Finalizing the parametric maps in", finalizeFolder, "..."));

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
    if ~strcmp(patientFold.name, '.') && ~strcmp(patientFold.name, '..')
        wb.Value = count/n_patients;
        wb.Message = strcat("Analyzing patient: ", num2str(count), "/", num2str(n_patients));
        count = count + 1;
        
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
                                
                                if ~isfolder(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                                    mkdir(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                                end
                                if ~isfolder(strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",subfold.name))
                                    mkdir(strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",subfold.name))
                                else
                                    delete(strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",subfold.name,"/*"));
                                end
                                
                                for image = annot_folder'
                                    if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                        tmp_imgname = split(image.name,"_");
                                        id = convertCharsToStrings(tmp_imgname{4});
                                        type_annot = tmp_imgname{5};
                                        
                                        img = imread(image.folder+"/"+image.name);
                                                                                
                                        new_annotationImage_name = strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",subfold.name,"/",id,".png");
                                        if isfile(new_annotationImage_name)
                                            % the image already exist
                                            blank_img = imread(new_annotationImage_name);
                                            if contains(type_annot,"penumbra")
                                                blank_img = double(logical(blank_img).*core_color);
                                            end
                                        else
                                            blank_img = zeros(size(img,1)).*255;
                                        end
                                        
                                        if contains(type_annot,"penumbra")
                                            color = penumbra_color;
                                        elseif contains(type_annot,"core")
                                            color = core_color;
                                        end
                                        
                                        blank_img = double(blank_img) + double(logical(img).*color);
                                        imwrite(uint8(blank_img),new_annotationImage_name);
                                    end
                                end
                            end
                        elseif strcmp(pm_fold.name,"MIP")
                            if processMIP
                                mip_folder = dir(pm_fold.folder + "/" + pm_fold.name);
                                for image = mip_folder' 
                                    if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                        id = image.name;
                                        new_annotationImage_name = strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/",subfold.name,"/",id);
                                        
                                        if isfile(new_annotationImage_name)
                                            mip_img = ~imfill(logical(rgb2gray(imread(strcat(image.folder+"/"+image.name)))),'holes');
                                            mip_img(:,colorbarPointY:end) = 255; % remove F in the bottom right
                                        
                                            blank_img = imread(new_annotationImage_name); 
                                            % change the color the part where
                                            % penumbra and core are oerlapping
                                            % to only core!
                                            blank_img(blank_img==(penumbra_color+core_color)) = core_color;
                                        
                                            final = (double(mip_img).*255)+double(blank_img);
                                            imwrite(uint8(final),new_annotationImage_name);
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

end

