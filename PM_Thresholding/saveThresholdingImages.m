function saveThresholdingImages(saveFolder,patient,suffix,research,tryImage,...
    MANUAL_ANNOTATION_FOLDER,penumbraImage,coreImage,penumbra_color,core_color,...
    totalCoreMask,totalPenumbraMask,saveCore,savePenumbra)
%SAVETHRESHOLDINGIMAGES Summary of this function goes here
%   Detailed explanation goes here

    %if exist('groundTruthImage', 'var') && exist('combinedResearchCoreMaks', 'var') && exist('combinedResearchPenumbraMaks', 'var')

         % create the folders if it don't exist
        if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH'),'dir')
            mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH'));
        end
        if ~ exist(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix),'dir')
            mkdir(strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix));
    %             else
    %                 if count~=researchesValues.Count
    %                     continue
    %                 end
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

        researchArray = struct2array(research);

        for indexImg=1:numel(tryImage)
        %for indexImg=1:numel(groundTruthImage)

            pIndex = patient(end-1:end);
            name = num2str(indexImg);
            if length(name) == 1
                name = strcat('0', name);
            end

            I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
            Igray = rgb2gray(I);
            I_penumbra = Igray==penumbra_color; % PENUMBRA COLOR
            I_core = Igray==core_color; % CORE COLOR

            saveCombInfarctedRegions = imfuse(penumbraImage{indexImg}, coreImage{indexImg}, 'blend');
            saveCombInfarctedRegions(saveCombInfarctedRegions==64) = 255;
            coreElement = sum(researchArray=="core");
            penumbraElement = sum(researchArray=="penumbra");
    %                 CI = saveCombInfarctedRegions .* uint8(totalCoreMask{indexImg}>=coreElement);
    %                 CI(CI==0)=255;
    %                 PI = saveCombInfarctedRegions .* uint8(totalPenumbraMask{indexImg}>=penumbraElement);
    %                 PI(PI==0)=255;

            %figure, imshow(tryImage{indexImg});
            figure, imshow(saveCombInfarctedRegions);
            hold on
            visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
            visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
            print(figure(1), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/contourns/', name, '_', suffix, '_contourns.png'));

            %% save the image + the contourn for penumbra and core
            imwrite(saveCombInfarctedRegions, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/', name, '_', suffix, '.png'))
            %imwrite(tryImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/', name, '_', suffix, '.png'))

            if saveCore
                figure, imshow(totalCoreMask{indexImg});
    %                     figure, imshow(CI);
                hold on
                visboundaries(I_core,'Color',[1,1,1] * (penumbra_color/255)); 
                print(figure(2), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_contourns.png'));

    %                     imwrite(coreImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_core.png'))
                imwrite(totalCoreMask{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/core/', name, '_', suffix, '_core.png'))
            end

            if savePenumbra
                penumbraWithoutCore = totalPenumbraMask{indexImg}-totalCoreMask{indexImg};
                figure, imshow(penumbraWithoutCore);
                %figure, imshow(PI);
                hold on
                visboundaries(I_penumbra,'Color',[1,1,1] * (core_color/255)); 
                print(figure(3), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_contourns.png'));

    %                     imwrite(penumbraImage{indexImg}, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
                imwrite(penumbraWithoutCore, strcat(saveFolder, patient, '/GROUNDTRUTH/', suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
            end

            %% save the combined image
    %                 if count==researchesValues.Count 
    %                     quorum = researchesValues.Count/2 + 1;
    %                     combImage = cat(3, (combinedResearchCoreMaks{indexImg} >= quorum)*255, (combinedResearchPenumbraMaks{indexImg} >= quorum)*255, uint8(zeros(size(combinedResearchPenumbraMaks{indexImg}))));
    %                     figure, imshow(combImage);
    %                     hold on
    %                     visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
    %                     visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
    %                     print(figure(4), '-dpng', strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/contourns/', name, '_contourns.png'));
    % 
    %                     imshow(combImage);
    %                     imwrite(combImage, strcat(saveFolder, patient, '/GROUNDTRUTH/_COMBINED/', name, '.png'))
    %                 end


            close all;
        end
    %end
end

