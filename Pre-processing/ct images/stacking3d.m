
clear all
load ImageRegistered
Image3=ImageRegistered;
load timesec

for i=1:30
    ImmTime(:,:,i)=Image3{1}{13}{i};
end

for i=1:13
    Imm(:,:,i)=(Image3{1}{i}{1});
   
end


% I = repmat(img.X,[1 1 5]);
% cmap = img.map;
I=ImmTime;
% hh=image(Imm(:,:,1));
close all
%# coordinates
%%
close all
figure(1)
I=ImmTime;
[X,Z] = meshgrid(1:size(I,2), 1:size(I,1));
Y = ones(size(I,1),size(I,2));
% load timesec

t=timesec{1}{1};
%# plot each slice as a texture-mapped surface (stacked along the Z-dimension)
subplot(122)
for k=1:size(I,3)
%     if k==30
    kk(k)=surface('XData',X, 'ZData',Z, 'YData',Y*t(k), ...
        'CData',double(I(:,:,k)), 'CDataMapping','direct', ...
        'EdgeColor','none', 'FaceColor','flat');
% %     
    alph=double(I(:,:,k)>0);
    alpha(kk(k),alph)
% hold on
%     end
end
title('Temporal images of one slice')
% pbaspect([1 3 10])
aa=linspace(0,1,4095)';
cmap=[aa aa aa];

colormap(cmap)
% view(-97.5,5)
% alpha(alph)
xlabel('Pixel coordinates')
ylabel('Time')
zlabel('Pixel coordinates')
view(-45,20)%, box on, axis tight square
% set(gca, 'YLim',[0 2],'ZLim',[50 450],'XLim',[50 450],'Color',[0 0 0])
set(gca, 'YLim',[0 max(t)+1],'ZLim',[50 450],'XLim',[50 450],'Color',[0 0 0])

pbaspect([1 1.5 1])

%
% close all
I=Imm;
% figure(2)
[X,Y] = meshgrid(1:size(I,2), 1:size(I,1));
Z = ones(size(I,1),size(I,2));
% load timesec

subplot(121)
t=timesec{1}{1};
%# plot each slice as a texture-mapped surface (stacked along the Z-dimension)
for k=1:size(I,3)
%     if k==30
    kk(k)=surface('XData',X, 'YData',Y, 'ZData',Z*k, ...
        'CData',(I(:,:,k)), 'CDataMapping','direct', ...
        'EdgeColor','none', 'FaceColor','flat');
% %     
    alph=double(I(:,:,k)>0);
    alpha(kk(k),alph)
% hold on
%     end
end
title('Slices from same sample/time')
% pbaspect([1 3 10])
% cmap=[linspace(0,1,4096)' linspace(0,1,4096)' linspace(0,1,4096)'];

colormap(cmap)
% view(-97.5,5)
% alpha(alph)
xlabel('Pixel coordinates')
ylabel('Pixel coordinates')
zlabel('Slice number')
view(-45,20)%, box on, axis tight square
set(gca, 'ZLim',[0 13+1],'YLim',[50 450],'XLim',[50 450],'Color',[0 0 0])

pbaspect([2 2 1])