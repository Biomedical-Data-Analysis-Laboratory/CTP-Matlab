%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the default stats plus others (DICE, Hausdorff distance,
% Bland–Altman plot, ...)
clear;
clc % clear command window
close all force;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VARIABLES
if ispc % windows
    IMG_PATH = "D:\Paper2_REVIEW\";
    IMG_PATH = IMG_PATH + "ModeFilter\";
    GT_PATH = "D:\Preprocessed-SUS2020_v2\GT_TIFF\";    
%     GT_PATH = "D:\Preprocessed-SUS2020_v2\INTER-OBSERVER VARIABILITY\FINALIZE_PM_Comparison_KK\";  
%     GT_PATH = "D:\Preprocessed-SUS2020_v2\INTER-OBSERVER VARIABILITY\FINALIZE_PM_Comparison_LJ\";  
    %IMG_PATH = "C:\Users\Luca\Desktop\"; 
    
elseif isunix % unix sistem (gorina)
    matlabpath = "/home/student/lucat/Matlab/REPOSITORY/";
    IMG_PATH = "/home/student/lucat/PhD_Project/Stroke_segmentation/PATIENTS/SUS2020_TIFF/FINALIZE_PMS/MODELS_biggertrain_HYPER/ModeFilter/"; % AllP__review
    GT_PATH =  "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/GT_TIFF/";
    % set the new matlab path and all its subfolders
    addpath(genpath(matlabpath));
end

steps = [2];
smote = [1];
use_superpixels = [2];
n_superpixels = [10];

for step = steps
for sp = use_superpixels 
for n_sp = n_superpixels
for smmm = smote
constants.SUFFIX_RES = 'SVM'; % 'SVM' // 'tree' // 'randomForest' 
constants.STEPS = step; % or 2 steps to divide penumbra and core prediction
constants.USESUPERPIXELS = sp; % set the variable == 2 for using ONLY the suprpixels features
constants.N_SUPERPIXELS = n_sp;
constants.SMOTE = smmm;
constants.TEST_SECRETDATASET = 0;
constants.MORE_TRAINING_DATA = 1;
constants.overlapName = ""; %"LIVKATHINKA";
constants.SUMSTATS = 1;
constants.KEEPALLPENUMBRA = 1;
 
constants.THRESHOLDING = 0;
research_name = "Bathla_2020"; % "SYNGO.VIA_default"; %"Bathla_2020"; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prefix = "FINALIZE_PM_";
add = "";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
secretdataset_prefix = "";
if constants.TEST_SECRETDATASET
    secretdataset_prefix = "_TEST";
    if contains(GT_PATH, "_Comparison_KK")
        secretdataset_prefix = secretdataset_prefix  + "_KK";
    elseif contains(GT_PATH, "_Comparison_LJ")
        secretdataset_prefix = secretdataset_prefix  + "_LJ";
    end
end

if ~constants.THRESHOLDING
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
end
% if constants.KEEPALLPENUMBRA
%     add = "AllP__v3\";
% end

if constants.THRESHOLDING
    name = strcat(prefix,research_name);
else
    name = strcat(prefix,int2str(constants.STEPS),"steps_",constants.SUFFIX_RES);
end

if ~strcmp(constants.overlapName,"")
    name = constants.overlapName;
end

disp(IMG_PATH+add+name+secretdataset_prefix+"_stats.mat");

if ~exist(IMG_PATH+add+name+secretdataset_prefix+"_stats.mat", "file")
    stats = calculateMoreStats(IMG_PATH+add+name, constants, GT_PATH);
else
    load(IMG_PATH+name+secretdataset_prefix+"_stats.mat",'stats');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the stats for all the groups together
extractStatsFromTable(stats,1:height(stats))
% Stats for the various groups distinctly
index = split(stats.patient,"_");
index = index(:,2);
index = string(cell2mat(index));
for severity = unique(index)'
    if ~strcmp(severity,"00")
        indexSeverity = contains(index, severity);
        if strcmp(severity,"01")
            zeroSeverity = contains(index, "00");
            indexSeverity = indexSeverity | zeroSeverity;
        end
        fprintf("\n SEVERITY: %s \n",severity);
        
        extractStatsFromTable(stats,indexSeverity);
    end
end

%% TODO: fix
options.plotCI=false;
options.plot_x_mean=true;
if ispc
    h_p = BlandAltmanPlot([stats.V_gt_p./1000;stats.V_gt_c./1000], [stats.V_img_p./1000;stats.V_img_c./1000],options);
end

end
end
end
end

close all

