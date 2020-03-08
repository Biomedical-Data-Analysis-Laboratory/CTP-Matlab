function [predictions,statsClassific] = predictFromModel(Mdl,data,nImages, ...
    MANUAL_ANNOTATION_FOLDER,pIndex,penumbra_color,core_color, ...
    statsClassific,suffix,patient,saveFolder, saveSubFolder)
%PREDICTFROMMODEL Summary of this function goes here
%   Detailed explanation goes here

maxClasses = 4;
valueClasses = [0, 85, 170, 255];
pred_img = cell(1,nImages);

%% prediction images based on the model
predictions = predict(Mdl,data);

% % % MdlSVM_penumbra = fitcsvm(data_penumbra,output_penumbra(:), ...
% % %   'Weights', weights_penumbra(:), 'Verbose',1, 'IterationLimit', 3000, 'Standardize',true);
% % % predSVM_penumbra = predict(MdlSVM_penumbra, data_penumbra);
% % % MdlSVM_core = fitcsvm(data_core,output_core(:), 'Weights', ...
% % %   weights_core(:), 'Verbose',1, 'IterationLimit', 3000, 'Standardize',true);
% % % predSVM_core = predict(MdlSVM_core, data_core);

lb_tmp = reshape(predictions,[512*512,nImages]);

for t=1:nImages
    pred_img{1,t} = mat2gray(imfill(reshape(lb_tmp(:,t), [512,512]))) .* 255;
    classPixel = unique(pred_img{1,t});
    if numel(classPixel) < maxClasses
        for c = 1:numel(classPixel)
            class_index = find(pred_img{1,t}==classPixel(c));
            pred_img{1,t}(class_index) = valueClasses(c);
        end
    end
    
    %% deal with old infactions
%     oldInfaction = find(realValueImages{5,t}==0);
%     maskSkull = find(pred_img{1,t}>0);
%     intersection = intersect(maskSkull, oldInfaction);
%     
%     maskInter = zeros(size(pred_img{1,t}));
%     maskInter(intersection) = 1;
%     maskConv = bwconvhull(maskInter, 'objects');
%     intersApprox = activecontour(maskInter, maskConv, 10, 'edge');
%     idx_approx = find(intersApprox==1);
%     
%     pred_img{1,t}(idx_approx) = classPixel(2); % brain
    
    %% get contourn from manual annotaions
    name = num2str(t);
    if length(name) == 1
        name = strcat('0', name);
    end
    I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
    Igray = rgb2gray(I);
    I_penumbra = Igray==penumbra_color; % PENUMBRA COLOR
    I_core = Igray==core_color; % CORE COLOR
    
    figure, imshow(pred_img{1,t},[]);  
    hold on;

    regions_params = [struct(), struct()];
    %% regions_params(1) == penumbra 
    regions_params(1).mask = zeros(512);
    regions_params(1).threshold = 85;
    regions_params(1).area = 75;
    regions_params(1).color = 'g';
    %% regions_params(1) == core 
    regions_params(2).mask = zeros(512);
    regions_params(2).threshold = 250;
    regions_params(2).area = 75;
    regions_params(2).color = 'r';
    %%
    for ri = 1:size(regions_params,2)
        region = regions_params(ri);
        mask = pred_img{1,t} > region.threshold;
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
            contour(bw, 1,region.color, 'LineWidth', 1); 
        end
    end
    
    %% get the statistical information for the clssified image compared with the manual annotation
    % return of the function !
    statsClassific = statisticalInfo(statsClassific, suffix, regions_params(1).mask, regions_params(2).mask, ...
        MANUAL_ANNOTATION_FOLDER, patient, t, penumbra_color, core_color, 1);
    
    
    %% Save the image with boundaries
% %     imwrite(mat2gray(pred_img{1,t}),strcat(saveFolder, patient, '/CLUSTER/', "fitcecoc_", name, ".png")); 
    visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
    visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
    print(figure(t), '-dpng', strcat(saveFolder, patient, saveSubFolder, suffix, "_", name, ".png")); 
end

end

