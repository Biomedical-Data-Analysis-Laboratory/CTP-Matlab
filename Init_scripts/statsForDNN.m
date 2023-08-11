clear;
clc % clear command window
close all force;

ROOT = "C:\Users\2921329\Desktop\Matlab_tmp_folder\mJ-Net\";

if isunix && ~ismac
    ROOT = "/home/student/lucat/PhD_Project/Stroke_segmentation/SAVE/EXP100.887/IMAGES/";
end

GT_folder = "D:\Preprocessed-SUS2020_v2\INTER-OBSERVER VARIABILITY\FINALIZE_PM_Comparison";
EXP_NAME = "EXP026__VNet_Milletari_DA_SGD_VAL20_SOFTMAX_128_512x512";
EXP_FOLD = ROOT+EXP_NAME;
TEST = 0;
Neuroradiologist = "LJ"; % "LJ" "" 
VAL_LIST = 11; % 0,1,2,11, 99
ANYSTRIPES = 0;

if VAL_LIST==0 % 10%
    VALIDATION_list = ["02_002", "01_020", "02_057", "01_011", "02_032", "01_015", ...
        "01_064", "01_038", "01_014", "01_023", "01_052", "02_005", "03_002", "02_042", "01_032"];
elseif VAL_LIST==1  % 20% 
    VALIDATION_list = ["01_016", "01_045", "01_003", "01_009", "01_063", "01_027", "01_015", "00_007", ...
        "01_029", "01_075", "01_032", "01_072", "01_046", "01_062", "01_014", "01_058", "02_056", ...
        "02_063", "02_059", "02_008", "02_024", "02_060", "02_029", "02_039", "02_027", "02_005", ...
        "02_038", "03_005", "03_008", "03_012"];
elseif VAL_LIST==2 % 20% (2)
    VALIDATION_list = ["01_036", "01_038", "01_063", "01_056", "01_050", "01_041", "01_040", ...
        "01_010", "01_028", "01_027", "01_055", "01_033", "01_002", "00_009", "01_060", "01_008", ...
        "02_017", "02_030", "02_045", "02_028", "02_021", "02_048", "02_006", "02_008", "02_010", ...
        "02_057", "02_018", "03_015", "03_013", "03_011"];
elseif VAL_LIST==11
    VALIDATION_list = ["21_063", "01_004", "21_016", "21_021", "01_024", "21_029", "21_009", ...
        "21_051", "01_076", "21_018", "01_028", "21_022", "21_050", "21_027", "01_006", ...
        "21_004", "21_002", "21_026", "01_038", "01_033", "21_070", "21_023", "21_028", ...
        "20_007", "01_040", "01_014", "01_034", "21_011", "21_075", "01_029", "01_063", ...
        "21_052", "02_005", "22_015", "02_041", "02_038", "22_040", "02_003", "02_020", ...
        "22_016", "22_060", "22_028", "02_018", "22_045", "22_003", "22_061", "22_042", ...
        "22_006", "02_040", "02_022", "22_024", "02_026", "02_010", "22_004", "03_005",  ...
        "03_002", "23_004", "03_004", "23_005", "23_013"];
elseif VAL_LIST==99
    % we are in the cross-validation
    VALIDATION_list = [];
end
TEST_list = ["02_007", "02_019", "01_073", "02_001", "01_071", "01_001", ...
    "03_003", "01_007", "01_068", "02_031", "01_037", "02_013", "01_025", ...
    "02_062", "03_014", "01_019", "01_066", "02_025", "01_031", "01_053", ...
    "01_013", "02_043", "01_059", "02_036", "01_061", "03_010", "01_049", ...
    "01_067", "01_074", "01_057", "02_050", "01_044", "02_055"];
penumbra_color = 170;
core_color = 255;

stats = table();
list_files = dir(EXP_FOLD)';
count = 0;
ground_truth_folder = "/GT/";

n_patients = numel(VALIDATION_list);
if VAL_LIST==99
    n_patients = numel(list_files) - numel(TEST_list);
end
if TEST
	n_patients = numel(TEST_list);
    ground_truth_folder = "";
end

index_sev = zeros(1,n_patients);
rest_count = zeros(1,n_patients);
brain_count = zeros(1,n_patients);
penumbra_count = zeros(1,n_patients);
core_count = zeros(1,n_patients);

severities = [1,2,3];

for p = list_files 
    if ~strcmp(p.name, '.') && ~strcmp(p.name, '..') && ~strcmp(p.name,"PLOTS") && ~strcmp(p.name,"TEXT")
        % jump to the next iteration if one of the following condition is
        % not fulfilled
        name_to_check = convertCharsToStrings(replace(p.name, "CTP_", ""));
        
        if VAL_LIST==99 && sum(contains(TEST_list,name_to_check))==0
            VALIDATION_list = [VALIDATION_list, name_to_check];
        end
        if ~TEST && isempty(VALIDATION_list)
            continue
        end
                
        if (TEST && sum(contains(TEST_list,name_to_check))==0) || (~TEST && sum(contains(VALIDATION_list,name_to_check))==0)
            continue
        end
        
        count = count + 1;
        CM_TOT = double(reshape([0,0,0,0,0,0,0,0,0], 3,3));
        
        for img_name = dir(strcat(p.folder,"/",p.name))'
            if ~strcmp(img_name.name, '.') && ~strcmp(img_name.name, '..') && ~strcmp(img_name.name, '.DS_Store') && ~img_name.isdir
                img = imread(strcat(img_name.folder,"/",img_name.name));
                
                if TEST && ~strcmp(Neuroradiologist,"")
                    gt_img = imread(strcat(GT_folder,"_",Neuroradiologist,"/",p.name,"/",replace(img_name.name,".png",".tiff")));
                else 
                    gt_img = imread(strcat(img_name.folder,"/GT/",replace(img_name.name,".png",".tiff")));
                end
                
                if isa(gt_img,"uint16")
                    gt_img = uint8(gt_img./256);
                end
                img(img>core_color-(penumbra_color/4)) = core_color;
                img(img<penumbra_color+(penumbra_color/4) & img>90) = penumbra_color;
                img(img<=90 & img>0) = 0; % the rest
                
                if ANYSTRIPES
                    for x = 1:size(img,1)
                        for y = 1:size(img,2)
                            if img(x,y)==core_color && img(x,y+1)~=core_color && img(x,y+2)==core_color
                                img(x,y+1) = core_color;
                            end
                            
                            if img(x,y)==core_color && img(x+1,y)~=core_color && img(x+2,y)==core_color
                                img(x+1,y) = core_color;
                            end
                        end
                    end
                end
                
                gt_img(gt_img>core_color-(penumbra_color/4)) = core_color;
                gt_img(gt_img<penumbra_color+(penumbra_color/4) & gt_img>90) = penumbra_color;
                
                brain_count(count) = brain_count(count) + sum(gt_img==85,"all");
                gt_img(gt_img<=90 & gt_img>0) = 0; % the rest 
                
                img_r = reshape(img, 1, []);
                gt_img_r = reshape(gt_img, 1, []);
                CM = confusionmat(gt_img_r, img_r,"ORDER",[0,penumbra_color,core_color]);
                CM_TOT = CM_TOT + CM;
                
                rest_count(count) = rest_count(count) + sum(CM(1,:));
                penumbra_count(count) = penumbra_count(count) + sum(CM(2,:));
                core_count(count) = core_count(count) + sum(CM(3,:));
            end
        end
        
        if contains(p.name,"_01_") || contains(p.name,"_00_")
            index_sev(count) = 1;
        elseif contains(p.name,"_02_")
            index_sev(count) = 2;
        elseif contains(p.name,"_03_")
            index_sev(count) = 3;
        end
        
        idx_penumbra = 2;
        CM_penumbra_noback = double(reshape([0,0,0,0], 2,2));
        tp = CM_TOT(idx_penumbra,idx_penumbra);
        fp = sum(CM_TOT(:,idx_penumbra))-tp;
        fn = sum(CM_TOT(idx_penumbra,:))-tp;
        tn = sum(CM_TOT,"all")-tp-fp-fn;
        CM_penumbra_noback = [tn,fp;fn,tp];
        
        idx_core = 3;
        CM_core_noback = double(reshape([0,0,0,0], 2,2));
        tp = CM_TOT(idx_core,idx_core);
        fp = sum(CM_TOT(:,idx_core))-tp;
        fn = sum(CM_TOT(idx_core,:))-tp;
        tn = sum(CM_TOT,"all")-tp-fp-fn;
        CM_core_noback = [tn,fp;fn,tp];
        
        rowToAdd = {p.name, ... 
            CM_penumbra_noback(1,1), ... "tn_p"
            CM_penumbra_noback(2,1), ... "fn_p"
            CM_penumbra_noback(1,2), ... "fp_p"
            CM_penumbra_noback(2,2), ... "tp_p"
            CM_core_noback(1,1), ... "tn_c"
            CM_core_noback(2,1), ... "fn_c"
            CM_core_noback(1,2), ... "fp_c"
            CM_core_noback(2,2)};
        stats = [stats; rowToAdd];
    end
end

if ~isempty(stats)
    stats.Properties.VariableNames = {'name' ...
        'tn_p_nb' 'fn_p_nb' 'fp_p_nb' 'tp_p_nb' ...
        'tn_c_nb' 'fn_c_nb' 'fp_c_nb' 'tp_c_nb'};

    for s = severities
        disp(s);

        tn_p_nb = sum(stats(index_sev==s,:).tn_p_nb);
        fn_p_nb = sum(stats(index_sev==s,:).fn_p_nb);
        fp_p_nb = sum(stats(index_sev==s,:).fp_p_nb);
        tp_p_nb = sum(stats(index_sev==s,:).tp_p_nb);
        tn_c_nb = sum(stats(index_sev==s,:).tn_c_nb);
        fn_c_nb = sum(stats(index_sev==s,:).fn_c_nb);
        fp_c_nb = sum(stats(index_sev==s,:).fp_c_nb);
        tp_c_nb = sum(stats(index_sev==s,:).tp_c_nb);

        accuracy_nb = (tn_p_nb + tp_p_nb + tn_c_nb + tp_c_nb)./(tn_p_nb + fn_p_nb + fp_p_nb + tp_p_nb + tn_c_nb + fn_c_nb + fp_c_nb + tp_c_nb +1e-07);

        precision_p_nb = (tp_p_nb)./(fp_p_nb + tp_p_nb+1e-07);
        precision_c_nb = (tp_c_nb)./(fp_c_nb + tp_c_nb+1e-07);
        specificity_p_nb = (tn_p_nb)./(fp_p_nb + tn_p_nb+1e-07);
        specificity_c_nb = (tn_c_nb)./(fp_c_nb + tn_c_nb+1e-07);
        sensitivity_p_nb = (tp_p_nb)./(fn_p_nb + tp_p_nb+1e-07);
        sensitivity_c_nb = (tp_c_nb)./(fn_c_nb + tp_c_nb+1e-07);
        f1_p_nb = (2.*(precision_p_nb .* sensitivity_p_nb))./(precision_p_nb + sensitivity_p_nb+1e-07);
        f1_c_nb = (2.*(precision_c_nb .* sensitivity_c_nb))./(precision_c_nb + sensitivity_c_nb+1e-07);

    %     fprintf("F1: " + string(round(f1_p_nb,3)) + " - " + string(round(f1_c_nb,3)) + "\n");
    %     fprintf("Sens: " + string(round(sensitivity_p_nb,3)) + " - " + string(round(sensitivity_c_nb,3)) + "\n");
    %     fprintf("Prec: " + string(round(precision_p_nb,3)) + " - " + string(round(precision_c_nb,3)) + "\n");
        fprintf(string(round(f1_p_nb,3)) + "\t" + string(round(f1_c_nb,3)) + "\t" ...
            + string(round(sensitivity_p_nb,3)) + "\t" + string(round(sensitivity_c_nb,3)) + "\t" ...
            + string(round(precision_p_nb,3)) + "\t" + string(round(precision_c_nb,3)) + "\t" + string(round(accuracy_nb,3)) + "\n");

        if s==1
            f1_p_1 = string(round(f1_p_nb,3));
            f1_c_1 = string(round(f1_c_nb,3));
            spe_p_1 = string(round(sensitivity_p_nb,3));
            spe_c_1 = string(round(sensitivity_c_nb,3));
            pre_p_1 = string(round(precision_p_nb,3));
            pre_c_1 = string(round(precision_c_nb,3));
            acc_p_1 = string(round(accuracy_nb,3));
        elseif s==2
            f1_p_2 = string(round(f1_p_nb,3));
            f1_c_2 = string(round(f1_c_nb,3));
            spe_p_2 = string(round(sensitivity_p_nb,3));
            spe_c_2 = string(round(sensitivity_c_nb,3));
            pre_p_2 = string(round(precision_p_nb,3));
            pre_c_2 = string(round(precision_c_nb,3));
            acc_p_2 = string(round(accuracy_nb,3));
        end
    end
    
    %% Calculate for AIS & WIS
    tn_p_nb = sum(stats(:,:).tn_p_nb);
    fn_p_nb = sum(stats(:,:).fn_p_nb);
    fp_p_nb = sum(stats(:,:).fp_p_nb);
    tp_p_nb = sum(stats(:,:).tp_p_nb);
    tn_c_nb = sum(stats(:,:).tn_c_nb);
    fn_c_nb = sum(stats(:,:).fn_c_nb);
    fp_c_nb = sum(stats(:,:).fp_c_nb);
    tp_c_nb = sum(stats(:,:).tp_c_nb);

    accuracy_nb = (tn_p_nb + tp_p_nb + tn_c_nb + tp_c_nb)./(tn_p_nb + fn_p_nb + fp_p_nb + tp_p_nb + tn_c_nb + fn_c_nb + fp_c_nb + tp_c_nb +1e-07);

    precision_p_nb = (tp_p_nb)./(fp_p_nb + tp_p_nb+1e-07);
    precision_c_nb = (tp_c_nb)./(fp_c_nb + tp_c_nb+1e-07);
    specificity_p_nb = (tn_p_nb)./(fp_p_nb + tn_p_nb+1e-07);
    specificity_c_nb = (tn_c_nb)./(fp_c_nb + tn_c_nb+1e-07);
    sensitivity_p_nb = (tp_p_nb)./(fn_p_nb + tp_p_nb+1e-07);
    sensitivity_c_nb = (tp_c_nb)./(fn_c_nb + tp_c_nb+1e-07);
    f1_p_nb = (2.*(precision_p_nb .* sensitivity_p_nb))./(precision_p_nb + sensitivity_p_nb+1e-07);
    f1_c_nb = (2.*(precision_c_nb .* sensitivity_c_nb))./(precision_c_nb + sensitivity_c_nb+1e-07);
    
    delim = "\t";
    if isunix && ~ismac
        delim = ";";
    end

    fprintf(replace(...
        f1_p_1 + delim + f1_c_1 + delim + ...
        f1_p_2 + delim + f1_c_2 + delim + ...
        spe_p_1 + delim + spe_c_1 + delim + ...
        spe_p_2 + delim + spe_c_2 + delim + ...
        pre_p_1 + delim + pre_c_1 + delim + ...
        pre_p_2 + delim + pre_c_2 + delim + ...
        acc_p_1 + delim + acc_p_2 + "\n",".",","));
    fprintf(f1_p_1 + delim + f1_c_1 + delim + ...
        f1_p_2 + delim + f1_c_2 + delim + ...
        spe_p_1 + delim + spe_c_1 + delim + ...
        spe_p_2 + delim + spe_c_2 + delim + ...
        pre_p_1 + delim + pre_c_1 + delim + ...
        pre_p_2 + delim + pre_c_2 + delim + ...
        acc_p_1 + delim + acc_p_2 + "\n");
    fprintf(replace(...
        f1_p_1 + " & " + f1_c_1 + " & " + ...
        f1_p_2 + " & " + f1_c_2 + " & " + ...
        spe_p_1 + " & " + spe_c_1 + " & " + ...
        spe_p_2 + " & " + spe_c_2 + " & " + ...
        pre_p_1 + " & " + pre_c_1 + " & " + ...
        pre_p_2 + " & " + pre_c_2 + "\n",".","."));
    
    fprintf(f1_p_1 + " & " + f1_c_1 + " & " + ...
        f1_p_2 + " & " + f1_c_2 + " & " + ...
        string(round(f1_p_nb,3)) + " & " + string(round(f1_c_nb,3)) + " & " + ...
        acc_p_1 + " & " + acc_p_2 + " & " + string(round(accuracy_nb,3)) + "\n");
    
else
    disp("stats is empty");
end
    
    
    
