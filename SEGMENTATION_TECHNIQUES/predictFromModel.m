function [predictions,statsClassific,pred_img] = predictFromModel(Mdl,data,nImages,predictionMasks, ...
    MANUAL_ANNOTATION_FOLDER,pIndex,penumbra_color,core_color,SUPERVISED_LEARNING, ...
    statsClassific,suffix,patient,saveFolder,saveSubFolder,flagToSaveImage,SHOW_IMAGES)
%PREDICTFROMMODEL Summary of this function goes here
%   Detailed explanation goes here

maxClasses = 4;
valueClasses = [0, 85, 170, 255];
pred_img = cell(1,nImages);

%% prediction images based on the model
predictions = predict(Mdl,data); 
if ~isa(predictions,'double') % if the predictions is a char
    predictions = str2double(predictions);
end

lb_tmp = reshape(predictions,[512*512,nImages]);

for t=1:nImages
    % multiply the lb_tmp predicted with the prediction mask!
    imgPredicted = reshape(lb_tmp(:,t), [512,512]) .* predictionMasks{1,t};
    pred_img{1,t} = mat2gray(imfill(imgPredicted)) .* 255;

    classPixel = unique(pred_img{1,t});
    if numel(classPixel) < maxClasses
        for c = 1:numel(classPixel)
            class_index = find(pred_img{1,t}==classPixel(c));
            pred_img{1,t}(class_index) = valueClasses(c);
        end
    end
    
    %% get contourn from manual annotaions
    name = num2str(t);
    if length(name) == 1
        name = strcat('0', name);
    end
    
    if SUPERVISED_LEARNING
        I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
        Igray = rgb2gray(I);
        I_penumbra = Igray==penumbra_color; % PENUMBRA COLOR
        I_core = Igray==core_color; % CORE COLOR
    end
    
    if flagToSaveImage
        if SHOW_IMAGES
            figure, imshow(pred_img{1,t},[]);  
            hold on;
        end

        regions_params = [struct(), struct()];
        %% regions_params(1) == penumbra 
        regions_params(1).mask = zeros(512);
        regions_params(1).name = "penumbra";
        regions_params(1).threshold = 85;
        regions_params(1).area = 200;
        regions_params(1).color = 'g';
        %% regions_params(1) == core 
        regions_params(2).mask = zeros(512);
        regions_params(2).name = "core";
        regions_params(2).threshold = 170;
        regions_params(2).area = 100;
        regions_params(2).color = 'r';
        %%
        for ri = 1:size(regions_params,2)
            region = regions_params(ri);
            mask = pred_img{1,t} >= region.threshold;
            labeledImage = bwlabel(mask,8);
            r = regionprops(mask);
            allareas = [r.Area];

            area_idx = (allareas > region.area);
            if sum(area_idx)>0
                keep_idx = find(area_idx);
                mask = zeros(size(mask));
                for x=keep_idx
                    mask = mask + (labeledImage==x);
                end
                mask = bwconvhull(mask, 'objects');
                bw = activecontour(pred_img{1,t}, mask, 400, 'edge');
                regions_params(ri).mask = bw; % set the mask to the correct region
                
                if SHOW_IMAGES
                    contour(bw, 1,region.color, 'LineWidth', 1); 
                end
            end
        end

        %% Save the image with boundaries
        if SUPERVISED_LEARNING
            %% get the statistical information for the clssified image compared with the manual annotation
            % return of the function !
            statsClassific = statisticalInfo(statsClassific, suffix, regions_params(1).mask, regions_params(2).mask, ...
                MANUAL_ANNOTATION_FOLDER, patient, t, penumbra_color, core_color, 1);

            %% save the image with boundaries
            if SHOW_IMAGES
                visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
                visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
                for sf = saveSubFolder
                    print(figure(t), '-dpng', strcat(saveFolder, patient, sf, suffix, "_", name, ".png")); 
                end
            end
        else % UNSUPERVISED 
            if SHOW_IMAGES
                for sf = saveSubFolder
                    print(figure(t), '-dpng', strcat(saveFolder, patient, sf, suffix, "_", name, ".png")); 
                end
            else % save the masks (penumbra & core)
                for ri = 1:size(regions_params,2)
                    for sf = saveSubFolder
                        if strcmp(sf, saveSubFolder{2}) % Original
                            imwrite(regions_params(ri).mask, strcat(saveFolder, patient, sf, suffix, "_", name, "_", regions_params(ri).name, ".png"));
                        end
                    end
                end
            end
        end
    end
end

close all;

end

