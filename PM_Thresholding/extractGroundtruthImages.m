clear;
close all;

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\';
USER = strcat(USER, 'Luca\');
% USER = strcat(USER, '2921329\');


%% folders for the original Patients
% HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
% perfusionCTFolder = strcat(HOME, 'PhD/Patients/');
% SAVED_MODELS_FOLDER = strcat(perfusionCTFolder, 'SAVED_MODELS/');
% 
% if PARAMETRIC_IMAGES_TO_ANALYZE
%     perfusionCTFolder = strcat(perfusionCTFolder, 'extracted_info/'); % update the perfusion folder
%     saveFolder = perfusionCTFolder;
% else
%     saveFolder = strcat(perfusionCTFolder, 'extracted_info/');
% end
% 
% MANUAL_ANNOTATION_FOLDER = strcat(USER, 'OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/');
% % brain, CBF, CBV, TMax, TTP <-- this is the order
% subfolds = ["SE000003", "SE000004", "SE000005", "SE000006", "SE000007"]; 
% patient_index = 2:11;

%% folders for the new dataset (SUS 2020)
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
perfusionCTFolder = strcat(USER, 'Desktop\SUS2020\');
SAVED_MODELS_FOLDER = strcat(HOME, 'PhD/Patients/SAVED_MODELS/');

if PARAMETRIC_IMAGES_TO_ANALYZE
    perfusionCTFolder = strcat(perfusionCTFolder, 'Parametric_Maps/'); % update the perfusion folder
    saveFolder = perfusionCTFolder;
    mkdir(saveFolder);
else
    saveFolder = strcat(perfusionCTFolder, 'Parametric_Maps/');
end

MANUAL_ANNOTATION_FOLDER = "";
% MIP, CBF, CBV, TMax, TTP <-- this is the order
subfolds = ["MIP", "CBF", "CBV", "TMAX", "TTP"]; 
patient_index = [12,15,76,79];


%% patients 
patient_prefix = "PA";
patients = []; 
for p=patient_index
    name = num2str(p);
    if length(name) == 1
        name = strcat('0', name);
    end
    patients = [patients; strcat(patient_prefix,name)];
end

SHOW_IMAGES = 1;
[predictions,statsClassific] = mainExtractionFunc(patients,perfusionCTFolder,MANUAL_ANNOTATION_FOLDER,SAVED_MODELS_FOLDER,saveFolder,subsavefolder,subfolds,SHOW_IMAGES);

if SUPERVISED_LEARNING
    if ~isempty(statsClassific)
        %% save the statistic information (both for the classification approach and the thresholding approach
        calculateStats(statsClassific,SAVED_MODELS_FOLDER,strcat("statsClassific_2steps_",SUFFIX_RES,".mat"));
        % calculateStats(stats,saveFolder,"Cambell_AUC10_allstats.mat");
    end
end




