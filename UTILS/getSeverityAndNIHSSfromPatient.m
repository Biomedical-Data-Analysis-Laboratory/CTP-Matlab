function [severity,NIHSS] = getSeverityAndNIHSSfromPatient(patient)
%GETSEVERITYANDNIHSSFROMPATIENT Summary of this function goes here
%   Detailed explanation goes here

tmp_el = split(patient,"_");

%% severity is used just to divide the LVO, SVO and WVO
severity = tmp_el{2};

if strcmp(severity,"00") % retrocompatibility with the Kathinka annotations
    severity = "01";
end

%% get the NIHSS from file
if ispc % windows
    T = readtable('D:\Preprocessed-SUS2020_v2\nihss_score.csv', 'HeaderLines',1);
elseif isunix % unix sistem (gorina) or mac
    if ismac
        T = readtable("/Users/lucatomasetti/OneDrive - Universitetet i Stavanger/Luca/PhD/MATLAB_CODE/Workspace//NIHSS-score.csv", 'HeaderLines',1);
    else
        T = readtable('/home/student/lucat/Matlab/Workspace_thresholdingMethods_REVIEW/NIHSS-score.csv', 'HeaderLines',1);
    end
end
patient_row = strcmp(T{:,1},patient);
NIHSS = T{patient_row,2}; % get the NIHSS at admission, use 3 if you want the NIHSS at dismission

if isnan(NIHSS)
    NIHSS = 0;
end

end

