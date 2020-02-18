close all;
clear all;
temp = load('subImagePA03_450.mat'); % Load all pre-processed and  skull-stripped images for a patient.
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

%% PAD IMAGES, MAKE THEM THE SAME SIZE.
largest_row_left = max(cellfun('size',roi_left,1)); % rows
largest_column_left = max(cellfun('size',roi_left,2)); % column

largest_row_right = max(cellfun('size',roi_right,1)); % rows
largest_column_right = max(cellfun('size',roi_right,2)); % column

largest_row = max(largest_row_left(1),max(largest_row_right(1)));
largest_column = max(largest_column_left(1),max(largest_column_right(1)));
%% CALCULATE FEATURES FOR DIFFERENT WAVELETS
diff_wavelets = {'haar', 'db4', 'coif4'};
koeff_lr = {};
level = 3;
for h = 1:length(diff_wavelets)
    for i=1:rows
        for j = 1:columns
            roi_left_pd{i, j} = imresize(roi_left{i, j},[max(largest_row(1)), max(largest_column(1))], 'bilinear');
            roi_right_pd{i, j} = imresize(roi_right{i, j},[max(largest_row(1)), max(largest_column(1))], 'bilinear');
            [C_left_db2{i, j},S] = wavedec2(roi_left_pd{i,j},level,diff_wavelets{h});
            C_left_db2{i, j}  = abs(C_left_db2{i, j});
            C_left_db2{i, j} = C_left_db2{i, j}/sum(C_left_db2{i, j});
            [C_right_db2{i, j},S] = wavedec2(roi_right_pd{i,j},level,diff_wavelets{h});
            C_right_db2{i, j}  = abs(C_right_db2{i, j});
            C_right_db2{i, j} = C_right_db2{i, j}/sum(C_right_db2{i, j});
            koeff_lr{h} = [{C_left_db2}, {C_right_db2}];
        end
    end
end
%%

for i = 1:length(koeff_lr)
    temp_left = cell2mat(koeff_lr{1,i}{1,1});
    [rows_coffl, columns_coffk] = size(temp_left);

    temp_right = cell2mat(koeff_lr{1,i}{1,2});
    [rows_coffr, columns_coffr] = size(temp_right);
%%
    for k = 1: j
        Series_left(:,:,k) = temp_left(:,1+(k-1)*(columns_coffk/j):k*(columns_coffk/j));
        Series_right(:,:,k) = temp_right(:,1+(k-1)*(columns_coffr/j):k*(columns_coffr/j));
    end
%% MEAN OF SERIES FOR EACH VOLUME-SERIES
    Series_left = mean(Series_left);
    Series_right = mean(Series_right);
%% PLOT THE CHI-SQUARED DISTANCE BETWEEN LEFT AND RIGHT HEMISPHERE
    for k = 1:j
        D1(k) = pdist2( Series_left(:,:,k), Series_right(:,:,k), 'chisq' );
        D_alle{i, k} = D1(k);
    end         
    figure(i)
    plot(1:30, D1)
    xlim([1 30])
    grid on; grid minor; 
    ylabel('Chi-squared') 
    xlabel('Time-Series')
    temp_left = [];
    temp_right = [];
    Series_right = [];
    Series_left = [];
    columns_coffk = 0;
    columns_coffr = 0;
    %D1 =[];
    k = 1;
end