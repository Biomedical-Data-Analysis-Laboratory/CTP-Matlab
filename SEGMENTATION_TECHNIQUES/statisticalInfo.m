function [stats] = statisticalInfo(stats, suffix, penumbraMask, coreMask, ...
    MANUAL_ANNOTATION_FOLDER, patient, indexImg, penumbra_color, core_color, flag_PENUMBRACORE)
%STATISTICALINFO Summary of this function goes here
%   Detailed explanation goes here

pIndex = patient(end-1:end);
name = num2str(indexImg);
if length(name) == 1
    name = strcat('0', name);
end

% remove overlapping
penumbraMask = penumbraMask - coreMask;
penumbraMask = double(penumbraMask>0);
coreMask = double(coreMask);

I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
Igray = rgb2gray(I);
index_no_back = find(Igray~=255);

I_penumbra = double(Igray==penumbra_color); % PENUMBRA COLOR
I_penumbra_no_back = double(Igray(index_no_back)==penumbra_color); % PENUMBRA COLOR

I_core = double(Igray==core_color); % CORE COLOR
I_core_no_back = double(Igray(index_no_back)==core_color); % CORE COLOR

if flag_PENUMBRACORE
    I_penumbraCore = I_penumbra+I_core;
    penumbraCoreMask = penumbraMask+coreMask;
    I_penumbraCore = double(I_penumbraCore>=1);
    penumbraCoreMask = double(penumbraCoreMask>=1);
    I_penumbraCore_reshape = reshape(I_penumbraCore, 1,[]);
    penumbraCoreMask_reshape = reshape(penumbraCoreMask, 1,[]);
end
    

penumbraMask_noback =  penumbraMask(index_no_back);
penumbraMask_reshape = reshape(penumbraMask,1,[]);
I_penumbra_reshape = reshape(I_penumbra,1,[]);

coreMask_noback =  coreMask(index_no_back);
coreMask_reshape = reshape(coreMask,1,[]);
I_core_reshape = reshape(I_core,1,[]);

if flag_PENUMBRACORE
    I_penumbraCore_no_back = I_penumbra_no_back+I_core_no_back;
    I_penumbraCore_no_back = double(I_penumbraCore_no_back>=1);
    penumbraCoreMask_noback = penumbraMask_noback+coreMask_noback;
    penumbraCoreMask_noback = double(penumbraCoreMask_noback>=1);
end

CM_penumbra = confusionmat(I_penumbra_reshape,penumbraMask_reshape);
if numel(CM_penumbra)==1
    CM_penumbra = double(reshape([CM_penumbra, 0, 0, 0], 2,2));
end
CM_core = confusionmat(I_core_reshape,coreMask_reshape);
if numel(CM_core)==1
    CM_core = double(reshape([CM_core, 0, 0, 0], 2,2));
end

if flag_PENUMBRACORE
    CM_both = confusionmat(I_penumbraCore_reshape,penumbraCoreMask_reshape); % CM_penumbra+CM_core;
    if numel(CM_both)==1
        CM_both = double(reshape([CM_both, 0, 0, 0], 2,2));
    end
else
    CM_both = double(reshape([0,0,0,0], 2,2));
end

CM_penumbra_noback = confusionmat(I_penumbra_no_back, penumbraMask_noback);
if numel(CM_penumbra_noback)==1
    CM_penumbra_noback = double(reshape([CM_penumbra_noback, 0, 0, 0], 2,2));
end
CM_core_noback = confusionmat(I_core_no_back, coreMask_noback);
if numel(CM_core_noback)==1
    CM_core_noback = double(reshape([CM_core_noback, 0, 0, 0], 2,2));
end

if flag_PENUMBRACORE
    CM_both_noback = confusionmat(I_penumbraCore_no_back,penumbraCoreMask_noback); % CM_penumbra_noback+CM_core_noback;
    if numel(CM_both_noback)==1
        CM_both_noback = double(reshape([CM_both_noback, 0, 0, 0], 2,2));
    end
else
    CM_both_noback = double(reshape([0,0,0,0], 2,2));
end

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
    CM_both(1,1), ... "tn_pc"
    CM_both(2,1), ... "fn_pc"
    CM_both(1,2), ... "fp_pc"
    CM_both(2,2), ... "tp_pc"
    CM_penumbra_noback(1,1), ... "tn_p"
    CM_penumbra_noback(2,1), ... "fn_p"
    CM_penumbra_noback(1,2), ... "fp_p"
    CM_penumbra_noback(2,2), ... "tp_p"
    CM_core_noback(1,1), ... "tn_c"
    CM_core_noback(2,1), ... "fn_c"
    CM_core_noback(1,2), ... "fp_c"
    CM_core_noback(2,2), ... "tp_c"
    CM_both_noback(1,1), ... "tn_pc"
    CM_both_noback(2,1), ... "fn_pc"
    CM_both_noback(1,2), ... "fp_pc"
    CM_both_noback(2,2) ... "tp_pc"
    };

stats = [stats; rowToAdd];

end

