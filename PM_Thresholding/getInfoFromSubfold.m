function [combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks,penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,imageMTT,stats,tableData,nImages] = ...
    getInfoFromSubfold(subfold,subfolds,PARAMETRIC_IMAGES_TO_ANALYZE,research,folderPath,patient,n_fold,...
    MANUAL_ANNOTATION_FOLDER,saveFolder,colorbarPointY,parametricMaps,SUPERVISED_LEARNING,FAKE_MIP,...
    suffix,colorbarPointBottomX,colorbarPointTopX,penumbra_color,core_color,flag_PENUMBRACORE,SAVE_PAR_MAPS,count,perce, ...
    combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks, ...
    penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,imageMTT,stats,dayFold,...
    image_suffix,USESUPERPIXELS,N_SUPERPIXELS)
% GETINFOFROMSUBFOLD Extract the various images from the subfold
%   For each subfold, extract the images and if the flag is set, it will
%   cluster the images (last lines)

n = numel(dir(folderPath))-2;

info = cell(1,n);
images = cell(1,n);
sec = zeros(n,2);

% initialization
tableWithoutOutput = [];
tableData = [];
nImages = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% extract DICOM images and info
if ~PARAMETRIC_IMAGES_TO_ANALYZE
    for i=1:n
        if i<10
            images{i} = dicomread([folderPath 'IM00000' num2str(i-1)]);
            info{i} = dicominfo([folderPath 'IM00000' num2str(i-1)]);
            %I = dicomread([folderPath 'Z0' num2str(i-1)]);
            %I = dicomread([folderPath 'CT00000' num2str(i-1)]);
        elseif i<101
            images{i} = dicomread([folderPath 'IM0000' num2str(i-1)]);
            info{i} = dicominfo([folderPath 'IM0000' num2str(i-1)]);
            %I = dicomread([folderPath 'CT0000' num2str(i-1)]);
        else
            images{i} = dicomread([folderPath 'IM000' num2str(i-1)]);
            info{i} = dicominfo([folderPath 'IM000' num2str(i-1)]);
            %I = dicomread([folderPath 'Z' num2str(i-1)]);
            %I = dicomread([folderPath 'CT000' num2str(i-1)]);
        end

        contTime = info{i}.ContentTime;
        H = str2double(contTime(1:2))*3600;
        M = str2double(contTime(3:4))*60;
        S = str2double(contTime(5:end));
        sec(i,1) = H+M+S;
        sec(i,2) = i;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% sort the images based on the acquisition time
    sec = sortrows(sec);

    if exist('valuesMTT','var') && ~exist('MTTimages', 'var')
        MTTimages = cell(size(images));
    end
else 
    for i=1:n
        if i<10
            images{i} = imread(strcat(folderPath,'0',num2str(i),'.png'));
        else
            images{i} = imread(strcat(folderPath,num2str(i),'.png'));
        end
        sec(i,1) = 0;
        sec(i,2) = i;
    end
end
sortInfo = cell(size(info));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get corresponding index of the subfold
pm_index = 1; % for SE000004 ( == Cerebral Blood Flow (CBF)
if strcmp(subfold, subfolds(end-2)) % for SE000005 == Cerebral Blood Volume (CBV)
    pm_index = 2;
elseif strcmp(subfold, subfolds(end-1)) % for SE000006: TMax
    pm_index = 3;
elseif strcmp(subfold, subfolds(end)) % SE000007 (TPP): Time to Peak (TTP)
    pm_index = 4;
elseif strcmp(subfold, subfolds(1)) % SE000003 (MIP): Enhanced image
    pm_index = 5;
elseif strcmp(subfold, subfolds(2)) % for MTT
    pm_index = 6;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for every image
for x=1:size(sec,1)
    newInd = sec(x,2);
    sortInfo{x} = info{newInd};
    sortImages{pm_index,x} = images{newInd};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% save the image
    name = num2str(x);
    if length(name) == 1
        name = strcat('0', name);
    end

    if length(size(sortImages{pm_index,x})) == 2
        sortImages{pm_index,x} = mat2gray(sortImages{pm_index,x});
    end
    % create the folder if it doesn't exits
    if ~ exist(strcat(saveFolder, patient),'dir')
        mkdir(strcat(saveFolder, patient));
    end
    % create also the day folder
    if ~ exist(strcat(saveFolder, patient,"/",dayFold),'dir')
        mkdir(strcat(saveFolder, patient,"/",dayFold));
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% save the parametric map
    if SAVE_PAR_MAPS
        % create the folder if it doesn't exits
        if ~ exist(strcat(saveFolder, patient, "/", dayFold, "/", subfold),'dir')
            mkdir(strcat(saveFolder, patient, "/", dayFold, "/", subfold));
        end
        imwrite(sortImages{pm_index,x}, strcat(saveFolder, patient, "/",dayFold, "/", subfold, "/", name, ".png"));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if subfold == subfolds(1)
        %% extract the shape of the brain slice from the grayscale image
        T = rgb2gray(sortImages{pm_index,x});
        blackWhiteMask = imbinarize(T);
        blackWhiteMask(:,colorbarPointY:end) = 0; % remove F in the bottom right

        totalCoreMask{x} = ones(size(T));
        totalPenumbraMask{x} = ones(size(T));

        blackWhiteMask = 255 * uint8(~blackWhiteMask);

        if count==1 % initialize the masks
            combinedResearchCoreMaks{x} = uint8(zeros(size(blackWhiteMask)));
            combinedResearchPenumbraMaks{x} = uint8(zeros(size(blackWhiteMask)));
        end
        groundTruthImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        tryImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        coreImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        penumbraImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        
        for t=1:4
            skullMasks{t,x} = double(~blackWhiteMask);
        end
        
        T(:,colorbarPointY:end) = 0; % remove F in the bottom right
        skullMasks{5,x} = double(T); % add the enhanced image for classification

    elseif ismember(subfold, subfolds) % not the first one but still a subfolder in my array 

        for indexName=1:numel(parametricMaps)
            mapName = parametricMaps{indexName};
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% find the infarcted regions based on the folder and the values 
            mask = false(size(sortImages{pm_index,x},1), size(sortImages{pm_index,x},2));
            percentage = 0;
            direction = "";
            isCore = 0;
            isPenumbra = 0;

            if subfold == subfolds(3) 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% CBF 
                if contains(mapName, 'CBF')
                    imageCBF{x} = uint8(sortImages{pm_index,x});
                    imageCBF{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 
                
                    valuesCBF = research.(mapName);
                    percentage = str2double(valuesCBF(1));
                    direction = valuesCBF(2);
                    if strcmp(valuesCBF(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesCBF(3), "penumbra")
                        isPenumbra = 1;
                    end
                end
            elseif subfold == subfolds(2)   
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% MTT
                if contains(mapName, 'MTT')
                    imageMTT{x} = uint8(sortImages{pm_index,x});
                    imageMTT{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 
                    valuesMTT = research.(mapName);
                    percentage = str2double(valuesMTT(1));
                    direction = valuesMTT(2);

                    if strcmp(valuesMTT(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesMTT(3), "penumbra")
                        isPenumbra = 1;
                    end
                end
            elseif subfold == subfolds(end-2) 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% CBV
                if contains(mapName, 'CBV')
                    imageCBV{x} = uint8(sortImages{pm_index,x});
                    imageCBV{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 

                    valuesCBV = research.(mapName);
                    percentage = str2double(valuesCBV(1));
                    direction = valuesCBV(2);
                    if strcmp(valuesCBV(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesCBV(3), "penumbra")
                        isPenumbra = 1;
                    end
                end
            elseif subfold == subfolds(end-1)
                if contains(mapName, 'TMax')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %% TMAX
                    imageTMAX{x} = uint8(sortImages{pm_index,x});
                    imageTMAX{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 

                    valuesTMax = research.(mapName);
                    percentage = str2double(valuesTMax(1));
                    direction = valuesTMax(2);
                    if strcmp(valuesTMax(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesTMax(3), "penumbra")
                        isPenumbra = 1;
                    end
                end
            elseif subfold == subfolds(end) 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% TTP
                if contains(mapName, 'TTP')
                    imageTTP{x} = uint8(sortImages{pm_index,x});
                    imageTTP{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 

                    valuesTTP = research.(mapName);
                    percentage = str2double(valuesTTP(1));
                    direction = valuesTTP(2);
                    if strcmp(valuesTTP(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesTTP(3), "penumbra")
                        isPenumbra = 1;
                    end
                end
            end

            %% % the percentage get replaced!!!
            % change the percentage only if it's not state FIXED
            if numel(research.(mapName)) >= 4
                if ~strcmp(research.(mapName)(4), "FIXED") && perce>=0
                    percToAdd = str2double(research.(mapName)(4));
                    % add something if it's says so
                    if ~isnan(percToAdd)
                        percentage = perce+percToAdd;
                        if percentage>100
                            percentage=100;
                        end
                    else
                        percentage = perce;
                    end
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% extracting the infarcted areas (penumbra & core)
            startingColorPixelX = colorbarPointBottomX - int16(((colorbarPointBottomX-colorbarPointTopX)/100)*percentage);

            if isCore % core region
                if percentage==0
                    tryImage{x} = zeros(size(sortImages{pm_index,x}));
                    retMask = zeros(size(sortImages{pm_index,x},1), size(sortImages{pm_index,x},2));
                elseif percentage==100
                    tryImage{x} = ones(size(sortImages{pm_index,x}));
                    retMask = ones(size(sortImages{pm_index,x},1), size(sortImages{pm_index,x},2));
                else
                    [tryImage{x}, retMask] = segmentWithKMeanClustering(sortImages{pm_index,x}, direction, 100, colorbarPointBottomX, colorbarPointTopX, startingColorPixelX, colorbarPointY);
                end
                % just use the red channel
                tryImage{x}(:,:,2) = 0;
                tryImage{x}(:,:,3) = 0;
                tryImage{x}(tryImage{x}>0) = 255;
                % image fusion..
                coreImage{x} = imfuse(coreImage{x}, tryImage{x}, 'blend');
                totalCoreMask{x} = logical(totalCoreMask{x}) & logical(retMask);

            elseif isPenumbra % penumnbra region
                if percentage==0
                    tryImage{x} = zeros(size(sortImages{pm_index,x}));
                    retMask = zeros(size(sortImages{pm_index,x},1), size(sortImages{pm_index,x},2));
                elseif percentage==100
                    tryImage{x} = ones(size(sortImages{pm_index,x}));
                    retMask = ones(size(sortImages{pm_index,x},1), size(sortImages{pm_index,x},2));
                else
                    if ~contains(mapName, 'MTT')
                        [tryImage{x}, retMask] = segmentWithKMeanClustering(sortImages{pm_index,x}, direction, 100, colorbarPointBottomX, colorbarPointTopX, startingColorPixelX, colorbarPointY);
                    else
                        % just for the created MTT map 
                        tryImage{x} = ones(size(sortImages{pm_index,x}));
                        MTTimages{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 
                        retMask = MTTimages{x};
                    end
                end
                % just use the green channel
                tryImage{x}(:,:,1) = 0;
                tryImage{x}(:,:,3) = 0;
                tryImage{x}(tryImage{x}>0) = 255;
                % image fusion...
                penumbraImage{x} = imfuse(penumbraImage{x}, tryImage{x}, 'blend');

                totalPenumbraMask{x} = logical(totalPenumbraMask{x}) & logical(retMask);
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if subfold == subfolds(end) % last folder  
            strpercentage = perce;
            if strpercentage==-1
                new_suffix = suffix;
            else
                if strpercentage<10
                    strpercentage = strcat("00", num2str(perce));
                elseif strpercentage<100
                    strpercentage = strcat("0", num2str(perce));
                else 
                    strpercentage = num2str(perce);
                end
                new_suffix = strcat(suffix, "_perc_", strpercentage);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% get the statistical information from the image
            if SUPERVISED_LEARNING % only if we are doing supervised learning 
                stats = statisticalInfo(stats, new_suffix, totalPenumbraMask{x}, totalCoreMask{x}, MANUAL_ANNOTATION_FOLDER, patient, x, penumbra_color, core_color, flag_PENUMBRACORE, image_suffix);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% go inside here only if the mapname == cluster (use only for the ML approach
if subfold == subfolds(end) && strcmp("cluster", mapName) % last folder
    if strcmp(research.(mapName), "yes")
        [tableData,nImages] = clusterImagesWithRealValues(skullMasks, sortImages, ...
            colorbarPointBottomX, colorbarPointTopX, colorbarPointY, MANUAL_ANNOTATION_FOLDER, ...
            SUPERVISED_LEARNING, FAKE_MIP, patient, n_fold, image_suffix, suffix, USESUPERPIXELS, N_SUPERPIXELS);
    end
end

end

