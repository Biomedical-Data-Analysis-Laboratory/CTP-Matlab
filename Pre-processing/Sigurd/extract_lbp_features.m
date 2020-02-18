close all;
clear all;
temp = load('subImagePA01_450_new.mat'); % Load all pre-processed and  skull-stripped images for a patient.
subImage = temp.subImage(:,:);
[rows, columns] = size(subImage)

%% SPLIT THE IMAGE BY THE CENTROID
for i=1:rows
    for j = 1:columns
        I = subImage;
        %figure, imshow(I)
        bw{i,j} = imbinarize(I{i,j}, graythresh(getimage));
        %figure, imshow(bw)
        bw2{i,j} = imfill(bw{i,j},'holes');
        L{i,j} = bwlabel(bw2{i,j});
        s = regionprops(L{i,j}, 'centroid');
        centroids = cat(1, s.Centroid);
        
        x_verdi{i,j} = round(centroids(1,1));
        y_verdi{i,j} = round(centroids(1,2));
        [m{i,j}, n{i,j}] = size(I{i,j});
        
        roi_right{i,j} = I{i,j}(1:m{i,j},1:x_verdi{i,j}-0.5);
        roi_left{i,j} = I{i,j}(1:m{i,j},x_verdi{i,j}+0.5:n{i,j});
    end
end


R = [1 2 3 4 5];% radiuses
N = [8 16]; %  Number of neighbours

%% CALCULATE SIGMA OF GAUSSIAN LOW-PASS FILTER.
sigma2 = tand(360/(N(2)*2))*R(2);
sigma3 = tand(360/(N(2)*2))*R(3);
sigma4 = tand(360/(N(2)*2))*R(4);
sigma5 = tand(360/(N(2)*2))*R(5);

%% APPLY FILTER TO IMAGES
for i=1:rows
    for j = 1:columns
        filter2_left{i,j} = imgaussfilt(roi_left{i,j}, sigma2);
        filter2_right{i,j} = imgaussfilt(roi_right{i,j}, sigma2);
        
        filter3_left{i,j} = imgaussfilt(roi_left{i,j}, sigma3);
        filter3_right{i,j} = imgaussfilt(roi_right{i,j}, sigma3);
        
        filter4_left{i,j} = imgaussfilt(roi_left{i,j}, sigma4);
        filter4_right{i,j} = imgaussfilt(roi_right{i,j}, sigma4);
       
        filter5_left{i,j} = imgaussfilt(roi_left{i,j}, sigma5);
        filter5_right{i,j} = imgaussfilt(roi_right{i,j}, sigma5);
        
        
    end
end

N = 16;
MAPPING=getmapping(N,'riu2');
%% CALCULATE LBP DESCRIPTORS
for i=1:rows
    for j = 1:columns
        LBPHIST_left1{i,j}=lbp(roi_left{i,j},R(1),N,MAPPING,'nh');%,'nh');
        LBPHIST_right1{i,j}=lbp(roi_right{i,j},R(1),N,MAPPING,'nh');
        
        LBPHIST_left2{i,j}=lbp(filter2_left{i,j},R(2),N,MAPPING,'nh');%,'nh');
        LBPHIST_right2{i,j}=lbp(filter2_right{i,j},R(2),N,MAPPING,'nh');
        
        LBPHIST_left3{i,j}=lbp(filter3_left{i,j},R(3),N,MAPPING,'nh');%,'nh');
        LBPHIST_right3{i,j}=lbp(filter3_right{i,j},R(3),N,MAPPING,'nh');
        
        LBPHIST_left4{i,j}=lbp(filter4_left{i,j},R(4),N,MAPPING,'nh');%,'nh');
        LBPHIST_right4{i,j}=lbp(filter4_right{i,j},R(4),N,MAPPING,'nh');
        
        LBPHIST_left5{i,j}=lbp(filter5_left{i,j},R(5),N,MAPPING,'nh');%,'nh');
        LBPHIST_right5{i,j}=lbp(filter5_right{i,j},R(5),N,MAPPING,'nh');
    end 
    
end
toc
%%

temp_frisk1 = cell2mat(LBPHIST_left1);
temp_syk1 = cell2mat(LBPHIST_right1);

temp_frisk2 = cell2mat(LBPHIST_left2);
temp_syk2 = cell2mat(LBPHIST_right2);

temp_frisk3 = cell2mat(LBPHIST_left3);
temp_syk3 = cell2mat(LBPHIST_right3);

temp_frisk4 = cell2mat(LBPHIST_left4);
temp_syk4 = cell2mat(LBPHIST_right4);

temp_frisk5 = cell2mat(LBPHIST_left5);
temp_syk5   = cell2mat(LBPHIST_right5);
%%
for k = 1:length(temp_frisk1)/(N+2)
    Serie_frisk1(:,:,k) = temp_frisk1(:,1+(k-1)*(N+2):k*(N+2));
    Serie_syk1(:,:,k) = temp_syk1(:,1+(k-1)*(N+2):k*(N+2));
    
    Serie_frisk2(:,:,k) = temp_frisk2(:,1+(k-1)*(N+2):k*(N+2));
    Serie_syk2(:,:,k) = temp_syk2(:,1+(k-1)*(N+2):k*(N+2));
    
    Serie_frisk3(:,:,k) = temp_frisk3(:,1+(k-1)*(N+2):k*(N+2));
    Serie_syk3(:,:,k) = temp_syk3(:,1+(k-1)*(N+2):k*(N+2));
    
    Serie_frisk4(:,:,k) = temp_frisk4(:,1+(k-1)*(N+2):k*(N+2));
    Serie_syk4(:,:,k) = temp_syk4(:,1+(k-1)*(N+2):k*(N+2));
    
    Serie_frisk5(:,:,k) = temp_frisk5(:,1+(k-1)*(N+2):k*(N+2));
    Serie_syk5(:,:,k) = temp_syk5(:,1+(k-1)*(N+2):k*(N+2));
    
    
    
end
%% MEAN OF SERIES FOR EACH VOLUME-SERIES

Serie_frisk1 = mean(Serie_frisk1);
Serie_syk1 = mean(Serie_syk1);

Serie_frisk2 = mean(Serie_frisk2);
Serie_syk2 = mean(Serie_syk2);

Serie_frisk3 = mean(Serie_frisk3);
Serie_syk3 = mean(Serie_syk3);

Serie_frisk4 = mean(Serie_frisk4);
Serie_syk4 = mean(Serie_syk4);

Serie_frisk5 = mean(Serie_frisk5);
Serie_syk5 = mean(Serie_syk5);
%%
for k = 1:length(temp_frisk1)/(N+2)
    
    D1(k) = pdist2( Serie_frisk1(:,:,k), Serie_syk1(:,:,k), 'chisq' );
    D2(k) = pdist2( Serie_frisk2(:,:,k), Serie_syk2(:,:,k), 'chisq' );
    D3(k) = pdist2( Serie_frisk3(:,:,k), Serie_syk3(:,:,k), 'chisq' );
    D4(k) = pdist2( Serie_frisk4(:,:,k), Serie_syk4(:,:,k), 'chisq' );
    D5(k) = pdist2( Serie_frisk5(:,:,k), Serie_syk5(:,:,k), 'chisq' );


end
%% PLOT FEATURES
plot(1:30, D2,1:30, D3,1:30, D4,1:30, D5) 
xlim([1 30])
ylabel('Chi-squared')
xlabel('Time-series')
legend('R = 2', 'R = 3','R = 4','R = 5')
grid on; grid minor;