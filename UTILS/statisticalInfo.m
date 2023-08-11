function [stats] = statisticalInfo(stats, suffix, penumbraMask, coreMask, ...
    MANUAL_ANNOTATION_FOLDER, patient, indexImg, penumbra_color, core_color, ...
    flag_PENUMBRACORE, image_suffix, calculateTogether, THRESHOLDING)
%STATISTICALINFO Get statistics from patients and the corresponding
% ground truth
%   Function that get the statistics of each patient and their extraction
%   based on the corresponding ground truth images

pIndex = patient(end-1:end);
name = num2str(indexImg);
if length(name) == 1
    name = strcat('0', name);
end

if isa(penumbraMask,'uint16')
    penumbraMask = penumbraMask./256;
    penumbraMask(penumbraMask>core_color-(penumbra_color/4)) = core_color;
    penumbraMask(penumbraMask<penumbra_color+(penumbra_color/4) & penumbraMask>90) = penumbra_color;
    penumbraMask(penumbraMask<90 & penumbraMask>0) = penumbra_color/2; % brain color
end

%% load the correct annotation image
filename = strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, image_suffix);
if ~isfile(filename)
    filename = strcat(MANUAL_ANNOTATION_FOLDER, patient, "/", name, image_suffix);
end

Igray = imread(filename);
if ndims(Igray)==3
    Igray = rgb2gray(Igray);
end

if isa(Igray,'uint16')
    Igray = Igray./256;    
    Igray(Igray>core_color-(penumbra_color/4)) = core_color;
    Igray(Igray<penumbra_color+(penumbra_color/4) & Igray>90) = penumbra_color;
    Igray(Igray<90 & Igray>0) = penumbra_color/2; % brain color
end

if THRESHOLDING
    Igray = uint8(Igray);
    coreMask = uint8(logical(coreMask)*core_color);
    penumbraMask = uint8(logical(penumbraMask)*penumbra_color);
end

% Get the various confusion matrices from the penumbra and core masks
[CM_penumbra,CM_core,CM_brain,CM_penumbra_noback,CM_core_noback,CM_brain_noback] = getConfusionMatrix(Igray,penumbraMask,coreMask,penumbra_color,core_color,calculateTogether,flag_PENUMBRACORE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% table structure:
% table("name", "tn_p", "fn_p", "fp_p", "tp_p", "tn_c", "fn_c", "fp_c", "tp_c", "tn_pc", "fn_pc", "fp_pc", "tp_pc" "auc_p" "auc_c" "auc_pc");
rowToAdd = {suffix, ...
    CM_penumbra(1,1), ... "tn_p"
    CM_penumbra(2,1), ... "fn_p"
    CM_penumbra(1,2), ... "fp_p"
    CM_penumbra(2,2), ... "tp_p"
    CM_core(1,1), ... "tn_c"
    CM_core(2,1), ... "fn_c"
    CM_core(1,2), ... "fp_c"
    CM_core(2,2), ... "tp_c"
    CM_brain(1,1), ... "tn_pc"
    CM_brain(2,1), ... "fn_pc"
    CM_brain(1,2), ... "fp_pc"
    CM_brain(2,2), ... "tp_pc"
    CM_penumbra_noback(1,1), ... "tn_p"
    CM_penumbra_noback(2,1), ... "fn_p"
    CM_penumbra_noback(1,2), ... "fp_p"
    CM_penumbra_noback(2,2), ... "tp_p"
    CM_core_noback(1,1), ... "tn_c"
    CM_core_noback(2,1), ... "fn_c"
    CM_core_noback(1,2), ... "fp_c"
    CM_core_noback(2,2), ... "tp_c"
    CM_brain_noback(1,1), ... "tn_pc"
    CM_brain_noback(2,1), ... "fn_pc"
    CM_brain_noback(1,2), ... "fp_pc"
    CM_brain_noback(2,2) ... "tp_pc"
    };

stats = [stats; rowToAdd];

end

