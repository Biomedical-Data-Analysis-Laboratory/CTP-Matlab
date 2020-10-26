function [brain,brain_mask] = testRemoveSkull(Im, tmp_mask, image)
%TESTREVOMESKELL Summary of this function goes here
%   Detailed explanation goes here

thres_hu = 160; % +300 == bones

if image==1 % if it's the first image, generate the mask, otherwise use the already generated 
    
    Im(Im<0) = 0; % remove any pixel values < 0 HU
    while thres_hu > 80
        Im(Im>thres_hu) = 0; % remove any pixel values < 100 HU
    
        mask = Im>0;
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
        
        disp(cf);
        disp(Bcf/cf);
        thres_hu = thres_hu - 5;
    end
    
    figure,imshow(brain_mask,[]);
    
else
    brain_mask = tmp_mask;
end

if sum(brain_mask,'all')==0 % if everything is black
    brain = int16(brain_mask);
else
    brain = Im.*int16(brain_mask);
end

end

