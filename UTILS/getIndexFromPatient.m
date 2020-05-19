function pIndex = getIndexFromPatient(patient, n_fold)
%GETINDEXFROMPATIENT Summary of this function goes here
%   Detailed explanation goes here

% pIndex = patient(end-1:end);

tmp_el = split(patient,"_");
pIndex = strcat(num2str(n_fold), tmp_el{2}, tmp_el{3});
end

