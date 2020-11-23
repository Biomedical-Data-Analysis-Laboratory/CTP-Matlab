%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run the thresholding based on the researchValues maps.
% The script runs it the external hard drive is present (the one containing the various patients)
clear;
clc % clear command window
close all force;

for train = [0]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    MORE_TRAINING_DATA = 1; % use a different combination to train, validate and test
    TRAIN = train;
    TEST_SECRETDATASET = 0;
    THRESHOLDING = 0;
    KEEPALLPENUMBRA = 1; % only for thresholding here
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% important variables
    subfolds = ["MIP", "MTT", "CBF", "CBV", "TMAX", "TTP"]; 
    subsavefolder = ["Annotations/", "Original/"];

    add = "";
    subfolder_model = "";
    if MORE_TRAINING_DATA
        subfolder_model = "MODELS_biggertrain/";
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
        perfusionCTFolder = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/Parametric_Maps/";
        saveFolder = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/Thresholding_Methods/";
        if ~strcmp(subfolder_model, "")
            saveFolder = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/Thresholding_Methods_"+subfolder_model;
        end
        workspaceFolder = strcat(MAIN_PATH, 'Workspace_thresholdingMethods/', subfolder_model); 
        SAVED_MODELS_FOLDER = strcat(MAIN_PATH, 'Workspace_thresholdingMethods/', subfolder_model); 
        MANUAL_ANNOTATION_FOLDER = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/FINALIZE_PM_TIFF/";

        matlabpath = MAIN_PATH;

        %maxNumCompThreads(4);

    else
        disp("It is not supposed to arrive here!");
        return
    end
    
    if ~isfolder(saveFolder)
        mkdir(saveFolder);
    end
    % set the new matlab path and all its subfolders
    addpath(genpath(matlabpath));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DO NOT TOUCH THEM (if you just want to test)
    use = [2, 39, 32, 8];
    tot = [4, 75, 60, 15]; 
    % tot = [4, 77, 63, 15]; <-- before was like this; removed: (CTP_02_052 +
    % CTP_01_054 + CTP_01_077) (remove also CTP_02_046 & CTP_02_049 due to
    % difference in the CTP slice number)
    skip = [0,0,0,0];
    
    if MORE_TRAINING_DATA
        use = [2, 50, 45, 10];

        % based on LIV and KATHINKA inter-oberver variability
        % 33 patients: 
        % - 19 LVO, 
        % - 11 without LVO,
        % - 3 WVO.
        secret_testdataset = ["CTP_01_001","CTP_01_007","CTP_01_013","CTP_01_019","CTP_01_025","CTP_01_031",...
            "CTP_01_037","CTP_01_044","CTP_01_049","CTP_01_053","CTP_01_061","CTP_01_067","CTP_01_074",...
            "CTP_02_001","CTP_02_007","CTP_02_013","CTP_02_019","CTP_02_025","CTP_02_031","CTP_02_036",...
            "CTP_02_043","CTP_02_050","CTP_02_055","CTP_02_062","CTP_03_003","CTP_03_010","CTP_03_014",...
            "CTP_01_057","CTP_01_059","CTP_01_066","CTP_01_068","CTP_01_071","CTP_01_073"];
    else
        % secret testing dataset:
        % - 6 LVO,
        % - 6 without LVO,
        % - 3 WVO
        secret_testdataset = ["CTP_01_010","CTP_01_025","CTP_01_037","CTP_01_057","CTP_01_061",...
            "CTP_01_066","CTP_02_001","CTP_02_004","CTP_02_009","CTP_02_016","CTP_02_020",...
            "CTP_02_027","CTP_03_003","CTP_03_010","CTP_03_014"];
        % before:
        % secret_testdataset = ["CTP_01_010","CTP_01_025","CTP_01_037","CTP_01_057","CTP_01_061",...
        %     "CTP_01_066","CTP_01_077","CTP_02_001","CTP_02_004","CTP_02_009","CTP_02_016","CTP_02_020",...
        %     "CTP_02_027","CTP_03_003","CTP_03_010","CTP_03_014"];
    end
    
    if ~TRAIN % for testing
        if THRESHOLDING
            use = tot;
        else
            skip = use;
            use = abs(tot-use);
        end
    end
    %% get patients name folder (not create a fixed one)
    infopatients.n_00.use = use(1); % 2% master's thesis patients (TOT:4)
    infopatients.n_01.use = use(2); % 39% LVO (TOT:77)
    infopatients.n_02.use = use(3); % 32% SVO (TOT:63)
    infopatients.n_03.use = use(4); % 8% WVO (TOT:15)

    infopatients.n_00.skip = skip(1); % USED for training
    infopatients.n_01.skip = skip(2); % USED for training
    infopatients.n_02.skip = skip(3); % USED for training
    infopatients.n_03.skip = skip(4); % USED for training
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    patients = []; 
    patients_struct = dir(perfusionCTFolder)';
    % set the seed and shuffle the patient struct 
    rng(10);
    rnd_indexes = randperm(length(patients_struct));
    for p_idx=rnd_indexes 
        p = patients_struct(p_idx);
        if ~strcmp(p.name, '.') && ~strcmp(p.name, '..')  
            process = 0;

            if TEST_SECRETDATASET
                if sum(cellfun(@any,strfind(secret_testdataset,p.name)))>0
                    process = 1;
                end
            else
                % exclude the patient inside the secret_testdataset list
                if THRESHOLDING || sum(cellfun(@any,strfind(secret_testdataset,p.name)))==0
                    if ~isempty(strfind(p.name, "_00_"))
                        if infopatients.n_00.skip>0
                            infopatients.n_00.skip = infopatients.n_00.skip - 1;
                        else 
                            if infopatients.n_00.use>0
                                process = 1;
                                infopatients.n_00.use = infopatients.n_00.use - 1;
                            end
                        end
                    elseif ~isempty(strfind(p.name, "_01_"))
                        if infopatients.n_01.skip>0
                            infopatients.n_01.skip = infopatients.n_01.skip - 1;
                        else 
                            if infopatients.n_01.use>0
                                process = 1;
                                infopatients.n_01.use = infopatients.n_01.use - 1;
                            end
                        end
                    elseif ~isempty(strfind(p.name, "_02_")) 
                        if infopatients.n_02.skip>0
                            infopatients.n_02.skip = infopatients.n_02.skip - 1;
                        else 
                            if infopatients.n_02.use>0
                                process = 1;
                                infopatients.n_02.use = infopatients.n_02.use - 1;
                            end
                        end
                    elseif ~isempty(strfind(p.name, "_03_")) 
                        if infopatients.n_03.skip>0
                            infopatients.n_03.skip = infopatients.n_03.skip - 1;
                        else 
                            if infopatients.n_03.use>0
                                process = 1;
                                infopatients.n_03.use = infopatients.n_03.use - 1;
                            end
                        end
                    end
                end
            end

            if process
                patients = [patients; convertCharsToStrings(p.name)];
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONSTANTS
    constants.SHOW_IMAGES = 0; % show the images during the execution of the function
    constants.RUN_EXTRACTION_AGAIN = 1; % run the extraction even if the corresponding folder ALREADY contains the values
    constants.PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
    constants.SAVE_PAR_MAPS = 0; % flag to save the parametric maps
    constants.flag_PENUMBRACORE = 1; % to run also the penumbra-core statistics
    constants.DIFFERENT_PERCENTAGES = 0; % use only for the ROC curve
    constants.SUPERVISED_LEARNING = 1; % flag for the supervised learning (with or without the ground truth)
    constants.CALCULATE_STATS_ONLY = 0; % flag to calculate only the stats of the prediction (if they are already saved!)
    constants.FAKE_MIP = 0; % use to just ignore the old infarction presented in the MIP (maximum intensity projection) images
    constants.TIFF_SUFFIX = 1;
    %% values for each parametric map [perc(%), up/down, core/penumbra, fixed_percentage]
    researchesValues = containers.Map;

    %% ML method
    if ~THRESHOLDING
        constants.SUFFIX_RES = 'randomForest'; % 'SVM' // 'tree' // 'randomForest' 
        constants.SAVE_TRESHOLDING = 0; % flag to save the thresholding values
        constants.USE_UNIQUE_MODEL = true; % for creating a unque model and not passing through a cross-validation over the patiens
        constants.STEPS = 1; % or 2 steps to divide penumbra and core prediction1

        prefix = "";
        % - set the constants.USESUPERPIXELS = 1 for using  the 3D superpixels features
        % - set the constants.USESUPERPIXELS = 2 for using ONLY the 3D suprpixels features
        % - set the constants.USESUPERPIXELS = 3 for using the 2D superpixel function
        % - set the constants.USESUPERPIXELS = 4 for using ONLY the 2D superpixel function
        constants.USESUPERPIXELS = 1;  
        constants.N_SUPERPIXELS = 225;
        constants.SMOTE = 1;

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

%         researchesValues('Wintermark_2006') = struct('CBV', [33, "down", "core", ""], 'MTT', [70, "up", "core", ""], 'CBV_2', [33, "up", "penumbra", ""], 'MTT_2', [7.25, "up", "core", ""]);
        researchesValues('Wintermark_2006') = struct('CBV', [33, "down", "core", ""]);
        researchesValues('Cambell_2012') = struct('CBF', [31, "down", "core", 10], 'TTP', [70, "up", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
        researchesValues('Cereda_2015') = struct('CBF', [38, "down", "core", ""], 'TMax', [33, "up", "core", ""]);
    %     researchesValues('Ma_Cambell_2019') = struct('CBF', [30, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
        researchesValues('Shaefer_2014') = struct('CBF', [15, "down", "core", ""], 'CBV', [30, "down", "core", ""]);
        researchesValues('Bivard_2014') = struct('CBF', [50, "down", "core", ""], 'TTP', [75, "up", "penumbra", ""]); 
        researchesValues('Murphy_2006') = struct('CBF', [13.3, "down", "core", ""], 'CBV', [18.8, "down", "core", ""], 'CBF_2', [25, "down", "penumbra", ""], 'CBV_2', [35.8, "down", "penumbra", ""]);
        researchesValues('Lin_2014') = struct('CBF', [30, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
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
    clear
end
