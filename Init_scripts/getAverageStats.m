%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the average stats for all the patients calculated
clear;
clc % clear command window
close all force;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VARIABLES
MAIN_PATH = "D:\Preprocessed-SUS2020_v2\";
SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\";

%SAVED_MODELS_FOLDER = "C:\Users\Luca\OneDrive - Universitetet i Stavanger\Luca\PhD\MATLAB_CODE\";

constants.SUFFIX_RES = 'SVM'; % 'SVM' // 'tree' // 'randomForest' 
constants.STEPS = 2; % or 2 steps to divide penumbra and core prediction
constants.USESUPERPIXELS = 0; % set the variable == 2 for using ONLY the suprpixels features
constants.N_SUPERPIXELS = 10;
constants.SMOTE = 0;
constants.TEST_SECRETDATASET = 0;

constants.THRESHOLDING = 0;
research_name = "Wintermark_2006";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

prefix = "";
add = "";

secretdataset_prefix = "";
if constants.TEST_SECRETDATASET
    secretdataset_prefix = "TESTDATASET";
end

if constants.USESUPERPIXELS
    if constants.USESUPERPIXELS==1
        prefix = prefix+"superpixels"+int2str(constants.N_SUPERPIXELS)+"_";
    elseif constants.USESUPERPIXELS==2
        prefix = prefix+"ONLYsuperpixels"+int2str(constants.N_SUPERPIXELS)+"_";
    end
else
    prefix = prefix+"10_"; % default value if no superpixels involved
end

if constants.SMOTE
    prefix = prefix+"SMOTE_";
end

name = strcat(prefix,int2str(constants.STEPS),"steps_",constants.SUFFIX_RES);

if constants.THRESHOLDING
    name = research_name;
    load(strcat(SAVED_MODELS_FOLDER, strcat(name, "_stats")),"stats");
    calculateStats(stats,SAVED_MODELS_FOLDER,strcat(secretdataset_prefix,"statsClassific_",name,add,".mat"),0)
end

filename = strcat(secretdataset_prefix,"statsClassific_",name,add,".mat");

load(strcat(SAVED_MODELS_FOLDER, filename),"stats");

statsToEvaluate = ["f1_p","f1_c","f1_pc","f1_p_nb","f1_c_nb","f1_pc_nb",...
    "sensitivity_p","sensitivity_c","sensitivity_pc","sensitivity_p_nb","sensitivity_c_nb","sensitivity_pc_nb",...    
    "specificity_p","specificity_c","specificity_pc","specificity_p_nb","specificity_c_nb","specificity_pc_nb",...
    "precision_p","precision_c","precision_pc","precision_p_nb","precision_c_nb","precision_pc_nb",...
    "accuracy_p","accuracy_c","accuracy_pc","accuracy_p_nb","accuracy_c_nb","accuracy_pc_nb",...
    ];

types = ["Penumbra","_p_nb";"Core","_c_nb"]; %"Together","_pc_nb"];

%% for LATEX
if constants.THRESHOLDING
    for indexrow = 1:height(stats)
        stat = stats(indexrow,:);
        fprintf(stat.name{1});
        fprintf("\n");
        
        for t=types'
            fprintf("& %s ",t(1));
            for s=statsToEvaluate
                if contains(s,t(2))
                    fprintf("& %3.3f ",stat.(s));
                end
            end
            fprintf("\n");
        end
    end
    
else
    
for t=types'
    fprintf("& %s ",t(1));
    for s=statsToEvaluate
        if contains(s,t(2))
            fprintf("& %3.3f ",mean(stats.(s)));
        end
    end
    fprintf("\n");
end

fprintf("%s \n",filename);
% for s = statsToEvaluate
%     fprintf('%s: %3.3f. \n',s,mean(stats.(s))); 
% end


%% divided by severity (LVO, SVO, WVO)
for t=types'
    index = split(stats.name,name);
    index = index(:,2);
    severities = extractBetween(index', 3,4);
    for severity = unique(severities)
        if ~strcmp(severity,"00")
            indexSeverity = contains(severities, severity);
            if strcmp(severity,"01")
                zeroSeverity = contains(severities, "00");
                indexSeverity = indexSeverity | zeroSeverity;
            end
            fprintf("SEVERITY: %s \n\n",severity);
            fprintf("& %s ",t(1));
            for s=statsToEvaluate
                if contains(s,t(2))
                    fprintf("& %3.3f ",mean(stats.(s)(indexSeverity)));
                end
            end
            fprintf("\n");
        end
    end
end
end

    
    