function [I,bw]=removeSkull(Im)
%% Skull removal by using traditional edge detection

type={'Sobel' 'Prewitt' 'Roberts' 'Canny' 'log'};
for m=3:3
    [~,t]=edge(Im,type{m},'nothinning');

    [edgeMask,~]=edge(Im,type{m},'nothinning',t/12);
end

bw=uint8(Im>0)&~edgeMask;
bw=logical(imfill(imgaussfilt((uint8(bwareafilt(bw,8,8))),5)));
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
L(~bw) = 0;
%%
A=zeros(1,max(max(L)));

for n=1:max(max(L))
    A(n)=bwarea(L==n); % Area of region n
end

[~,largest]=max(A);

for n=1:max(max(L))
    if n~=largest
        P=regionprops(L==n,'Perimeter');
        P=P.Perimeter; % Perimeter of region n 
        
        cf=4*pi*A(n)/P.^2; % Circularity factor of region n
        
        c=regionprops(L==n,'Centroid'); % Centroid of region n
        cLargest=regionprops(L==largest,'Centroid'); % Centroid of largest region
        
        distance=pdist([c.Centroid; cLargest.Centroid]); % Euclidean distance between regions
              %  disp([num2str(n) ' cf=' num2str(cf) ' distance' num2str(distance) ' A' num2str(A)])
        if cf<0.45 || distance>170 || A(n)<500
            L(L==n)=0;
        end
    end
end

bw=L>0;
I=Im.*uint16(bw);