clear;
close all force;
clc;

MAIN_PATH = "D:\Preprocessed-SUS2020_v2\GT_TIFF\";
workspaceFolder = 'D:\Preprocessed-SUS2020_v2\Workspace_RAW_TIFF/';
load(strcat(workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
allInforCTP = struct2cell(allInfoValuesPERFUSIONCT5);
DICOMfolders = allInforCTP(2,:); % 2=index of filename !!! 
patients = [5,6,8,9,13,19,21,22,23,28,31,32,35,36,37,70,79,82,91,98,119];

for p = patients

    folderPath = DICOMfolders{p};
    if strcmp(folderPath,"")
        Image{p} = []; % the images of the current patient can NOT be retrieved
        continue
    end
    p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));        
    disp(strcat("Patient: ", p_id));
    patient_dir = strcat(MAIN_PATH,p_id);
    for gtfile = dir(patient_dir)'
        if ~strcmp(gtfile.name, '.') && ~strcmp(gtfile.name, '..')
            gtimg = imread(strcat(patient_dir,"/",gtfile.name));
            if length(size(gtimg))==3
                gtimg = gtimg(:,:,1);
            end
            gtimg = im2double(gtimg);
            brainmask = gtimg>0;
            cc = bwconncomp(brainmask);
            BP = regionprops(brainmask,'Circularity','Centroid');
            centroid = zeros(1,numel(BP));
            for n=1:numel(BP)
                centroid(n) = BP(n).Centroid(2);
            end
            idx = find([centroid] > 100); 
            mask = ismember(labelmatrix(cc),idx);
            newgt = 255*(double(mask).*gtimg);
            newgt = round(newgt);
            figure,imshow(newgt,[0 255])
            
            imwrite(mat2gray(newgt, [0 255]), strcat(patient_dir,"/",gtfile.name));
        end
    end
    
    close all force;

end
        