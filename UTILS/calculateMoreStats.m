function [stats] = calculateMoreStats(path_name,constants,GT_PATH)
%CALCULATEMORESTATS Summary of this function goes here
%   Detailed explanation goes here
stats = table();
if constants.TEST_SECRETDATASET
    save_stats_filename = path_name+"_TEST_stats.mat";
    if contains(GT_PATH, "_Comparison_KK")
        save_stats_filename = path_name+"_TEST_KK_stats.mat";
    elseif contains(GT_PATH, "_Comparison_LJ")
        save_stats_filename = path_name+"_TEST_LJ_stats.mat";
    end
else
    save_stats_filename = path_name+"_stats.mat";
end

penumbra_color = 170; 
core_color = 255; 
calculateTogether = 1;
x = 0.436645510000000; y = 0.436645510000000; z = 5; % measure in mm

VALIDATION_list = [];
TEST_list = ["CTP_02_007", "CTP_02_019", "CTP_01_073", "CTP_02_001", "CTP_01_071", "CTP_01_001", ...
    "CTP_03_003", "CTP_01_007", "CTP_01_068", "CTP_02_031", "CTP_01_037", "CTP_02_013", "CTP_01_025", ...
    "CTP_02_062", "CTP_03_014", "CTP_01_019", "CTP_01_066", "CTP_02_025", "CTP_01_031", "CTP_01_053", ...
    "CTP_01_013", "CTP_02_043", "CTP_01_059", "CTP_02_036", "CTP_01_061", "CTP_03_010", "CTP_01_049", ...
    "CTP_01_067", "CTP_01_074", "CTP_01_057", "CTP_02_050", "CTP_01_044", "CTP_02_055"];

if ~isfile(save_stats_filename)
for p = dir(path_name)'
    if ~strcmp(p.name, '.') && ~strcmp(p.name, '..') 
        % skip if there's no ground truth images for this patient
        if ~isfolder(strcat(GT_PATH,p.name,"/"))
            continue
        end
        if sum(contains(TEST_list,p.name))==0
            VALIDATION_list = [VALIDATION_list, p.name];
        end
        if ~constants.TEST_SECRETDATASET && isempty(VALIDATION_list)
            continue
        end
        if (constants.TEST_SECRETDATASET && sum(contains(TEST_list,p.name))==0) || (~constants.TEST_SECRETDATASET && sum(contains(VALIDATION_list,p.name))==0)
            continue
        end    
        disp(p.name);
        HD_penumbra = [];
        HD_core = [];
        CM_penumbra_noback_tot = double(reshape([0,0,0,0], 2,2));
        CM_core_noback_tot = double(reshape([0,0,0,0], 2,2));
        CM_brain_noback_tot = double(reshape([0,0,0,0], 2,2));
        
        slice_n = numel(dir(p.folder + "/" + p.name)')-5;
        gt_C_3Dstack = zeros(512,512,slice_n);
        img_C_3Dstack = zeros(512,512,slice_n);
        gt_P_3Dstack = zeros(512,512,slice_n);
        img_P_3Dstack = zeros(512,512,slice_n);
        gt_H_3Dstack = zeros(512,512,slice_n);
        img_H_3Dstack = zeros(512,512,slice_n);
                
        for subfold = dir(p.folder + "/" + p.name)'
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..') && ~subfold.isdir 
                img = imread(strcat(subfold.folder,"/",subfold.name));
                
                gt_imagename = strcat(GT_PATH,p.name,"/",subfold.name);
                if isfield(constants, "TIFF_SUFFIX_GT")
                    if constants.TIFF_SUFFIX_GT
                        gt_imagename = replace(gt_imagename, ".png", ".tiff");
                    end
                end
                gt = imread(gt_imagename);
                
                if isa(img, "uint16")
                    img = double(img./256);
                end
                if isa(gt, "uint16")
                    gt = double(gt./256);
                end
                if isa(gt, "uint8")
                    gt = double(gt);
                end
                
                if length(size(gt))>2
%                     disp("The previous size of gt was:");
%                     disp(size(gt));
                    gt = gt(:,:,1);
                end
                if length(size(img))>2
                    img = img(:,:,1);
                end
                                
                penumbraCoreMask = zeros(size(img));
                coreMask = zeros(size(img));
                penumbraCoreMask(img>core_color-(penumbra_color/4)) = core_color;
                penumbraCoreMask(img<penumbra_color+(penumbra_color/4) & img>90) = penumbra_color;
                penumbraCoreMask(img<90 & img>0) = penumbra_color/2; % brain color
                
                gt(gt>core_color-(penumbra_color/4)) = core_color;
                gt(gt<penumbra_color+(penumbra_color/4) & gt>90) = penumbra_color;
                gt(gt<90 & gt>0) = penumbra_color/2; % brain color
                
                % Calculate Hausdorff distance
                HD_penumbra = [HD_penumbra; HausdorffDist(gt==penumbra_color, penumbraCoreMask==penumbra_color) .* x];
                HD_core = [HD_core; HausdorffDist(gt==core_color, penumbraCoreMask==core_color) .* x];
                
                % Stack the masks
                img_index = str2double(replace(subfold.name, ".tiff","")); 
                if isfield(constants, "TIFF_SUFFIX")
                    if constants.TIFF_SUFFIX
                        img_index =  str2double(replace(subfold.name, ".png","")); 
                    end
                end
                gt_C_3Dstack(:,:,img_index) = gt==core_color;
                gt_P_3Dstack(:,:,img_index) = gt==penumbra_color;
                gt_H_3Dstack(:,:,img_index) = gt>=penumbra_color;
                img_C_3Dstack(:,:,img_index) = penumbraCoreMask==core_color;
                img_P_3Dstack(:,:,img_index) = penumbraCoreMask==penumbra_color;
                img_H_3Dstack(:,:,img_index) = penumbraCoreMask>=penumbra_color;
                
                [~,~,~,CM_penumbra_noback,CM_core_noback,CM_brain_noback] = getConfusionMatrix(gt,penumbraCoreMask,coreMask,penumbra_color,core_color,calculateTogether,1);
                CM_penumbra_noback_tot = CM_penumbra_noback_tot+CM_penumbra_noback;
                CM_core_noback_tot = CM_core_noback_tot+CM_core_noback;
                CM_brain_noback_tot = CM_brain_noback_tot+CM_brain_noback;
            end
        end
        
        tn_h = CM_brain_noback_tot(1,1);
        fn_h = CM_brain_noback_tot(2,1);
        fp_h = CM_brain_noback_tot(1,2);
        tp_h = CM_brain_noback_tot(2,2);


        volume_gt_core = nnz(gt_C_3Dstack)*x*y*z;
        volume_gt_penumbra = nnz(gt_P_3Dstack)*x*y*z;
        volume_gt_hypo = nnz(gt_H_3Dstack)*x*y*z;
        volume_img_core = nnz(img_C_3Dstack)*x*y*z;
        volume_img_penumbra = nnz(img_P_3Dstack)*x*y*z;
        volume_img_hypo = nnz(img_H_3Dstack)*x*y*z;
        dice_p = dice(img_P_3Dstack,gt_P_3Dstack);
        dice_c = dice(img_C_3Dstack,gt_C_3Dstack);
        dice_h = dice(img_H_3Dstack,gt_H_3Dstack);
        jacc_p = jaccard(img_P_3Dstack,gt_P_3Dstack);
        jacc_c = jaccard(img_C_3Dstack,gt_C_3Dstack);

        mcc_h = (tn_h*tp_h - fp_h*fn_h) / sqrt((tn_h+fn_h)*(fp_h+tp_h)*(tn_h+fp_h)*(fn_h+tp_h));

        if isempty(dice_p)
            dice_p = 0;
        end
        if isempty(dice_c)
            dice_c = 0;
        end
        if isempty(dice_h)
            dice_h = 0;
        end
        if isempty(jacc_p)
            jacc_p = 0;
        end
        if isempty(jacc_c)
            jacc_c = 0;
        end
        if isempty(mcc_h) || isnan(mcc_h)
            mcc_h = 0;
        end
        
        row = {
            p.name, ...
            mean(HD_penumbra), ...
            mean(HD_core), ...
            dice_p,...
            dice_c,...
            dice_h,...
            jacc_p,...
            jacc_c,...
            mcc_h,...
            volume_gt_penumbra, ...
            volume_img_penumbra, ...
            volume_gt_core, ...
            volume_img_core, ...
            volume_gt_hypo, ...
            volume_img_hypo, ...
            CM_penumbra_noback_tot(1,1), ... "tn_p"
            CM_penumbra_noback_tot(2,1), ... "fn_p"
            CM_penumbra_noback_tot(1,2), ... "fp_p"
            CM_penumbra_noback_tot(2,2), ... "tp_p"
            CM_core_noback_tot(1,1), ... "tn_c"
            CM_core_noback_tot(2,1), ... "fn_c"
            CM_core_noback_tot(1,2), ... "fp_c"
            CM_core_noback_tot(2,2), ... "tp_c"
            CM_brain_noback_tot(1,1), ... "tn_h"
            CM_brain_noback_tot(2,1), ... "fn_h"
            CM_brain_noback_tot(1,2), ... "fp_h"
            CM_brain_noback_tot(2,2) ... "tp_h"
        };
    
        stats = [stats; row];
        stats.Properties.VariableNames = ["patient", "HD_penumbra", "HD_core", "dice_penumbra", "dice_core","dice_hypo",...
            "jaccard_penumbra", "jaccard_core", "MCC_h", "V_gt_p", "V_img_p", "V_gt_c", "V_img_c", "V_gt_h", "V_img_h", ...
            "tn_p", "fn_p", "fp_p", "tp_p", "tn_c", "fn_c", "fp_c", "tp_c", "tn_h", "fn_h", "fp_h", "tp_h"];
        
    end
end

disp(save_stats_filename);
save(save_stats_filename, 'stats', '-v7.3');
else 
    load(save_stats_filename, 'stats');
end
end

