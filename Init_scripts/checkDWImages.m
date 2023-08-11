clear;
close all force;
clc;

DWI_fold = "D:\DWI\Raw\";

if isunix
    DWI_fold = "/home/prosjekt/PerfusionCT/StrokeSUS/DWI/RAW STUDIES/Follow-Up/";
end

for patient = dir(DWI_fold)'
    if ~strcmp(patient.name, '.') && ~strcmp(patient.name, '..')
        disp(patient.name);
        
    end
end