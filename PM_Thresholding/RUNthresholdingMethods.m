%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run the thresholding based on the researchValues maps.
% The script runs it the external hard drive is present (the one containing the various patients)
clear;
close all force;

MAIN_PATH = "D:\Preprocessed-SUS2020_v2\";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% important variables
perfusionCTFolder = MAIN_PATH+"Parametric_maps\";
saveFolder = MAIN_PATH+"Thresholding_Methods\";
workspaceFolder = MAIN_PATH+"Workspace_thresholdingMethods\";
SAVED_MODELS_FOLDER = "";
MANUAL_ANNOTATION_FOLDER = MAIN_PATH+"FINALIZE_PM\";
subfolds = ["MIP", "CBF", "CBV", "TMAX", "TTP"]; 
subsavefolder = ["Annotations/", "Original/"];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get patients name folder (not create a fixed one)
totPats = numel(dir(perfusionCTFolder))-2;
previousNumPatiens = 0;
patient_index = double(previousNumPatiens+1:previousNumPatiens+totPats);
patients = []; 
count_idx = 1;
for p=dir(perfusionCTFolder)'
    if ~strcmp(p.name, '.') && ~strcmp(p.name, '..')
        if sum(patient_index==count_idx)>0
            patients = [patients; convertCharsToStrings(p.name)];
        end
        count_idx=count_idx+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONSTANTS
constants.SHOW_IMAGES = 0; % show the images during the execution of the function
constants.LOAD_AND_PREDICT_PATIENT = 0; % load and predict a single patient at the time
constants.RUN_EXTRACTION_AGAIN = 1; % run the extraction even if the corresponding folder ALREADY contains the values
constants.PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
constants.SAVE_PAR_MAPS = 0; % flag to save the parametric maps
constants.SAVE_TRESHOLDING = 1; % flag to save the thresholding values
constants.flag_PENUMBRACORE = 1; % to run also the penumbra-core statistics
constants.DIFFERENT_PERCENTAGES = 0; % use only for the ROC curve
constants.SUPERVISED_LEARNING = 1; % flag for the supervised learning (with or without the ground truth)
constants.FAKE_MIP = 0; % use to just ignore the old infarction presented in the MIP (maximum intensity projection) images
constants.SUFFIX_RES = 'tree'; % 'SVM' // 'tree' // 'SVM_tree' 
constants.USE_UNIQUE_MODEL = true; % for creating a unque model and not passing through a cross-validation over the patiens

%% values for each parametric map [perc(%), up/down, core/penumbra]
researchesValues = containers.Map;

researchesValues('Cereda_2015') = struct('CBF', [38, "down", "core", ""], 'TMax', [33, "up", "penumbra", ""]);
researchesValues('Wintermark_2006') = struct('CBV', [33, "down", "core", ""]); %, 'MTT', [6, "up", "penumbra"]);
researchesValues('Ma_Cambell_2019') = struct('CBF', [30, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
% % % researchesValues('Bivard_Lin_2014') = struct('CBF', [30, "down", "core"], 'TMax', [50, "up", "penumbra"]);
% % 
% researchesValues('Shaefer_2014') = struct('CBF', [15, "down", "core", ""], 'CBV', [30, "down", "core", ""]);
% % 
% % % researchesValues('Bivard_2014') = struct('CBF', [50, "down", "core"], 'TTP', [75, "up", "penumbra"]);
researchesValues('Cambell_2012') = struct('CBF', [31, "down", "core", 10], 'TTP', [20, "up", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
% researchesValues('Murphy_2006') = struct('CBF', [13.3, "down", "core", ""], 'CBV', [18.6, "down", "core", 5], 'CBF_2', [25, "down", "penumbra", ""], 'CBV_2', [36, "down", "penumbra", 10]);
% % % researchesValues('Shaefer_2006') = struct('CBF', [17.92, "down", "penumbra"], 'CBV', [24.5, "down", "core"]);
% % % researchesValues('Shaefer_2006_2') = struct('CBF', [8.8, "down", "core"], 'CBV', [49, "down", "penumbra"]);
% % % researchesValues('Bivard') = struct('CBF', [50, "down", "core"], 'TTP', [75, "down", "penumbra"]);
% % %researchesValues('COMB_Wintermark_Shaefer') = struct('CBV', [24.5, "down", "core"], 'CBF', [30, "down", "penumbra"], 'TMax', [50, "up", "penumbra"], 'TTP', [75, "up", "penumbra"]);


%% execute the main extraction function
mainExtractionFunc(patients,researchesValues,perfusionCTFolder,MANUAL_ANNOTATION_FOLDER,...
    SAVED_MODELS_FOLDER,saveFolder,subsavefolder,subfolds,constants,workspaceFolder);
