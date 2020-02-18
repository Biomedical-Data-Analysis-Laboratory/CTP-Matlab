function [returnImage, returnMask] = segmentWithKMeanClustering(im, direction, nCluster, colorbarPointBottomX, colorbarPointTopX, startingColorPixelX, colorbarPointTopY)
%SEGMENTWITHKMEANCLUSTERING Summary of this function goes here
%   Detailed explanation goes here
    
    % Step 1:Initialize variables
    howManyPixelsUsed = 0;
    howManyPixelsUsedFILTERED = 0;
    totalPixelToUse = 0;
    totalMask = zeros(size(im,1), size(im,2));
    totalMaskFILTERED = zeros(size(im,1), size(im,2));
        
    if strcmp(direction, "down")
        totalPixelToUse = colorbarPointBottomX - startingColorPixelX + 1;
    elseif strcmp(direction, "up")
        totalPixelToUse = startingColorPixelX - colorbarPointTopX + 1;
    end 

    % Step 2: Convert Image from RGB Color Space to L*a*b* Color Space
    lab_im = rgb2lab(im);
    
    % Step 3: Classify the Colors in 'a*b*' Space Using K-Means Clustering
    ab = lab_im(:,:,2:3);
    ab = im2single(ab);
    % repeat the clustering 3 times to avoid local minima
    pixel_labels = imsegkmeans(ab,nCluster,'NumAttempts',3);
    
    
%     subplot(2,2, 1)
%     imshow(im)
%     subplot(2,2, 2)
%     imshow(pixel_labels,[])
        
    clusteImages = cell(1, nCluster);
    
    % Step 4: Create Images that Segment the Image by Color
    for n =1:nCluster
        mask1 = pixel_labels==n;
        
        pixelsInRightDirection = 0;
        if strcmp(direction, "down")
            pixelsInRightDirection = sum(mask1(startingColorPixelX:colorbarPointBottomX,colorbarPointTopY));
        elseif strcmp(direction, "up")
            pixelsInRightDirection = sum(mask1(colorbarPointTopX:startingColorPixelX,colorbarPointTopY));
        end
        
        howManyPixelsUsed = howManyPixelsUsed + pixelsInRightDirection;
        if pixelsInRightDirection>0
            totalMask = totalMask + mask1;
%             clusteImages{n} = im .* uint8(mask1);
%             subplot(2,nCluster+1, n+1)
%             imshow(clusteImages{n})

            L = lab_im(:,:,1);
            L_blue = L .* double(mask1);
            L_blue = rescale(L_blue);
            idx_light_blue = imbinarize(nonzeros(L_blue));
            blue_idx = find(mask1);
            mask_dark_blue = mask1;
            mask_dark_blue(blue_idx(idx_light_blue)) = 0;
            
            pixelsInRightDirectionFILTERED = 0;
            if strcmp(direction, "down")
                pixelsInRightDirectionFILTERED = sum(mask_dark_blue(startingColorPixelX:colorbarPointBottomX,colorbarPointTopY));
            elseif strcmp(direction, "up")
                pixelsInRightDirectionFILTERED = sum(mask_dark_blue(colorbarPointTopX:startingColorPixelX,colorbarPointTopY));
            end
            
            totalMask(:,colorbarPointTopY:end) = 0; % remove colorbar 
            totalMaskFILTERED(:,colorbarPointTopY:end) = 0; % remove colorbar 
            
            howManyPixelsUsedFILTERED = howManyPixelsUsedFILTERED + pixelsInRightDirectionFILTERED;
            totalMaskFILTERED = totalMaskFILTERED + mask_dark_blue;
            
%             blue_nuclei = im .* uint8(mask_dark_blue);
%             subplot(2,nCluster+1, nCluster+n+2)
%             imshow(blue_nuclei)
        end
    end
    
    percImg = 0;
    percImgFILTERED = 0;
    if totalPixelToUse > 0
        percImg = (double(howManyPixelsUsed)*100)/double(totalPixelToUse);
        percImgFILTERED = (double(howManyPixelsUsedFILTERED)*100)/double(totalPixelToUse);
    end
%     disp(strcat("Percentage display: ", int2str(percImg), "%"))
%     disp(strcat("Percentage display FILTERED: ", int2str(percImgFILTERED), "%"))
    totImg = im .* uint8(totalMask);
    totImgFILTERED = im .* uint8(totalMaskFILTERED);
%     subplot(2,2,3)   
%     imshow(totImg)
%     subplot(2,2,4)
%     imshow(totImgFILTERED)

    if percImg >= percImgFILTERED
        returnImage = totImg;
        %returnMask = totalMask;
    else
        returnImage = totImgFILTERED;
        %returnMask = totalMaskFILTERED;
    end
    
	returnMask = logical(rgb2gray(returnImage));
    
end

