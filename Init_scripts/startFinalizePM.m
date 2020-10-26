clear;
close all force;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VARIABLES
constants.SUFFIX_RES = 'randomForest'; % 'SVM' // 'tree' // 'randomForest' 
constants.STEPS = 2; % or 2 steps to divide penumbra and core prediction
constants.USESUPERPIXELS = 1; % set the variable == 2 for using ONLY the suprpixels features
constants.N_SUPERPIXELS = 50;
constants.SMOTE = 1;
app.option = 1; % 10 --> Liv // 11 --> Kathinka

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix = "";
add = "";

if app.option==1
    suffix = "TIFF";
elseif app.option==2 || app.option==3
    if constants.USESUPERPIXELS
        if constants.USESUPERPIXELS==1
            prefix = prefix+"superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
        elseif constants.USESUPERPIXELS==2
            prefix = prefix+"ONLYsuperpixels"+int2str(constants.N_SUPERPIXELS)+"_";
        end
    else
        prefix = prefix+"10_"; % default value if no superpixels involved
    end

    if constants.SMOTE
        prefix = prefix+"SMOTE_";
    end

    suffix = strcat(prefix,int2str(constants.STEPS),"steps_",constants.SUFFIX_RES);
elseif app.option==10
    suffix = "Comparison_Liv";
elseif app.option==11
    suffix = "Comparison_Kathinka";
end

%% SUS2020_v2
if ispc % windows
    app.mainSavepath = "D:\Preprocessed-SUS2020_v2\";
    matlabpath = "C:\Users\2921329\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\REPOSITORY\";
elseif isunix % unix sistem (gorina)
    app.mainSavepath = "/nfs/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/";
    matlabpath = "/home/student/lucat/Matlab/";
end

% set the new matlab path and all its subfolders
addpath(genpath(matlabpath));
    
if app.option==1
    app.patientspath = app.mainSavepath+ "Parametric_Maps/";
elseif app.option==2
    app.patientspath = app.mainSavepath+ "Thresholding_Methods";
elseif app.option==3
    app.patientspath = app.mainSavepath+ "Thresholding_Methods_gorina2 (tree)";
elseif app.option==10
    app.patientspath = app.mainSavepath+ "Parametric_Maps_Comparison_Liv/";
elseif app.option==11
    app.patientspath = app.mainSavepath+ "Parametric_Maps_Comparison_Kathinka/";
end
app.realpatientspath = app.mainSavepath+"Parametric_Maps";
app.finalizeFolder = "FINALIZE_PMS/FINALIZE_PM_"+suffix+"/";
if app.option~=10 && app.option~=1 && app.option~=11
    app.overrideSuffix = suffix; 
end

if ispc
    app.GUIAutomaticManualAnnotationsUIFigure = uifigure;
end

finalizeParametricMaps(app)

clear;
close all force;