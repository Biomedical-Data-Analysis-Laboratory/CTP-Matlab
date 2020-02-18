clear;
close all;

%% APPLE
USER = '/Users/lucatomasetti/';
%% WINDOWS 
% USER = 'C:\Users\';
% USER = strcat(USER, 'Luca\');
% USER = strcat(USER, '2921329\');

%% CONSTANTS
PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
perfusionCTFolder = strcat(HOME, 'PhD/Patients/');

if PARAMETRIC_IMAGES_TO_ANALYZE
    perfusionCTFolder = strcat(perfusionCTFolder, 'extracted_info/');
    saveFolder = perfusionCTFolder;
else
    saveFolder = strcat(perfusionCTFolder, 'extracted_info/');
end

MANUAL_ANNOTATION_FOLDER = strcat(USER, 'OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/');

SAVE_PAR_MAPS = 0; 
patients = ["PA02", "PA03", "PA04", "PA05", "PA06", "PA07", "PA09", "PA10", "PA11"]; %["PA08"]; 

%subfolds = ["SE000002"]; 
% brain , CBF, CBV, TMax, TTP
subfolds = ["SE000003", "SE000004", "SE000005", "SE000006", "SE000007"]; 

colorbarPointTopX = 129;
colorbarPointBottomX = 384;
colorbarPointY = 436;
penumbra_color = 76;
core_color = 150;

%% values for each parametric map [perc(%), up/down, core/penumbra]

researchesValues = containers.Map;
researchesValues('Cereda_2015') = struct('CBF', [38, "down", "core"], 'TMax', [33, "up", "penumbra"]);
researchesValues('Wintermark_2006') = struct('CBV', [30, "down", "core"], 'TMax', [50, "up", "penumbra"]);
researchesValues('Ma_Cambell_2019') = struct('CBF', [30, "down", "core"], 'TMax', [50, "up", "penumbra"]);
researchesValues('Shaefer_2014') = struct('CBF', [15, "down", "core"], 'CBV', [30, "down", "penumbra"]);
% researchesValues('Bivard_Lin_2014') = struct('CBF', [45, "down", "core"], 'TMax', [50, "up", "penumbra"]);
researchesValues('Bivard_2014') = struct('CBF', [50, "down", "core"], 'TTP', [75, "up", "penumbra"]);
researchesValues('Cambell_2012') = struct('CBF', [31, "down", "core"], 'TMax', [50, "up", "penumbra"]);
researchesValues('Murphy_2006') = struct('CBF', [13.3, "down", "core"], 'CBV', [36, "down", "penumbra"]);
% researchesValues('Murphy_2006_2') = struct('CBF', [25, "down", "penumbra"], 'CBV', [18.6, "down", "core"]);
% researchesValues('Shaefer_2006') = struct('CBF', [17.92, "down", "penumbra"], 'CBV', [24.5, "down", "core"]);
researchesValues('Shaefer_2006_2') = struct('CBF', [8.8, "down", "core"], 'CBV', [49, "down", "penumbra"]);
% researchesValues('Bivard') = struct('CBF', [50, "down", "core"], 'TTP', [75, "down", "penumbra"]);
%researchesValues('COMB_Wintermark_Shaefer') = struct('CBV', [24.5, "down", "core"], 'CBF', [30, "down", "penumbra"], 'TMax', [50, "up", "penumbra"], 'TTP', [75, "up", "penumbra"]);


stats = table();
%% for each suffix 
for suff = researchesValues.keys
    count = 0;
    
    suffix = suff{1};
    research = researchesValues(suffix);
    parametricMaps = fieldnames(research);
    %% for each patient
    for p=1:numel(patients)

        savePenumbra = 1;
        saveCore = 1;
        count = count + 1;

        patient = convertStringsToChars(patients(p));

        combinedResearchCoreMaks = cell(1,50); % initialize the combined core mask
        combinedResearchPenumbraMaks = cell(1,50); % initialize the combined penumbra mask
        
        %% for each subfolder of parametric maps   
%         maskPenumbra = uint8(zeros(512,512,3));
%         maskCore = uint8(zeros(512,512,3));
                
        for s=1:numel(subfolds)
            subfold = subfolds(s);
            intermediateFold = '/';
            if ~PARAMETRIC_IMAGES_TO_ANALYZE
                intermediateFold = '/ST000000/';
            end
            folderPath = strcat(perfusionCTFolder, patient, intermediateFold, convertStringsToChars(subfold), '/');
            
            n = numel(dir(folderPath))-2;

            info = cell(1,n);
            images = cell(1,n);
            sec = zeros(n,2);

            %% initialize the cells if we are cecking the grayscale image 
            if strcmp(subfold, "SE000003")
                tryImage = cell(1,n); % initialize the ground truth cell
                groundTruthImage = cell(1,n); % initialize the ground truth cell
                coreImage = cell(1,n); % initialize the core image cell
                penumbraImage = cell(1,n); % initialize the penumbra image cell
                %%
                totalCoreMask = cell(1,n);
                totalPenumbraMask = cell(1,n);
                imageCBV = cell(1,n);
                imageCBF = cell(1,n);
                imageTTP = cell(1,n);
                imageTMAX = cell(1,n);
                %%
            end

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
                
                
    %             if exist('valuesMTT','var') && ~exist('MTTimages', 'var')
    %                 MTTimages = cell(size(images));
    %             end
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
            sortImages = cell(size(images));
            
            for x=1:size(sec,1)
                newInd = sec(x,2);
                sortInfo{x} = info{newInd};
                sortImages{x} = images{newInd};

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

                if length(size(sortImages{x})) == 2
                    sortImages{x} = mat2gray(sortImages{x});
                end

                % save the parametric map
                if SAVE_PAR_MAPS
                    imwrite(sortImages{x}, strcat(saveFolder, patient, '/', subfold, '/', name, '.png'));
                end

                if strcmp(subfold, "SE000003")
                    %% extract the shape of the brain slice from the grayscale image
                    T = rgb2gray(sortImages{x});
                    blackWhiteMask = imbinarize(T);
                    blackWhiteMask(:,colorbarPointY:end) = 0; % remove F in the bottom right
                    
                    totalCoreMask{x} = zeros(size(T));
                    totalPenumbraMask{x} = zeros(size(T));

                    blackWhiteMask = 255 * uint8(~blackWhiteMask);
                    
                    if count==1
                        combinedResearchCoreMaks{x} = uint8(zeros(size(blackWhiteMask)));
                        combinedResearchPenumbraMaks{x} = uint8(zeros(size(blackWhiteMask)));
                    end
                    groundTruthImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
                    tryImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
                    coreImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);
                    penumbraImage{x} = cat(3, blackWhiteMask, blackWhiteMask, blackWhiteMask);

                elseif strcmp(subfold, "SE000004") || strcmp(subfold, "SE000005") || strcmp(subfold, "SE000006") || strcmp(subfold, "SE000007")
                    
                    for indexName=1:numel(parametricMaps)
                        mapName = parametricMaps{indexName};
                        
                        %% find the infarcted regions based on the folder and the values 
                        mask = false(size(sortImages{x},1), size(sortImages{x},2));
                        percentage = 0;
                        direction = "";
                        isCore = 0;
                        isPenumbra = 0;

                        if strcmp(subfold, "SE000004") 
                            imageCBF{x} = uint8(sortImages{x});
                            imageCBF{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 
                            
                            % add the CBF image in order to calculate later 
                            % MTT = CBV/CBF
%                             if strcmp(mapName, 'MTT')
%                                 MTTimages{x} = sortImages{x};
%                             end

                            % if we want the percentage of CBF
                            if strcmp(mapName, 'CBF')
                                valuesCBF = research.CBF;
                                percentage = str2double(valuesCBF(1));
                                direction = valuesCBF(2);
                                if strcmp(valuesCBF(3), "core")
                                    isCore = 1;
                                elseif strcmp(valuesCBF(3), "penumbra")
                                    isPenumbra = 1;
                                end
                            end
                        elseif strcmp(subfold, "SE000005") 
                            imageCBV{x} = uint8(sortImages{x});
                            imageCBV{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 
                            
                            if strcmp(mapName, 'MTT')
        %                         subplot(1,3,1), imshow(MTTimages{x});
        %                         %MTTimages{x} = 
        %                         subplot(1,3,2), imshow(imabsdiff(sortImages{x}, MTTimages{x}),[]);
        %                         subplot(1,3,3), imshow(sortImages{x});
                            end

                            if strcmp(mapName, 'CBV')
                                valuesCBV = research.CBV;
                                percentage = str2double(valuesCBV(1));
                                direction = valuesCBV(2);
                                if strcmp(valuesCBV(3), "core")
                                    isCore = 1;
                                elseif strcmp(valuesCBV(3), "penumbra")
                                    isPenumbra = 1;
                                end
                            end
                        elseif strcmp(subfold, "SE000006") && strcmp(mapName, 'TMax')
                            imageTMAX{x} = uint8(sortImages{x});
                            imageTMAX{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 
                            
                            valuesTMax = research.TMax;
                            percentage = str2double(valuesTMax(1));
                            direction = valuesTMax(2);
                            if strcmp(valuesTMax(3), "core")
                                isCore = 1;
                            elseif strcmp(valuesTMax(3), "penumbra")
                                isPenumbra = 1;
                            end
                        elseif strcmp(subfold, "SE000007") && strcmp(mapName, 'TTP')
                            imageTTP{x} = uint8(sortImages{x});
                            imageTTP{x}(:,colorbarPointY:end, :) = 0; % remove colorbar 
                            
                            valuesTTP = research.TTP;
                            percentage = str2double(valuesTTP(1));
                            direction = valuesTTP(2);
                            if strcmp(valuesTTP(3), "core")
                                isCore = 1;
                            elseif strcmp(valuesTTP(3), "penumbra")
                                isPenumbra = 1;
                            end
                        end
                            
                        %% extracting the infarcted areas (penumbra & core)
                        startingColorPixelX = colorbarPointBottomX - int16(((colorbarPointBottomX-colorbarPointTopX)/100)*percentage);
                        
                        if isCore 
                            [tryImage{x}, retMask] = segmentWithKMeanClustering(sortImages{x}, direction, 100, colorbarPointBottomX, colorbarPointTopX, startingColorPixelX, colorbarPointY);
                            coreImage{x} = imfuse(coreImage{x}, tryImage{x}, 'blend');
                            totalCoreMask{x} = totalCoreMask{x} + retMask;
                        elseif isPenumbra
                            [tryImage{x}, retMask] = segmentWithKMeanClustering(sortImages{x}, direction, 100, colorbarPointBottomX, colorbarPointTopX, startingColorPixelX, colorbarPointY);
                            penumbraImage{x} = imfuse(penumbraImage{x}, tryImage{x}, 'blend');
                            totalPenumbraMask{x} = totalPenumbraMask{x} + retMask;
                        end
                        
%                         for indexX=startingColorPixelX:colorbarPointBottomX-1
%                             colorBarPoint = sortImages{x}(indexX,colorbarPointY,:);
%                             nextColorBarPoint = sortImages{x}(indexX+1,colorbarPointY,:);
%                             if strcmp(direction, "down")
%                                 tmpMask = sortImages{x}<=colorBarPoint & sortImages{x}>=nextColorBarPoint;
%                             elseif strcmp(direction, "up")
%                                 tmpMask = sortImages{x}==colorBarPoint | sortImages{x}>=nextColorBarPoint;
%                             end
%                             mask = mask | tmpMask;
%                             if strcmp(mapName, 'TTP')
%                                 imshow(mask(:,:,1) & mask(:,:,2) & mask(:,:,3));
%                             end
%                         end
% 
%                         if strcmp(direction, "down")
%                             mask = mask(:,:,1) & mask(:,:,2) & mask(:,:,3);
%                             mask(:,colorbarPointY:end) = 0; % remove colorbar 
%                         elseif strcmp(direction, "up")
%                             mask = ~(mask(:,:,1) & mask(:,:,2) & mask(:,:,3));
%                             mask(:,colorbarPointY:end) = 1; % remove colorbar 
%                             T = rgb2gray(sortImages{x});
%                             blackWhiteMask = imbinarize(T);
%                             blackWhiteMask(:,colorbarPointY:end) = 0; % remove F in the bottom right
% 
%                             mask = ~xor(blackWhiteMask, mask);
%                         end
% 
%                         mask = uint8(mask);
%                         mask = cat(3, mask, mask, mask);
%                         
%                         maskPenumbra = maskPenumbra + mask*isPenumbra;
%                         maskCore = maskCore + mask*isCore;
%                         
%                         combinedResearchCoreMaks{x} = combinedResearchCoreMaks{x} + mask(:,:,1)*isCore;
%                         combinedResearchPenumbraMaks{x} = combinedResearchPenumbraMaks{x} + mask(:,:,2)*isPenumbra;                        
%                         
%                         tmpMask = mask;
%                         mask(:,:,1) = mask(:,:,1) * 255 * isCore;
%                         mask(:,:,2) = mask(:,:,2) * 255 * isPenumbra;
%                         mask(:,:,3) = 0;
%                        
%                         groundTruthImage{x} = groundTruthImage{x} + mask;
%                         
%                         
%                         tryImage{x} = tryImage{x} + (sortImages{x}.*tmpMask);
                        %%imshow(tryImage{x});
                       
%                         if isCore 
%                             coreImage{x} = mask;
%                         elseif isPenumbra
%                             penumbraImage{x} = mask;
%                         end 
                    end
                    
                    if strcmp(subfold, "SE000007") % last folder  
                        
                        stats = statisticalInfo(stats, suffix, totalPenumbraMask{x}, totalCoreMask{x}, MANUAL_ANNOTATION_FOLDER, patient, x, penumbra_color, core_color);
                        
                        
                        %% call the method proposed by Rasmus to extract the various infarcted regions
%                         outRasmus = RasmusMethod(totalPenumbraMask{x}, totalCoreMask{x}, imageCBV{x}, imageCBF{x}, imageTTP{x}, imageTMAX{x});
%                         
%                         subplot(3,4,1)
%                         imshow(imageCBV{x});
%                         subplot(3,4,2)
%                         imshow(imageCBF{x});
%                         subplot(3,4,3)
%                         imshow(imageTTP{x});
%                         subplot(3,4,4)
%                         imshow(imageTMAX{x});
%                         
%                         for y=[1,2,3,4]
%                             combImg = 0;
%                             for xx=[1,2,3]
%                                 combImg = combImg + outRasmus{xx}(:,:,:,y);
%                             end
%                             
%                             subplot(3,4,4+y)
%                             imshow(combImg)
%                         end
%                         
%                         for xx=[1,2,3]
%                             combImg = 0;
%                             for y=[1,2,3,4]
%                                 combImg = combImg + outRasmus{xx}(:,:,:,y);
%                             end
%                             
%                             subplot(3,4,8+xx)
%                             imshow(combImg)
%                         end
                    end
                
                end
            end
        end
              
        %% Save the ground truth images
        if exist('groundTruthImage', 'var') && exist('combinedResearchCoreMaks', 'var') && exist('combinedResearchPenumbraMaks', 'var')
            
             % create the folders if it don't exist
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH'));
            end
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix));
            else
                if count~=researchesValues.Count
                    continue
                end
            end      
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core'));
            end
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra'));
            end
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/contourns'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/contourns'));
            end
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED'));
            end
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/core'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/core'));
            end
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/penumbra'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/penumbra'));
            end
            if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/contourns'),'dir')
                mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/contourns'));
            end
            
%             researchArray = struct2array(research);
%             
%             for indexImg=1:numel(tryImage)
%             %for indexImg=1:numel(groundTruthImage)
%                
%                 pIndex = patient(end-1:end);
%                 name = num2str(indexImg);
%                 if length(name) == 1
%                     name = strcat('0', name);
%                 end
% 
%                 I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
%                 Igray = rgb2gray(I);
%                 I_penumbra = Igray==penumbra_color; % PENUMBRA COLOR
%                 I_core = Igray==core_color; % CORE COLOR
%                 
%                 saveCombInfarctedRegions = imfuse(penumbraImage{indexImg}, coreImage{indexImg}, 'blend');
%                 saveCombInfarctedRegions(saveCombInfarctedRegions==64) = 255;
%                 coreElement = sum(researchArray=="core");
%                 penumbraElement = sum(researchArray=="penumbra");
%                 CI = saveCombInfarctedRegions .* uint8(totalCoreMask{indexImg}>=coreElement);
%                 CI(CI==0)=255;
%                 PI = saveCombInfarctedRegions .* uint8(totalPenumbraMask{indexImg}>=penumbraElement);
%                 PI(PI==0)=255;
%                 
%                 %figure, imshow(tryImage{indexImg});
%                 figure, imshow(saveCombInfarctedRegions);
%                 hold on
%                 visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
%                 visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
%                 print(figure(1), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/contourns/', name, '_', suffix, '_contourns.png'));
% 
%                 %% save the image + the contourn for penumbra and core
%                 imwrite(saveCombInfarctedRegions, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/', name, '_', suffix, '.png'))
%                 %imwrite(tryImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/', name, '_', suffix, '.png'))
%                 
%                 if saveCore
% %                     figure, imshow(coreImage{indexImg});
%                     figure, imshow(CI);
%                     hold on
%                     visboundaries(I_core,'Color',[1,1,1] * (penumbra_color/255)); 
%                     print(figure(2), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_contourns.png'));
% 
% %                     imwrite(coreImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_core.png'))
%                     imwrite(CI, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_core.png'))
%                 end
% 
%                 if savePenumbra
% %                     figure, imshow(penumbraImage{indexImg});
%                     figure, imshow(PI);
%                     hold on
%                     visboundaries(I_penumbra,'Color',[1,1,1] * (core_color/255)); 
%                     print(figure(3), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_contourns.png'));
% 
% %                     imwrite(penumbraImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
%                     imwrite(PI, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
%                 end
%                 
%                 %% save the combined image
% %                 if count==researchesValues.Count 
% %                     quorum = researchesValues.Count/2 + 1;
% %                     combImage = cat(3, (combinedResearchCoreMaks{indexImg} >= quorum)*255, (combinedResearchPenumbraMaks{indexImg} >= quorum)*255, uint8(zeros(size(combinedResearchPenumbraMaks{indexImg}))));
% %                     figure, imshow(combImage);
% %                     hold on
% %                     visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
% %                     visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
% %                     print(figure(4), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/contourns/', name, '_contourns.png'));
% % 
% %                     imshow(combImage);
% %                     imwrite(combImage, strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/', name, '.png'))
% %                 end
% 
%                 
%                 close all;
%             end
        end
    end
    
    
    
end

stats.Properties.VariableNames = {'name' 'tn_p' 'fn_p' 'fp_p' 'tp_p' 'tn_c' 'fn_c' 'fp_c' 'tp_c' 'tn_pc' 'fn_pc' 'fp_pc' 'tp_pc' ...
    'tn_p_nb' 'fn_p_nb' 'fp_p_nb' 'tp_p_nb' 'tn_c_nb' 'fn_c_nb' 'fp_c_nb' 'tp_c_nb' 'tn_pc_nb' 'fn_pc_nb' 'fp_pc_nb' 'tp_pc_nb' 'auc_p' 'auc_c' 'auc_pc'};

G = findgroups(stats.name);
names = unique(stats.name);

stats = splitapply(@sum, [stats.tn_p, stats.fn_p, stats.fp_p, stats.tp_p, ...
    stats.tn_c, stats.fn_c, stats.fp_c, stats.tp_c, stats.tn_c, stats.fn_c, stats.fp_c, stats.tp_c, ...
    stats.tn_p_nb, stats.fn_p_nb, stats.fp_p_nb, stats.tp_p_nb, stats.tn_c_nb, stats.fn_c_nb, stats.fp_c_nb, stats.tp_c_nb, ...
    stats.tn_pc_nb, stats.fn_pc_nb, stats.fp_pc_nb, stats.tp_pc_nb], G);

stats = splitvars(stats);
stats = [stats string(names)];
stats.Properties.VariableNames = {'name' 'tn_p' 'fn_p' 'fp_p' 'tp_p' 'tn_c' 'fn_c' 'fp_c' 'tp_c' 'tn_pc' 'fn_pc' 'fp_pc' 'tp_pc' ...
    'tn_p_nb' 'fn_p_nb' 'fp_p_nb' 'tp_p_nb' 'tn_c_nb' 'fn_c_nb' 'fp_c_nb' 'tp_c_nb' 'tn_pc_nb' 'fn_pc_nb' 'fp_pc_nb' 'tp_pc_nb' 'auc_p' 'auc_c' 'auc_pc'};

stats.accuracy_p = (stats.tn_p + stats.tp_p +1e-07)./(stats.tn_p + stats.fn_p + stats.fp_p + stats.tp_p +1e-07);
stats.accuracy_c = (stats.tn_c + stats.tp_c +1e-07)./(stats.tn_c + stats.fn_c + stats.fp_c + stats.tp_c +1e-07);
stats.accuracy_pc = (stats.tn_pc + stats.tp_pc +1e-07)./(stats.tn_pc + stats.fn_pc + stats.fp_pc + stats.tp_pc +1e-07);
stats.accuracy_p_nb = (stats.tn_p_nb + stats.tp_p_nb +1e-07)./(stats.tn_p_nb + stats.fn_p_nb + stats.fp_p_nb + stats.tp_p_nb +1e-07);
stats.accuracy_c_nb = (stats.tn_c_nb + stats.tp_c_nb +1e-07)./(stats.tn_c_nb + stats.fn_c_nb + stats.fp_c_nb + stats.tp_c_nb +1e-07);
stats.accuracy_pc_nb = (stats.tn_pc_nb + stats.tp_pc_nb +1e-07)./(stats.tn_pc_nb + stats.fn_pc_nb + stats.fp_pc_nb + stats.tp_pc_nb +1e-07);

stats.precision_p = (stats.tp_p+1e-07)./(stats.fp_p + stats.tp_p+1e-07);
stats.precision_c = (stats.tp_c+1e-07)./(stats.fp_c + stats.tp_c+1e-07);
stats.precision_pc = (stats.tp_pc+1e-07)./(stats.fp_pc + stats.tp_pc+1e-07);
stats.precision_p_nb = (stats.tp_p_nb+1e-07)./(stats.fp_p_nb + stats.tp_p_nb+1e-07);
stats.precision_c_nb = (stats.tp_c_nb+1e-07)./(stats.fp_c_nb + stats.tp_c_nb+1e-07);
stats.precision_pc_nb = (stats.tp_pc_nb+1e-07)./(stats.fp_pc_nb + stats.tp_pc_nb+1e-07);

stats.specificity_p = (stats.tn_p+1e-07)./(stats.fp_p + stats.tn_p+1e-07);
stats.specificity_c = (stats.tn_c+1e-07)./(stats.fp_c + stats.tn_c+1e-07);
stats.specificity_pc = (stats.tn_pc+1e-07)./(stats.fp_pc + stats.tn_pc+1e-07);
stats.specificity_p_nb = (stats.tn_p_nb+1e-07)./(stats.fp_p_nb + stats.tn_p_nb+1e-07);
stats.specificity_c_nb = (stats.tn_c_nb+1e-07)./(stats.fp_c_nb + stats.tn_c_nb+1e-07);
stats.specificity_pc_nb = (stats.tn_pc_nb+1e-07)./(stats.fp_pc_nb + stats.tn_pc_nb+1e-07);

stats.sensitivity_p = (stats.tp_p+1e-07)./(stats.fn_p + stats.tp_p+1e-07);
stats.sensitivity_c = (stats.tp_c+1e-07)./(stats.fn_c + stats.tp_c+1e-07);
stats.sensitivity_pc = (stats.tp_pc+1e-07)./(stats.fn_pc + stats.tp_pc+1e-07);
stats.sensitivity_p_nb = (stats.tp_p_nb+1e-07)./(stats.fn_p_nb + stats.tp_p_nb+1e-07);
stats.sensitivity_c_nb = (stats.tp_c_nb+1e-07)./(stats.fn_c_nb + stats.tp_c_nb+1e-07);
stats.sensitivity_pc_nb = (stats.tp_pc_nb+1e-07)./(stats.fn_pc_nb + stats.tp_pc_nb+1e-07);

stats.f1_p = (2.*(stats.precision_p .* stats.sensitivity_p) +1e-07)./(stats.precision_p + stats.sensitivity_p+1e-07);
stats.f1_c = (2.*(stats.precision_c .* stats.sensitivity_c) +1e-07)./(stats.precision_c + stats.sensitivity_c+1e-07);
stats.f1_pc = (2.*(stats.precision_pc .* stats.sensitivity_pc) +1e-07)./(stats.precision_pc + stats.sensitivity_pc+1e-07);
stats.f1_p_nb = (2.*(stats.precision_p_nb .* stats.sensitivity_p_nb) +1e-07)./(stats.precision_p_nb + stats.sensitivity_p_nb+1e-07);
stats.f1_c_nb = (2.*(stats.precision_c_nb .* stats.sensitivity_c_nb) +1e-07)./(stats.precision_c_nb + stats.sensitivity_c_nb+1e-07);
stats.f1_pc_nb = (2.*(stats.precision_pc_nb .* stats.sensitivity_pc_nb) +1e-07)./(stats.precision_pc_nb + stats.sensitivity_pc_nb+1e-07);

stats.jaccard_p = (stats.f1_p+1e-07)./(2-stats.f1_p+1e-07);
stats.jaccard_c = (stats.f1_c+1e-07)./(2-stats.f1_c+1e-07);
stats.jaccard_pc = (stats.f1_pc+1e-07)./(2-stats.f1_pc+1e-07);
stats.jaccard_p_nb = (stats.f1_p_nb+1e-07)./(2-stats.f1_p_nb+1e-07);
stats.jaccard_c_nb = (stats.f1_c_nb+1e-07)./(2-stats.f1_c_nb+1e-07);
stats.jaccard_pc_nb = (stats.f1_pc_nb+1e-07)./(2-stats.f1_pc_nb+1e-07);

% rowsStats = splitapply(@mean,...
%     [stats.accuracy_p, stats.accuracy_c, stats.accuracy_pc, ...
%     stats.precision_p, stats.precision_c, stats.precision_pc, ...
%     stats.specificity_p, stats.specificity_c, stats.specificity_pc, ...
%     stats.sensitivity_p, stats.sensitivity_c, stats.sensitivity_pc, ...
%     stats.f1_p, stats.f1_c, stats.f1_pc,stats.jaccard_p, stats.jaccard_c, stats.jaccard_pc, ...
%     stats.auc_p, stats.auc_c, stats.auc_pc],G);
% 
% ALLSTATS = [rowsStats string(names)];
% ALLSTATS(end+1,:) = {'accuracy_p' 'accuracy_c' 'accuracy_pc' ...
%     'precision_p' 'precision_c' 'precision_pc' ...
%     'specificity_p' 'specificity_c' 'specificity_pc' ...
%     'sensitivity_p' 'sensitivity_c' 'sensitivity_pc' ...
%     'f1_p' 'f1_c' 'f1_pc' 'jaccard_p' 'jaccard_c' 'jaccard_pc' ...
%     'stats.auc_p' 'stats.auc_c' 'stats.auc_pc' 'name'};
% 
% disp(ALLSTATS);

save(strcat(saveFolder, "allstats.mat"));







