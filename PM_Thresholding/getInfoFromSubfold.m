function [combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks,penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,stats] = ...
    getInfoFromSubfold(subfold,PARAMETRIC_IMAGES_TO_ANALYZE,research,folderPath,patient,MANUAL_ANNOTATION_FOLDER,saveFolder,colorbarPointY,parametricMaps,...
    suffix,colorbarPointBottomX,colorbarPointTopX,penumbra_color,core_color,flag_PENUMBRACORE,SAVE_PAR_MAPS,count,perce, ...
    combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks, ...
    penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,stats)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

n = numel(dir(folderPath))-2;

info = cell(1,n);
images = cell(1,n);
sec = zeros(n,2);

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

    %% sort the images based on the acquisition time
    sec = sortrows(sec);

    if exist('valuesMTT','var') && ~exist('MTTimages', 'var')
        MTTimages = cell(size(images));
    end
else 
    for i=1:n
        if i<10
            images{i} = imread([folderPath '0' num2str(i) '.png']);
        else
            images{i} = imread([folderPath num2str(i) '.png']);
        end
        sec(i,1) = 0;
        sec(i,2) = i;
    end
end
sortInfo = cell(size(info));

pm_index = 1; % for SE000004 == Cerebral Blood Flow (CBF)
if strcmp(subfold, "SE000005") % for SE000005 == Cerebral Blood Volume (CBV)
    pm_index = 2;
elseif strcmp(subfold, "SE000006") % for SE000006: TMax
    pm_index = 3;
elseif strcmp(subfold, "SE000007") % SE000007: Time to Peak (TTP)
    pm_index = 4;
end


for x=1:size(sec,1)
    newInd = sec(x,2);
    sortInfo{x} = info{newInd};
    sortImages{pm_index,x} = images{newInd};

    % create the folder if it doesn't exits
    if ~ exist(strcat(saveFolder, patient),'dir')
        mkdir(strcat(saveFolder, patient));
    end
    % create the folder if it doesn't exits
    if ~ exist(strcat(saveFolder, patient, '/', subfold),'dir')
        mkdir(strcat(saveFolder, patient, '/', subfold));
    end

    % save the image
    name = num2str(x);
    if length(name) == 1
        name = strcat('0', name);
    end

    if length(size(sortImages{pm_index,x})) == 2
        sortImages{pm_index,x} = mat2gray(sortImages{pm_index,x});
    end

    % save the parametric map
    if SAVE_PAR_MAPS
        imwrite(sortImages{pm_index,x}, strcat(saveFolder, patient, '/', subfold, '/', name, '.png'));
    end

    if strcmp(subfold, "SE000003")
        %% extract the shape of the brain slice from the grayscale image
        T = rgb2gray(sortImages{pm_index,x});
        blackWhiteMask = imbinarize(T);
        blackWhiteMask(:,colorbarPointY:end) = 0; % remove F in the bottom right

        totalCoreMask{x} = ones(size(T));
        totalPenumbraMask{x} = ones(size(T));

        blackWhiteMask = 255 * uint8(~blackWhiteMask);

        if count==1
            combinedResearchCoreMaks{x} = uint8(zeros(size(blackWhiteMask)));
            combinedResearchPenumbraMaks{x} = uint8(zeros(size(blackWhiteMask)));
        end
        groundTruthImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        tryImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        coreImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        penumbraImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
        
        skullMasks{1,x} = double(~blackWhiteMask);

    elseif strcmp(subfold, "SE000004") || strcmp(subfold, "SE000005") || strcmp(subfold, "SE000006") || strcmp(subfold, "SE000007")

        for indexName=1:numel(parametricMaps)
            mapName = parametricMaps{indexName};

            %% find the infarcted regions based on the folder and the values 
            mask = false(size(sortImages{pm_index,x},1), size(sortImages{pm_index,x},2));
            percentage = 0;
            direction = "";
            isCore = 0;
            isPenumbra = 0;

            if strcmp(subfold, "SE000004") 
                imageCBF{x} = uint8(sortImages{pm_index,x});
                imageCBF{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 

%                             add the CBF image in order to calculate later 
%                             MTT = CBV/CBF;
                if strcmp(mapName, 'MTT')
                    MTTimages{x} = uint8(sortImages{pm_index,x});
                end

                % if we want the percentage of CBF
                if contains(mapName, 'CBF')
                    valuesCBF = research.(mapName);
                    percentage = str2double(valuesCBF(1));
                    direction = valuesCBF(2);
                    if strcmp(valuesCBF(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesCBF(3), "penumbra")
                        isPenumbra = 1;
                    end
                end
            elseif strcmp(subfold, "SE000005") 
                imageCBV{x} = uint8(sortImages{pm_index,x});

                if contains(mapName, 'MTT')

                    MTTimages{x} = mapMTT(imageCBV{x},MTTimages{x}, colorbarPointTopX,colorbarPointBottomX,colorbarPointY);

                    valuesMTT = research.(mapName);
                    percentage = str2double(valuesMTT(1));
                    direction = valuesMTT(2);

                    if strcmp(direction, "up")
                        MTTimages{x} = MTTimages{x} > percentage;
                    elseif strcmp(direction, "down")
                        MTTimages{x} = MTTimages{x} < percentage;
                    end

                    if strcmp(valuesCBV(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesCBV(3), "penumbra")
                        isPenumbra = 1;
                    end
                end

                imageCBV{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 

                if contains(mapName, 'CBV')
                    valuesCBV = research.(mapName);
                    percentage = str2double(valuesCBV(1));
                    direction = valuesCBV(2);
                    if strcmp(valuesCBV(3), "core")
                        isCore = 1;
                    elseif strcmp(valuesCBV(3), "penumbra")
                        isPenumbra = 1;
                    end
                end
            elseif strcmp(subfold, "SE000006") && contains(mapName, 'TMax')
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
            elseif strcmp(subfold, "SE000007") && contains(mapName, 'TTP')
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

            %% % the percentage get replaced!!!
            % change the percentage only if it's not state FIXED
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

            %% extracting the infarcted areas (penumbra & core)
            startingColorPixelX = colorbarPointBottomX - int16(((colorbarPointBottomX-colorbarPointTopX)/100)*percentage);

            if isCore
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
                % just use the red channel
                tryImage{x}(:,:,2) = 0;
                tryImage{x}(:,:,3) = 0;
                tryImage{x}(tryImage{x}>0) = 255;
                % image fusion..
                coreImage{x} = imfuse(coreImage{x}, tryImage{x}, 'blend');
                totalCoreMask{x} = logical(totalCoreMask{x}) & logical(retMask);

            elseif isPenumbra
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

        if strcmp(subfold, "SE000007") % last folder  
            strpercentage = perce;
            if strpercentage<10
                strpercentage = strcat("00", num2str(perce));
            elseif strpercentage<100
                strpercentage = strcat("0", num2str(perce));
            else 
                strpercentage = num2str(perce);
            end
            new_suffix = strcat(suffix, "_perc_", strpercentage);
            %% get the statistical information from the image
            stats = statisticalInfo(stats, new_suffix, totalPenumbraMask{x}, totalCoreMask{x}, MANUAL_ANNOTATION_FOLDER, patient, x, penumbra_color, core_color, flag_PENUMBRACORE);

%                         %% call the method proposed by Rasmus to extract the various infarcted regions
% %                         outRasmus = RasmusMethod(totalPenumbraMask{x}, totalCoreMask{x}, imageCBV{x}, imageCBF{x}, imageTTP{x}, imageTMAX{x});
% %                         
% %                         subplot(3,4,1)
% %                         imshow(imageCBV{x});
% %                         subplot(3,4,2)
% %                         imshow(imageCBF{x});
% %                         subplot(3,4,3)
% %                         imshow(imageTTP{x});
% %                         subplot(3,4,4)
% %                         imshow(imageTMAX{x});
% %                         
% %                         for y=[1,2,3,4]
% %                             combImg = 0;
% %                             for xx=[1,2,3]
% %                                 combImg = combImg + outRasmus{xx}(:,:,:,y);
% %                             end
% %                             
% %                             subplot(3,4,4+y)
% %                             imshow(combImg)
% %                         end
% %                         
% %                         for xx=[1,2,3]
% %                             combImg = 0;
% %                             for y=[1,2,3,4]
% %                                 combImg = combImg + outRasmus{xx}(:,:,:,y);
% %                             end
% %                             
% %                             subplot(3,4,8+xx)
% %                             imshow(combImg)
% %                         end
        end
    end
end

if strcmp(subfold, "SE000007") % last folder
    clusterImagesWithRealValues(totalPenumbraMask, totalCoreMask, skullMasks, sortImages, colorbarPointBottomX, colorbarPointTopX, colorbarPointY);
end

end

