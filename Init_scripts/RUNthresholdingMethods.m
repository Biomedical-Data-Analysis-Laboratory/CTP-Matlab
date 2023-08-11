%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run the thresholding based on the researchValues maps.
% The script runs it the external hard drive is present (the one containing the various patients)
clear;
clc % clear command window
close all force;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IF THE DS IS NEW, CREATE IT WITH THE SUPERPIXELS VERSION!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for suffix_res = ["SVM"] % 'SVM' // 'tree' // 'randomForest' 
for step = [2]
for train = [0] % ==0 if thresholding
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    MORE_TRAINING_DATA = 1; % use a different combination to train, validate and test
    TRAIN = train;
    TEST_SECRETDATASET = 0;
    THRESHOLDING = 0;
    KEEPALLPENUMBRA = 1; % only for thresholding here
    USEHYPERPARAMETERS = false;
    HYPERPARAMETERS = struct();  % for hyper-parameter optimization (for now, only use for Mld-X.1 and BEST)
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% important variables
    subfolds = ["MIP", "MTT", "CBF", "CBV", "TMAX", "TTP"]; 
    subsavefolder = ["Annotations/", "Original/"];

    add = "";
    subfolder_model = "";
    if MORE_TRAINING_DATA
        subfolder_model = "MODELS_biggertrain";
        subfolder_model = strcat(subfolder_model,"_HYPER");  % _LAST
        subfolder_model = strcat(subfolder_model,"/");
    end
    
    if THRESHOLDING && ~KEEPALLPENUMBRA
        subfolder_model = "KEEPONLYLARGEPENUMBRA\";
    end
        
    if ispc % windows
        MAIN_PATH = "D:\Preprocessed-SUS2020_v2\";
    %     MAIN_PATH = "C:\Users\Luca\Desktop\Matlab_tmp_folder\";
        perfusionCTFolder = MAIN_PATH+"Parametric_maps\";
        saveFolder = MAIN_PATH+"Thresholding_Methods" + add + "\";
        if ~strcmp(subfolder_model, "")
            saveFolder = MAIN_PATH+"Thresholding_Methods" + add + "_" + subfolder_model;
        end
        workspaceFolder = MAIN_PATH+"Workspace_thresholdingMethods\"+subfolder_model;
        SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\"+subfolder_model;
        MANUAL_ANNOTATION_FOLDER = MAIN_PATH+"FINALIZE_PMS\FINALIZE_PM_TIFF\";
        appUIFIGURE = uifigure;

        matlabpath = "C:\Users\2921329\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\REPOSITORY\";
    %     matlabpath = "C:\Users\Luca\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\REPOSITORY\";

    elseif isunix % unix sistem (gorina)
        MAIN_PATH = "/home/student/lucat/Matlab/";
        perfusionCTFolder = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/Parametric_Maps/";
        saveFolder = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/Thresholding_Methods_REVIEW/";
        if ~strcmp(subfolder_model, "")
            saveFolder = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/Thresholding_Methods_REVIEW_"+subfolder_model;
        end
        workspaceFolder = strcat(MAIN_PATH, 'Workspace_thresholdingMethods_REVIEW/', subfolder_model); 
        SAVED_MODELS_FOLDER = strcat(MAIN_PATH, 'Workspace_thresholdingMethods_REVIEW/', subfolder_model); 
        MANUAL_ANNOTATION_FOLDER = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/GT_TIFF/";

        matlabpath = strcat(MAIN_PATH, "REPOSITORY/");

        %maxNumCompThreads(10);
    end
    
    if ~isfolder(saveFolder)
        mkdir(saveFolder);
    end
    if ~isfolder(workspaceFolder)
        mkdir(workspaceFolder);
    end
    % set the new matlab path and all its subfolders
    addpath(genpath(matlabpath));

    % for retro-compatibility
    app.perfusionCTFolder = perfusionCTFolder;
    app.option = 2;
    
    patients = getPatients(app, MORE_TRAINING_DATA, TRAIN, TEST_SECRETDATASET, THRESHOLDING);
    patients = patients(:end);
    disp(patients);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTANTS
    constants.SHOW_IMAGES = 0; % show the images during the execution of the function
    constants.RUN_EXTRACTION_AGAIN = 0; % run the extraction even if the corresponding folder ALREADY contains the values
    constants.PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
    constants.SAVE_PAR_MAPS = 0; % flag to save the parametric maps
    constants.flag_PENUMBRACORE = 1; % to run also the penumbra-core statistics
    constants.DIFFERENT_PERCENTAGES = 0; % use only for the ROC curve
    constants.SUPERVISED_LEARNING = 1; % flag for the supervised learning (with or without the ground truth)
    constants.CALCULATE_STATS_ONLY = 0; % flag to calculate only the stats of the prediction (if they are already saved!)
    constants.FAKE_MTT = 1; % use to just ignore the MTT images
    constants.TIFF_SUFFIX = 1;
    constants.USEHYPERPARAMETERS = USEHYPERPARAMETERS;
    constants.HYPERPARAMETERS = HYPERPARAMETERS;
    %% values for each parametric map [perc(%), up/down, core/penumbra, fixed_percentage]
    researchesValues = containers.Map;

    %% ML method
    if ~THRESHOLDING
        constants.SUFFIX_RES = suffix_res;  %'randomForest'; % 'SVM' // 'tree' // 'randomForest' 
        constants.SAVE_TRESHOLDING = 0; % flag to save the thresholding values
        constants.USE_UNIQUE_MODEL = true; % for creating a unque model and not passing through a cross-validation over the patiens
        constants.STEPS = step; % or 2 steps to divide penumbra and core predictions

        prefix = "";
        % - set the constants.USESUPERPIXELS = 1 for using  the 3D superpixels features
        % - set the constants.USESUPERPIXELS = 2 for using ONLY the 3D suprpixels features
        % - set the constants.USESUPERPIXELS = 3 for using the 2D superpixel function
        % - set the constants.USESUPERPIXELS = 4 for using ONLY the 2D superpixel function
        constants.USESUPERPIXELS = 2;  
        constants.N_SUPERPIXELS = 10;
        constants.SMOTE = 1;
        
        if strcmp(constants.SUFFIX_RES,'tree')
            if constants.STEPS==1
                constants.HYPERPARAMETERS.one = struct('MaxNumSplits',22489,...
                    'MinLeafSize',138,...
                    'SplitCriterion','deviance');
            elseif constants.STEPS==2
                constants.HYPERPARAMETERS.one = struct('MaxNumSplits',3.579e+05,...
                    'MinLeafSize',153,...
                    'SplitCriterion','deviance');
                constants.HYPERPARAMETERS.two = struct('MaxNumSplits',34427,...
                    'MinLeafSize',10,...
                    'SplitCriterion','deviance');
            end
        elseif strcmp(constants.SUFFIX_RES,'randomForest')
            if constants.STEPS==1
                if contains(subfolder_model, "_HYPER_LAST")
                    constants.HYPERPARAMETERS.one = struct('NumLearningCycles',43,...
                    'MaxNumSplits',68982,...
                    'MinLeafSize',315,...
                    'NumVariablesToSample','all',...
                    'SplitCriterion','deviance');
                else
                    constants.HYPERPARAMETERS.one = struct('NumLearningCycles',4,...
                        'MaxNumSplits',5535,...
                        'MinLeafSize',345,...
                        'NumVariablesToSample','all',...
                        'SplitCriterion','gdi');
                end
            elseif constants.STEPS==2
                constants.HYPERPARAMETERS.one = struct('NumLearningCycles',10,...
                    'MaxNumSplits',1400500,...
                    'MinLeafSize',384,...
                    'NumVariablesToSample','all',...
                    'SplitCriterion','deviance');
                constants.HYPERPARAMETERS.two = struct('NumLearningCycles',10,...
                    'MaxNumSplits',20979,...
                    'MinLeafSize',2,...
                    'NumVariablesToSample','all',...
                    'SplitCriterion','gdi');
            end
        elseif strcmp(constants.SUFFIX_RES,'SVM')
            if constants.STEPS==1
                constants.HYPERPARAMETERS.one = struct('BoxConstraint',1,...
                    'KernelScale',1,...
                    'KernelFunction','gaussian',...
                    'PolynomialOrder',3,...
                    'Standardize',false);
            elseif constants.STEPS==2
                constants.HYPERPARAMETERS.one = struct('BoxConstraint',993.73,...
                    'KernelScale',5.7579,...
                    'KernelFunction','gaussian',...
                    'Standardize',false);
                constants.HYPERPARAMETERS.two = struct('BoxConstraint',0.4877,...
                    'KernelScale',0.089206,...
                    'KernelFunction','gaussian',...
                    'Standardize',false);
            end
        end
        
        if constants.USESUPERPIXELS
            if constants.USESUPERPIXELS==1
                prefix = prefix+"superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            elseif constants.USESUPERPIXELS==2
                prefix = prefix+"ONLYsuperpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            elseif constants.USESUPERPIXELS==3
                prefix = prefix+"2D_superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            elseif constants.USESUPERPIXELS==4
                prefix = prefix+"ONLY2D_superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            end
        else
            prefix = prefix+"10_"; % default value if no superpixels involved
        end

        if constants.SMOTE
            prefix = prefix+"SMOTE_";
        end

        name = strcat(prefix,int2str(constants.STEPS),"steps_",constants.SUFFIX_RES);
        researchesValues(name) = struct('cluster',"yes"); % no need of thresholding values!

        disp("**********");
        disp(strcat("NAME: ",name));
        disp(strcat("TRAIN: ", int2str(TRAIN)));
        disp(strcat("RUN EXTRACTION AGAIN: ", int2str(constants.RUN_EXTRACTION_AGAIN)));
        disp(strcat("TEST SECRET DATASET: ", int2str(TEST_SECRETDATASET)));
        disp(strcat("MORE TRAINING DATA: ", int2str(MORE_TRAINING_DATA)));
        disp("**********");
    else
    %% thresholding methods
        constants.USE_UNIQUE_MODEL = 0;
        constants.SUFFIX_RES = "";
        constants.SAVE_TRESHOLDING = 1; % flag to save the thresholding values
        constants.USESUPERPIXELS = 0;
        constants.N_SUPERPIXELS = 0;
        constants.SMOTE = 0;
        constants.STEPS = 1;

        researchesValues('SYNGO.VIA_default') = struct('CBF', [27, "down", "penumbra", ""], 'CBV', [20, "down", "core", ""]);
        researchesValues('Bathla_2020') = struct('CBF', [20, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
% %         researchesValues('Wintermark_2006') = struct('CBV', [33, "down", "core", ""], 'MTT', [70, "up", "core", ""], 'CBV_2', [33, "up", "penumbra", ""], 'MTT_2', [7.25, "up", "core", ""]);
        researchesValues('Wintermark_2006') = struct('CBV', [33.3, "down", "core", ""]);
        researchesValues('Cambell_2011') = struct('CBF', [15, "down", "core", 10]);
%         researchesValues('Cambell_2012') = struct('CBF', [31, "down", "core", 10], 'TTP', [70, "up", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
%         researchesValues('Cereda_2015') = struct('CBF', [38, "down", "core", ""], 'TMax', [33, "up", "core", ""]);
%     %     researchesValues('Ma_Cambell_2019') = struct('CBF', [30, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
%         researchesValues('Shaefer_2014') = struct('CBF', [15, "down", "core", ""], 'CBV', [30, "down", "core", ""]);
% %         researchesValues('Bivard_2014') = struct('CBF', [50, "down", "core", ""], 'TTP', [75, "up", "penumbra", ""]); 
        researchesValues('Bivard_2014') = struct('CBF', [17.5, "down", "core", ""], 'TTP', [75, "up", "penumbra", ""]); 
        researchesValues('Murphy_2006') = struct('CBF', [13.3, "down", "core", ""], 'CBV', [18.8, "down", "core", ""], 'CBF_2', [25, "down", "penumbra", ""], 'CBV_2', [35.8, "down", "penumbra", ""]);
%         researchesValues('Lin_2014') = struct('CBF', [30, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
    end

    %% test ML and run thresholding
    % load and predict a single patient at the time
    constants.LOAD_AND_PREDICT_PATIENT = ~TRAIN; % 1==for testing
    constants.THRESHOLDING = THRESHOLDING;
    constants.KEEPALLPENUMBRA = KEEPALLPENUMBRA;

    %% execute the main extraction function
    if ispc % windows
        [predictions,statsClassific] = mainExtractionFunc(patients,researchesValues,perfusionCTFolder,MANUAL_ANNOTATION_FOLDER,...
            SAVED_MODELS_FOLDER,saveFolder,subsavefolder,subfolds,constants,workspaceFolder, appUIFIGURE);
    elseif isunix
        [predictions,statsClassific] = mainExtractionFunc(patients,researchesValues,perfusionCTFolder,MANUAL_ANNOTATION_FOLDER,...
            SAVED_MODELS_FOLDER,saveFolder,subsavefolder,subfolds,constants,workspaceFolder);
    end

    if constants.SUPERVISED_LEARNING 
        if ~isempty(statsClassific)
            appendToSavedStats = 0; % always set to 0 except for the small changes required for a patient (es. 00_007)
            %% save the statistic information (both for the classification approach and the thresholding approach
            secretdataset_prefix = "";
            if TEST_SECRETDATASET
                secretdataset_prefix = "TESTDATASET";
            end

            calculateStats(statsClassific,SAVED_MODELS_FOLDER,strcat(secretdataset_prefix,"statsClassific_",name,add,".mat"), appendToSavedStats);
        end
    end
    
    % clear
end
end
end
