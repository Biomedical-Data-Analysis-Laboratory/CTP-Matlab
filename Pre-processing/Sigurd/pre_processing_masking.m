
%% INITIALIZE PRE_PROCESSING AND MASKING
clear all, close all;
directory = 'insert directory of aligned PCT images';
files = dir(fullfile(directory, '*.tif'));

for i=1:length(files)
    
    filePattern = fullfile(directory, '*.tif');
    theFiles = dir(filePattern);
    baseFileName = theFiles(i).name;
    files_tif(:,:,i) = fullfile(directory, baseFileName);
end

%% ROTATE IMAGES WITH AN APPROPRIATE ANGLE FOR THE PATIENTS
%angle = -5;                    %PA1 
%angle = 5;                     %PA2
%angle = -9                     %PA3
%angle = -12;                   %PA4
%angle = -1;                    %PA5
%angle = 8;                     %PA6
%angle = -10;                   %PA7
%angle = 7;                     %PA8
%angle = -4;                    %PA9
%angle = 10;                    %PA10
%angle = -8;                    %PA11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRE-PROCESS ALL IMAGES

for i = 1: length(files)
    imageArray{i} = imread(files_tif(:,:,i));
    A{i} = imrotate(imageArray{i},angle,'bilinear','crop');
    normalisert{i} = (img_norm(A{i}, 0, 65535));
    mid{i} = histeq(normalisert{i});
end
 %% SPECIAL TREATMEANT FOR THE FIRST TIME-SERIES
 
for i = 1:length(files)/30
    temp_normalisert{i} = (img_norm(A{i}, 0, 4090));
    temp_mid{i} = histeq(temp_normalisert{i});
    
end
 
for i = 1:length(files)/30
    filt{i} = imgaussfilt(temp_mid{i},3);
    [P, Mask{i}] =  regiongrowing(filt{i}, [250,250],'tfmean', 'tfsimiplify','tfFillHoles'); %tFMean is slow, but for some patients, it returns better masks.
end
Mask = Mask(~cellfun('isempty',Mask));
%% RESHAPE THE MASKS AND PRE-PRCOESSED IMAGES

B = repmat(Mask,1, 30) % Repeat mask for all 30 time-series.

B = reshape(B,[length(files)/30,[length(files)/i]])
mid = reshape(mid,[length(files)/30,[length(files)/i]])
%% APPLY MASKS TO PRE-PROCESSED IMAGES.

for i =1:length(files)/30
    for j = 1:30
        Bilde{i,j} = bsxfun(@times, mid{i,j}, cast(B{i,j}, 'like', mid{i,j}));
    end
end

%% CREATE A BOUNDING BOX AROUND THE IMAGE i.e. REMOVE UNNECESSARY BACKGROUND.

[rows, columns] = size(Bilde);
for i=1:rows
    for j = 1:columns
        s=regionprops(B{i,j},'BoundingBox');
        rectangle('Position', s(1).BoundingBox);
        subImage{i,j}=imcrop(Bilde{i,j},s(1).BoundingBox);
    end
end
%% ALTERNATIVE METHOD FOR SKULL-STRIPPING
for i=3:rows
    for j = 1:columns
        binaryImage{i,j} = normalisert{i,j} > 100%FIND SUITABLE THRESHOLD;

        % Get rid of small specks of noise
        binaryImage{i,j} = bwareaopen(binaryImage{i,j}, 10); % TEST DIFFEERENT PARAMETERS
        binaryImage{i,j}(end,:) = true;

        % Fill the image
        binaryImage{i,j} = imfill(binaryImage{i,j}, 'holes');

        % Erode away X layers of pixels.
        se = strel('disk', X, 0);
        binaryImage{i,j} = imerode(binaryImage{i,j}, se);
        Bilde{i,j} = bsxfun(@times, mid{i,j}, cast(binaryImage{i,j}, 'like', mid{i,j}));
    end
end
