function generateParametricMaps(app)
%GENERATEPARAMETRICMAPS Summary of this function goes here
%   Detailed explanation goes here

if isstring(app.rawdatapath)
    app.rawdatapath = convertStringsToChars(app.rawdatapath);
end
patientsFolder = dir(fullfile(app.rawdatapath, '*/'));

if isstring(app.workspacepath)
    app.workspacepath = convertStringsToChars(app.workspacepath);
end
workspaceFolder = app.workspacepath;

if isstring(app.patientspath)
    app.patientspath = convertStringsToChars(app.patientspath);
end
rawDataFolder = app.patientspath;

%% main function
getMAINinfo(patientsFolder,rawDataFolder,workspaceFolder,app.GUIAutomaticManualAnnotationsUIFigure)

end

