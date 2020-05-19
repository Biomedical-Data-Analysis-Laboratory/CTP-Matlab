function prepareDataForExtract(app)
%PREPAREDATAFOREXTRACT Summary of this function goes here
%   Detailed explanation goes here

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

totPats = numel(dir(saveFolder))-2;

subfolds = ["MIP", "CBF", "CBV", "TMAX", "TTP"]; 
subsavefolder = ["Annotations/", "Original/"];
previousNumPatiens = 0; % 11;

patient_index = double(previousNumPatiens+1:previousNumPatiens+totPats);
if app.RunallpatientsCheckBox.Value ~= 1
    patient_index = double((previousNumPatiens+app.FrompatientSpinner.Value):(previousNumPatiens+app.TopatientSpinner.Value));
end

%% patients 
% patient_prefix = "PA";
% patients = []; 
% for p=patient_index
%     name = num2str(p);
%     if length(name) == 1
%         name = strcat('0', name);
%     end
%     patients = [patients; strcat(patient_prefix,name)];
% end

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

SHOW_IMAGES = 0;
LOAD_AND_PREDICT_PATIENT = 1;

tic
mainExtractionFunc(patients,perfusionCTFolder,"",SAVED_MODELS_FOLDER,saveFolder,subsavefolder,subfolds,SHOW_IMAGES,LOAD_AND_PREDICT_PATIENT,workspaceFolder,app.GUIAutomaticManualAnnotationsUIFigure);
timepass = toc;

% f = msgbox(strcat("Operation Completed in ", num2str(timepass), "s."),'Success');

end

