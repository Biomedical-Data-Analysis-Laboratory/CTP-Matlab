clear;
close all;

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\';
% USER = strcat(USER, 'Luca\');
USER = strcat(USER, '2921329\');

%% CONSTANTS
PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
perfusionCTFolder = strcat(HOME, 'Luca/PhD/Patients/');

if PARAMETRIC_IMAGES_TO_ANALYZE
    perfusionCTFolder = strcat(perfusionCTFolder, 'extracted_info/');
    saveFolder = perfusionCTFolder;
else
    saveFolder = strcat(perfusionCTFolder, 'extracted_info/');
end

%%
% ############################################################
% ############################################################
%%

% load(strcat(saveFolder, "best_new_allstats.mat"), "stats", "researchesValues");
load(strcat(saveFolder, "BEST_AUC10_allstats.mat"), "stats", "researchesValues");


AUC_table = table();

for flag = ["penumbra", "core"]
    AUC_table = plotROC(researchesValues,stats,AUC_table,flag);
end

