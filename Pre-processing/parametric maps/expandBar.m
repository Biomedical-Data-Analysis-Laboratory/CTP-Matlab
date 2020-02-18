function [barCBF,barCBV,barTTP,barTMAX]=expandBar(barCBF,barCBV,barTTP,barTMAX)
%% 
imTMAX_Reshape=reshape(imTMAX,dimCBV(1)*dimCBV(2),3);
imTMAX_Reshape( all(~imTMAX_Reshape,2), : ) = [];
[C,~,~] = unique(imTMAX_Reshape,'rows');

imTMAX_Reshape=reshape(imTMAX,dimCBV(1)*dimCBV(2),3);
imTMAX_Reshape( all(~imTMAX_Reshape,2), : ) = [];

barC=unique(cat(1,bar2,C),'rows');

bar5HSV=rgb2hsv(reshape(barC,length(barC),1,3));
bar5HSV=reshape(bar5HSV,length(barC),3,1);
bar5HSV=sortrows(bar5HSV);

barTMAXHSV=reshape(rgb2hsv(barTMAX),256,3,1);
barTMAX=uint8((hsv2rgb(reshape(bar5HSV,length(barC),1,3)))*255);
barTMAXRGB=reshape(barTMAX,length(barC),3,1);

imCBV_Reshape=reshape(imCBV,dimCBV(1)*dimCBV(2),3);
imCBV_Reshape( all(~imCBV_Reshape,2), : ) = [];
[C,~,~] = unique(imCBV_Reshape,'rows');

bar4=unique(cat(1,bar3,C),'rows');

bar4HSV=rgb2hsv(reshape(bar4,length(bar4),1,3));
bar4HSV=reshape(bar4HSV,length(bar4),3,1);
bar4HSV=sortrows(bar4HSV);
bar4HSV(275:end,:)=sortrows(bar4HSV(275:end,:),-3);

barCBVHSV=reshape(rgb2hsv(barCBV),256,3,1);
barCBV=uint8((hsv2rgb(reshape(bar4HSV,length(bar4),1,3)))*255);