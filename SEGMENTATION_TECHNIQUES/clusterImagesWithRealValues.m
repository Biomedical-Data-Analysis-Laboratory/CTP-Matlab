function [data,tableData,nImages] = clusterImagesWithRealValues(maskPenumbra, maskCore, ...
    skullMasks, sortImages, colorbarPointBottomX, colorbarPointTopX, colorbarPointY, PREDICT_WITH_OTHER_MODElS, ...
    MANUAL_ANNOTATION_FOLDER, pIndex, penumbra_color, core_color, saveFolder, suffix, statsClassific, MODELS)
%CONVERTIMAGESTOGRAYSCALE Summary of this function goes hereI
%   Detailed explanation goes here

newClusterParametricMaps = cell(1,size(sortImages,2));

colorbar_index = colorbarPointTopX:colorbarPointBottomX;
nCluster = 4; %% size(colorbar_index,2);

realValueImages = cell(size(sortImages));
realMaxValues = [100, 6, 20, 12];

for pm_idx = 1:size(sortImages,1) % from 1 to 5
    
    for x=1:size(sortImages(pm_idx,:),2)
        imWithColorbar = sortImages(pm_idx,x);
        imWithColorbar = imWithColorbar{1};
        if pm_idx<5
            lab_im = rgb2lab(imWithColorbar);
            % Classify the Colors in 'a*b*' Space Using K-Means Clustering
            ab = lab_im(:,:,2:3);
            ab = im2single(ab);
            % repeat the clustering 3 times to avoid local minima
            pixel_labels = imsegkmeans(ab,nCluster,'NumAttempts',3);

            realValueImages{pm_idx,x} = zeros(size(imWithColorbar,1), size(imWithColorbar,2));

            prevPix = -1;
            for pix_idx=1:nCluster
                if pixel_labels(1,1)~=pix_idx
                    maskVal = pixel_labels==pix_idx;
                    maskVal(:,colorbarPointY:end) = 0;
                    maskVal = maskVal * (1*pix_idx)/nCluster;
                    realValueImages{pm_idx,x} = realValueImages{pm_idx,x}+maskVal;
                end
                
                
                %% clustering with the entire color bar
                %% lose some pixel info if they are close to black
%                 pix = colorbar_index(pix_idx);
%                 pixelVal = pixel_labels(pix,colorbarPointY);
% 
%                 if prevPix ~= pixelVal
%                     maskVal = pixel_labels==pixelVal;
% 
%                     %% replace realMaxValues(pm_idx) with 1 if you want values 0~1!
%                     maskVal = maskVal * ((realMaxValues(pm_idx)*(nCluster-pix_idx+1))/nCluster);
% 
%                     %% update the new image with the real values
%                     realValueImages{pm_idx,x} = realValueImages{pm_idx,x}+maskVal;
%                     prevPix = pixelVal;
%                 end
            end
        else % we are working with the enhanced image
            oldInfactionMask = rgb2gray(imWithColorbar)>110; %% 110 is a chosen value! (TODO: it could be improved)
            oldInfactionMask(:,colorbarPointY:end) = 0; % remove the F
            realValueImages{pm_idx,x} = oldInfactionMask; 
        end
    end
end

%% At this point, we have all the parametric maps with real values!
% K-mean clustering based on the 4 values of the parametric maps of each slide
[data,tableData,nImages] = classificationApproach(realValueImages,skullMasks, PREDICT_WITH_OTHER_MODElS, ...
    MANUAL_ANNOTATION_FOLDER, pIndex, penumbra_color, core_color, saveFolder, suffix, statsClassific, MODELS);

end

