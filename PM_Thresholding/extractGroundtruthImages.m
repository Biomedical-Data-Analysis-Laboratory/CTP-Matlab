clear;
close all;

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\';
USER = strcat(USER, 'Luca\');
% USER = strcat(USER, '2921329\');

%% CONSTANTS
PARAMETRIC_IMAGES_TO_ANALYZE = 1; % to read the proper images (parametric maps images (png) or DICOM files)
SAVE_PAR_MAPS = 0; 
% to run also the penumbra-core statistics
flag_PENUMBRACORE = 1;
DIFFERENT_PERCENTAGES = 0;
HOME = strcat(USER, 'OneDrive - Universitetet i Stavanger/');
perfusionCTFolder = strcat(HOME, 'PhD/Patients/');

if PARAMETRIC_IMAGES_TO_ANALYZE
    perfusionCTFolder = strcat(perfusionCTFolder, 'extracted_info/');
    saveFolder = perfusionCTFolder;
else
    saveFolder = strcat(perfusionCTFolder, 'extracted_info/');
end

MANUAL_ANNOTATION_FOLDER = strcat(USER, 'OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/');

patients = ["PA02","PA03","PA04", "PA05", "PA06", "PA07", "PA08", "PA09", "PA10", "PA11"]; 
% brain , CBF, CBV, TMax, TTP
subfolds = ["SE000003", "SE000004", "SE000005", "SE000006", "SE000007"]; 

% flag for the leave-one-out prediction (predict with other models!)
totalTableData = table(); 
totalData = cell(1,numel(patients));
totalNImages = cell(1,numel(patients));
PREDICT_WITH_OTHER_MODElS = 1;

%% colors index
colorbarPointTopX = 129;
colorbarPointBottomX = 384;
colorbarPointY = 436;
penumbra_color = 76;
core_color = 150;


%% values for each parametric map [perc(%), up/down, core/penumbra]

researchesValues = containers.Map;
researchesValues('superpixelstree') = struct('cluster',"yes"); % no need of thresholding values!

% researchesValues('Cereda_2015') = struct('CBF', [38, "down", "core", ""], 'TMax', [33, "up", "penumbra", ""]);
% researchesValues('Wintermark_2006') = struct('CBV', [33, "down", "core", ""]); %, 'MTT', [6, "up", "penumbra"]);
% researchesValues('Ma_Cambell_2019') = struct('CBF', [30, "down", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
% % % researchesValues('Bivard_Lin_2014') = struct('CBF', [30, "down", "core"], 'TMax', [50, "up", "penumbra"]);
% % 
% researchesValues('Shaefer_2014') = struct('CBF', [15, "down", "core", ""], 'CBV', [30, "down", "core", ""]);
% % 
% % % researchesValues('Bivard_2014') = struct('CBF', [50, "down", "core"], 'TTP', [75, "up", "penumbra"]);
% researchesValues('Cambell_2012') = struct('CBF', [31, "down", "core", 10], 'TTP', [20, "up", "core", ""], 'TMax', [50, "up", "penumbra", ""]);
% researchesValues('Murphy_2006') = struct('CBF', [13.3, "down", "core", ""], 'CBV', [18.6, "down", "core", 5], 'CBF_2', [25, "down", "penumbra", ""], 'CBV_2', [36, "down", "penumbra", 10]);
% % % researchesValues('Shaefer_2006') = struct('CBF', [17.92, "down", "penumbra"], 'CBV', [24.5, "down", "core"]);
% % % researchesValues('Shaefer_2006_2') = struct('CBF', [8.8, "down", "core"], 'CBV', [49, "down", "penumbra"]);
% % % researchesValues('Bivard') = struct('CBF', [50, "down", "core"], 'TTP', [75, "down", "penumbra"]);
% % %researchesValues('COMB_Wintermark_Shaefer') = struct('CBV', [24.5, "down", "core"], 'CBF', [30, "down", "penumbra"], 'TMax', [50, "up", "penumbra"], 'TTP', [75, "up", "penumbra"]);


stats = table();
statsClassific = table();

MODELS = cell(1,numel(patients));
%% for each suffix 
for suff = researchesValues.keys
    count = 0;
    
    suffix = suff{1};
    research = researchesValues(suffix);
    parametricMaps = fieldnames(research);
    
    
    %% for each patient
    for p=1:numel(patients)
        percToLoop = 0:10:100;
        if ~DIFFERENT_PERCENTAGES
            percToLoop = -1;
        end
        
        for perce=percToLoop
        tic
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
                sortImages = cell(5,n); % 5 == number of parametric maps + enhanced image
                skullMasks = cell(5,n);
            end

            %% get the information of the various map for a specific subfolder
            [combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks, ...
                penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,stats,data,tableData,nImages] = ...
                getInfoFromSubfold(subfold,PARAMETRIC_IMAGES_TO_ANALYZE,research,folderPath,patient,PREDICT_WITH_OTHER_MODElS,... 
                MANUAL_ANNOTATION_FOLDER,saveFolder,colorbarPointY,parametricMaps,suffix,...
                colorbarPointBottomX,colorbarPointTopX,penumbra_color,core_color,flag_PENUMBRACORE,SAVE_PAR_MAPS,count,perce, ...
                combinedResearchCoreMaks,combinedResearchPenumbraMaks,tryImage,groundTruthImage,coreImage,sortImages,skullMasks, ...
                penumbraImage,totalCoreMask,totalPenumbraMask,imageCBV,imageCBF,imageTTP,imageTMAX,stats,statsClassific,MODELS);
        
            if strcmp(subfold, "SE000007")
                % concatenate the data information in a table
                totalTableData = [totalTableData; tableData];
                totalData{1,p} = data;
                totalNImages{1,p} = nImages;
            end
        end
        
        toc
        %% Save the ground truth images
%         if exist('groundTruthImage', 'var') && exist('combinedResearchCoreMaks', 'var') && exist('combinedResearchPenumbraMaks', 'var')
%             
%              % create the folders if it don't exist
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH'));
%             end
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix));
% %             else
% %                 if count~=researchesValues.Count
% %                     continue
% %                 end
%             end      
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core'));
%             end
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra'));
%             end
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/contourns'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/contourns'));
%             end
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED'));
%             end
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/core'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/core'));
%             end
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/penumbra'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/penumbra'));
%             end
%             if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/contourns'),'dir')
%                 mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/contourns'));
%             end
%             
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
% %                 CI = saveCombInfarctedRegions .* uint8(totalCoreMask{indexImg}>=coreElement);
% %                 CI(CI==0)=255;
% %                 PI = saveCombInfarctedRegions .* uint8(totalPenumbraMask{indexImg}>=penumbraElement);
% %                 PI(PI==0)=255;
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
%                     figure, imshow(totalCoreMask{indexImg});
% %                     figure, imshow(CI);
%                     hold on
%                     visboundaries(I_core,'Color',[1,1,1] * (penumbra_color/255)); 
%                     print(figure(2), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_contourns.png'));
% 
% %                     imwrite(coreImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_core.png'))
%                     imwrite(totalCoreMask{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_core.png'))
%                 end
% 
%                 if savePenumbra
%                     penumbraWithoutCore = totalPenumbraMask{indexImg}-totalCoreMask{indexImg};
%                     figure, imshow(penumbraWithoutCore);
%                     %figure, imshow(PI);
%                     hold on
%                     visboundaries(I_penumbra,'Color',[1,1,1] * (core_color/255)); 
%                     print(figure(3), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_contourns.png'));
% 
% %                     imwrite(penumbraImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
%                     imwrite(penumbraWithoutCore, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
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
%         end
        
        end
    end
    
    if isfield(research, "cluster") && strcmp(research.cluster, "yes")
        %% for each patient
        for p=1:numel(patients)
            
            patient = convertStringsToChars(patients(p));
            pIndex = patient(end-1:end);
            if ~ exist(strcat(saveFolder, patient, '/CLUSTER_OTHER_PATIENTS'),'dir')
                mkdir(strcat(saveFolder, patient, '/CLUSTER_OTHER_PATIENTS'));
            end
            
            currentTableIndex = (totalTableData.patient ~= str2double(pIndex));
            currentTable = totalTableData(currentTableIndex,:);
            %% train the model 
            t = templateTree('MaxNumSplits',150);
            Mdl = fitcensemble(currentTable,"output", "Method","AdaBoostM2", "Learner",t, 'Weights', "weights");
            MODELS{1,str2double(pIndex)} = Mdl; %add the Mdl to MODELS for predictions without ground truth
            
            new_suffix = strcat(suffix, "_", pIndex);
            
            [predictions,statsClassific] = predictFromModel(Mdl,totalData{1,str2double(p)},totalNImages{1,str2double(p)}, ...
                MANUAL_ANNOTATION_FOLDER,pIndex,penumbra_color,core_color, ...
                statsClassific,new_suffix,patient,saveFolder, '/CLUSTER_OTHER_PATIENTS/');
            
            % display MEAN SQUARE ERROR (MSE)
            disp("MSE:");
            disp(immse(output(:), predictions));
        end
    end
end


%% save the statistic information (both for the classification approach and the thresholding approach
calculateStats(statsClassific,saveFolder,"statsClassific.mat");
% calculateStats(stats,saveFolder,"Cambell_AUC10_allstats.mat");

if ~PREDICT_WITH_OTHER_MODElS
    save(strcat(saveFolder,"MODELS.mat"), 'MODELS', '-v7.3');
end






