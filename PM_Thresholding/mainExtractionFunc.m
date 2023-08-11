function [predictions,statsClassific] = mainExtractionFunc(patients,researchesValues,...
    perfusionCTFolder,MANUAL_ANNOTATION_FOLDER,SAVED_MODELS_FOLDER,saveFolder,...
    subsavefolder,subfolds,constants,workspaceFolder,appUIFIGURE)
%MAINEXTRACTIONFUNC Extraction of the information of the patients 
%   Function that performs different steps:
%       0) for each researchesValues: 
%       1) extract the parametric maps calling getInfoFromSubfold function
%       2) predict the information with predictWithUnsupervisedLearning
%           function if the flag is set 
%       3) predict ALL the patient with a supervised learning and a
%           cross-validation approach if the flag is set

if nargin<11
	appUIFIGURE = 0; 
end
if nargin<10
    workspaceFolder = saveFolder;
end

if appUIFIGURE~=0
    wb = uiprogressdlg(appUIFIGURE,'Title','Please Wait',...
        'Message','Start analyzing patients...');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONSTANTS
SHOW_IMAGES = constants.SHOW_IMAGES; % show the images during the execution of the function
LOAD_AND_PREDICT_PATIENT = constants.LOAD_AND_PREDICT_PATIENT; % load and predict a single patient at the time
RUN_EXTRACTION_AGAIN = constants.RUN_EXTRACTION_AGAIN; % run the extraction even if the corresponding folder ALREADY contains the values
PARAMETRIC_IMAGES_TO_ANALYZE = constants.PARAMETRIC_IMAGES_TO_ANALYZE; % to read the proper images (parametric maps images (png) or DICOM files)
SAVE_PAR_MAPS = constants.SAVE_PAR_MAPS; % flag to save the parametric maps
SAVE_TRESHOLDING = constants.SAVE_TRESHOLDING; % flag to save the thresholding values
flag_PENUMBRACORE = constants.flag_PENUMBRACORE; % to run also the penumbra-core statistics
DIFFERENT_PERCENTAGES = constants.DIFFERENT_PERCENTAGES; % use only for the ROC curve
SUPERVISED_LEARNING = constants.SUPERVISED_LEARNING; % flag for the supervised learning (with or without the ground truth)
CALCULATE_STATS_ONLY = constants.CALCULATE_STATS_ONLY; % flag to calculate only the stats of the prediction (if they are already saved!)
FAKE_MTT = constants.FAKE_MTT; % use to just ignore the old infarction presented in the MTT images
TIFF_SUFFIX = constants.TIFF_SUFFIX; % use the .tiff suffix in the images
SUFFIX_RES = constants.SUFFIX_RES; % 'SVM' // 'tree' // 'SVM_tree' 
USE_UNIQUE_MODEL = constants.USE_UNIQUE_MODEL; % for creating a unque model and not passing through a cross-validation over the patiens
THRESHOLDING = constants.THRESHOLDING;
KEEPALLPENUMBRA = constants.KEEPALLPENUMBRA;
USESUPERPIXELS = constants.USESUPERPIXELS;
N_SUPERPIXELS = constants.N_SUPERPIXELS;
SMOTE = constants.SMOTE;
STEPS = constants.STEPS;
USEHYPERPARAMETERS = constants.USEHYPERPARAMETERS;
HYPERPARAMETERS = constants.HYPERPARAMETERS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add the n_superpixels at the end, even if the superpixels flag is false
prefixForTable = "";

if USESUPERPIXELS
    if USESUPERPIXELS==1 || USESUPERPIXELS==2
        prefixForTable = int2str(N_SUPERPIXELS)+"_";
    elseif USESUPERPIXELS==3 || USESUPERPIXELS==4
        prefixForTable = "2D_"+int2str(N_SUPERPIXELS)+"_";
    end
else
    prefixForTable = prefixForTable+"10_"; % default value if no superpixels involved
end

if SMOTE
    prefixForTable = prefixForTable+"SMOTE_";
end

disp("*** mainExtractionFunc function ***");
disp(strcat(workspaceFolder,prefixForTable));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialize variables 
% flag for the leave-one-out prediction (predict with other models!)
totalTableData =  table();
totalNImages = cell(1,numel(patients));
predictionMasks = cell(3,numel(patients));

predictions = [];
stats = table();
statsClassific = table();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% colors index
colorbarPointTopX = 129;
colorbarPointBottomX = 384;
colorbarPointY = 436;
penumbra_color = 170; %76;
core_color = 255; %150

image_suffix = ".png";
if TIFF_SUFFIX
    image_suffix = ".tiff";
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for each suffix 
for suff = researchesValues.keys
    count = 0;
    MODELS = cell(1,STEPS);
    
    suffix = suff{1};
    research = researchesValues(suffix);
    parametricMaps = fieldnames(research);
    
    tic
    %% Load the right model(s) if they are already saved.
    if USE_UNIQUE_MODEL && isfield(research, "cluster") && strcmp(research.cluster, "yes") && ...
        ((STEPS>1 && exist(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",suffix,"_ALL.mat"),'file')==2 || ...
        exist(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",suffix,"_ALL.mat"),'file')==2) || ...
        (STEPS==1 && exist(strcat(SAVED_MODELS_FOLDER,"MODELS_UNIQUE_",suffix,"_ALL.mat"),'file')==2))
        disp("--Loading the right model(s)");
        for step=1:STEPS
            if step==1
                if STEPS == 1 %% unique classifier model 
                    load(strcat(SAVED_MODELS_FOLDER,"MODELS_UNIQUE_",suffix,"_ALL.mat"),"Mdl")
                else
                    if strcmp(SUFFIX_RES,'SVM_tree')
                        load(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",int2str(STEPS),"steps_SVM_ALL.mat"),"Mdl");
                    else
                        if exist(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",suffix,"_ALL.mat"),'file')==2
                            load(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",suffix,"_ALL.mat"),"Mdl");
                        else 
                            Mdl = {};
                        end
                    end
                end
            elseif step==STEPS
                if strcmp(SUFFIX_RES,'SVM_tree')
                    load(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",int2str(STEPS),"steps_tree_ALL.mat"),"Mdl");
                else
                    if exist(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",suffix,"_ALL.mat"),'file')==2
                        load(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",suffix,"_ALL.mat"),"Mdl");
                    else 
                        Mdl = {};
                    end
                end
            end
            
            MODELS{1,step} = Mdl;
        end
    end
    toc
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 0^ STEP
    %% for each patient
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~LOAD_AND_PREDICT_PATIENT && exist(strcat(workspaceFolder,prefixForTable,"totalTableData.mat"),'file')==2 && ...
            exist(strcat(workspaceFolder,prefixForTable,"totalNImages.mat"),'file')==2 && ...
            exist(strcat(workspaceFolder,prefixForTable,"predictionMasks.mat"),'file')==2 
        disp("--Loading the complete dataset table");
        load(strcat(workspaceFolder,prefixForTable,"totalTableData.mat"),"totalTableData");
        load(strcat(workspaceFolder,prefixForTable,"totalNImages.mat"),"totalNImages");
        load(strcat(workspaceFolder,prefixForTable,"predictionMasks.mat"),"predictionMasks");
        
    else
        
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
        
        if strcmp(patient, "CTP_01_054") || strcmp(patient, "CTP_01_077") || strcmp(patient, "CTP_02_046") || strcmp(patient, "CTP_02_049") || strcmp(patient, "CTP_02_052")
            % wrong patient to check
            continue
        end

        combinedResearchCoreMaks = cell(1,50); % initialize the combined core mask
        combinedResearchPenumbraMaks = cell(1,50); % initialize the combined penumbra mask

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % for each day folder
        for dayFold = dir(strcat(perfusionCTFolder, patient))'
        if ~strcmp(dayFold.name, '.') && ~strcmp(dayFold.name, '..') 
        n_fold = n_fold + 1;
        
        disp(strcat("Patient: ", patient, " - ", dayFold.name, " -- ", num2str(p), "/", num2str(numel(patients))));
        
        % count the subfolders inside the dayFold, sutracting the
        %       "Annotations" and "Original" folders from the count and if the
        % number is less than the number of the initial subfolds, do nothing
        foldsInsideDayFold = struct2cell(dir(strcat(dayFold.folder,'/',dayFold.name)));
        foldsInsideDayFold = foldsInsideDayFold(1,3:end);
        subsavefoldcount = 0;
        for subfold_name = subsavefolder
            subfold_name = convertStringsToChars(subfold_name);
            if any(strcmp(foldsInsideDayFold, subfold_name(1:end-1)))
               subsavefoldcount = subsavefoldcount + 1;
            end
        end
        if (numel(foldsInsideDayFold) - subsavefoldcount) < numel(subfolds)-1
            disp("Number of folders not correct! Skip this one...");
            continue
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% for each subfolder of parametric maps   
        for s=1:numel(subfolds)
            subfold = subfolds(s);
            if FAKE_MTT && strcmp(subfold,"MTT")
                continue
            end
            intermediateFold = '/';
            if ~PARAMETRIC_IMAGES_TO_ANALYZE
                intermediateFold = '/ST000000/';
            end
            folderPath = strcat(perfusionCTFolder,patient,'/',dayFold.name,intermediateFold,convertStringsToChars(subfold),'/');
            n = numel(dir(folderPath))-2;
            
            if s==1
                number_of_slice_per_pm = n; % set it for later comparison
            else
                if number_of_slice_per_pm~=n && ~strcmp(subfold,"MTT")
                    disp("number of slices not equal in the PM: " + folderPath);
                    break
                end
            end

            savedAnnotationFolderPath = strcat(perfusionCTFolder,patient,'/',dayFold.name,intermediateFold,subsavefolder{2});
            saved_n = numel(dir(savedAnnotationFolderPath))-2;
            % if the folder does not exist, not necessary to go and predict
            if ~isfolder(savedAnnotationFolderPath)
                saved_n = n*2;
            end
            
            count_pred = 0;
            if ~RUN_EXTRACTION_AGAIN
                filenames = struct2cell(dir(strcat(saveFolder,patient,'/',dayFold.name,intermediateFold,subsavefolder{1})));
                
                for x = 1:size(filenames,2)
                    if strfind(filenames{1,x},suffix)
                        count_pred = count_pred+1;
                    end
                end
            end

             % nothing already saved in the original folder or the RUN_EXTRACTION_AGAIN is set == true
            if ((saved_n/2) < n || RUN_EXTRACTION_AGAIN) || ((count_pred/2)~=n && ~RUN_EXTRACTION_AGAIN)
                %% initialize the cells if we are checking the grayscale image 
                if subfold == subfolds(1)
                    tryImage = cell(1,n); % initialize the ground truth cell
                    groundTruthImage = cell(1,n); % initialize the ground truth cell
                    coreImage = cell(1,n); % initialize the core image cell
                    penumbraImage = cell(1,n); % initialize the penumbra image cell
                    %% initialize the pm cells
                    totalCoreMask = cell(1,n);
                    totalPenumbraMask = cell(1,n);
                    imageCBV = cell(1,n);
                    imageCBF = cell(1,n);
                    imageTTP = cell(1,n);
                    imageTMAX = cell(1,n);
                    imageMTT = cell(1,n);
                    
                    sortImages = cell(numel(subfolds),n);
                    skullMasks = cell(numel(subfolds),n);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% 1^ STEP
                %% get the information of the various map for a specific subfolder
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks,penumbraImage,...
                totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,imageMTT,stats,tableData,nImages] = ...
                    getInfoFromSubfold(subfold,subfolds,PARAMETRIC_IMAGES_TO_ANALYZE,research,folderPath,patient,n_fold,...
                    MANUAL_ANNOTATION_FOLDER,saveFolder,colorbarPointY,parametricMaps,SUPERVISED_LEARNING,FAKE_MTT,...
                    suffix,colorbarPointBottomX,colorbarPointTopX,penumbra_color,core_color,flag_PENUMBRACORE,SAVE_PAR_MAPS,count,perce, ...
                    combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks, ...
                    penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,imageMTT,stats,dayFold.name,...
                    image_suffix, USESUPERPIXELS, N_SUPERPIXELS, THRESHOLDING, KEEPALLPENUMBRA);

                if subfold == subfolds(end)
                    totalNImages{1,p} = nImages;
                    predictionMasks{1,p} = cell(1,nImages);
                    for sm=1:size(skullMasks,2)
                        predictionMasks{1,p}{1,sm} = ones(size(skullMasks{1,sm})); % skullMasks{1,p};
                    end
                    if ~LOAD_AND_PREDICT_PATIENT
                        if USESUPERPIXELS
                            if USESUPERPIXELS==1 || USESUPERPIXELS==3
                                varnames = ["patient","cbf","cbf_superpixels",...
                                    "cbv","cbv_superpixels",...
                                    "tmax","tmax_superpixels",...
                                    "ttp","ttp_superpixels",...
                                    "NIHSS","oldInfarction","weights",...
                                    "output","outputPenumbraCore","outputCore","countRow"];
                            elseif USESUPERPIXELS==2 || USESUPERPIXELS==4
                                varnames = ["patient","cbf_superpixels","cbv_superpixels",...
                                    "tmax_superpixels","ttp_superpixels",...
                                    "NIHSS","oldInfarction","weights",...
                                    "output","outputPenumbraCore","outputCore","countRow"];
                            end
                        else
                            varnames = ["patient","cbf","cbv","tmax","ttp",...
                                "NIHSS","oldInfarction","weights",...
                                "output","outputPenumbraCore","outputCore","countRow"];
                        end
                        % concatenate the data information in a table
                        % can create memory problem if there are too many
                        % patients to predict (use the elseif statement in case!!
                        
                        %% remove duplicate rows from table
                        countRow = ones(size(tableData,1),1);
                        if sum(contains(tableData.Properties.VariableNames,'countRow'))==0
                            tableData.countRow = countRow;
                        end
                        
                        [uniqueTableData,ia,ic] = unique(tableData(:,2:end-1));
                        
                        countRow = histcounts(ic,1:numel(ia)+1)'; % count the frequency of the unique values
                        
                        pIndex = getIndexFromPatient(patient, n_fold);
                        indexPatient = ones(size(countRow,1),1) .* str2double(pIndex);
                        
                        if USESUPERPIXELS
                            if USESUPERPIXELS==1 || USESUPERPIXELS==3
                                tableData = table(indexPatient,...
                                    uniqueTableData.cbf,uniqueTableData.cbf_superpixels,...
                                    uniqueTableData.cbv,uniqueTableData.cbv_superpixels,...
                                    uniqueTableData.tmax,uniqueTableData.tmax_superpixels,...
                                    uniqueTableData.ttp,uniqueTableData.ttp_superpixels,...
                                    uniqueTableData.NIHSS,uniqueTableData.oldInfarction,uniqueTableData.weights,...
                                    uniqueTableData.output,uniqueTableData.outputPenumbraCore,uniqueTableData.outputCore,...
                                    countRow, 'VariableNames', varnames);
                            elseif USESUPERPIXELS==2 || USESUPERPIXELS==4
                                tableData = table(indexPatient,...
                                    uniqueTableData.cbf_superpixels,...
                                    uniqueTableData.cbv_superpixels,...
                                    uniqueTableData.tmax_superpixels,...
                                    uniqueTableData.ttp_superpixels,...
                                    uniqueTableData.NIHSS,uniqueTableData.oldInfarction,uniqueTableData.weights,...
                                    uniqueTableData.output,uniqueTableData.outputPenumbraCore,uniqueTableData.outputCore,...
                                    countRow, 'VariableNames', varnames);
                            end
                        else
                             tableData = table(indexPatient,...
                                uniqueTableData.cbf,uniqueTableData.cbv,...
                                uniqueTableData.tmax,uniqueTableData.ttp,...
                                uniqueTableData.NIHSS,uniqueTableData.oldInfarction,uniqueTableData.weights,...
                                uniqueTableData.output,uniqueTableData.outputPenumbraCore,uniqueTableData.outputCore,...
                                countRow, 'VariableNames', varnames);
                        end
                        
                        if SMOTE % run this only if we set to use SMOTE alg.
                            penumbraRowsIndex = tableData.output==2;
                            coreRowsIndex = tableData.output==3;

                            % var that contain the index, the percentage of oversampling (*100), the weight and the
                            % corresponding output for each infarcted region
                            inforInfarctedRows = {penumbraRowsIndex,5,3,2,1;coreRowsIndex,20,20,2,3};

                            for infreg_idx = 1:size(inforInfarctedRows,1)
                                
                                nearestneig_percentageoversampling = inforInfarctedRows{infreg_idx,2};
                                if sum(coreRowsIndex)<=nearestneig_percentageoversampling
                                    nearestneig_percentageoversampling = sum(coreRowsIndex)-1;
                                end
                                
                                if nearestneig_percentageoversampling>0 % only if there are rows defined as core/penumbra

                                    [X,C] = smote(table2array(tableData(inforInfarctedRows{infreg_idx,1},2:end-5)), ...
                                        nearestneig_percentageoversampling, nearestneig_percentageoversampling, ...
                                        'Class', tableData.output(inforInfarctedRows{infreg_idx,1}));

                                    indexPatient = ones(size(X,1),1) .* str2double(pIndex);
                                    if USESUPERPIXELS==1 || USESUPERPIXELS==3
                                        sinthesizeTable = table(indexPatient,...
                                            X(:,1),X(:,2),X(:,3),X(:,4),X(:,5),X(:,6),X(:,7),X(:,8),X(:,9),X(:,10),...
                                            ones(size(X,1),1).*inforInfarctedRows{infreg_idx,3},C,...
                                            ones(size(X,1),1).*inforInfarctedRows{infreg_idx,4},...
                                            ones(size(X,1),1).*inforInfarctedRows{infreg_idx,5},ones(size(X,1),1),...
                                            'VariableNames', varnames);
                                    else
                                        sinthesizeTable = table(indexPatient,...
                                            X(:,1),X(:,2),X(:,3),X(:,4),X(:,5),X(:,6),...
                                            ones(size(X,1),1).*inforInfarctedRows{infreg_idx,3},C,...
                                            ones(size(X,1),1).*inforInfarctedRows{infreg_idx,4},...
                                            ones(size(X,1),1).*inforInfarctedRows{infreg_idx,5},ones(size(X,1),1),...
                                            'VariableNames', varnames);
                                    end

                                    tableData = [tableData;sinthesizeTable];
                                    
                                    clear sinthesizeTable
                                end
                            end
                            
                            clear penumbraRowsIndex coreRowsIndex
                        end
                        
                        totalTableData = [totalTableData; tableData]; %#ok<*AGROW>
                        % shuffle the table
                        totalTableData = totalTableData(randperm(size(totalTableData,1)),:);
                        clear uniqueTableData countRow ia ic tableData
                        
                    else 
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
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %% 2^ STEP
                        %% predict the information using an unsupervised learning approach
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [predictions,statsClassific,~] = predictWithUnsupervisedLearning(p,pIndex,suffix,tableData,predictionMasks,...
                            MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING,totalNImages,...
                            statsClassific,patientSubFold,saveFolder,subsavefolder,SHOW_IMAGES,...
                            SAVED_MODELS_FOLDER,SUFFIX_RES,STEPS,USE_UNIQUE_MODEL,image_suffix,MODELS);
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Save the thresholding images
        if SAVE_TRESHOLDING
            saveThresholdingImages(saveFolder,patient,suffix,research,tryImage,...
                MANUAL_ANNOTATION_FOLDER,penumbraImage,coreImage,penumbra_color,core_color,...
                totalCoreMask,totalPenumbraMask,saveCore,savePenumbra);    
        end
        end
        end

        
        toc
        end
        
        divided = 1;
        msg = "Loaded and predicted patient ";
        if isfield(research, "cluster") && strcmp(research.cluster, "yes") && ~LOAD_AND_PREDICT_PATIENT
            divided = 2;
            msg = "Loaded patient ";
        end
        
        if appUIFIGURE~=0
            wb.Value = ((p/numel(patients))/divided);
            wb.Message = strcat(msg, num2str(p), "/", num2str(numel(patients)));
        end
    end
       
    if appUIFIGURE~=0
        wb.Value = (p/numel(patients))/divided;
        wb.Message = "Saving workspace...";
    end

    if THRESHOLDING
        save(strcat(workspaceFolder,suffix,"_stats.mat"), 'stats', '-v7.3');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % multiply the weights for the count rows (the non unique) and remove that column
    if ~LOAD_AND_PREDICT_PATIENT
        totalTableData.weights = totalTableData.weights .* totalTableData.countRow;
        totalTableData.countRow = [];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Save the tables
        save(strcat(workspaceFolder,prefixForTable,"totalTableData.mat"), 'totalTableData', '-v7.3');
        save(strcat(workspaceFolder,prefixForTable,"totalNImages.mat"), 'totalNImages', '-v7.3');
        save(strcat(workspaceFolder,prefixForTable,"predictionMasks.mat"), 'predictionMasks', '-v7.3');
        save(strcat(workspaceFolder,suffix,"_stats.mat"), 'stats', '-v7.3');
    end
    
    end % end if the previous variables are not saved
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 3^ STEP
    %% predict the information using a supervised (or unsupervised) learning approach + cross-validation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isfield(research, "cluster") && strcmp(research.cluster, "yes") && ~LOAD_AND_PREDICT_PATIENT
        
        if appUIFIGURE~=0
            wb.Value = 0.5;
            wb.Message = "Predicting patient(s)...";
        else
            disp("--Predicting patient(s)...");
        end
                
        %% for each patient
        for p=1:numel(patients)
            
            patient = convertStringsToChars(patients(p));
            n_fold = 0;
            
            if appUIFIGURE~=0
                % progress bar update
                wb.Value = ((p/numel(patients))/2) + 0.5;
                wb.Message = strcat("Predicting patient ", num2str(p), "/", num2str(numel(patients)), "...");
            else
                disp(strcat("--Predicting patient ", num2str(p), "/", num2str(numel(patients)), "..."));
            end

            for dayFold = dir(strcat(perfusionCTFolder, patient))'
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
                        if (STEPS > 1 && (exist(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",suffix,"_",p_string,".mat"),'file')==0 || ...
                            exist(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",suffix,p_string,".mat"),'file')==0)) || ...
                            (STEPS == 1 && exist(strcat(SAVED_MODELS_FOLDER,"MODELS_UNIQUE_",suffix,"_",p_string,".mat"),'file')==0)
                            PREDICT = true;
                            isSUPERVISED_learn = SUPERVISED_LEARNING;
                            if USE_UNIQUE_MODEL
                                isSUPERVISED_learn = 0;
                                PREDICT = false; % we don't want to predict if we are creating a single model
                            end
                            
                            %% set the model and (maybe) predict
                            statsClassific = setModelAndPredict(SAVED_MODELS_FOLDER,SUFFIX_RES,pIndex_use,p,STEPS,totalTableData,totalNImages,...
                                penumbra_color,core_color,isSUPERVISED_learn,statsClassific,patientSubFold,saveFolder,subsavefolder,suffix,...
                                predictionMasks,MANUAL_ANNOTATION_FOLDER,PREDICT,SHOW_IMAGES,image_suffix,USESUPERPIXELS,USEHYPERPARAMETERS, HYPERPARAMETERS);
                        else % if the model exists
                            if CALCULATE_STATS_ONLY
                                new_suffix = strcat(suffix, "_", pIndex);
                                
                                annot_folder = dir(strcat(saveFolder, patientSubFold, subsavefolder{1}))';
                                correct_files_index = contains({annot_folder.name}, suffix);
                                annot_folder = annot_folder(correct_files_index);
                                                                
                                for img_idx=1:numel(annot_folder)/2
                                    strimgidx = num2str(img_idx);
                                    if length(strimgidx) == 1
                                        strimgidx = strcat('0', strimgidx);
                                    end
                                    penumbraMask = double(imread(strcat(saveFolder,patientSubFold,subsavefolder{1},new_suffix,"_",strimgidx,"_penumbra.png")));
                                    coreMask = double(imread(strcat(saveFolder,patientSubFold,subsavefolder{1},new_suffix,"_",strimgidx,"_core.png")));

                                    statsClassific = statisticalInfo(statsClassific, new_suffix, penumbraMask, coreMask, ...
                                        MANUAL_ANNOTATION_FOLDER, patient, img_idx, penumbra_color, core_color, flag_PENUMBRACORE, image_suffix, 0, THRESHOLDING);

                                end
                            end
                        end
                    else % UNSUPERVISED
                        [predictions,statsClassific,pred_img] = predictWithUnsupervisedLearning(p,pIndex,suffix,totalTableData,predictionMasks,...
                            MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING,totalNImages,...
                            statsClassific,patientSubFold,saveFolder,subsavefolder,SHOW_IMAGES,...
                            SAVED_MODELS_FOLDER,SUFFIX_RES,STEPS,USE_UNIQUE_MODEL,image_suffix,MODELS);
                    end
                end
            end
        end
    end
end

if appUIFIGURE~=0
    close(wb); % close the waitbar
end

end

