function [tableData,nImages] = classificationApproach(realValueImages,skullMasks, ...
    MANUAL_ANNOTATION_FOLDER, SUPERVISED_LEARNING, patient, n_fold, image_suffix, suffix, USESUPERPIXELS, N_SUPERPIXELS)

%CLASSIFICATIONAPPROACH Summary of this function goes here
%   Detailed explanation goes here

close all;

tmp_suffix = split(suffix,"_");
cbf = []; cbv = []; tmax = []; ttp = []; oldInfactionMask = []; 
if USESUPERPIXELS
    cbf_superpixels = []; cbv_superpixels = []; tmax_superpixels = []; ttp_superpixels = [];
end

output = []; 

multiplyBack = -1;
showSUBPLOT = false;

pIndex = getIndexFromPatient(patient, n_fold);
nImages = size(realValueImages,2);

for pm_idx = 1:size(realValueImages,1)
    V = zeros(512,512,nImages);
    
    for index = 1:size(realValueImages,2)
        name = num2str(index);
        if length(name) == 1
            name = strcat('0', name);
        end
        
        if pm_idx <= 4 % pm_idx = [CBF,CBV,Tmax,TTP] 
            if pm_idx==1 % just on the first PM load the output
                if SUPERVISED_LEARNING
                    filename = strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, image_suffix);
                    if ~isfile(filename)
                        filename = strcat(MANUAL_ANNOTATION_FOLDER, patient, "/", name, image_suffix);
                    end

                    Igray = imread(filename);
                    if ndims(Igray)==3
                        Igray = rgb2gray(Igray);
                    end

                    if isa(Igray,'uint16')
                        Igray = im2uint8(Igray);
                    end
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
            
            %% real values (0~1) 
            pm_mask = (imfill(realValueImages{pm_idx,index}) .* imfill(skullMasks{pm_idx,index})) + ((skullMasks{pm_idx,index}==0) .* multiplyBack);
            V(:,:,index) = realValueImages{pm_idx,index};
        end
        
        if pm_idx==1 % == CBF
            cbf = [cbf, pm_mask];
        elseif pm_idx==2 % == CBV
            cbv = [cbv, pm_mask];
        elseif pm_idx==3 % == Tmax
            tmax = [tmax, pm_mask];
        elseif pm_idx==4 % == TTP
            ttp = [ttp, pm_mask];
        elseif pm_idx==5 % == MIP
            oldInfactionMask = [oldInfactionMask, ((realValueImages{pm_idx,index}==0) .* multiplyBack)];
            if showSUBPLOT
                subplot(2,5,pm_idx),imshow(realValueImages{pm_idx,index}==0,[]);
            end
        end
    end
    
    if USESUPERPIXELS
        if pm_idx <= 4 % pm_idx = [CBF,CBV,Tmax,TTP] 
            [L,N] = superpixels3(V,N_SUPERPIXELS);
            pm_mask_superpixels = meanSuperpixelsImage(V,L,N);
            for x = 1:size(pm_mask_superpixels,3)
                pm_mask_superpixel = (imfill(pm_mask_superpixels(:,:,x)) .* imfill(skullMasks{pm_idx,x})) + ((skullMasks{pm_idx,x}==0) .* multiplyBack);

                if pm_idx==1 % == CBF
                    cbf_superpixels = [cbf_superpixels, pm_mask_superpixel];
                elseif pm_idx==2 % == CBV
                    cbv_superpixels = [cbv_superpixels, pm_mask_superpixel];
                elseif pm_idx==3 % == Tmax
                    tmax_superpixels = [tmax_superpixels, pm_mask_superpixel];
                elseif pm_idx==4 % == TTP
                    ttp_superpixels = [ttp_superpixels, pm_mask_superpixel];
                end
            end
        end
    end
end

%% prepare the data --> superpixels 2D
% for index = 1:size(realValueImages,2)
%     name = num2str(index);
%     if length(name) == 1
%         name = strcat('0', name);
%     end
%     
%     for pm_idx = 1:size(realValueImages,1)
%         if pm_idx <= 4 % pm_idx = [CBF,CBV,Tmax,TTP] 
%             %% real values (0~1) 
%             pm_mask = (imfill(realValueImages{pm_idx,index}) .* imfill(skullMasks{pm_idx,index})) + ((skullMasks{pm_idx,index}==0) .* multiplyBack);
%         
%             %% superpixels feature of the real values ? 
%             [L,N] = superpixels(realValueImages{pm_idx,index},100);
%             pm_mask_superpixels = meanSuperpixelsImage(realValueImages{pm_idx,index},L,N);
%             pm_mask_superpixels = (imfill(pm_mask_superpixels) .* imfill(skullMasks{pm_idx,index})) + ((skullMasks{pm_idx,index}==0) .* multiplyBack);
%             
%             if showSUBPLOT
%                 %subplot...
%                 subplot(2,5,pm_idx),imshow(pm_mask,[]);
%                 subplot(2,5,pm_idx+5),imshow(pm_mask_superpixels,[]);
%             end
%         end
%         
%         if pm_idx==1 % == CBF
%             cbf = [cbf, pm_mask];
%             cbf_superpixels = [cbf_superpixels, pm_mask_superpixels];
%         elseif pm_idx==2 % == CBV
%             cbv = [cbv, pm_mask];
%             cbv_superpixels = [cbv_superpixels, pm_mask_superpixels];
%         elseif pm_idx==3 % == Tmax
%             tmax = [tmax, pm_mask];
%             tmax_superpixels = [tmax_superpixels, pm_mask_superpixels];
%         elseif pm_idx==4 % == TTP
%             ttp = [ttp, pm_mask];
%             ttp_superpixels = [ttp_superpixels, pm_mask_superpixels];
%         elseif pm_idx==5 % == MIP
%             oldInfactionMask = [oldInfactionMask, ((realValueImages{pm_idx,index}==0) .* multiplyBack)];
%             if showSUBPLOT
%                 subplot(2,5,pm_idx),imshow(realValueImages{pm_idx,index}==0,[]);
%             end
%         end
%     end
%     
%     if SUPERVISED_LEARNING
%         filename = strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, image_suffix);
%         if ~isfile(filename)
%             filename = strcat(MANUAL_ANNOTATION_FOLDER, patient, "/", name, image_suffix);
%         end
%         
%         Igray = imread(filename);
%         if ndims(Igray)==3
%             Igray = rgb2gray(Igray);
%         end
%             
%         if isa(Igray,'uint16')
%             Igray = im2uint8(Igray);
%         end
%         output = [output, double(Igray)];
%         if showSUBPLOT
%             %subplot output
%             subplot(2,5,10),imshow(double(Igray),[]);
%         end
%     else 
%         % for the unsupervised learning:
%         % just use a fake output in order to create the table later
%         fake_output = ones(512,512);
%         output = [output, fake_output];
%     end
% end

%% set weights and output
weights = ones(size(output));

back_idx = output<=20; % backgroung
brain_idx = intersect(find(output>=20), find(output<150)); % brain
penumbra_idx = intersect(find(output>=150), find(output<240));
core_idx = output>=240;

%% output = [1,2,3] --> 1==brain+back, 2==penumbra, 3==core
output(back_idx) = 1; % set the background rows with the same output as 
output(brain_idx) = 1; 
output(penumbra_idx) = 2;
output(core_idx) = 3;
%% set the weights
weights(penumbra_idx) = 3;
weights(core_idx) = 10;

%% create the table
indexPatient = ones(size(cbf(:))) .* str2double(pIndex);
[~,NIHSS_value] =  getSeverityAndNIHSSfromPatient(patient);

NIHSS = ones(size(cbf(:))) .* NIHSS_value;

if USESUPERPIXELS
    if USESUPERPIXELS==1
        tableData = table(indexPatient,...
            cbf(:),cbf_superpixels(:),...
            cbv(:),cbv_superpixels(:),...
            tmax(:),tmax_superpixels(:),...
            ttp(:),ttp_superpixels(:),NIHSS,...
            oldInfactionMask(:),weights(:),...
            output(:),output(:),output(:),... 
            'VariableNames', ["patient","cbf","cbf_superpixels",...
            "cbv","cbv_superpixels",...
            "tmax","tmax_superpixels",...
            "ttp","ttp_superpixels",...
            "NIHSS","oldInfarction","weights",...
            "output","outputPenumbraCore","outputCore"]);
    elseif USESUPERPIXELS==2
        tableData = table(indexPatient,cbf_superpixels(:),...
            cbv_superpixels(:),tmax_superpixels(:),...
            ttp_superpixels(:),NIHSS,...
            oldInfactionMask(:),weights(:),...
            output(:),output(:),output(:),... 
            'VariableNames', ["patient","cbf_superpixels",...
            "cbv_superpixels","tmax_superpixels",...
            "ttp_superpixels","NIHSS","oldInfarction","weights",...
            "output","outputPenumbraCore","outputCore"]);
    end
else
    tableData = table(indexPatient,...
        cbf(:),cbv(:),tmax(:),ttp(:),NIHSS,...
        oldInfactionMask(:),weights(:),...
        output(:),output(:),output(:),... 
        'VariableNames', ["patient","cbf",...
        "cbv","tmax","ttp",...
        "NIHSS","oldInfarction","weights",...
        "output","outputPenumbraCore","outputCore"]);
end

%% outputPenumbraCore = [1,2] --> 1==brain+back, 2==core+penumbra
penumbraCoreRows = (tableData.output>=2); % get the index of the infarcted regions
tableData.outputPenumbraCore(penumbraCoreRows) = 2; % set penumbra and core in the same class

%% outputCore = [1,3] --> 1==not core, 3==core
notCoreRegionRows = (tableData.output<3);
tableData.outputCore(notCoreRegionRows) = 1; % set this output equal for all the regions differnet from the core

end

