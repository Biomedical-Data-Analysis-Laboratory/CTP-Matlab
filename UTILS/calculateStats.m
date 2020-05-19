function calculateStats(stats,saveFolder,filename)
%CALCULATESTATS Summary of this function goes here
%   Detailed explanation goes here
stats.Properties.VariableNames = {'name' ...
    'tn_p' 'fn_p' 'fp_p' 'tp_p' ...
    'tn_c' 'fn_c' 'fp_c' 'tp_c' ...
    'tn_pc' 'fn_pc' 'fp_pc' 'tp_pc' ...
    'tn_p_nb' 'fn_p_nb' 'fp_p_nb' 'tp_p_nb' ...
    'tn_c_nb' 'fn_c_nb' 'fp_c_nb' 'tp_c_nb' ...
    'tn_pc_nb' 'fn_pc_nb' 'fp_pc_nb' 'tp_pc_nb'};

G = findgroups(stats.name);
names = unique(stats.name);

splits = splitapply(@sum, [...
    stats.tn_p, stats.fn_p, stats.fp_p, stats.tp_p, ...
    stats.tn_c, stats.fn_c, stats.fp_c, stats.tp_c, ...
    stats.tn_pc, stats.fn_pc, stats.fp_pc, stats.tp_pc, ...
    stats.tn_p_nb, stats.fn_p_nb, stats.fp_p_nb, stats.tp_p_nb, ...
    stats.tn_c_nb, stats.fn_c_nb, stats.fp_c_nb, stats.tp_c_nb, ...
    stats.tn_pc_nb, stats.fn_pc_nb, stats.fp_pc_nb, stats.tp_pc_nb], G);

stats = table(splits);
stats = splitvars(stats);
stats.Properties.VariableNames = {...
    'tn_p' 'fn_p' 'fp_p' 'tp_p' ...
    'tn_c' 'fn_c' 'fp_c' 'tp_c' ...
    'tn_pc' 'fn_pc' 'fp_pc' 'tp_pc' ...
    'tn_p_nb' 'fn_p_nb' 'fp_p_nb' 'tp_p_nb' ...
    'tn_c_nb' 'fn_c_nb' 'fp_c_nb' 'tp_c_nb' ...
    'tn_pc_nb' 'fn_pc_nb' 'fp_pc_nb' 'tp_pc_nb'};

stats.name = names; 
% chang the perc_100 name and order the rows
% stats.name = replace(stats.name, "_perc_100", "_perc_99");
stats = sortrows(stats,'name','ascend');
stats = movevars(stats, 'name', 'Before', 'tn_p');

%% Accuracy
stats.accuracy_p = (stats.tn_p + stats.tp_p +1e-07)./(stats.tn_p + stats.fn_p + stats.fp_p + stats.tp_p +1e-07);
stats.accuracy_c = (stats.tn_c + stats.tp_c +1e-07)./(stats.tn_c + stats.fn_c + stats.fp_c + stats.tp_c +1e-07);
stats.accuracy_pc = (stats.tn_pc + stats.tp_pc +1e-07)./(stats.tn_pc + stats.fn_pc + stats.fp_pc + stats.tp_pc +1e-07);
stats.accuracy_p_nb = (stats.tn_p_nb + stats.tp_p_nb +1e-07)./(stats.tn_p_nb + stats.fn_p_nb + stats.fp_p_nb + stats.tp_p_nb +1e-07);
stats.accuracy_c_nb = (stats.tn_c_nb + stats.tp_c_nb +1e-07)./(stats.tn_c_nb + stats.fn_c_nb + stats.fp_c_nb + stats.tp_c_nb +1e-07);
stats.accuracy_pc_nb = (stats.tn_pc_nb + stats.tp_pc_nb +1e-07)./(stats.tn_pc_nb + stats.fn_pc_nb + stats.fp_pc_nb + stats.tp_pc_nb +1e-07);

%% Precision
stats.precision_p = (stats.tp_p+1e-07)./(stats.fp_p + stats.tp_p+1e-07);
stats.precision_c = (stats.tp_c+1e-07)./(stats.fp_c + stats.tp_c+1e-07);
stats.precision_pc = (stats.tp_pc+1e-07)./(stats.fp_pc + stats.tp_pc+1e-07);
stats.precision_p_nb = (stats.tp_p_nb+1e-07)./(stats.fp_p_nb + stats.tp_p_nb+1e-07);
stats.precision_c_nb = (stats.tp_c_nb+1e-07)./(stats.fp_c_nb + stats.tp_c_nb+1e-07);
stats.precision_pc_nb = (stats.tp_pc_nb+1e-07)./(stats.fp_pc_nb + stats.tp_pc_nb+1e-07);

%% Specificity
stats.specificity_p = (stats.tn_p+1e-07)./(stats.fp_p + stats.tn_p+1e-07);
stats.specificity_c = (stats.tn_c+1e-07)./(stats.fp_c + stats.tn_c+1e-07);
stats.specificity_pc = (stats.tn_pc+1e-07)./(stats.fp_pc + stats.tn_pc+1e-07);
stats.specificity_p_nb = (stats.tn_p_nb+1e-07)./(stats.fp_p_nb + stats.tn_p_nb+1e-07);
stats.specificity_c_nb = (stats.tn_c_nb+1e-07)./(stats.fp_c_nb + stats.tn_c_nb+1e-07);
stats.specificity_pc_nb = (stats.tn_pc_nb+1e-07)./(stats.fp_pc_nb + stats.tn_pc_nb+1e-07);

%% Sensitivity
stats.sensitivity_p = (stats.tp_p+1e-07)./(stats.fn_p + stats.tp_p+1e-07);
stats.sensitivity_c = (stats.tp_c+1e-07)./(stats.fn_c + stats.tp_c+1e-07);
stats.sensitivity_pc = (stats.tp_pc+1e-07)./(stats.fn_pc + stats.tp_pc+1e-07);
stats.sensitivity_p_nb = (stats.tp_p_nb+1e-07)./(stats.fn_p_nb + stats.tp_p_nb+1e-07);
stats.sensitivity_c_nb = (stats.tp_c_nb+1e-07)./(stats.fn_c_nb + stats.tp_c_nb+1e-07);
stats.sensitivity_pc_nb = (stats.tp_pc_nb+1e-07)./(stats.fn_pc_nb + stats.tp_pc_nb+1e-07);

%% F1 score (= Dice coefficient)
stats.f1_p = (2.*(stats.precision_p .* stats.sensitivity_p) +1e-07)./(stats.precision_p + stats.sensitivity_p+1e-07);
stats.f1_c = (2.*(stats.precision_c .* stats.sensitivity_c) +1e-07)./(stats.precision_c + stats.sensitivity_c+1e-07);
stats.f1_pc = (2.*(stats.precision_pc .* stats.sensitivity_pc) +1e-07)./(stats.precision_pc + stats.sensitivity_pc+1e-07);
stats.f1_p_nb = (2.*(stats.precision_p_nb .* stats.sensitivity_p_nb) +1e-07)./(stats.precision_p_nb + stats.sensitivity_p_nb+1e-07);
stats.f1_c_nb = (2.*(stats.precision_c_nb .* stats.sensitivity_c_nb) +1e-07)./(stats.precision_c_nb + stats.sensitivity_c_nb+1e-07);
stats.f1_pc_nb = (2.*(stats.precision_pc_nb .* stats.sensitivity_pc_nb) +1e-07)./(stats.precision_pc_nb + stats.sensitivity_pc_nb+1e-07);

%% Jaccard index (NOT usefull)
% stats.jaccard_p = (stats.f1_p+1e-07)./(2-stats.f1_p+1e-07);
% stats.jaccard_c = (stats.f1_c+1e-07)./(2-stats.f1_c+1e-07);
% stats.jaccard_pc = (stats.f1_pc+1e-07)./(2-stats.f1_pc+1e-07);
% stats.jaccard_p_nb = (stats.f1_p_nb+1e-07)./(2-stats.f1_p_nb+1e-07);
% stats.jaccard_c_nb = (stats.f1_c_nb+1e-07)./(2-stats.f1_c_nb+1e-07);
% stats.jaccard_pc_nb = (stats.f1_pc_nb+1e-07)./(2-stats.f1_pc_nb+1e-07);

%% save the workspace 
save(strcat(saveFolder, filename));

end
