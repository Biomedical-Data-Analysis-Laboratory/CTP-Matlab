function [BW,imdiff,imdiff_orig] = SegAdaptThresh(ImAll)
% Vessel segmentation using adaptive thresholding.

% maxIP = cellfun(@max,TDC);
% minIP = cellfun(@min,TDC);
% figure
% imshow(maxIP,[1080 1100])

maxIP = max(ImAll,[],3);
minIP = min(ImAll,[],3);
%
[~,~,v] = find(minIP);
minIP(minIP<900 & minIP>100) = mean(v);

[~,~,v] = find(maxIP);
maxIP(maxIP<900 & maxIP>100) = mean(v);

imdiff = (imabsdiff(maxIP,minIP));
% imdiff_orig = imdiff;

imdiff = imbilatfilt(imdiff,100,'SpatialSigma',3);

imdiff = imdiff.*uint16(~bwperim(imdiff>0));
imdiff = imdiff.*uint16(~bwperim(imdiff>0));
imdiff = imdiff.*uint16(~bwperim(imdiff>0));
imdiff = imdiff.*uint16(~bwperim(imdiff>0));

imdiff_orig = imdiff;
imdiff(imdiff>750 | imdiff<15) = 0;
[~,~,v] = find(imdiff);
imdiff(imdiff  ==  0) = mean(v); %zeros are replaced by the mean value of the non-zero elements

%         [~,~,v] = find(imdiff);
%         imdiff(imdiff<3) = mean(v);

% B = fibermetric(imdiff,linspace(3,25,12));
B = fibermetric(imdiff,linspace(2,18,9),'StructureSensitivity',15);
B(B<0.025) = 0;
BW = imbinarize(B,adaptthresh(B,0.3,'NeighborhoodSize',2*floor(size(B)/128)+1,'Statistic','gaussian'));