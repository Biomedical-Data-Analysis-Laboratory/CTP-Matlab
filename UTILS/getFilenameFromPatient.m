function [fname,folderPath,p_id] = getFilenameFromPatient(patient, workspaceFolder, save_prefix, directory, ISLISTOFDIR)
%GETFILENAMEFROMPATIENT Summary of this function goes here
%   Detailed explanation goes here
if ~ISLISTOFDIR % old patients
    p_id = num2str(patient);
    if patient<10
        p_id = strcat('PA0',p_id);
        fname = strcat(workspaceFolder,save_prefix,p_id,'.mat');
    else
        p_id = strcat('PA',p_id);
        fname = strcat(workspaceFolder,save_prefix,p_id,'.mat');
    end
    if patient<9
        folderPath = strcat(directory,p_id,'/ST000000/SE000001/');
    else
        if patient == 9
            folderPath = strcat(directory,p_id,'/ST000000/SE000000/');
        else
            folderPath = strcat(directory,p_id,'/ST000000/SE000000/');
        end
    end
else
    folderPath = directory{patient}; 
    p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));        
    fname = workspaceFolder + convertCharsToStrings(save_prefix) + p_id + ".mat";
end
end

