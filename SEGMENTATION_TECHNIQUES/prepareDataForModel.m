function [tableData] = prepareDataForModel(realValueImages,skullMasks,MANUAL_ANNOTATION_FOLDER,SUPERVISED_LEARNING,pIndex)
%PREPAREDATAFORMODEL Summary of this function goes here
%   Detailed explanation goes here
cbf = []; cbv = []; tmax = []; ttp = []; oldInfactionMask = []; 
cbf_superpixels = []; cbv_superpixels = []; tmax_superpixels = []; ttp_superpixels = [];
output = []; 

multiplyBack = -1;
showSUBPLOT = false;

for index = 1:size(realValueImages,2)
    name = num2str(index);
    if length(name) == 1
        name = strcat('0', name);
    end
    
    for pm_idx = 1:size(realValueImages,1)
        if pm_idx <= 4
            %% real values (0~1) 
            pm_mask = (imfill(realValueImages{pm_idx,index}) .* imfill(skullMasks{pm_idx,index})) + ((skullMasks{pm_idx,index}==0) .* multiplyBack);
        
            %% superpixels feature of the real values ? 
            [L,N] = superpixels(realValueImages{pm_idx,index},100);
            pm_mask_superpixels = meanSuperpixelsImage(realValueImages{pm_idx,index},L,N);
            pm_mask_superpixels = (imfill(pm_mask_superpixels) .* imfill(skullMasks{pm_idx,index})) + ((skullMasks{pm_idx,index}==0) .* multiplyBack);
            
            if showSUBPLOT
                %subplot...
                subplot(2,5,pm_idx),imshow(pm_mask,[]);
                subplot(2,5,pm_idx+5),imshow(pm_mask_superpixels,[]);
            end
        end
        
        if pm_idx==1
            cbf = [cbf, pm_mask];
            cbf_superpixels = [cbf_superpixels, pm_mask_superpixels];
        elseif pm_idx==2
            cbv = [cbv, pm_mask];
            cbv_superpixels = [cbv_superpixels, pm_mask_superpixels];
        elseif pm_idx==3
            tmax = [tmax, pm_mask];
            tmax_superpixels = [tmax_superpixels, pm_mask_superpixels];
        elseif pm_idx==4
            ttp = [ttp, pm_mask];
            ttp_superpixels = [ttp_superpixels, pm_mask_superpixels];
        else
            oldInfactionMask = [oldInfactionMask, ((realValueImages{pm_idx,index}==0) .* multiplyBack)];
            if showSUBPLOT
                subplot(2,5,pm_idx),imshow(realValueImages{pm_idx,index}==0,[]);
            end
        end
    end
    
    if SUPERVISED_LEARNING
        I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
        Igray = rgb2gray(I);
        output = [output, double(Igray)];
        if showSUBPLOT
            %subplot output
            subplot(2,5,10),imshow(double(Igray),[]);
        end
    else 
        % for the unsupervised learning:
        % just use a fake output in order to create the table later
        fake_output = ones(512,512);
        output = [output, fake_output];
    end
end

%% set weights and output
weights = ones(size(output));

back_idx = find(output>=234); % backgroung
brain_idx = find(output<60); % brain
penumbra_idx = intersect(find(output>=60), find(output<135));
core_idx = intersect(find(output>=135), find(output<234));

output(back_idx) = 1; % set the background rows with the same output as 
output(brain_idx) = 1; 
output(penumbra_idx) = 2;
output(core_idx) = 3;

% weights(brain_idx) = 2;
weights(penumbra_idx) = 3;
weights(core_idx) = 10;

%% create the table
indexPatient = ones(size(cbf(:))) .* str2double(pIndex);

tableData = table(indexPatient,...
    cbf(:),cbf_superpixels(:),...
    cbv(:),cbv_superpixels(:),...
    tmax(:),tmax_superpixels(:),...
    ttp(:), ttp_superpixels(:),...
    oldInfactionMask(:),weights(:),...
    output(:),output(:),... 
    'VariableNames', ["patient","cbf","cbf_superpixels",...
    "cbv","cbv_superpixels","tmax","tmax_superpixels",...
    "ttp","ttp_superpixels","oldInfarction","weights","output","outputPenumbraCore"]);


penumbraCoreRows = (tableData.output>=2); % get the index of the infarcted regions
notInfarctedRegionsRows = (tableData.output<2);

tableData.output(penumbraCoreRows) = 2; % set penumbra and core in the same class
tableData.outputPenumbraCore(notInfarctedRegionsRows) = 2; % set brain and background output = penumbra

end

