%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Overlay GT with prediction
clear;
clc % clear command window
close all force;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VARIABLES
MAIN_PATH = "D:\Preprocessed-SUS2020_v2\FINALIZE_PMS\";

SAVE_PATH = "D:\Preprocessed-SUS2020_v2\OVERLAY_PMS\";
if ~isfolder(SAVE_PATH)
    mkdir(SAVE_PATH);
end

constants.SUFFIX_RES = 'randomForest'; % 'SVM' // 'tree' // 'randomForest' 
constants.STEPS = 1; % or 2 steps to divide penumbra and core prediction
constants.USESUPERPIXELS = 0; % set the variable == 2 for using ONLY the suprpixels features
constants.N_SUPERPIXELS = 10;
constants.SMOTE = 1;

GT_PATH = MAIN_PATH + "FINALIZE_PM_TIFF\";

prefix = "FINALIZE_PM_";

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

overlay_subfold = strcat(SAVE_PATH, name);
if ~isfolder(overlay_subfold)
    mkdir(overlay_subfold);
end

severity_1 = 15;
severity_2 = 15;
severity_3 = 3;

for p = dir(MAIN_PATH + name)'
    if ~strcmp(p.name, '.') && ~strcmp(p.name, '..')  
        if ~isempty(strfind(p.name, "_01_")) || ~isempty(strfind(p.name, "_00_"))
            if severity_1>0
                severity_1 = severity_1-1;
            else
                continue
            end
        elseif ~isempty(strfind(p.name, "_02_"))
            if severity_2>0
                severity_2 = severity_2-1;
            else 
                continue
            end
        elseif ~isempty(strfind(p.name, "_03_"))
            if severity_3>0
                severity_3 = severity_3-1;
            else
                continue
            end
        end
        
        new_save_patient_folder = strcat(overlay_subfold ,"/", p.name);
        if ~isfolder(new_save_patient_folder)
            mkdir(new_save_patient_folder);
        end
        
        for subfold = dir(p.folder + "/" + p.name)'
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')  
                img = imread(strcat(subfold.folder,"/",subfold.name));
                gt = imread(strcat(GT_PATH,p.name,"/",subfold.name));
                
                img = double(img./256);
                gt = double(gt./256);
                
                imshow(gt,[0,256])
                hold on
                contour(img==170,"-blue")
                contour(img==256,"-red")
                hold off
                
                saveas(figure(1), strcat(new_save_patient_folder,"/",subfold.name));
                
                
            end
        end
    end
end

close all


