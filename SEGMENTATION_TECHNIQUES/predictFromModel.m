function [predictions,statsClassific,pred_img] = predictFromModel(Mdl,data,nImages,predictionMasks,step,STEPS, ...
    MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING, ...
    statsClassific,suffix,patient,saveFolder,saveSubFolder,flagToSaveImage,SHOW_IMAGES,image_suffix)
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
    imgPredicted = reshape(lb_tmp(:,t), [512,512]) .* logical(predictionMasks{step}{1,t});
    % map the prediction with the real colors
    
    if sum(fieldnames(Mdl)=="SupportVectors")
        if strcmp(Mdl.ResponseName, "outputPenumbraCore")
            imgPredicted(imgPredicted==1) = penumbra_color;
        elseif strcmp(Mdl.ResponseName, "outputCore")
            imgPredicted(imgPredicted==1) = core_color;
        end
    else
        imgPredicted(imgPredicted==2) = penumbra_color;
        imgPredicted(imgPredicted==3) = core_color;
    end
    % fill the empty spaces (if any)
    imgPredicted = imfill(imgPredicted);
    
    pred_img{1,t} = imgPredicted;
    
    %% get contourn from manual annotaions
    name = num2str(t);
    if length(name) == 1
        name = strcat('0', name);
    end
    
    % get the manual annotation image
    if SUPERVISED_LEARNING
        Igray = imread(strcat(MANUAL_ANNOTATION_FOLDER, patient(1:10), '/', name, image_suffix));
        if ndims(Igray)==3
            Igray = rgb2gray(Igray);
        end
        I_penumbra = Igray==penumbra_color; % PENUMBRA COLOR
        I_core = Igray==core_color; % CORE COLOR
    end
    
    if flagToSaveImage
        if SHOW_IMAGES % show the iamge and hold it for later (the boundaries)
            figure, imshow(imgPredicted,[]);  
            hold on;
        end

        regions_params = [struct(), struct()];
        %% regions_params(1) == penumbra 
        regions_params(1).mask = zeros(512);
        regions_params(1).name = "penumbra";
        regions_params(1).threshold = 160;
        regions_params(1).area = 150;
        regions_params(1).color = 'g';
        %% regions_params(1) == core 
        regions_params(2).mask = zeros(512);
        regions_params(2).name = "core";
        regions_params(2).threshold = 250;
        regions_params(2).area = 10;
        regions_params(2).color = 'r';
        
        %% find the masks for penumbra and core based on the information above
        for ri = 1:size(regions_params,2)
            region = regions_params(ri);
            
            % this is good for saving the one step model predictions and 
            % the one for generated for the core in two steps 
            imageToUse = imgPredicted; 
            if STEPS >1 && step>1 % we are in the 2 STEPS model
                if ri == 1 % penumbra
                    imageToUse = predictionMasks{STEPS}{1,t};
                end
            end
            
            
            mask = imageToUse >= region.threshold;
            labeledImage = bwlabel(mask,8);
            r = regionprops(mask);
            allareas = [r.Area];

            area_idx = (allareas >= region.area);
            if sum(area_idx)>0
                keep_idx = find(area_idx);
                mask = zeros(size(mask));
                for x=keep_idx
                    mask = mask + (labeledImage==x);
                end
                
                regions_params(ri).mask = mask;
                
                %% TODO: check this part... it does NOT seems correct to do this
%                 mask = bwconvhull(mask, 'objects');
%                 bw = activecontour(imageToUse, mask, 400, 'edge');
%                 regions_params(ri).mask = bw; % set the mask to the correct region
                
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
                MANUAL_ANNOTATION_FOLDER, patient(1:10), t, penumbra_color, core_color, 1, image_suffix);
            
            disp(statsClassific{end,1:5});
            
            %% save the image with boundaries
            if SHOW_IMAGES
                visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
                visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
                for sf = saveSubFolder
                    print(figure(t), '-dpng', strcat(saveFolder, patient, sf, suffix, "_", name, ".png")); 
                end
            else % save the masks (penumbra & core)
                for ri = 1:size(regions_params,2)
                    for sf = saveSubFolder
                        if strcmp(sf, saveSubFolder{1}) % Annotations
                            imwrite(regions_params(ri).mask, strcat(saveFolder, patient, sf, suffix, "_", name, "_", regions_params(ri).name, ".png"));
                        end
                    end
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

