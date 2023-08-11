clear;
clc % clear command window
close all force;

DIR = "/Users/lucatomasetti/Desktop/Registered_images/FINALIZE_PM_TIFF/";
penumbra_color = 170;
core_color = 255;
list_files = dir(DIR)';
n_patients = numel(list_files)-2;
count = 0;

rest_count = zeros(n_patients,1);
brain_count = zeros(n_patients,1);
penumbra_count = zeros(n_patients,1);
core_count = zeros(n_patients,1);
stats = table();

for p = list_files 
    if ~strcmp(p.name, '.') && ~strcmp(p.name, '..') 
        count = count + 1;
        for img_name = dir(strcat(p.folder,"/",p.name))'
            if ~strcmp(img_name.name, '.') && ~strcmp(img_name.name, '..') && ~strcmp(img_name.name, '.DS_Store') && ~img_name.isdir
                gt_img = imread(strcat(img_name.folder,"/",img_name.name));
                gt_img = gt_img./256;
                gt_img(gt_img>core_color-(penumbra_color/4)) = core_color;
                gt_img(gt_img<penumbra_color+(penumbra_color/4) & gt_img>90) = penumbra_color;
                
                brain_count(count) = brain_count(count) + sum(gt_img==85,"all");
                gt_img(gt_img<=90 & gt_img>0) = 0; % the rest 
                
                gt_img_r = reshape(gt_img, 1, []);
                
                rest_count(count) = rest_count(count) + sum(gt_img_r==0);
                penumbra_count(count) = penumbra_count(count) + sum(gt_img_r==penumbra_color);
                core_count(count) = core_count(count) + sum(gt_img_r==core_color);
            end
        end
        stats = [stats; {p.name,rest_count(count),brain_count(count),penumbra_count(count),core_count(count)}];
    end
end