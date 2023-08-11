function generateParametricMaps(app)
%GENERATEPARAMETRICMAPS Extract the PMs from the DICOM folders
%   Get the PMs and other info from the DICOM folder (applies to the new
%   dataset)

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

if isstring(app.patientsDWIpath)
    app.patientsDWIpath = convertStringsToChars(app.patientsDWIpath);
end
DWIDataFolder = app.patientsDWIpath;
%% main function
getMAINinfo(patientsFolder,rawDataFolder,DWIDataFolder,workspaceFolder,app.GUIAutomaticManualAnnotationsUIFigure)

end

