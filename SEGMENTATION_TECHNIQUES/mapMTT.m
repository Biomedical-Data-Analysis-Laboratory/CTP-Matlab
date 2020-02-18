function MTTImg = mapMTT(CBVImg,CBFImg,colorbarPointTopX,colorbarPointBottomX,colorbarPointY)
%MAPMTT Summary of this function goes here
%   Detailed explanation goes here

MTTImg = zeros(size(CBVImg,1), size(CBVImg,2));
% colorbarImgCBV = CBVImg(colorbarPointTopX:colorbarPointBottomX, colorbarPointY, :);
% colorbarImgCBF = CBFImg(colorbarPointTopX:colorbarPointBottomX, colorbarPointY, :);

% Step 2: Convert Image from RGB Color Space to L*a*b* Color Space
lab_im_CBV = rgb2lab(CBVImg);
lab_im_CBF = rgb2lab(CBFImg);
% Step 3: Classify the Colors in 'a*b*' Space Using K-Means Clustering
ab = lab_im_CBV(:,:,2:3);
ab = im2single(ab);
ab_CBF = lab_im_CBF(:,:,2:3);
ab_CBF = im2single(ab_CBF);

% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(ab,256,'NumAttempts',3);
pixel_labels_CBF = imsegkmeans(ab_CBF,256,'NumAttempts',3);

for n=1:256
    maskN = pixel_labels==n;
    colorbarImgCBV = maskN(colorbarPointTopX:colorbarPointBottomX, colorbarPointY, :);
    indexColorBar = find(colorbarImgCBV,1);
    
    if  isempty(indexColorBar)
        realValue=0;
    else
        percentageColorBar = 100-((indexColorBar*100/size(colorbarImgCBV,1)));
        realValue = (6*percentageColorBar)/100;
    end
    
    MTTImg(maskN) = realValue;
end

for n=1:256
    maskN_CBF = pixel_labels_CBF==n;
    colorbarImgCBF = maskN_CBF(colorbarPointTopX:colorbarPointBottomX, colorbarPointY, :);
    indexColorBar_CBF = find(colorbarImgCBF,1);
    
    if  isempty(indexColorBar_CBF)
        MTTImg(maskN_CBF)=0;
    else
        realValue = 100-((indexColorBar*100/size(colorbarImgCBF,1)));
        MTTImg(maskN_CBF) = (MTTImg(maskN_CBF) / realValue) * 60; % convert from min to sec
    end
    
end
%% get the real values from CBV
% for ii=1:size(CBVImg,1)
%     for jj=1:size(CBVImg,2)
%         pixel = CBVImg(ii,jj,:);
%         indexColorBar = find(sum(sum(colorbarImgCBV==pixel, 3),2)==3);
%         if isempty(indexColorBar)
%             realValue=0;
%         else
%             c = c+1;
%             percentageColorBar = 100-((indexColorBar*100/size(colorbarImgCBV,1)));
%             realValue = (6*percentageColorBar)/100;
%         end
%         
%         MTTImg(ii,jj) = realValue;
%     end
% end
% %% get the real values from CBF
% for ii=1:size(CBFImg,1)
%     for jj=1:size(CBFImg,2)
%         pixel = CBFImg(ii,jj,:);
%         indexColorBar = find(sum(sum(colorbarImgCBF==pixel, 3),2)==3);
%         if isempty(indexColorBar)
%             MTTImg(ii,jj)=0;
%         else
%             realValue = 100-((indexColorBar*100/size(colorbarImgCBF,1)));
%             MTTImg(ii,jj) = (MTTImg(ii,jj) / realValue) * 60; % convert from min to sec
%         end
%         
%     end
% end

end

