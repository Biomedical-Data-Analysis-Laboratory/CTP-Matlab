function [stats,stats_modefilter] = finalizeParametricMaps(app)
%FINALIZEPARAMETRICMAPS Convert the manual annotations into GT images
%   Convert the manual annotations made on the GUI into the correct
%   grayscale values for generating ground truth images.

stats = table();
stats_modefilter = table();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
finalizeFolder = "FINALIZE_PM/"; 
if isfield(app,'finalizeFolder') % use to change the finalize folder 
    finalizeFolder  = app.finalizeFolder;
end
modeFilterFolder = "";
if isfield(app,'modeFilterFolder') % use to change the finalize folder 
    modeFilterFolder  = app.modeFilterFolder;
end
use_suffix = "superpixels"; %"tree";
if isfield(app,'overrideSuffix') % use to change the suffix for the ML method
    use_suffix  = app.overrideSuffix;
end

option = 1;
if isfield(app,'option') 
    option = app.option;
end

THRESHOLDING = 0;
if isfield(app,'THRESHOLDING') 
    THRESHOLDING = app.THRESHOLDING;
end
research_name = '';
if isfield(app,'research_name')
    research_name = app.research_name;
end
MODEFILTER = false;
if isfield(app,'MODEFILTER')
    MODEFILTER = app.MODEFILTER;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colorbarPointY = 436;

brain_color = 85;
penumbra_color = brain_color*2;
core_color = 255;
image_suffix = ".tiff";


if ispc % windows
    wb = uiprogressdlg(app.GUIAutomaticManualAnnotationsUIFigure,'Title','Please Wait',...
        'Message',strcat("Finalizing the parametric maps in", finalizeFolder, "..."));
end

if isstring(app.mainSavepath)
    app.mainSavepath = convertStringsToChars(app.mainSavepath);
end

% create the directory to contain the finalize parametric maps
if ~isfolder(strcat(app.mainSavepath,finalizeFolder)) && ~THRESHOLDING
    mkdir(strcat(app.mainSavepath,finalizeFolder))
end
if ~isfolder(strcat(app.mainSavepath,modeFilterFolder)) && ~THRESHOLDING
    mkdir(strcat(app.mainSavepath,modeFilterFolder))
end

if isstring(app.patientspath)
    app.patientspath = convertStringsToChars(app.patientspath);
end

if isempty(app.patients)
    for patientFold = dir(app.patientspath)'
        if ~strcmp(patientFold.name, '.') && ~strcmp(patientFold.name, '..')
            app.patients = [app.patients; convertCharsToStrings(patientFold.name)];
        end
    end
end

n_patients = numel(dir(app.patientspath))-2;
count = 1;

for patientFold = dir(app.patientspath)'
    n_fold = 0;
    % exclude the previous folders and the patients already analyzed by Kathinka.
    if ~strcmp(patientFold.name, '.') && ~strcmp(patientFold.name, '..')
        
    if ispc % windows
        wb.Value = count/n_patients;
        wb.Message = strcat("Analyzing patient: ", num2str(count), "/", num2str(n_patients));
        count = count + 1;
    else
        %disp(patientFold.folder + "/" + patientFold.name);
    end
    
    %% thresholding predictions
    if THRESHOLDING
        if sum(cellfun(@any,strfind(app.patients, patientFold.name)))>0
            for research_fld  = dir(patientFold.folder + "/" + patientFold.name + "/" + research_name + "/")'
                if ~strcmp(research_fld.name, '.') && ~strcmp(research_fld.name, '..') && ~research_fld.isdir
                    img_idx = split(research_fld.name,research_name);
                    img_idx = extractBetween(string(img_idx(1)),1,2);
                    img = imread(app.MANUAL_ANNOTATION_FOLDER+"/"+patientFold.name+"/"+img_idx+image_suffix);
                    img(img>0)= brain_color;
                    
                    if ~contains(app.research_name, "Cambell") && ~contains(app.research_name, "Wintermark")
                        penumbra = imread(research_fld.folder+"/penumbra/"+img_idx+"_"+research_name+"_penumbra.png");
                        if sum(sum(logical(penumbra)))<numel(penumbra)
                            img(penumbra>0) = penumbra_color;
                        end
                    else
                        penumbra = uint8(zeros(size(img)));
                    end
                    core = imread(research_fld.folder+"/core/"+img_idx+"_"+research_name+"_core.png");
                    if sum(sum(core))<numel(core)
                        img(core>0) = core_color;
                    end
                    if ~isfolder(strcat(finalizeFolder,patientFold.name))
                        mkdir(strcat(finalizeFolder,patientFold.name))
                    end
                    new_annotationImage_name = strcat(finalizeFolder,patientFold.name,"/",img_idx,".tiff");
                    img = uint8(img);
                    imwrite(img,new_annotationImage_name);
                    
                    if app.calculateSTATS        
                        calculateTogether = 1;

                        stats = statisticalInfo(stats, use_suffix,...
                            penumbra, core, app.MANUAL_ANNOTATION_FOLDER, patientFold.name, ...
                            str2double(img_idx), penumbra_color, core_color, 1, ...
                            image_suffix, calculateTogether, THRESHOLDING);
                    end
                end
            end
        end
    else
    %% enter here if the option is > 1 or the patient ID is different from Kathinka's annotations 
    if (~strcmp(patientFold.name, 'CTP_01_057') && ~strcmp(patientFold.name, 'CTP_01_059') && ~strcmp(patientFold.name, 'CTP_01_066') ...
            && ~strcmp(patientFold.name, 'CTP_01_068') && ~strcmp(patientFold.name, 'CTP_01_071') && ~strcmp(patientFold.name, 'CTP_01_073') ...
            && ~strcmp(patientFold.name, 'CTP_00_002') && ~strcmp(patientFold.name, 'CTP_00_006') && ~strcmp(patientFold.name, 'CTP_00_007') ...
            && ~strcmp(patientFold.name, 'CTP_00_009')) || option>1 
        
        if sum(cellfun(@any,strfind(app.patients, patientFold.name)))>0
        for subfold = dir(patientFold.folder + "/" + patientFold.name)'
            processMIP = false; % flag to process MIP folder only if there are annotations
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')
                for pm_fold = dir(subfold.folder + "/" + subfold.name)'
                    if ~strcmp(pm_fold.name, '.') && ~strcmp(pm_fold.name, '..')
                        if strcmp(pm_fold.name, "Annotations")
                            n_fold = n_fold+1;
                            
                            annot_folder = dir(pm_fold.folder + "/" + pm_fold.name);
                            n_elem = numel(annot_folder)-2;
                            
                            if n_elem > 0 % there is something in the annotations folder
                                disp(pm_fold.folder + "/" + pm_fold.name);
                                processMIP = true;
                                
                                if isfolder(strcat(app.mainSavepath,finalizeFolder,patientFold.name))
                                    delete(strcat(app.mainSavepath,finalizeFolder,patientFold.name,"/*"));
                                end
                                
                                name_indices = startsWith({annot_folder.name},use_suffix);
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
                                        
                                        % if all image is white (SVM for core) 
                                        if sum(sum(logical(img))) == size(img,1)*size(img,2)
                                            img = img .* 0; % empty the image
                                        end
                                        if ~app.KEEPALLPENUMBRA
                                            %% if penumbra: keep only the largest area
                                            if contains(type_annot,"penumbra")
                                                mask = zeros(size(img));
                                                labeledImg = bwlabel(img,8);
                                                r = regionprops(logical(img));
                                                allareas = [r.Area];

                                                if ~isempty(allareas)
                                                    keep_idx = find(allareas==max(allareas));
                                                    for x = keep_idx
                                                        mask = mask + (labeledImg==x);
                                                    end
                                                    img = mask;
                                                end
                                            end
                                        end
                                        

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
                                
                                % for 3D mode filter
                                stacked_preds = zeros(512,512,numel(mip_folder)-2);
                                stk_idx = 1;
                                for image = mip_folder' 
                                    if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                        id = image.name;
                                        id = replace(id,".png",image_suffix);
                                        
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
                                            
                                            mask_final = im2uint16(mip_img./256);
                                            mask_final = mask_final .* im2uint16(xor(mask_final,blank_img)./65535);
                                            
                                            final = mask_final+blank_img;
                                            
                                            % stack the predictions together
                                            stacked_preds(:,:,stk_idx) = final;
                                            stk_idx = stk_idx + 1;

                                            imwrite(final,new_annotationImage_name);
                                            
                                            if app.calculateSTATS        
                                                calculateTogether = 1;
                                                
                                                stats = statisticalInfo(stats, strcat(use_suffix,"_",getIndexFromPatient(patientFold.name,n_fold)),...
                                                    final, 0, app.MANUAL_ANNOTATION_FOLDER, patientFold.name, ...
                                                    replace(id,image_suffix,""), penumbra_color, core_color, 1, ...
                                                    image_suffix, calculateTogether, 0);
                                            end
                                        end
                                    end
                                end
                                
                                % we have a field for the mode filter folder
                                if ~strcmp(modeFilterFolder,"") && MODEFILTER
                                    if ~isfolder(strcat(app.mainSavepath,modeFilterFolder,patientFold.name))
                                        mkdir(strcat(app.mainSavepath,modeFilterFolder,patientFold.name))
                                    end
                                    preds_filter = modefilt(stacked_preds);
                                    for i = 1:size(preds_filter,3)
                                        index = num2str(i);
                                        if i<10
                                            index = strcat("0", num2str(i));
                                        end
                                        new_annotationImage_name = strcat(app.mainSavepath,modeFilterFolder,patientFold.name,"/",index,image_suffix);
                                        filt_img = uint16(preds_filter(:,:,i));
                                        
                                        imwrite(filt_img,new_annotationImage_name);
                                            
                                        if app.calculateSTATS        
                                            calculateTogether = 1;

                                            stats_modefilter = statisticalInfo(stats_modefilter, strcat(use_suffix,"_",getIndexFromPatient(patientFold.name,n_fold)),...
                                                filt_img, 0, app.MANUAL_ANNOTATION_FOLDER, patientFold.name, ...
                                                replace(id,image_suffix,""), penumbra_color, core_color, 1, ...
                                                image_suffix, calculateTogether, 0);
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
        end
    else
        %% here we have the annotations made by Kathinka
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

end

