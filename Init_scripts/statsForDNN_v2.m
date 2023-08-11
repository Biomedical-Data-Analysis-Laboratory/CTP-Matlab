close all
clc
warning off

% ROOT = "D:\Results paper 4\TEST__mJNet_3dot5D_noDrop_DA_ADAM_VAL20_SOFTMAX_128_512x512\"; 
% % ROOT = "D:\Results paper 4\"; 
% GT_PATH = "D:\Preprocessed-SUS2020_v2\GT_TIFF\";
ROOT = "D:\Preprocessed-SUS2020_v2\INTER-OBSERVER VARIABILITY\FINALIZE_PM_Comparison_KK\";
GT_PATH = "D:\Preprocessed-SUS2020_v2\INTER-OBSERVER VARIABILITY\FINALIZE_PM_Comparison_LJ\";

matlabpath = "C:\Users\2921329\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\REPOSITORY\";
        
if isunix && ~ismac
    ROOT = "/bhome/lucat/mJ-Net/SAVE/EXP041.04/IMAGES_v21-0.5/";
    
    GT_PATH = "/home/prosjekt/PerfusionCT/StrokeSUS/COMBINED/GT_TIFF/";
    % GT_PATH = "/home/prosjekt/PerfusionCT/StrokeSUS/DWI/REGISTERED_2.0/GT/";

%     ROOT = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/INTER-OBSERVER_VARIABILITY/FINALIZE_PM_Comparison_KK/";
%     GT_PATH = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/INTER-OBSERVER_VARIABILITY/FINALIZE_PM_Comparison_LJ/";
    matlabpath = "/home/student/lucat/Matlab/";
end
    
EXP_NAME = ""; % "__mJNet_4D_DA_ADAM_VAL20_SOFTMAX_128_512x512";
% EXP_NAME = "EXP036.0__mJNet_DA_ADAM_VAL20_SOFTMAX_128_512x512";
% EXP_NAME = "EXP038.03__mJNet_4D_noDrop_DA_ADAM_VAL20_SOFTMAX_128_512x512";
% EXP_NAME = "EXP099.937__PMs_segmentation_NOBatch_DA_ADAM_VAL20_SOFTMAX_128_512x512";
% EXP_NAME = "__TCNet_3dot5D_single_encoder_DA_ADAM_VAL20_SOFTMAX_128_512x512";
% EXP_NAME = "__TCNet_DA_ADAM_VAL20_SOFTMAX_128_512x512";

% filename = "multiPMs_99.txt";
filename = "3Dmjnet_v21-0.5.txt";

% EXP_NAME = ""; % for inter-observer variability
EXP_FOLD = fullfile(ROOT,EXP_NAME);

constants.TEST_SECRETDATASET = 1;
constants.TIFF_SUFFIX = 0;
constants.TIFF_SUFFIX_GT = 1;
constants.MULTICLASS = 1; % binary for DWI segmentation

% set the new matlab path and all its subfolders
matlabpath = strcat(matlabpath, 'REPOSITORY/');
addpath(genpath(matlabpath));

disp(EXP_FOLD); 
stats = calculateMoreStats(EXP_FOLD,constants,GT_PATH);

% Calculate the stats for all the groups together
extractStatsFromTable(stats,1:height(stats),constants,ROOT+filename)

% f1 = figure;
% axes1 = axes('Parent',f1);
% hold(axes1,'all');
% scatter(stats.("V_gt_p")(1:height(stats)), stats.("dice_penumbra")(1:height(stats)), "filled"),legend
%saveas(f1,EXP_FOLD+"_scatter_VOL-DICE_penumbra.png")

% Stats for the various groups distinctly
index = split(stats.patient,"_");
index = index(:,2);
index = string(cell2mat(index));
for severity = unique(index)'
    if ~strcmp(severity,"00") && ~strcmp(severity,"20") ...
            && ~strcmp(severity,"21") && ~strcmp(severity,"22") && ~strcmp(severity,"23")
        indexSeverity = contains(index, severity);
        if strcmp(severity,"01")
            zeroSeverity = contains(index, "00");
            combSev_0 = contains(index, "20");
            combSev = contains(index, "21");
            indexSeverity = indexSeverity | zeroSeverity | combSev_0 | combSev;
        elseif strcmp(severity,"02")
            combSev = contains(index, "22");
            indexSeverity = indexSeverity | combSev;
        elseif strcmp(severity,"03")
            combSev = contains(index, "23");
            indexSeverity = indexSeverity | combSev;
        end
        fileID = fopen(ROOT+filename,"a");
        fprintf(fileID,"\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n" + ...
            " SEVERITY: %s \n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n",severity);
        
        extractStatsFromTable(stats,indexSeverity,constants,ROOT+filename);

        % f1 = figure;
        % axes1 = axes('Parent',f1);
        % hold(axes1,'all');
        % scatter(stats.("V_gt_p")(indexSeverity), stats.("dice_penumbra")(indexSeverity), "filled"),legend
        %saveas(f1,EXP_FOLD+strcat("_scatter_VOL-DICE_penumbra_",severity,".png"))

    end
end

fclose('all');