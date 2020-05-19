function [predictions,statsClassific] = mainExtractionFunc(patients,perfusionCTFolder,MANUAL_ANNOTATION_FOLDER,SAVED_MODELS_FOLDER,saveFolder,subsavefolder,subfolds,SHOW_IMAGES,LOAD_AND_PREDICT_PATIENT,workspaceFolder,appUIFIGURE)
%MAINEXTRACTIONFUNC Summary of this function goes here
%   Detailed explanation goes here

if nargin<7
    LOAD_AND_PREDICT_PATIENT = 0;
    if nargin<8
        workspaceFolder = saveFolder;
        if nargin<9
            appUIFIGURE = uifigure;
        end
    end
end

wb = uiprogressdlg(appUIFIGURE,'Title','Please Wait',...
    'Message','Start analyzing patients...');

%% CONSTANTS
PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
SAVE_PAR_MAPS = 0; % flag to save the parametric maps
SAVE_TRESHOLDING = 0; % flag to save the thresholding values
flag_PENUMBRACORE = 1; % to run also the penumbra-core statistics
DIFFERENT_PERCENTAGES = 0; % use only for the ROC curve
SUPERVISED_LEARNING = 0; % flag for the supervised learning (with or without the ground truth)
FAKE_MIP = 0; % use to just ignore the old infarction presented in the MIP (maximum intensity projection) images
SUFFIX_RES = 'tree'; % 'SVM' // 'tree' // 'SVM_tree' 
USE_UNIQUE_MODEL = true; % for creating a unque model and not passing through a cross-validation over the patiens


%% initialize variables 
% flag for the leave-one-out prediction (predict with other models!)
totalTableData =  table();
STEPS = 2;
totalNImages = cell(1,numel(patients));
predictionMasks = cell(3,numel(patients));

stats = table();
statsClassific = table();

MODELS_PENUMBRA = cell(1,numel(patients));
MODELS_CORE = cell(1,numel(patients));

%% load the saved stats
% if exist(strcat(SAVED_MODELS_FOLDER,"statsClassific_2steps_",SUFFIX_RES,".mat"),'file')
%     load(strcat(SAVED_MODELS_FOLDER,"statsClassific_2steps_",SUFFIX_RES,".mat"));
% end


%% colors index
colorbarPointTopX = 129;
colorbarPointBottomX = 384;
colorbarPointY = 436;
penumbra_color = 76;
core_color = 150;

%% values for each parametric map [perc(%), up/down, core/penumbra]

researchesValues = containers.Map;
researchesValues(strcat('superpixels2steps_',SUFFIX_RES)) = struct('cluster',"yes"); % no need of thresholding values!

% researchesValues('Cereda_2015') = struct('CBF', [38, "down", "core", ""], 'TMax', [33, "up", "penumbra", ""]);
% researchesValues('Wintermark_2006') = struct('CBV', [33, "down", "core", ""]); %, 'MTT', [6, "up", "penumbra"]);
% researchesValues('Ma_Cambell_2019') = struct('CBF', [30, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
% % % researchesValues('Bivard_Lin_2014') = struct('CBF', [30, "down", "core"], 'TMax', [50, "up", "penumbra"]);
% % 
% researchesValues('Shaefer_2014') = struct('CBF', [15, "down", "core", ""], 'CBV', [30, "down", "core", ""]);
% % 
% % % researchesValues('Bivard_2014') = struct('CBF', [50, "down", "core"], 'TTP', [75, "up", "penumbra"]);
% researchesValues('Cambell_2012') = struct('CBF', [31, "down", "core", 10], 'TTP', [20, "up", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
% researchesValues('Murphy_2006') = struct('CBF', [13.3, "down", "core", ""], 'CBV', [18.6, "down", "core", 5], 'CBF_2', [25, "down", "penumbra", ""], 'CBV_2', [36, "down", "penumbra", 10]);
% % % researchesValues('Shaefer_2006') = struct('CBF', [17.92, "down", "penumbra"], 'CBV', [24.5, "down", "core"]);
% % % researchesValues('Shaefer_2006_2') = struct('CBF', [8.8, "down", "core"], 'CBV', [49, "down", "penumbra"]);
% % % researchesValues('Bivard') = struct('CBF', [50, "down", "core"], 'TTP', [75, "down", "penumbra"]);
% % %researchesValues('COMB_Wintermark_Shaefer') = struct('CBV', [24.5, "down", "core"], 'CBF', [30, "down", "penumbra"], 'TMax', [50, "up", "penumbra"], 'TTP', [75, "up", "penumbra"]);

%% for each suffix 
for suff = researchesValues.keys
    count = 0;
    
    suffix = suff{1};
    research = researchesValues(suffix);
    parametricMaps = fieldnames(research);
    
%     if exist(strcat(saveFolder,"totalTableData.mat"),'file')==0
    %% for each patient
    for p=1:numel(patients)
        
        percToLoop = 0:10:100;
        if ~DIFFERENT_PERCENTAGES
            percToLoop = -1;
        end
        
        for perce=percToLoop
        tic
        savePenumbra = 1;
        saveCore = 1;
        count = count + 1;
        n_fold = 0;
        number_of_slice_per_pm = 0;
        
        patient = convertStringsToChars(patients(p));

        combinedResearchCoreMaks = cell(1,50); % initialize the combined core mask
        combinedResearchPenumbraMaks = cell(1,50); % initialize the combined penumbra mask

        for dayFold = dir(strcat(perfusionCTFolder, patient))'
        if ~strcmp(dayFold.name, '.') && ~strcmp(dayFold.name, '..') 
        n_fold = n_fold + 1;
        
        disp(strcat(patient, " - ", dayFold.name));
        
        % count the subfolders inside the dayFold, sutracting the
        % "Annotations" and "Original" folders from the count and if the
        % number is lless than the number of the initial subfolds, do nothing
        foldsInsideDayFold = struct2cell(dir(strcat(dayFold.folder,'/',dayFold.name)));
        foldsInsideDayFold = foldsInsideDayFold(1,3:end);
        subsavefoldcount = 0;
        for subfold_name = subsavefolder
            subfold_name = convertStringsToChars(subfold_name);
            if any(strcmp(foldsInsideDayFold, subfold_name(1:end-1)))
               subsavefoldcount = subsavefoldcount + 1;
            end
        end
        if (numel(foldsInsideDayFold) - subsavefoldcount) < numel(subfolds)
            continue
        end
        
        %% for each subfolder of parametric maps   
        for s=1:numel(subfolds)
            subfold = subfolds(s);
            intermediateFold = '/';
            if ~PARAMETRIC_IMAGES_TO_ANALYZE
                intermediateFold = '/ST000000/';
            end
            folderPath = strcat(perfusionCTFolder,patient,'/',dayFold.name,intermediateFold,convertStringsToChars(subfold),'/');
            n = numel(dir(folderPath))-2;
            
            if s==1
                number_of_slice_per_pm = n; % set it for later comparison
            else
                if number_of_slice_per_pm~=n
                    % at the moment it's only happening with CTP_01_069...
                    disp("number of slices not equal in the PM");
                    break
                end
            end

            savedAnnotationFolderPath = strcat(perfusionCTFolder,patient,'/',dayFold.name,intermediateFold,subsavefolder{2});
            saved_n = numel(dir(savedAnnotationFolderPath))-2;

            if (saved_n/2) < n % nothing already saved in the original folder
                %% initialize the cells if we are cecking the grayscale image 
                if subfold == subfolds(1)
                    tryImage = cell(1,n); % initialize the ground truth cell
                    groundTruthImage = cell(1,n); % initialize the ground truth cell
                    coreImage = cell(1,n); % initialize the core image cell
                    penumbraImage = cell(1,n); % initialize the penumbra image cell
                    %%
                    totalCoreMask = cell(1,n);
                    totalPenumbraMask = cell(1,n);
                    imageCBV = cell(1,n);
                    imageCBF = cell(1,n);
                    imageTTP = cell(1,n);
                    imageTMAX = cell(1,n);
                    %%
                    sortImages = cell(5,n); % 5 == number of parametric maps + enhanced image
                    skullMasks = cell(5,n);
                end

                %% get the information of the various map for a specific subfolder
                [combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks,penumbraImage,...
                totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,stats,tableData,nImages] = ...
                    getInfoFromSubfold(subfold,subfolds,PARAMETRIC_IMAGES_TO_ANALYZE,research,folderPath,patient,n_fold,...
                    MANUAL_ANNOTATION_FOLDER,saveFolder,colorbarPointY,parametricMaps,SUPERVISED_LEARNING,FAKE_MIP,...
                    suffix,colorbarPointBottomX,colorbarPointTopX,penumbra_color,core_color,flag_PENUMBRACORE,SAVE_PAR_MAPS,count,perce, ...
                    combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks, ...
                    penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,stats);

                if subfold == subfolds(end)
                    totalNImages{1,p} = nImages;
                    predictionMasks{1,p} = cell(1,nImages);
                    for sm=1:size(skullMasks,2)
                        predictionMasks{1,p}{1,sm} = ones(size(skullMasks{1,sm})); % skullMasks{1,p};
                    end
                    if ~LOAD_AND_PREDICT_PATIENT
                        % concatenate the data information in a table
                        % can create memory problem if there are too many
                        % patients too predict (use the elseif statement in case!!
                        totalTableData = [totalTableData; tableData]; %#ok<*AGROW>
                    elseif LOAD_AND_PREDICT_PATIENT
                        pIndex = getIndexFromPatient(patient,n_fold);
                        patientSubFold = strcat(patient,'/', dayFold.name, '/');                
                        continue_pred = 1;
                        for sf = subsavefolder
                            if ~exist(strcat(saveFolder, patientSubFold, sf),'dir')
                                mkdir(strcat(saveFolder, patientSubFold, sf));
                            end

                            if strcmp(sf, subsavefolder{2})
                                saved_n = numel(dir(strcat(saveFolder, patientSubFold, sf)))-2;
                                if isempty(totalNImages{1,p}) % if the annotations are already saved 
                                    continue_pred = 0; % continue the loop without predicting 
                                    break
                                end
                            end
                        end

                        if continue_pred==0
                            continue
                        end
                        
                        [predictions,statsClassific,~] = predictWithUnsupervisedLearning(p,pIndex,suffix,tableData,predictionMasks,...
                            MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING,totalNImages,...
                            statsClassific,patientSubFold,saveFolder,subsavefolder,SHOW_IMAGES,...
                            SAVED_MODELS_FOLDER,SUFFIX_RES,STEPS,USE_UNIQUE_MODEL);
                    end
                end
            else
                manualAnnotFolderPath = strcat(perfusionCTFolder,patient,'/',dayFold.name,intermediateFold,subsavefolder{1});
                saved_n = numel(dir(manualAnnotFolderPath))-2;
                if saved_n == 0 % no manual annotations saved
                    pIndex = getIndexFromPatient(patient,n_fold);
                    for xx = 1:n
                        for reg = ["penumbra","core"]
                            name = num2str(xx);
                            if length(name) == 1
                                name = strcat('0', name);
                            end
                            name = name + "_" + reg;
                            imwrite(zeros(512), strcat(perfusionCTFolder,patient,'/',dayFold.name,intermediateFold,subsavefolder{1}, suffix, "_", pIndex, "_", name, ".png"));
                        end
                    end
                    
                end

            end
        end
        end
        end

        %% Save the thresholding images
        if SAVE_TRESHOLDING
            saveThresholdingImages(saveFolder,patient,suffix,research,tryImage,...
                MANUAL_ANNOTATION_FOLDER,penumbraImage,coreImage,penumbra_color,core_color,...
                totalCoreMask,totalPenumbraMask,saveCore,savePenumbra);    
        end
        toc
        end
        
        divided = 1;
        msg = "Loaded and predicted patient ";
        if isfield(research, "cluster") && strcmp(research.cluster, "yes") && ~LOAD_AND_PREDICT_PATIENT
            divided = 2;
            msg = "Loaded patient ";
        end
        
        wb.Value = ((p/numel(patients))/divided);
        wb.Message = strcat(msg, num2str(p), "/", num2str(numel(patients)));
        
    end
        
    wb.Value = (p/numel(patients))/divided;
    wb.Message = "Saving workspace...";

    save(strcat(workspaceFolder,"totalTableData.mat"), 'totalTableData', '-v7.3');
    save(strcat(workspaceFolder,"totalNImages.mat"), 'totalNImages', '-v7.3');
    save(strcat(workspaceFolder,"predictionMasks.mat"), 'predictionMasks', '-v7.3');
    
%     else
%     
%         load(strcat(saveFolder,"totalTableData.mat"));
%         load(strcat(saveFolder,"totalNImages.mat"));
%         load(strcat(saveFolder,"predictionMasks.mat"));
%     end
    if isfield(research, "cluster") && strcmp(research.cluster, "yes") && ~LOAD_AND_PREDICT_PATIENT
        
        wb.Value = (p/numel(patients))/2;
        wb.Message = "Predicting patient(s)...";
        
        %% for each patient
        for p=1:numel(patients)
            
            patient = convertStringsToChars(patients(p));
            n_fold = 0;
            
            % progress bar update
            wb.Value = ((p/numel(patients))/2) + 0.5;
            wb.Message = strcat("Predicting patient ", num2str(p), "/", num2str(numel(patients)), "...");

            for dayFold = dir(strcat(saveFolder, patient))'
            if ~strcmp(dayFold.name, '.') && ~strcmp(dayFold.name, '..') 
            
            n_fold = n_fold + 1;
            pIndex = getIndexFromPatient(patient,n_fold);
            
            patientSubFold = strcat(patient,'/', dayFold.name, '/');
                
            continue_pred = 1;
            for sf = subsavefolder
                if ~ exist(strcat(saveFolder, patientSubFold, sf),'dir')
                    mkdir(strcat(saveFolder, patientSubFold, sf));
                end
                
                if strcmp(sf, subsavefolder{2})
                    saved_n = numel(dir(strcat(saveFolder, patientSubFold, sf)))-2;
                    if isempty(totalNImages{1,p}) % if the annotations are already saved 
                        continue_pred = 0; % continue the loop without predicting 
                        break
                    end
                end
            end
            
            if continue_pred==0
                continue
            end
            
            p_string = pIndex;
            pIndex_use = pIndex;
            if USE_UNIQUE_MODEL % to go over the next if only once
                p_string = "ALL";
                pIndex_use = "-1";
            end 
            
            if SUPERVISED_LEARNING 
                if exist(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_2steps_",SUFFIX_RES,"_",p_string,".mat"),'file')==0 && ...
                    exist(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_2steps_",SUFFIX_RES,"_",p_string,".mat"),'file')==0
                    PREDICT = true;
                    isSUPERVISED_learn = SUPERVISED_LEARNING;
                    if USE_UNIQUE_MODEL
                        isSUPERVISED_learn = 0;
                        PREDICT = false; % we don't want to predcit if we are creating a single model
                    end
                    %% set the model and (maybe) predict
                    [statsClassific] = setModelAndPredict(SAVED_MODELS_FOLDER,SUFFIX_RES,pIndex_use,p,STEPS,totalTableData,totalNImages,...
                        penumbra_color,core_color,isSUPERVISED_learn,statsClassific,patientSubFold,saveFolder,subsavefolder,suffix,...
                        predictionMasks,MANUAL_ANNOTATION_FOLDER,PREDICT,SHOW_IMAGES);
                end
            else % UNSUPERVISED
                [predictions,statsClassific,pred_img] = predictWithUnsupervisedLearning(p,pIndex,suffix,totalTableData,predictionMasks,...
                    MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING,totalNImages,...
                    statsClassific,patientSubFold,saveFolder,subsavefolder,SHOW_IMAGES,...
                    SAVED_MODELS_FOLDER,SUFFIX_RES,STEPS,USE_UNIQUE_MODEL);
            end
            end
            end
        end
    end
end

close(wb); % close the waitbar

end

