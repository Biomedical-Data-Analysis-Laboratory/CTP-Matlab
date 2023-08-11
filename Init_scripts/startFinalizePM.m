clear;
clc % clear command window
close all force;

steps = [2];
smote = [1];
use_superpixels = [2];
n_superpixels = [10];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for step = steps
for sp = use_superpixels 
for n_sp = n_superpixels
for smmm = smote
    %% VARIABLES
    constants.SUFFIX_RES = 'SVM'; % 'SVM' // 'tree' // 'randomForest' 
    constants.STEPS = step; % or 2 steps to divide penumbra and core prediction
    constants.USESUPERPIXELS = sp; % set the variable == 2 for using ONLY the suprpixels features
    constants.N_SUPERPIXELS = n_sp;
    constants.SMOTE = smmm;
    app.option = 2; % 10 --> Liv // 11 --> Kathinka // 0 --> THRESHOLDING
    app.calculateSTATS = 1;
    app.KEEPALLPENUMBRA = 1;
    app.MODEFILTER = true;  % apply 3D mode filter on the predictions

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MORE_TRAINING_DATA = 1; % use a different combination to train, validate and test
    TRAIN = 0;
    constants.TEST_SECRETDATASET = 0;
    app.THRESHOLDING = 0;
    app.research_name = "Wintermark_2006";
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    prefix = "";
    add = "_review";
    subfolder_model = "";
    if MORE_TRAINING_DATA
        subfolder_model = "MODELS_biggertrain";
        subfolder_model = strcat(subfolder_model,"_HYPER"); 
        subfolder_model = strcat(subfolder_model,"/");
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
    elseif app.option==0
        suffix = app.research_name;
    end

    %% SUS2020_v2
    if ispc % windows
        app.mainSavepath = "D:\Preprocessed-SUS2020_v2\";
        perfusionCTFolder = app.mainSavepath+"Parametric_maps\";
        SAVED_MODELS_FOLDER = app.mainSavepath+"Workspace_thresholdingMethods\"+subfolder_model+add;
        if ~strcmp(add,"")
            SAVED_MODELS_FOLDER = SAVED_MODELS_FOLDER + "/";
        end
        matlabpath = "C:\Users\2921329\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\REPOSITORY\";
        app.MANUAL_ANNOTATION_FOLDER = app.mainSavepath+"GT_TIFF\";
        IMG_PATH = "D:\Paper2_REVIEW\";
    elseif isunix % unix sistem (gorina)
        perfusionCTFolder = "/nfs/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/Parametric_Maps/";
        app.mainSavepath = "/nfs/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/";
        matlabpath = "/nfs/student/lucat/Matlab/";
        SAVED_MODELS_FOLDER = strcat(matlabpath, 'Workspace_thresholdingMethods_REVIEW/',subfolder_model,add); 
        if ~strcmp(add,"")
            SAVED_MODELS_FOLDER = SAVED_MODELS_FOLDER + "/";
        end
        app.MANUAL_ANNOTATION_FOLDER = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/GT_TIFF/";
        IMG_PATH = strcat("/nfs/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/FINALIZE_PMS/", subfolder_model, "ModeFilter/");
    end

    % set the new matlab path and all its subfolders
    matlabpath = strcat(matlabpath, 'REPOSITORY/');
    addpath(genpath(matlabpath));

    if ~isfolder(SAVED_MODELS_FOLDER)
        mkdir(SAVED_MODELS_FOLDER);
    end

    if app.option==1
        app.patientspath = app.mainSavepath+ "Parametric_Maps/";
    elseif app.option==2
        app.patientspath = app.mainSavepath+ "Thresholding_Methods_REVIEW";
        if ~strcmp(subfolder_model,"")
            app.patientspath = app.patientspath + "_" + subfolder_model;
            app.patientspath = convertStringsToChars(app.patientspath);
            app.patientspath = app.patientspath(1:end-1);
        end
    elseif app.option==3
        app.patientspath = app.mainSavepath+"Thresholding_Methods_gorina2 (tree)";
    elseif app.option==10
        app.patientspath = app.mainSavepath+"INTER-OBSERVER VARIABILITY/Parametric_Maps_Comparison_LJ/";
    elseif app.option==11
        app.patientspath = app.mainSavepath+"INTER-OBSERVER VARIABILITY/Parametric_Maps_Comparison_KK/";
    elseif app.option==0
        app.patientspath = app.mainSavepath+"Thresholding_Methods_MODELS_biggertrain_HYPER/";
    end
    
    app.realpatientspath = "/nfs/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/Parametric_Maps";
    app.finalizeFolder = "FINALIZE_PMS/"+subfolder_model+"FINALIZE_PM_"+suffix+"/";
    
    if app.KEEPALLPENUMBRA 
        app.finalizeFolder = "FINALIZE_PMS/"+subfolder_model+add+"/FINALIZE_PM_"+suffix+"/";
        % use for the mode filter option
        app.modeFilterFolder = "FINALIZE_PMS/"+subfolder_model+"ModeFilter/FINALIZE_PM_"+suffix+"/";
    end
    
    if app.THRESHOLDING
        app.finalizeFolder = IMG_PATH+"FINALIZE_PM_"+suffix+"\";
    end

    if app.option~=10 && app.option~=1 && app.option~=11
        app.overrideSuffix = suffix; 
    end

    if ispc
        app.GUIAutomaticManualAnnotationsUIFigure = uifigure;
    end

    disp(suffix);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    app.perfusionCTFolder = perfusionCTFolder;
    app.patients = getPatients(app, MORE_TRAINING_DATA, TRAIN, constants.TEST_SECRETDATASET, app.THRESHOLDING);
    
    disp(app.patients);
    
    [stats,stats_modefilter] = finalizeParametricMaps(app);
    
    if ~isempty(stats)
        secretdataset_prefix = "";
        if constants.TEST_SECRETDATASET
            secretdataset_prefix = "TESTDATASET";
        end

        disp("Calculate stats...");
        disp(strcat(SAVED_MODELS_FOLDER, secretdataset_prefix,"finalize-stats_",suffix,add,".mat"));

        calculateStats(stats, SAVED_MODELS_FOLDER, strcat(secretdataset_prefix,"finalize-stats_",suffix,add,".mat"), 0);
        prefix_formorestats = "FINALIZE_PM_";
        disp(IMG_PATH+prefix_formorestats+suffix);
        calculateMoreStats(IMG_PATH+prefix_formorestats+suffix, constants, app.MANUAL_ANNOTATION_FOLDER);
    end
    if ~isempty(stats_modefilter) && app.MODEFILTER 
        disp("Calculate stats for mode filter...");
        path = char(app.mainSavepath+app.modeFilterFolder);
        path = string(path(1:end-1));
        disp(app.modeFilterFolder);
        calculateMoreStats(path, constants, app.MANUAL_ANNOTATION_FOLDER);
    end
end
end
end
end

clear;
close all force;
