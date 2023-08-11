%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the average stats for all the patients calculated
clear;
clc % clear command window
close all force;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VARIABLES
MAIN_PATH = "D:\Preprocessed-SUS2020_v2\";
workspace_dir = "Workspace_thresholdingMethods"; % Workspace_thresholdingMethods
SAVED_MODELS_FOLDER = MAIN_PATH+workspace_dir+"\MODELS_biggertrain_HYPER\";
% SAVED_MODELS_FOLDER = "C:\Users\Luca\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\";
%SAVED_MODELS_FOLDER = "/Users/lucatomasetti/OneDrive - Universitetet i Stavanger/Luca/PhD/MATLAB_CODE/";

constants.SUFFIX_RES = 'randomForest'; % 'SVM' // 'tree' // 'randomForest' 
constants.STEPS = 1; % or 2 steps to divide penumbra and core prediction
constants.USESUPERPIXELS = 1; % set the variable == 2 for using ONLY the superpixels features
constants.N_SUPERPIXELS = 200;
constants.SMOTE = 0;
constants.TEST_SECRETDATASET = 1;
constants.MORE_TRAINING_DATA = 1;
constants.overlapName = ""; %"LIVKATHINKA";
constants.SUMSTATS = 1;
constants.KEEPALLPENUMBRA = 1;

constants.THRESHOLDING = 1;
research_name = "Murphy_2006";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix = "";
add = "_HYPER";

if constants.MORE_TRAINING_DATA
    SAVED_MODELS_FOLDER = MAIN_PATH+workspace_dir+"\MODELS_biggertrain"+add+"\";
end

secretdataset_prefix = "";
if constants.TEST_SECRETDATASET
    secretdataset_prefix = "TESTDATASET";
end

if constants.USESUPERPIXELS
    if constants.USESUPERPIXELS==1
        prefix = prefix+"superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
    elseif constants.USESUPERPIXELS==2
        prefix = prefix+"ONLYsuperpixels"+int2str(constants.N_SUPERPIXELS)+"_";
    elseif constants.USESUPERPIXELS==3
        prefix = prefix+"2D_superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
    elseif constants.USESUPERPIXELS==4
        prefix = prefix+"2D_ONLYsuperpixels"+int2str(constants.N_SUPERPIXELS)+"_";
    end
else
    prefix = prefix+"10_"; % default value if no superpixels involved
end

if constants.SMOTE
    prefix = prefix+"SMOTE_";
end

if constants.KEEPALLPENUMBRA
    add = "AllP_"+add;
end

name = strcat(prefix,int2str(constants.STEPS),"steps_",constants.SUFFIX_RES);

if ~strcmp(constants.overlapName,"")
    name = constants.overlapName;
end

if constants.THRESHOLDING
    if ~constants.KEEPALLPENUMBRA
        SAVED_MODELS_FOLDER = MAIN_PATH+workspace_dir+"\KEEPONLYLARGEPENUMBRA\";
    end
    name = research_name;
    
    load(strcat(SAVED_MODELS_FOLDER, strcat("Wintermark_2006", "_stats")),"stats");
    calculateStats(stats,SAVED_MODELS_FOLDER,strcat(secretdataset_prefix,"finalize-stats_","Wintermark_2006",add,".mat"),0)
    
    filename = strcat(secretdataset_prefix,"finalize-stats_","Wintermark_2006",add,".mat");
else
    if constants.KEEPALLPENUMBRA
        SAVED_MODELS_FOLDER = MAIN_PATH+workspace_dir+"\AllP__v3\";
       if constants.MORE_TRAINING_DATA
           SAVED_MODELS_FOLDER = MAIN_PATH+workspace_dir+"\MODELS_biggertrain\AllP__v3\";
       end
    end
   
    filename = strcat(secretdataset_prefix,"finalize-stats_",name,add,".mat");
end

%filename = strcat(secretdataset_prefix,"statsClassific_",name,add,".mat");
filename = strcat(secretdataset_prefix,"statsClassific_",name,".mat");

load(strcat(SAVED_MODELS_FOLDER, filename),"stats");

statsToEvaluate = ["f1_p","f1_c","f1_b","f1_p_nb","f1_c_nb","f1_b_nb",...
    "sensitivity_p","sensitivity_c","sensitivity_b","sensitivity_p_nb","sensitivity_c_nb","sensitivity_b_nb",...    
    "specificity_p","specificity_c","specificity_b","specificity_p_nb","specificity_c_nb","specificity_b_nb",...
    "precision_p","precision_c","precision_b","precision_p_nb","precision_c_nb","precision_b_nb",...
    "accuracy_p","accuracy_c","accuracy_b","accuracy_p_nb","accuracy_c_nb","accuracy_b_nb",...
    ];

if constants.SUMSTATS
    statsToEvaluate = ["tn_p_nb","fn_p_nb","fp_p_nb","tp_p_nb",...
        "tn_c_nb","fn_c_nb","fp_c_nb","tp_c_nb",...
        "tn_b_nb","fn_b_nb","fp_b_nb","tp_b_nb"];
end

types = ["Brain", "_b_nb"; "Penumbra","_p_nb";"Core","_c_nb"]; %"Together","_pc_nb"];

if constants.THRESHOLDING || ~strcmp(constants.overlapName,"")
    types = ["Penumbra","_p_nb";"Core","_c_nb"];
end

%% for LATEX
f1_exc = "";
sens_exc = "";
spec_exc = "";
prec_exc = "";
acc_exc = "";

if constants.THRESHOLDING
    
    n_researches = 7;
    index = 1; 
    for indexrow = 1:n_researches
        howmany = height(stats)/n_researches;
        stat = stats(((indexrow-1)*howmany)+1:howmany*indexrow,:);
        fprintf(stat.name{1});
        fprintf("\n");
        
        f1_exc = "";
        sens_exc = "";
        spec_exc = "";
        prec_exc = "";
        acc_exc = "";
        tn_acc = 0;
        fn_acc = 0;
        fp_acc = 0;
        tp_acc = 0;

        for t=types'
            fprintf("& %s ",t(1));
            tn = 0;
            fn = 0;
            fp = 0;
            tp = 0;
            
            for s=statsToEvaluate
                
                if contains(s,t(2))
                    if constants.SUMSTATS
                        if contains(s,"tn")
                            tn = sum(stat.(s));
                            tn_acc = tn_acc + sum(stat.(s));
                        elseif contains(s,"fn")
                            fn = sum(stat.(s));
                            fn_acc = fn_acc + sum(stat.(s));
                        elseif contains(s,"fp")
                            fp = sum(stat.(s));
                            fp_acc = fp_acc + sum(stat.(s));
                        elseif contains(s,"tp")
                            tp = sum(stat.(s));
                            tp_acc = tp_acc + sum(stat.(s));
                        end
                    else
                        fprintf("& %3.3f ",mean(stat.(s)));
                    end
                end
            end
            
            if constants.SUMSTATS
                prec = tp/(tp+fp);
                rec = tp/(tp+fn);
                f1 = 2*((prec*rec)/(prec+rec));

                if isnan(prec)
                    prec = 0;
                end
                if isnan(rec)
                    rec = 0;
                end
                if isnan(f1)
                    f1 = 0;
                end

                f1_exc = f1_exc + string(round(f1,3)) + " \t";
                sens_exc = sens_exc + string(round(rec,3)) + " \t";
                prec_exc = prec_exc + string(round(prec,3)) + " \t";
            end
            fprintf("\n");
        end
        acc = (tp_acc+tn_acc)/(tp_acc+tn_acc+fp_acc+fn_acc);
        if isnan(acc)
            acc = 0;
        end
        acc_exc = acc_exc + string(round(acc,3)) + " \t";
        fprintf(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n");
        
        tn_acc_1 = 0;
        fn_acc_1 = 0;
        fp_acc_1 = 0;
        tp_acc_1 = 0;
        tn_acc_2 = 0;
        fn_acc_2 = 0;
        fp_acc_2 = 0;
        tp_acc_2 = 0;
        
        for t=types'
            % Check severity only for the research saved in name!
            if contains(stat.name{1}, name)
                index = split(stat.name,name);
                index = index(:,2);
                severities = extractBetween(index', 3,4);
                for severity = unique(severities)
                    if ~strcmp(severity,"00")
                        indexSeverity = contains(severities, severity);
                        if strcmp(severity,"01")
                            zeroSeverity = contains(severities, "00");
                            indexSeverity = indexSeverity | zeroSeverity;
                        end
                        f1_exc = "";
                        sens_exc = "";
                        prec_exc = "";
                        acc_exc = "";
                        fprintf("SEVERITY: %s \t %s \n",severity, t(1));
                        
                        tn = 0;
                        fn = 0;
                        fp = 0;
                        tp = 0;
                        
                        for s=statsToEvaluate
                            if contains(s,t(2))
                                if constants.SUMSTATS
                                    if contains(s,"tn")
                                        tn = sum(stat.(s)(indexSeverity));
                                        if strcmp(severity,"02")
                                            tn_acc_2 = tn_acc_2 + sum(stat.(s)(indexSeverity));
                                        elseif strcmp(severity,"01")
                                            tn_acc_1 = tn_acc_1 + sum(stat.(s)(indexSeverity));
                                        end
                                    elseif contains(s,"fn")
                                        fn = sum(stat.(s)(indexSeverity));
                                        if strcmp(severity,"02")
                                            fn_acc_2 = fn_acc_2 + sum(stat.(s)(indexSeverity));
                                        elseif strcmp(severity,"01")
                                            fn_acc_1 = fn_acc_1 + sum(stat.(s)(indexSeverity));
                                        end
                                    elseif contains(s,"fp")
                                        fp = sum(stat.(s)(indexSeverity));
                                        if strcmp(severity,"02")
                                            fp_acc_2 = fp_acc_2 + sum(stat.(s)(indexSeverity));
                                        elseif strcmp(severity,"01")
                                            fp_acc_1 = fp_acc_1 + sum(stat.(s)(indexSeverity));
                                        end
                                    elseif contains(s,"tp")
                                        tp = sum(stat.(s)(indexSeverity));
                                        if strcmp(severity,"02")
                                            tp_acc_2 = tp_acc_2 + sum(stat.(s)(indexSeverity));
                                        elseif strcmp(severity,"01")
                                            tp_acc_1 = tp_acc_1 + sum(stat.(s)(indexSeverity));
                                        end
                                    end
                                else
                                    fprintf("& %3.3f ",mean(stats.(s)(indexSeverity)));
                                end
                            end
                        end
                        
                        if constants.SUMSTATS
                            prec = tp/(tp+fp);
                            rec = tp/(tp+fn);
                            acc = (tp+tn)/(tp+tn+fp+fn);
                            f1 = 2*((prec*rec)/(prec+rec));

                            if isnan(prec)
                                prec = 0;
                            end
                            if isnan(rec)
                                rec = 0;
                            end
                            if isnan(acc)
                                acc = 0;
                            end
                            if isnan(f1)
                                f1 = 0;
                            end

                            f1_exc = f1_exc + string(round(f1,3)) + " \t";
                            sens_exc = sens_exc + string(round(rec,3)) + " \t";
                            prec_exc = prec_exc + string(round(prec,3)) + " \t";
                            acc_exc = acc_exc + string(round(acc,3)) + " \t";
                        end
                        
                        fprintf(string(round(f1,3))+ " & " + string(round(rec,3)) + " & " + string(round(prec,3)) + " & " + string(round(acc,3))); 
                        
                        fprintf("\n");
                        
                        fprintf(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n");
                    end
                end
            end
        end
        
        if constants.SUMSTATS && contains(stat.name{1}, name)
            acc_1 = (tp_acc_1+tn_acc_1)/(tp_acc_1+tn_acc_1+fp_acc_1+fn_acc_1);
            acc_2 = (tp_acc_2+tn_acc_2)/(tp_acc_2+tn_acc_2+fp_acc_2+fn_acc_2);
            fprintf(" --- " + string(round(acc_1,3))+ " & " + string(round(acc_2,3)) + "\n")
        end
        
    end
    
else
    
    fprintf("%s \n",filename);
    f1_exc = "";
    sens_exc = "";
    spec_exc = "";
    prec_exc = "";
    acc_exc = "";
    f1_exc_notab = "";
    sens_exc_notab = "";
    spec_exc_notab = "";
    prec_exc_notab = "";
    acc_exc_notab = "";


    for t=types'
        tn = 0;
        fn = 0;
        fp = 0;
        tp = 0;

        if ~strcmp(t(1), "Core")
            fprintf("& %s \t",t(1));
        else
            fprintf("& %s \t\t",t(1));
        end
        for s=statsToEvaluate
            if contains(s,t(2))
                if constants.SUMSTATS
                    if contains(s,"tn")
                        tn = sum(stats.(s));
                    elseif contains(s,"fn")
                        fn = sum(stats.(s));
                    elseif contains(s,"fp")
                        fp = sum(stats.(s));
                    elseif contains(s,"tp")
                        tp = sum(stats.(s));
                    end
                else
                    fprintf("& %3.3f ",mean(stats.(s)));
                    if contains(s,"f1_")
                        f1_exc = f1_exc + string(round(mean(stats.(s)),3)) + " \t";
                    elseif contains(s,"sensitivity_")
                        sens_exc = sens_exc + string(round(mean(stats.(s)),3)) + " \t";
                    elseif contains(s,"precision_")
                        prec_exc = prec_exc + string(round(mean(stats.(s)),3)) + " \t";
                    elseif contains(s,"accuracy_")
                        acc_exc = acc_exc + string(round(mean(stats.(s)),3)) + " \t";
                    end
                end
            end
        end
        if constants.SUMSTATS
            prec = tp/(tp+fp);
            rec = tp/(tp+fn);
            spec = tn/(tn+fp);
            acc = (tp+tn)/(tp+tn+fp+fn);
            f1 = 2*((prec*rec)/(prec+rec));

            if isnan(prec)
                prec = 0;
            end
            if isnan(rec)
                rec = 0;
            end
            if isnan(spec)
                spec = 0;
            end
            if isnan(acc)
                acc = 0;
            end
            if isnan(f1)
                f1 = 0;
            end

            f1_exc = f1_exc + string(round(f1,3)) + " \t";
            sens_exc = sens_exc + string(round(rec,3)) + " \t";
            prec_exc = prec_exc + string(round(prec,3)) + " \t";
            acc_exc = acc_exc + string(round(acc,3)) + " \t";
            f1_exc_notab = f1_exc_notab + string(round(f1,3)) + ", ";
            sens_exc_notab = sens_exc_notab + string(round(rec,3)) + ", ";
            prec_exc_notab = prec_exc_notab + string(round(prec,3)) + ", ";
            acc_exc_notab = acc_exc_notab + string(round(acc,3)) + ", ";
        end
        fprintf("\n");
    end

    fprintf(replace(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n", ".", ","));
    fprintf(f1_exc_notab+sens_exc_notab+spec_exc_notab+prec_exc_notab+acc_exc_notab+"\n");
    %% divided by severity (LVO, SVO, WVO)
    if ~strcmp(constants.overlapName,"")
        name = "tree";
    end
    index = split(stats.name,name);
    index = index(:,2);
    severities = extractBetween(index', 3,4);
    tn_acc_1 = 0;
    fn_acc_1 = 0;
    fp_acc_1 = 0;
    tp_acc_1 = 0;
    tn_acc_2 = 0;
    fn_acc_2 = 0;
    fp_acc_2 = 0;
    tp_acc_2 = 0;

    
    for severity = unique(severities)
        f1_exc = "";
        sens_exc = "";
        prec_exc = "";
        acc_exc = "";

        if ~strcmp(severity,"00")
            indexSeverity = contains(severities, severity);
            if strcmp(severity,"01")
                zeroSeverity = contains(severities, "00");
                indexSeverity = indexSeverity | zeroSeverity;
            end
            fprintf("\n SEVERITY: %s \n",severity);
            for t=types'
                tn = 0;
                fn = 0;
                fp = 0;
                tp = 0;

                if ~strcmp(t(1), "Core")
                    fprintf("& %s \t",t(1));
                else
                    fprintf("& %s \t\t",t(1));
                end
                for s=statsToEvaluate
                    if contains(s,t(2))
                        if constants.SUMSTATS
                            if contains(s,"tn")
                                tn = sum(stats.(s)(indexSeverity));
                                if strcmp(severity,"02")
                                    tn_acc_2 = tn_acc_2 + sum(stats.(s)(indexSeverity));
                                elseif strcmp(severity,"01")
                                    tn_acc_1 = tn_acc_1 + sum(stats.(s)(indexSeverity));
                                end
                            elseif contains(s,"fn")
                                fn = sum(stats.(s)(indexSeverity));
                                if strcmp(severity,"02")
                                    fn_acc_2 = fn_acc_2 + sum(stats.(s)(indexSeverity));
                                elseif strcmp(severity,"01")
                                    fn_acc_1 = fn_acc_1 + sum(stats.(s)(indexSeverity));
                                end
                            elseif contains(s,"fp")
                                fp = sum(stats.(s)(indexSeverity));
                                if strcmp(severity,"02")
                                    fp_acc_2 = fp_acc_2 + sum(stats.(s)(indexSeverity));
                                elseif strcmp(severity,"01")
                                    fp_acc_1 = fp_acc_1 + sum(stats.(s)(indexSeverity));
                                end
                            elseif contains(s,"tp")
                                tp = sum(stats.(s)(indexSeverity));
                                if strcmp(severity,"02")
                                    tp_acc_2 = tp_acc_2 + sum(stats.(s)(indexSeverity));
                                elseif strcmp(severity,"01")
                                    tp_acc_1 = tp_acc_1 + sum(stats.(s)(indexSeverity));
                                end
                            end
                        else
                            fprintf("& %3.3f ",mean(stats.(s)(indexSeverity)));
                            if contains(s,"f1_")
                                f1_exc = f1_exc + string(round(mean(stats.(s)(indexSeverity)),3)) + " \t";
                            elseif contains(s,"sensitivity_")
                                sens_exc = sens_exc + string(round(mean(stats.(s)(indexSeverity)),3)) + " \t";
                            elseif contains(s,"precision_")
                                prec_exc = prec_exc + string(round(mean(stats.(s)(indexSeverity)),3)) + " \t";
                            elseif contains(s,"accuracy_")
                                acc_exc = acc_exc + string(round(mean(stats.(s)(indexSeverity)),3)) + " \t";
                            end
                        end
                    end
                end
                if constants.SUMSTATS
                    prec = tp/(tp+fp);
                    rec = tp/(tp+fn);
                    acc = (tp+tn)/(tp+tn+fp+fn);
                    f1 = 2*((prec*rec)/(prec+rec));

                    if isnan(prec)
                        prec = 0;
                    end
                    if isnan(rec)
                        rec = 0;
                    end
                    if isnan(acc)
                        acc = 0;
                    end
                    if isnan(f1)
                        f1 = 0;
                    end

                    f1_exc = f1_exc + string(round(f1,3)) + " \t";
                    sens_exc = sens_exc + string(round(rec,3)) + " \t";
                    prec_exc = prec_exc + string(round(prec,3)) + " \t";
                    acc_exc = acc_exc + string(round(acc,3)) + " \t";
                end
                fprintf("\n");
            end
        end

        fprintf(replace(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n", ".",","));
    end
    
    if constants.SUMSTATS && contains(stats.name{1}, name)
        acc_1 = (tp_acc_1+tn_acc_1)/(tp_acc_1+tn_acc_1+fp_acc_1+fn_acc_1);
        acc_2 = (tp_acc_2+tn_acc_2)/(tp_acc_2+tn_acc_2+fp_acc_2+fn_acc_2);
        fprintf(" --- " + string(round(acc_1,3))+ " & " + string(round(acc_2,3)) + "\n")
    end
end

    
    