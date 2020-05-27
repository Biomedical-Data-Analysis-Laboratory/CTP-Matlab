function saveThresholdingImages(saveFolder,patient,suffix,research,tryImage,...
    MANUAL_ANNOTATION_FOLDER,penumbraImage,coreImage,penumbra_color,core_color,...
    totalCoreMask,totalPenumbraMask,saveCore,savePenumbra,dayFold)
%SAVETHRESHOLDINGIMAGES Save the thresholding images
%   Function that save the thresholding images based on the research values

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create the folders if they don't exist
mainSaveFolder = strcat(saveFolder, patient, "\", dayFold, "\");

if ~isfolder(mainSaveFolder)
    mkdir(mainSaveFolder);
end
if ~isfolder(strcat(mainSaveFolder, suffix))
    mkdir(strcat(mainSaveFolder, suffix));
end      
if ~ isfolder(strcat(mainSaveFolder, suffix, '/core'))
    mkdir(strcat(mainSaveFolder, suffix, '/core'));
end
if ~isfolder(strcat(mainSaveFolder, suffix, '/penumbra'))
    mkdir(strcat(mainSaveFolder, suffix, '/penumbra'));
end
if ~isfolder(strcat(mainSaveFolder, suffix, '/contourns'))
    mkdir(strcat(mainSaveFolder, suffix, '/contourns'));
end
%     if ~isfolder(strcat(mainSaveFolder, '_COMBINED'))
%         mkdir(strcat(mainSaveFolder, '_COMBINED'));
%     end
%     if ~isfolder(strcat(mainSaveFolder, '_COMBINED/core'))
%         mkdir(strcat(mainSaveFolder, '_COMBINED/core'));
%     end
%     if ~ isfolder(strcat(mainSaveFolder, '_COMBINED/penumbra'))
%         mkdir(strcat(mainSaveFolder, '_COMBINED/penumbra'));
%     end
%     if ~isfolder(strcat(mainSaveFolder, '_COMBINED/contourns'))
%         mkdir(strcat(mainSaveFolder, '_COMBINED/contourns'));
%     end

researchArray = struct2array(research);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for all the images
for indexImg=1:numel(tryImage)

    pIndex = patient(end-1:end);
    name = num2str(indexImg);
    if length(name) == 1
        name = strcat('0', name);
    end

    filename = strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png');
    if isfile(filename)
        I = imread(filename);
        Igray = rgb2gray(I);
    else
        filename = strcat(MANUAL_ANNOTATION_FOLDER, patient, "\", dayFold, "\", name, '.png');
        Igray = imread(filename);
    end

    I_penumbra = Igray==penumbra_color; % PENUMBRA COLOR
    I_core = Igray==core_color; % CORE COLOR

    saveCombInfarctedRegions = imfuse(penumbraImage{indexImg}, coreImage{indexImg}, 'blend');
    saveCombInfarctedRegions(saveCombInfarctedRegions==64) = 255;
    coreElement = sum(researchArray=="core");
    penumbraElement = sum(researchArray=="penumbra");
%     CI = saveCombInfarctedRegions .* uint8(totalCoreMask{indexImg}>=coreElement);
%     CI(CI==0)=255;
%     PI = saveCombInfarctedRegions .* uint8(totalPenumbraMask{indexImg}>=penumbraElement);
%     PI(PI==0)=255;
% 
%     figure, imshow(tryImage{indexImg});
    figure, imshow(saveCombInfarctedRegions);
    hold on
    visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
    visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
    print(figure(1), '-dpng', strcat(mainSaveFolder, suffix, '/contourns/', name, '_', suffix, '_contourns.png'));

    %% save the image + the contourn for penumbra and core
    imwrite(saveCombInfarctedRegions, strcat(mainSaveFolder, suffix, '/', name, '_', suffix, '.png'))
%     imwrite(tryImage{indexImg}, strcat(mainSaveFolder, suffix, '/', name, '_', suffix, '.png'))

    if saveCore
        figure, imshow(totalCoreMask{indexImg});
%         figure, imshow(CI);
        hold on
        visboundaries(I_core,'Color',[1,1,1] * (penumbra_color/255)); 
        print(figure(2), '-dpng', strcat(mainSaveFolder, suffix, '/core/', name, '_', suffix, '_contourns.png'));

%         imwrite(coreImage{indexImg}, strcat(mainSaveFolder, suffix, '/core/', name, '_', suffix, '_core.png'))
        imwrite(totalCoreMask{indexImg}, strcat(mainSaveFolder, suffix, '/core/', name, '_', suffix, '_core.png'))
    end

    if savePenumbra
        penumbraWithoutCore = totalPenumbraMask{indexImg}-totalCoreMask{indexImg};
        figure, imshow(penumbraWithoutCore);
        %figure, imshow(PI);
        hold on
        visboundaries(I_penumbra,'Color',[1,1,1] * (core_color/255)); 
        print(figure(3), '-dpng', strcat(mainSaveFolder, suffix, '/penumbra/', name, '_', suffix, '_contourns.png'));

%         imwrite(penumbraImage{indexImg}, strcat(mainSaveFolder, suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
        imwrite(penumbraWithoutCore, strcat(mainSaveFolder, suffix, '/penumbra/', name, '_', suffix, '_penumbra.png'))
    end

    %% save the combined image
%     if count==researchesValues.Count 
%         quorum = researchesValues.Count/2 + 1;
%         combImage = cat(3, (combinedResearchCoreMaks{indexImg} >= quorum)*255, (combinedResearchPenumbraMaks{indexImg} >= quorum)*255, uint8(zeros(size(combinedResearchPenumbraMaks{indexImg}))));
%         figure, imshow(combImage);
%         hold on
%         visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
%         visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
%         print(figure(4), '-dpng', strcat(mainSaveFolder, '_COMBINED/contourns/', name, '_contourns.png'));
% 
%         imshow(combImage);
%         imwrite(combImage, strcat(mainSaveFolder, '_COMBINED/', name, '.png'))
%     end


    close all;
end
end

