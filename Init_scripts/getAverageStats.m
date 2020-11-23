%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the average stats for all the patients calculated
clear;
clc % clear command window
close all force;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VARIABLES
MAIN_PATH = "D:\Preprocessed-SUS2020_v2\";
SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\_v3\";

%SAVED_MODELS_FOLDER = "C:\Users\Luca\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\";

constants.SUFFIX_RES = 'randomForest'; % 'SVM' // 'tree' // 'randomForest' 
constants.STEPS = 1; % or 2 steps to divide penumbra and core prediction
constants.USESUPERPIXELS = 1; % set the variable == 2 for using ONLY the suprpixels features
constants.N_SUPERPIXELS = 450;
constants.SMOTE = 1;
constants.TEST_SECRETDATASET = 0;
constants.MORE_TRAINING_DATA = 1;
constants.overlapName = ""; %"LIVKATHINKA";
constants.SUMSTATS = 1;
constants.KEEPALLPENUMBRA = 1;

constants.THRESHOLDING = 0;
research_name = "Shaefer_2014";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix = "";
add = "_v3";

if constants.MORE_TRAINING_DATA
    SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\MODELS_biggertrain\_v3\";
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
        SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\KEEPONLYLARGEPENUMBRA\";
    end
    name = research_name;
    
    load(strcat(SAVED_MODELS_FOLDER, strcat("Wintermark_2006", "_stats")),"stats");
    calculateStats(stats,SAVED_MODELS_FOLDER,strcat(secretdataset_prefix,"finalize-stats_","Wintermark_2006",add,".mat"),0)
    
    
    filename = strcat(secretdataset_prefix,"finalize-stats_","Wintermark_2006",add,".mat");
else
    if constants.KEEPALLPENUMBRA
        SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\AllP__v3\";
       if constants.MORE_TRAINING_DATA
           SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\MODELS_biggertrain\AllP__v3\";
       end
    end
   
    filename = strcat(secretdataset_prefix,"finalize-stats_",name,add,".mat");
end

% filename = strcat(secretdataset_prefix,"statsClassific_",name,add,".mat");

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
                        elseif contains(s,"fn")
                            fn = sum(stat.(s));
                        elseif contains(s,"fp")
                            fp = sum(stat.(s));
                        elseif contains(s,"tp")
                            tp = sum(stat.(s));
                        end
                    else
                        fprintf("& %3.3f ",mean(stat.(s)));
                    end
                end
            end
            
            if constants.SUMSTATS
                prec = tp/(tp+fp);
                rec = tp/(tp+fn);
%                 spec = tn/(tn+fp);
                acc = (tp+tn)/(tp+tn+fp+fn);
                f1 = 2*((prec*rec)/(prec+rec));

                if isnan(prec)
                    prec = 0;
                end
                if isnan(rec)
                    rec = 0;
                end
%                 if isnan(spec)
%                     spec = 0;
%                 end
                if isnan(acc)
                    acc = 0;
                end
                if isnan(f1)
                    f1 = 0;
                end

                f1_exc = f1_exc + string(round(f1,3)) + " \t";
                sens_exc = sens_exc + string(round(rec,3)) + " \t";
%                 spec_exc = spec_exc + string(round(spec,3)) + " \t";
                prec_exc = prec_exc + string(round(prec,3)) + " \t";
                acc_exc = acc_exc + string(round(acc,3)) + " \t";
            end
            fprintf("\n");
        end
        fprintf(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n");
        
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
                        spec_exc = "";
                        prec_exc = "";
                        acc_exc = "";
                        fprintf("SEVERITY: %s \n\n",severity);
                        fprintf("& %s ",t(1));
                        
                        tn = 0;
                        fn = 0;
                        fp = 0;
                        tp = 0;
                        
                        for s=statsToEvaluate
                            if contains(s,t(2))
                                if constants.SUMSTATS
                                    if contains(s,"tn")
                                        tn = sum(stat.(s)(indexSeverity));
                                    elseif contains(s,"fn")
                                        fn = sum(stat.(s)(indexSeverity));
                                    elseif contains(s,"fp")
                                        fp = sum(stat.(s)(indexSeverity));
                                    elseif contains(s,"tp")
                                        tp = sum(stat.(s)(indexSeverity));
                                    end
                                else
                                    fprintf("& %3.3f ",mean(stats.(s)(indexSeverity)));
                                end
                            end
                        end
                        
                        if constants.SUMSTATS
                            prec = tp/(tp+fp);
                            rec = tp/(tp+fn);
%                             spec = tn/(tn+fp);
                            acc = (tp+tn)/(tp+tn+fp+fn);
                            f1 = 2*((prec*rec)/(prec+rec));

                            if isnan(prec)
                                prec = 0;
                            end
                            if isnan(rec)
                                rec = 0;
                            end
%                             if isnan(spec)
%                                 spec = 0;
%                             end
                            if isnan(acc)
                                acc = 0;
                            end
                            if isnan(f1)
                                f1 = 0;
                            end

                            f1_exc = f1_exc + string(round(f1,3)) + " \t";
                            sens_exc = sens_exc + string(round(rec,3)) + " \t";
%                             spec_exc = spec_exc + string(round(spec,3)) + " \t";
                            prec_exc = prec_exc + string(round(prec,3)) + " \t";
                            acc_exc = acc_exc + string(round(acc,3)) + " \t";
                        end
                        
                        fprintf(string(round(f1,3))+ " & " + string(round(rec,3)) + " & " + string(round(prec,3)) + " & " +  string(round(acc,3)) + " \n"); 
                        
                        fprintf("\n");
                        
                        fprintf(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n");
                    end
                end
            end
        end
    end
    
else
    
    fprintf("%s \n",filename);
    f1_exc = "";
    sens_exc = "";
    spec_exc = "";
    prec_exc = "";
    acc_exc = "";

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
                    %fprintf("(%3.2f) ", std(stats.(s)));
                    if contains(s,"f1_")
                        f1_exc = f1_exc + string(round(mean(stats.(s)),3)) + " \t";
                    elseif contains(s,"sensitivity_")
                        sens_exc = sens_exc + string(round(mean(stats.(s)),3)) + " \t";
%                     elseif contains(s,"specificity_")
%                         spec_exc = spec_exc + string(round(mean(stats.(s)),3)) + " \t";
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
%             spec_exc = spec_exc + string(round(spec,3)) + " \t";
            prec_exc = prec_exc + string(round(prec,3)) + " \t";
            acc_exc = acc_exc + string(round(acc,3)) + " \t";
        end
        fprintf("\n");
    end

    fprintf(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n");

    %% divided by severity (LVO, SVO, WVO)
    if ~strcmp(constants.overlapName,"")
        name = "tree";
    end
    index = split(stats.name,name);
    index = index(:,2);
    severities = extractBetween(index', 3,4);
    for severity = unique(severities)
        f1_exc = "";
        sens_exc = "";
        spec_exc = "";
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
                            elseif contains(s,"fn")
                                fn = sum(stats.(s)(indexSeverity));
                            elseif contains(s,"fp")
                                fp = sum(stats.(s)(indexSeverity));
                            elseif contains(s,"tp")
                                tp = sum(stats.(s)(indexSeverity));
                            end
                        else
                            fprintf("& %3.3f ",mean(stats.(s)(indexSeverity)));
                            if contains(s,"f1_")
                                f1_exc = f1_exc + string(round(mean(stats.(s)(indexSeverity)),3)) + " \t";
                            elseif contains(s,"sensitivity_")
                                sens_exc = sens_exc + string(round(mean(stats.(s)(indexSeverity)),3)) + " \t";
%                             elseif contains(s,"specificity_")
%                                 spec_exc = spec_exc + string(round(mean(stats.(s)(indexSeverity)),3)) + " \t";
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
%                     spec_exc = spec_exc + string(round(spec,3)) + " \t";
                    prec_exc = prec_exc + string(round(prec,3)) + " \t";
                    acc_exc = acc_exc + string(round(acc,3)) + " \t";
                end
                fprintf("\n");
            end
        end

        fprintf(f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+"\n");
    end
end

    
    