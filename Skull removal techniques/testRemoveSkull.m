function [brain,brain_mask,thres_hu] = testRemoveSkull(Im, tmp_mask, image, thres_hu)
%TESTREVOMESKELL Summary of this function goes here
%   Detailed explanation goes here

if image==1 % if it's the first image, generate the mask, otherwise use the already generated     
    Im(Im<0) = 0; % remove any pixel values < 0 HU
    tmp_im = Im; % don't change the image
    while thres_hu > 80
        tmp_im(Im>thres_hu) = 0; % remove any pixel values < 100 HU
    
        mask = tmp_im>0;
        if sum(mask,'all')==0 % if everything is black
            brain_mask = mask;
            break
        end
        
        biggestmask = bwareafilt(mask,1);
        brain_mask = imfill(biggestmask, 'holes'); % extract the largest area in the mask and fill the possible holes
        % calculate the circularity factor of the filled mask and the mask
        BP = regionprops(biggestmask,'Perimeter');
        BP = BP.Perimeter;
        BA = bwarea(biggestmask);
        Bcf = 4*pi*BA/BP.^2; % Circularity factor of the biggest mask
        
        P = regionprops(brain_mask,'Perimeter');
        P = P.Perimeter;
        A = bwarea(brain_mask);
        cf = 4*pi*A/P.^2; % Circularity factor of the brain mask
        if cf >0.17 && (Bcf/cf) > 0.9
            break
        end
        
        thres_hu = thres_hu - 5;
    end
    
    if ~isunix
        figure,imshow(brain_mask,[]);
    end
    
else
    Im(Im<0) = 0;
    %% NO! Don't alterate the pixels in the image
    % Im(Im>thres_hu) = thres_hu; 
    brain_mask = tmp_mask;
end

if sum(brain_mask,'all')==0 % if everything is black
    brain = double(brain_mask);
else
    brain = double(Im).*double(brain_mask);
end

end

