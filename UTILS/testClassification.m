clear; % clear the workspace
close all; % close all window images

load("PM_totalinfor_workspace_cluster_p03");


%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\';
USER = strcat(USER, 'Luca\');
% USER = strcat(USER, '2921329\');

%% CONSTANTS
PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
SAVE_PAR_MAPS = 0; 
% to run also the penumbra-core statistics
flag_PENUMBRACORE = 1;
DIFFERENT_PERCENTAGES = 0;
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
perfusionCTFolder = strcat(HOME, 'PhD/Patients/');
penumbra_color = 76;
core_color = 150;

if PARAMETRIC_IMAGES_TO_ANALYZE
    perfusionCTFolder = strcat(perfusionCTFolder, 'extracted_info/');
    saveFolder = perfusionCTFolder;
else
    saveFolder = strcat(perfusionCTFolder, 'extracted_info/');
end

MANUAL_ANNOTATION_FOLDER = strcat(USER, 'OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/');
patient = 'PA03';

statsClassific = table();
suffix = 'superpixelstree';

%% starting at the end of clusterImagesWithRealValues.m
statsClassific = classificationApproach(realValueImages,skullMasks, ...
    MANUAL_ANNOTATION_FOLDER, patient, penumbra_color, core_color, saveFolder, suffix, statsClassific);

calculateStats(statsClassific,saveFolder,"teststats.mat")