clear;
clc % clear command window
close all force;

steps = [1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for step = steps
    %% VARIABLES
    constants.SUFFIX_RES = 'randomForest'; % 'SVM' // 'tree' // 'randomForest' 
    constants.STEPS = step; % or 2 steps to divide penumbra and core prediction
    constants.USESUPERPIXELS = 1; % set the variable == 2 for using ONLY the suprpixels features
    constants.N_SUPERPIXELS = 225;
    constants.SMOTE = 1;
    app.option = 2; % 10 --> Liv // 11 --> Kathinka
    app.calculateSTATS = 1;
    app.KEEPALLPENUMBRA = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MORE_TRAINING_DATA = 1; % use a different combination to train, validate and test
    TRAIN = 0;
    TEST_SECRETDATASET = 0;
    THRESHOLDING = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    prefix = "";
    add = "_v3";
    subfolder_model = "";
    if MORE_TRAINING_DATA
        subfolder_model = "MODELS_biggertrain/";
    end
    
    if app.option==1
        suffix = "TIFF";
    elseif app.option==2 || app.option==3
        if constants.USESUPERPIXELS
            if constants.USESUPERPIXELS==1 
                prefix = prefix+"superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            elseif constants.USESUPERPIXELS==2
                prefix = prefix+"ONLYsuperpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            elseif constants.USESUPERPIXELS==3
                prefix = prefix+"2D_superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            elseif constants.USESUPERPIXELS==4
                prefix = prefix+"2D_ONLYsuperpixels"+int2str(constants.N_SUPERPIXELS)+"_";
            end
        else
            prefix = prefix+"10_"; % default value if no superpixels involved
        end

        if constants.SMOTE
            prefix = prefix+"SMOTE_";
        end

        if app.KEEPALLPENUMBRA
            add = "AllP_"+add;
        end
        
        % careful changing the suffix!
        suffix = strcat(prefix,int2str(constants.STEPS),"steps_",constants.SUFFIX_RES);
        
    elseif app.option==10
        suffix = "Comparison_Liv";
    elseif app.option==11
        suffix = "Comparison_Kathinka";
    end

    %% SUS2020_v2
    if ispc % windows
        app.mainSavepath = "D:\Preprocessed-SUS2020_v2\";
        SAVED_MODELS_FOLDER = app.mainSavepath+"Workspace_thresholdingMethods\"+subfolder_model+add;
        if ~strcmp(add,"")
            SAVED_MODELS_FOLDER = SAVED_MODELS_FOLDER + "/";
        end
        matlabpath = "C:\Users\2921329\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\REPOSITORY\";
        app.MANUAL_ANNOTATION_FOLDER = app.mainSavepath+"FINALIZE_PMS\FINALIZE_PM_TIFF\";
    elseif isunix % unix sistem (gorina)
        app.mainSavepath = "/nfs/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/";
        matlabpath = "/home/student/lucat/Matlab/";
        SAVED_MODELS_FOLDER = strcat(matlabpath, 'Workspace_thresholdingMethods/',subfolder_model,add); 
        if ~strcmp(add,"")
            SAVED_MODELS_FOLDER = SAVED_MODELS_FOLDER + "/";
        end
        app.MANUAL_ANNOTATION_FOLDER = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/FINALIZE_PM_TIFF/";
    end

    % set the new matlab path and all its subfolders
    addpath(genpath(matlabpath));

    if ~isfolder(SAVED_MODELS_FOLDER)
        mkdir(SAVED_MODELS_FOLDER);
    end

    if app.option==1
        app.patientspath = app.mainSavepath+ "Parametric_Maps/";
    elseif app.option==2
        app.patientspath = app.mainSavepath+ "Thresholding_Methods";
        if ~strcmp(subfolder_model,"")
            app.patientspath = app.patientspath + "_" + subfolder_model;
            app.patientspath = convertStringsToChars(app.patientspath);
            app.patientspath = app.patientspath(1:end-1);
        end
    elseif app.option==3
        app.patientspath = app.mainSavepath+ "Thresholding_Methods_gorina2 (tree)";
    elseif app.option==10
        app.patientspath = app.mainSavepath+ "Parametric_Maps_Comparison_Liv/";
    elseif app.option==11
        app.patientspath = app.mainSavepath+ "Parametric_Maps_Comparison_Kathinka/";
    end
    
    app.realpatientspath = app.mainSavepath+"Parametric_Maps";
    app.finalizeFolder = "FINALIZE_PMS/"+subfolder_model+"FINALIZE_PM_"+suffix+"/";
    
    if app.KEEPALLPENUMBRA 
        app.finalizeFolder = "FINALIZE_PMS/"+subfolder_model+add+"/FINALIZE_PM_"+suffix+"/";
    end

    if app.option~=10 && app.option~=1 && app.option~=11
        app.overrideSuffix = suffix; 
    end

    if ispc
        app.GUIAutomaticManualAnnotationsUIFigure = uifigure;
    end

    disp(suffix);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    patients_struct = dir(app.patientspath)';
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
            elseif app.option>=10 % for Liv and Kathinka annotations 
                process = 1; 
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

    app.patients = patients;
    stats = finalizeParametricMaps(app);

    if ~isempty(stats)
        secretdataset_prefix = "";
        if TEST_SECRETDATASET
            secretdataset_prefix = "TESTDATASET";
        end

        disp("Calculate stats...");
        disp(strcat(SAVED_MODELS_FOLDER, secretdataset_prefix,"finalize-stats_",suffix,add,".mat"));

        calculateStats(stats, SAVED_MODELS_FOLDER, ...
            strcat(secretdataset_prefix,"finalize-stats_",suffix,add,".mat"), 0);
    end
end

clear;
close all force;