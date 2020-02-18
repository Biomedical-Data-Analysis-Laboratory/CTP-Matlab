function [I,bw] = removeSkull2(Im,ftype,thold)
%% Skull removal by using wavelet coefficient thresholding
% thold = 14;

[~,cH,cV,cD] = swt2(Im,1,ftype);

cH = wcodemat(cH(:,:,1),1000);
cV = wcodemat(cV(:,:,1),1000);
cD = wcodemat(cD(:,:,1),1000);

% 
% 
% figure
% subplot(241)
% imshow(Im,[]),title('Input')
edgeMask = cH>thold|cV>thold|cD>thold; % Thresholding the Wavelet coefficients
% subplot(242)
% imshow(edgeMask,[]),title('Edge mask')
bw = (Im>0)&~edgeMask;
% subplot(243)

% imshow(bw,[]),title('~(Edge mask) & (Input)>0')
bw = (logical(imfill(imgaussfilt((uint8(bwareafilt(bw,8,8))),5))));
% subplot(244)
% imshow(bw,[]),title({'Smooth, fill and ','remove small objects'})
% figure
% imshow(bw,[])
%% 
% This section uses code from 
% "Watershed transform question from tech support", by Steve Eddins
% Available here: https://blogs.mathworks.com/steve/2013/11/19/watershed-transform-question-from-tech-support/
D = -bwdist(~bw);

H_min = imhmin(D,7);
BW_min = imregionalmin(H_min);

D = imimposemin(D,BW_min);

D(~bw) = Inf;

L = watershed(D);
% figure
% imshow(L,[])
L(~bw) = 0;
% figure
% imshow(L,[])
%%
A = zeros(1,max(max(L)));

for n = 1:max(max(L))
    A(n) = bwarea(L == n); % Area of region n
end

[~,largest] = max(A);

for n = 1:max(max(L))
    %if n ~= largest
        P = regionprops(L == n,'Perimeter');
        P = P.Perimeter; % Perimeter of region n 
        
        cf = 4*pi*A(n)/P.^2; % Circularity factor of region n
        
        c = regionprops(L == n,'Centroid'); % Centroid of region n
%         cLargest = regionprops(L == largest,'Centroid'); % Centroid of largest region
%         distance = pdist([c.Centroid; cLargest.Centroid]); % Euclidean distance between regions
        centroids = size(Im)/2; % middle of the image
        distance = pdist([c.Centroid; centroids]); % Euclidean distance between regions
% %         disp([num2str(n) ' cf = ' num2str(cf) ' distance = ' num2str(distance) ' A = ' num2str(A(n))])
        if cf<0.40 || distance>170 % || A(n)<500
            L(L == n) = 0;
        end
    %end
end
% rgb2 = label2rgb(L);%,'jet',[.5 .5 .5]);
%  subplot(247)
% subplot(322)
%  imshow(L,[0 10]),title('The kept segment(s)')
bw = L>0;

I = Im.*uint16(bw);
%imshow(I, []);
I = histeq(I);

%imshow(I, []);

end