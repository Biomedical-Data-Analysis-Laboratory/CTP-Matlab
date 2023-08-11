function extractStatsFromTable(stats,indices,constants,filename)
%EXTRACTSTATSFROMTABLE Summary of this function goes here
%   Detailed explanation goes here
dice_exc = "";
f1_exc = "";
sens_exc = "";
spec_exc = "";
prec_exc = "";
acc_exc = "";
mcc_exc = "";
dice_exc_notab = "";
f1_exc_notab = "";
sens_exc_notab = "";
spec_exc_notab = "";
prec_exc_notab = "";
acc_exc_notab = "";
mcc_exc_notab = "";
tn = 0;
fn = 0;
fp = 0;
tp = 0;

if constants.MULTICLASS
    types = ["Hypo", "_h"; "Penumbra","_p";"Core","_c"];
    statsToEvaluate = ["tn_p", "fn_p", "fp_p", "tp_p", "tn_c", "fn_c", "fp_c", "tp_c", "tn_h", "fn_h", "fp_h", "tp_h"];
    tn_both = 0;
    fn_both = 0;
    fp_both = 0;
    tp_both = 0;
else
    types = ["Core","_c"];
    statsToEvaluate = ["tn_c", "fn_c", "fp_c", "tp_c"];
end

for t=types'
    % calculate the totality of TP,TN,FP,FN
    for s=statsToEvaluate  
        if contains(s,t(2))
            if contains(s,"tn")
                tn = sum(stats.(s)(indices));
            elseif contains(s,"fn")
                fn = sum(stats.(s)(indices));
            elseif contains(s,"fp")
                fp = sum(stats.(s)(indices));
            elseif contains(s,"tp")
                tp = sum(stats.(s)(indices));
            end
        end
    end

    [prec,rec,acc,f1,dice,mcc] = getStatsFromCM(fn,fp,tn,tp);

    dice_exc = dice_exc + string(round(dice,3)) + " \t";
    f1_exc = f1_exc + string(round(f1,3)) + " \t";
    sens_exc = sens_exc + string(round(rec,3)) + " \t";
    prec_exc = prec_exc + string(round(prec,3)) + " \t";
    acc_exc = acc_exc + string(round(acc,3)) + " \t";
    mcc_exc = mcc_exc + string(round(mcc,3)) + " \t";
    dice_exc_notab = dice_exc_notab + string(round(dice,3)) + ", ";
    f1_exc_notab = f1_exc_notab + string(round(f1,3)) + ", ";
    sens_exc_notab = sens_exc_notab + string(round(rec,3)) + ", ";
    prec_exc_notab = prec_exc_notab + string(round(prec,3)) + ", ";
    acc_exc_notab = acc_exc_notab + string(round(acc,3)) + ", ";
    mcc_exc_notab = mcc_exc_notab + string(round(acc,3)) + ", ";
end

if constants.MULTICLASS
    mean_hd_p = string(round(mean(stats.("HD_penumbra")(indices)),3));
    std_hd_p = string(round(std(stats.("HD_penumbra")(indices)),3));
    mean_dice_p = string(round(mean(stats.("dice_penumbra")(indices)),3));
    std_dice_p = string(round(std(stats.("dice_penumbra")(indices)),3));
    mean_iou_p = string(round(mean(stats.("jaccard_penumbra")(indices)),3));
    std_iou_p = string(round(std(stats.("jaccard_penumbra")(indices)),3));
    
    up_h = abs(abs(stats.("V_img_h")(indices)) - abs(stats.("V_gt_h")(indices)));
    down_h = abs(stats.("V_img_h")(indices)) + abs(stats.("V_gt_h")(indices));
    vs_h = string(round(mean(1 - (up_h./(down_h+1))),4));

    up_p = abs(abs(stats.("V_img_p")(indices)) - abs(stats.("V_gt_p")(indices)));
    down_p = abs(stats.("V_img_p")(indices)) + abs(stats.("V_gt_p")(indices));
    vs_p = string(round(mean(1 - (up_p./(down_p+1))),4));

    abs_voldiff_p = string(round(sum(abs(stats.("V_gt_p")(indices)-stats.("V_img_p")(indices))./1000),4));
    abs_voldiff_h = string(round(sum(abs(stats.("V_gt_h")(indices)-stats.("V_img_h")(indices))./1000),4));
    mean_voldiff_p = string(round((mean(abs(stats.("V_gt_p")(indices)-stats.("V_img_p")(indices)))./1000),4));
    std_voldiff_p = string(round((std(abs(stats.("V_gt_p")(indices)-stats.("V_img_p")(indices)))./1000),4));
    mean_voldiff_h = string(round((mean(abs(stats.("V_gt_h")(indices)-stats.("V_img_h")(indices)))./1000),4));
    std_voldiff_h = string(round((std(abs(stats.("V_gt_h")(indices)-stats.("V_img_h")(indices)))./1000),4));
    mean_dice_h = string(round(mean(stats.("dice_hypo")(indices)),3));
    std_dice_h = string(round(std(stats.("dice_hypo")(indices)),3));
    mean_mcc_h = string(round(mean(stats.("MCC_h")(indices)),3));
    std_mcc_h = string(round(std(stats.("MCC_h")(indices)),3));
end
mean_hd_c = string(round(mean(stats.("HD_core")(indices)),3));
std_hd_c = string(round(std(stats.("HD_core")(indices)),3));
mean_dice_c = string(round(mean(stats.("dice_core")(indices)),3));
std_dice_c = string(round(std(stats.("dice_core")(indices)),3));
mean_iou_c = string(round(mean(stats.("jaccard_core")(indices)),3));
std_iou_c = string(round(std(stats.("jaccard_core")(indices)),3));

up_c = abs(abs(stats.("V_img_c")(indices)) - abs(stats.("V_gt_c")(indices)));
down_c = abs(stats.("V_img_c")(indices)) + abs(stats.("V_gt_c")(indices));
vs_c = string(round(mean(1 - (up_c./(down_c+1))),4));

abs_voldiff_c = string(round(sum(abs(stats.("V_gt_c")(indices)-stats.("V_img_c")(indices))./1000),4));
mean_voldiff_c = string(round((mean(abs(stats.("V_gt_c")(indices)-stats.("V_img_c")(indices)))./1000),4));
std_voldiff_c = string(round((std(abs(stats.("V_gt_c")(indices)-stats.("V_img_c")(indices)))./1000),4));

if constants.MULTICLASS
    to_add = mean_hd_p+" \t"+mean_hd_c+" \t"+abs_voldiff_p+" \t"+abs_voldiff_c+" \t"+mean_voldiff_p+" \t"+mean_voldiff_c+" \t"+mean_dice_p+" \t"+mean_dice_c +" \t";
    to_add_end = mean_iou_p+" \t"+mean_iou_c +" \t";
    to_add_notab = mean_hd_p+"+-"+std_hd_p+", "+mean_hd_c+"+-"+std_hd_c+", "+abs_voldiff_p+", "+abs_voldiff_c+", "...
        +mean_voldiff_p+"+-"+std_voldiff_p+", "+mean_voldiff_c+"+-"+std_voldiff_c+", "+mean_dice_p+"+-"+std_dice_p+", "+mean_dice_c+"+-"+std_dice_c+", ";
    to_add_notab_end = mean_iou_p+"+-"+std_iou_p+", "+mean_iou_c+"+-"+std_iou_c+", ";
else 
    to_add = mean_hd_c+" \t"+mean_voldiff_c+" \t"+mean_dice_c +" \t";
    to_add_end = mean_iou_c +" \t" + mcc_exc + " \t";
    to_add_notab = mean_hd_c+"+-"+std_hd_c+", "+mean_voldiff_c+"+-"+std_voldiff_c+", "+mean_dice_c+"+-"+std_dice_c+", ";
    to_add_notab_end = mean_iou_c+"+-"+std_iou_c+", " + mcc_exc + ", ";
end
fileID = fopen(filename,"a");
% fprintf(replace(to_add+dice_exc+f1_exc+sens_exc+spec_exc+prec_exc+acc_exc+to_add_end+"\n", ".", "."));
% fprintf(to_add_notab+dice_exc_notab+f1_exc_notab+sens_exc_notab+spec_exc_notab+prec_exc_notab+acc_exc_notab+to_add_notab_end+"\n");

if constants.MULTICLASS
    fprintf(fileID,"Dice (micro Dice (ALL/PENUMBRA/CORE): \t");
    fprintf(fileID,dice_exc+" \n");
    fprintf(fileID,"Dice (MACRO DICE (HYPO/PENUMBRA/CORE) + sd : \t");
    fprintf(fileID,mean_dice_h+"+-"+std_dice_h+", "+mean_dice_p+"+-"+std_dice_p+", "+mean_dice_c+"+-"+std_dice_c+" \n");
    fprintf(fileID,"HD (mean PENUMBRA/CORE + sd): \t");
    fprintf(fileID,mean_hd_p+"+-"+std_hd_p+" \t"+mean_hd_c+"+-"+std_hd_c+" \n");
    fprintf(fileID,"MCC (mean Hypo + sd / micro MCC (ALL/PENUMBRA/CORE): \t");
    fprintf(fileID,mean_mcc_h+"+-"+std_mcc_h+" \t"+mcc_exc+" \n");
    fprintf(fileID,"Delta V (mean HYPO/PENUMBRA/CORE + sd): \t");
    fprintf(fileID,mean_voldiff_h+"+-"+std_voldiff_h+", "+mean_voldiff_p+"+-"+std_voldiff_p+", "+mean_voldiff_c+"+-"+std_voldiff_c+" \n");
    fprintf(fileID,"ABS Delta V (HYPO/PENUMBRA/CORE): \t");
    fprintf(fileID,abs_voldiff_h+", "+abs_voldiff_p+", "+abs_voldiff_c+" \n");
    fprintf(fileID,"Volume SIMILARITY (HYPO/PENUMBRA/CORE): \t");
    fprintf(fileID,vs_h+", "+vs_p+", "+vs_c+" \n");
end

end

