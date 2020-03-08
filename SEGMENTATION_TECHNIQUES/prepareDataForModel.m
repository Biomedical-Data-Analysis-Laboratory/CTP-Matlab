function [data,output,tableData,weights] = prepareDataForModel(realValueImages,skullMasks,MANUAL_ANNOTATION_FOLDER,pIndex)
%PREPAREDATAFORMODEL Summary of this function goes here
%   Detailed explanation goes here
cbf = []; cbv = []; tmax = []; ttp = []; oldInfactionMask = []; 
output = []; output_penumbra = []; output_core = [];

for index = 1:size(realValueImages,2)
    name = num2str(index);
    if length(name) == 1
        name = strcat('0', name);
    end
    
    for pm_idx = 1:size(realValueImages,1)
        if pm_idx <= 4
            %% real values (0~1) 
%             pm_mask = (imfill(realValueImages{pm_idx,index}) .* imfill(skullMasks{pm_idx,index})) + ((skullMasks{pm_idx,index}==0) .* -10);
        
            %% superpixels feature of the real values ? 
            [L,N] = superpixels(realValueImages{pm_idx,index},100);
            pm_mask = meanSuperpixelsImage(realValueImages{pm_idx,index},L,N);
            pm_mask = (imfill(pm_mask) .* imfill(skullMasks{pm_idx,index})) + ((skullMasks{pm_idx,index}==0) .* -10);
        end
        
        if pm_idx==1
            cbf = [cbf, pm_mask];
        elseif pm_idx==2
            cbv = [cbv, pm_mask];
        elseif pm_idx==3
            tmax = [tmax, pm_mask];
        elseif pm_idx==4
            ttp = [ttp, pm_mask];
        else
            oldInfactionMask = [oldInfactionMask, ((realValueImages{pm_idx,index}==0) .* -10)];
        end
    end
    I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
    Igray = rgb2gray(I);
    output = [output, double(Igray)];
    output_penumbra = [output_penumbra, double(Igray)];
    output_core = [output_core, double(Igray)];
end

weights = ones(size(output));
weights_penumbra = ones(size(output_penumbra));
weights_core = ones(size(output_core));

back_idx = find(output>=234); % backgroung
brain_idx = find(output<60); % brain
penumbra_idx = intersect(find(output>=60), find(output<135));
core_idx = intersect(find(output>=135), find(output<234));

output(back_idx) = 0;
output(brain_idx) = 1; 
output(penumbra_idx) = 2;
output(core_idx) = 3;
% weights(brain_idx) = 5;
% weights(penumbra_idx) = 10;
weights(core_idx) = 5;

% output_penumbra(back_idx) = 0;
% output_penumbra(brain_idx) = 0;
% output_penumbra(penumbra_idx) = 1;
% output_penumbra(core_idx) = 1;
% weights_penumbra(penumbra_idx) = 2;
% weights_penumbra(core_idx) = 4;
% 
% output_core(back_idx) = 0;
% output_core(brain_idx) = 0;
% output_core(penumbra_idx) = 0;
% output_core(core_idx) = 1;
% weights_core(core_idx) = 5;

indexPatient = ones(size(cbf(:))) .* str2double(pIndex);

tableData = table(indexPatient,cbf(:),cbv(:),tmax(:),ttp(:),oldInfactionMask(:),weights(:),output(:), ... 
    'VariableNames', ["patient","cbf","cbv","tmax","ttp","oldInfarction","weights","output"]);
dataWithOutput = [cbf(:),cbv(:),tmax(:),ttp(:),oldInfactionMask(:),output(:)];
data = [cbf(:),cbv(:),tmax(:),ttp(:),oldInfactionMask(:)];
% for svm (NOT used atm)
% data_core = [cbf(:),cbv(:)];
% data_penumbra = [tmax(:),ttp(:)];

end

