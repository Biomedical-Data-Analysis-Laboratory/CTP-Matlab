function [tableData,nImages] = classificationApproach(realValueImages,skullMasks, ...
    MANUAL_ANNOTATION_FOLDER, SUPERVISED_LEARNING, patient, n_fold)

%CLASSIFICATIONAPPROACH Summary of this function goes here
%   Detailed explanation goes here

close all;

pIndex = getIndexFromPatient(patient, n_fold);
nImages = size(realValueImages,2);

%% prepare the data 
[tableData] = prepareDataForModel(realValueImages,skullMasks,MANUAL_ANNOTATION_FOLDER,SUPERVISED_LEARNING,pIndex);

end

