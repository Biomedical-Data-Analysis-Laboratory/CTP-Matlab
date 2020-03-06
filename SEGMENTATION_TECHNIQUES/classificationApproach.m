function classificationApproach(realValueImages,skullMasks, ...
    MANUAL_ANNOTATION_FOLDER, patient, penumbra_color, core_color, saveFolder)
%CLASSIFICATIONAPPROACH Summary of this function goes here
%   Detailed explanation goes here

close all;

% % create the folders if it don't exist
if ~ exist(strcat(saveFolder, patient, '/CLUSTER'),'dir')
    mkdir(strcat(saveFolder, patient, '/CLUSTER'));
end

pIndex = patient(end-1:end);
cbf = []; cbv = []; tmax = []; ttp = []; oldInfactionMask = []; output = []; output_penumbra = []; output_core = [];

for index = 1:size(realValueImages,2)
    name = num2str(index);
    if length(name) == 1
        name = strcat('0', name);
    end
    
	cbf = [cbf, (imfill(realValueImages{1,index}) .* imfill(skullMasks{1,index})) + ((skullMasks{1,index}==0) .* -10)];
    cbv = [cbv, (imfill(realValueImages{2,index}) .* imfill(skullMasks{2,index})) + ((skullMasks{2,index}==0) .* -10)];
    tmax = [tmax, (imfill(realValueImages{3,index}) .* imfill(skullMasks{3,index})) + ((skullMasks{3,index}==0) .* -10)];
    ttp = [ttp, (imfill(realValueImages{4,index}) .* imfill(skullMasks{4,index})) + ((skullMasks{4,index}==0) .* -10)];
    %oldInfactionMask = [oldInfactionMask, ((realValueImages{5,index}==0) .* -10)];
    
    I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
    Igray = rgb2gray(I);
    output = [output, double(Igray)];
    output_penumbra = [output_penumbra, double(Igray)];
    output_core = [output_core, double(Igray)];
end

weights = ones(size(output));
weights_penumbra = ones(size(output_penumbra));
weights_core = ones(size(output_core));

back_idx = find(output>=234); % backgroung
brain_idx = find(output<60); % brain
penumbra_idx = intersect(find(output>=60), find(output<135));
core_idx = intersect(find(output>=135), find(output<234));

output(back_idx) = 0;
output(brain_idx) = 1; 
output(penumbra_idx) = 2;
output(core_idx) = 3;
% weights(brain_idx) = 5;
% weights(penumbra_idx) = 10;
weights(core_idx) = 5;

output_penumbra(back_idx) = 0;
output_penumbra(brain_idx) = 0;
output_penumbra(penumbra_idx) = 1;
output_penumbra(core_idx) = 1;
weights_penumbra(penumbra_idx) = 2;
weights_penumbra(core_idx) = 4;

output_core(back_idx) = 0;
output_core(brain_idx) = 0;
output_core(penumbra_idx) = 0;
output_core(core_idx) = 1;
weights_core(core_idx) = 5;


data2 = [cbf(:),cbv(:),tmax(:),ttp(:),output(:)];
data = [cbf(:),cbv(:),tmax(:),ttp(:)];
% for svm
data_core = [cbf(:),cbv(:)];
data_penumbra = [tmax(:),ttp(:)];


nImages = size(realValueImages,2);

% LearnRate = ["linear", "quadratic", "diaglinear", "diagquadratic", "pseudolinear", "pseudoquadratic"];
% Gamma = [0,1,0,1,0,1];
% numDT = numel(DiscrimType);
% HyperparameterOptimizationOptions = struct('UseParallel', true, 'Verbose', 2,'Holdout',0.3, 'Optimizer','randomsearch');
% Mdl = cell(1,numDT);
% predictions = cell(1,numDT);
% for k=1:numDT
%     Mdl{1,k} = fitcdiscr(data,output(:), 'Weights', weights(:), 'DiscrimType', DiscrimType(k), 'Gamma', Gamma(k), 'HyperparameterOptimizationOptions', HyperparameterOptimizationOptions);
%     predictions{1,k} = predict(Mdl{1,k},data);
%     disp("MSE:");
%     disp(immse(output(:), predictions{1,k}));
% end

t = templateLinear('LearnRate', 0.01, 'Verbose',1);
% Mdl = fitcecoc(data,output(:), 'Weights', weights(:), 'Learners', t);
Mdl = fitcdiscr(data,output(:), 'Weights', weights(:));
predictions = predict(Mdl,data);
    

% MdlSVM_penumbra = fitcsvm(data_penumbra,output_penumbra(:), 'Weights', weights_penumbra(:), 'Verbose',1, 'IterationLimit', 3000, 'Standardize',true);
% predSVM_penumbra = predict(MdlSVM_penumbra, data_penumbra);
% MdlSVM_core = fitcsvm(data_core,output_core(:), 'Weights', weights_core(:), 'Verbose',1, 'IterationLimit', 3000, 'Standardize',true);
% predSVM_core = predict(MdlSVM_core, data_core);

lb_tmp = reshape(predictions,[512*512,nImages]);
pred_img = cell(1,nImages);


for t=1:nImages
    pred_img{1,t} = mat2gray(imfill(reshape(lb_tmp(:,t), [512,512]))) .* 255;
    
    oldInfaction = find(realValueImages{5,t}==0);
    maskSkull = find(pred_img{1,t}>0);
    intersection = intersect(maskSkull, oldInfaction);
    maskInter = zeros(size(pred_img{1,t}));
    maskInter(intersection) = 1;
    maskConv = bwconvhull(maskInter, 'objects');
    intersApprox = activecontour(maskInter, maskConv, 10, 'edge');
    classPixel = unique(pred_img{1,t});
    idx_approx = find(intersApprox==1);
    
    pred_img{1,t}(idx_approx) = classPixel(2); % brain
    name = num2str(t);
    if length(name) == 1
        name = strcat('0', name);
    end
    I = imread(strcat(MANUAL_ANNOTATION_FOLDER, 'Patient', pIndex, '/', pIndex , name, '.png'));
    Igray = rgb2gray(I);
    I_penumbra = Igray==penumbra_color; % PENUMBRA COLOR
    I_core = Igray==core_color; % CORE COLOR
    
    figure, imshow(pred_img{1,t},[]);  
    %axis on;
    hold on;

    regions_params = [struct(), struct()];
    %% regions_params(1) == penumbra 
    regions_params(1).threshold = 85;
    regions_params(1).area = 200;
    regions_params(1).color = 'g';
    %% regions_params(1) == core 
    regions_params(2).threshold = 250;
    regions_params(2).area = 100;
    regions_params(2).color = 'r';
    %%
    for ri = 1:size(regions_params,2)
        region = regions_params(ri);
        mask = pred_img{1,t} > region.threshold;
        labeledImage = bwlabel(mask,8);
        r = regionprops(mask);
        allareas = [r.Area];
        areaThres = region.area;
        if areaThres < mean(allareas)+std(allareas)
            areaThres =  mean(allareas)+std(allareas);
        end
        area_idx = (allareas > areaThres);
        if sum(area_idx)>0
            keep_idx = find(area_idx);
            mask = zeros(size(mask));
            for x=keep_idx
                mask = mask + (labeledImage==x);
            end
            mask = bwconvhull(mask, 'objects');
            bw = activecontour(pred_img{1,t}, mask, 400, 'edge');
            contour(bw, 1,region.color, 'LineWidth', 2); 
        end
    end
%     imwrite(mat2gray(pred_img{1,t}),strcat(saveFolder, patient, '/CLUSTER/', "fitcecoc_", name, ".png")); 
    
    visboundaries(I_penumbra,'Color',[1,1,1] * (penumbra_color/255)); 
    visboundaries(I_core,'Color',[1,1,1] * (core_color/255)); 
    print(figure(t), '-dpng', strcat(saveFolder, patient, '/CLUSTER/', "linear_", name, ".png")); 
end
    
disp("MSE:");
disp(immse(output(:), predictions));

% [lb,center] = clusteringParametricMaps(cbf,cbv,tmax,ttp, size(realValueImages,2));
% disp(center);
% for t=1:nImages
%     figure, imshow(lb{1,t},[]);
% end

end

