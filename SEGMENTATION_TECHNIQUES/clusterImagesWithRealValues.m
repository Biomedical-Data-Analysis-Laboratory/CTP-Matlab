function [outputArg1,outputArg2] = clusterImagesWithRealValues(maskPenumbra, maskCore, skullMasks, sortImages, colorbarPointBottomX, colorbarPointTopX, colorbarPointY)
%CONVERTIMAGESTOGRAYSCALE Summary of this function goes hereI
%   Detailed explanation goes here

newClusterParametricMaps = cell(1,size(sortImages,2));

colorbar_index = colorbarPointTopX:colorbarPointBottomX;
nCluster = size(colorbar_index,2);

realValueImages = cell(size(sortImages));
realMaxValues = [6, 100, 20, 12];

for pm_idx = 1:size(sortImages,1) % from 1 to 4

    for x=1:size(sortImages(pm_idx,:),2)
        imWithColorbar = sortImages(pm_idx,x);
        imWithColorbar = imWithColorbar{1};
        
        lab_im = rgb2lab(imWithColorbar);
        % Classify the Colors in 'a*b*' Space Using K-Means Clustering
        ab = lab_im(:,:,2:3);
        ab = im2single(ab);
        % repeat the clustering 3 times to avoid local minima
        pixel_labels = imsegkmeans(ab,nCluster,'NumAttempts',3);
        
        realValueImages{pm_idx,x} = zeros(size(imWithColorbar,1), size(imWithColorbar,2));
        
        prevPix = -1;
        
        for pix_idx=1:nCluster
            pix = colorbar_index(pix_idx);
            pixelVal = pixel_labels(pix,colorbarPointY);
                
            if prevPix ~= pixelVal
                maskVal = pixel_labels==pixelVal;

                %% replace realMaxValues(pm_idx) with 1 if you want values 0~1!
                maskVal = maskVal * ((1*(nCluster-pix_idx+1))/nCluster);

                %% update the new image with the real values
                realValueImages{pm_idx,x} = realValueImages{pm_idx,x}+maskVal;
                prevPix = pixelVal;
            end
        end
    end
end

%% at this point, we have all the parametric maps with real values!
% K-mean clustering based on the 4 values of the parametric maps of each
% slide

cbf = []; cbv = []; tmax = []; ttp = [];

for index = 1:size(realValueImages,2)
	cbf = [cbf, realValueImages{1,index} .* skullMasks{1,index}];
    cbv = [cbv, realValueImages{2,index} .* skullMasks{1,index}];
    tmax = [tmax, realValueImages{3,index} .* skullMasks{1,index}];
    ttp = [ttp, realValueImages{4,index} .* skullMasks{1,index}];
    
end

[lb,center] = clusteringParametricMaps(cbf,cbv,tmax,ttp, size(realValueImages,2));
disp(center);
%lb = lb .* skullMasks{1,index};
for lb_idx=1:size(lb,2)
    figure, imshow(lb{1,lb_idx},[]);
    newClusterParametricMaps{1,lb_idx} = lb{1,lb_idx};
end

disp("here");

end

