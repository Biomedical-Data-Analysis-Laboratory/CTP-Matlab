function prepareDataForExtract(app)
%PREPAREDATAFOREXTRACT Prepare CTP images of the patients for extraction
%   Based on the paths: patientpath, modelspath, workspacepath generate the
%   right values of the patients (with their ID) plus other flags to call
%   the MAINEXTRACTIONFUNC!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% extract the various paths
if isstring(app.patientspath)
    app.patientspath = convertStringsToChars(app.patientspath);
end
perfusionCTFolder = app.patientspath;
saveFolder = app.patientspath;

if isstring(app.modelspath)
    app.modelspath = convertStringsToChars(app.modelspath);
end
SAVED_MODELS_FOLDER = app.modelspath;

if isstring(app.workspacepath)
    app.workspacepath = convertStringsToChars(app.workspacepath);
end
workspaceFolder = app.workspacepath;
MANUAL_ANNOTATION_FOLDER = "";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% other important variables
totPats = numel(dir(saveFolder))-2;
subfolds = ["MIP", "CBF", "CBV", "TMAX", "TTP"]; 
subsavefolder = ["Annotations/", "Original/"];
previousNumPatiens = 0; % 11;

patient_index = double(previousNumPatiens+1:previousNumPatiens+totPats);
if app.RunallpatientsCheckBox.Value ~= 1
    patient_index = double((previousNumPatiens+app.FrompatientSpinner.Value):(previousNumPatiens+app.TopatientSpinner.Value));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get patients name folder (not create a fixed one)
patients = []; 
count_idx = 1;
for p=dir(saveFolder)'
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
constants.LOAD_AND_PREDICT_PATIENT = 1; % load and predict a single patient at the time
constants.RUN_EXTRACTION_AGAIN = 0; % run the extraction even if the corresponding folder ALREADY contains the values
constants.PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
constants.SAVE_PAR_MAPS = 0; % flag to save the parametric maps
constants.SAVE_TRESHOLDING = 0; % flag to save the thresholding values
constants.flag_PENUMBRACORE = 1; % to run also the penumbra-core statistics
constants.DIFFERENT_PERCENTAGES = 0; % use only for the ROC curve
constants.SUPERVISED_LEARNING = 0; % flag for the supervised learning (with or without the ground truth)
constants.FAKE_MIP = 0; % use to just ignore the old infarction presented in the MIP (maximum intensity projection) images
constants.SUFFIX_RES = 'tree'; % 'SVM' // 'tree' // 'SVM_tree' 
constants.USE_UNIQUE_MODEL = true; % for creating a unque model and not passing through a cross-validation over the patiens

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% values for each parametric map [perc(%), up/down, core/penumbra]
researchesValues = containers.Map;
researchesValues(strcat('superpixels2steps_',SUFFIX_RES)) = struct('cluster',"yes"); % no need of thresholding values!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% execute the main extraction function
mainExtractionFunc(patients,researchesValues,perfusionCTFolder,MANUAL_ANNOTATION_FOLDER,...
    SAVED_MODELS_FOLDER,saveFolder,subsavefolder,subfolds,constants,...
    workspaceFolder,app.GUIAutomaticManualAnnotationsUIFigure);

end

