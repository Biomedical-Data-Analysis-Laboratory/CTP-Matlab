function [tableData,nImages] = clusterImagesWithRealValues(skullMasks, sortImages, ...
    colorbarPointBottomX, colorbarPointTopX, colorbarPointY, MANUAL_ANNOTATION_FOLDER, ...
    SUPERVISED_LEARNING, FAKE_MTT, patient, n_fold, image_suffix, suffix, USESUPERPIXELS,N_SUPERPIXELS)
%CONVERTIMAGESTOGRAYSCALE Summary of this function goes hereI
%   Detailed explanation goes here

nCluster = 20; 

realValueImages = cell(size(sortImages));
realMaxValues = [100, 6, 20, 12];

%% if at least one of the parametric maps have an empty slice (or less slices than the others), don't extract data
if sum(cellfun(@isempty, sortImages(1:5,:)),'all')>0
    tableData = [];
    nImages = [];
    return
end
    
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

            for pix_idx=1:nCluster
                if pixel_labels(1,1)~=pix_idx
                    maskVal = pixel_labels==pix_idx;
                    indexVal = find(maskVal(:,colorbarPointY)>0);
                    if ~isempty(indexVal)
                        middleVal = ceil(numel(indexVal)/2);
                        realVal = ((colorbarPointBottomX-indexVal(middleVal))*100)/(colorbarPointBottomX-colorbarPointTopX);

                        maskVal(:,colorbarPointY:end) = 0; % remove colorbar
                        %% replace realMaxValues(pm_idx) with 1 if you want values 0~1!
%                         maskVal = maskVal * (realMaxValues(pm_idx)*realVal)/100;
                        maskVal = maskVal * (1*realVal)/100;
                        realValueImages{pm_idx,x} = realValueImages{pm_idx,x}+maskVal;
                    end
                end
            end
        else % we are working with the MTT image
            if FAKE_MTT
                realValueImages{pm_idx,x} = zeros(size(imWithColorbar,1), size(imWithColorbar,2));
            else
                %% 110 is a chosen value! (TODO: it could be improved)
                oldInfactionMask = rgb2gray(imWithColorbar)>110; 
                oldInfactionMask(:,colorbarPointY:end) = 0; % remove the F
                realValueImages{pm_idx,x} = oldInfactionMask; 
            end
        end
    end
end

%% At this point, we have all the parametric maps with real values!
% K-mean clustering based on the 4 values of the parametric maps of each slide
[tableData,nImages] = classificationApproach(realValueImages,skullMasks,...
    MANUAL_ANNOTATION_FOLDER, SUPERVISED_LEARNING, patient, n_fold, image_suffix, suffix, USESUPERPIXELS, N_SUPERPIXELS);

end

