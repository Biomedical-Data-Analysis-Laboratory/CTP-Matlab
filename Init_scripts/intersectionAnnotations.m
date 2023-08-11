clear;
close all force;

CTP_gt_path = "D:\Preprocessed-SUS2020_v2\GT_TIFF\";
DWI_gt_path = "D:\DWI\REGISTERED\DWI_annotations\";   
save_intersections = "D:\DWI\CTP_DWI_Intersections\";

%% Unix server
if isunix
    CTP_gt_path = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/GT_TIFF/";
    DWI_gt_path = "/home/prosjekt/PerfusionCT/StrokeSUS/DWI/REGISTERED_2.0/GT/";
    save_intersections = "/home/prosjekt/PerfusionCT/StrokeSUS/DWI/REGISTERED_2.0/CTP_DWI_Intersections/";
end

for patient = dir(DWI_gt_path)'
    if ~strcmp(patient.name, '.') && ~strcmp(patient.name, '..') && ~isfolder(strcat(save_intersections,patient.name))
        disp(patient.name);
        if ~isfolder(strcat(save_intersections,patient.name))
            mkdir(strcat(save_intersections,patient.name));
        end
        for imagename = dir(strcat(patient.folder,"/",patient.name))'
            if ~strcmp(imagename.name, '.') && ~strcmp(imagename.name, '..')
                DWI_img = imread(strcat(imagename.folder,"/",imagename.name));
                if isa(DWI_img,"uint16")
                    DWI_img = DWI_img./256;
                end
                if length(size(DWI_img))>2
                    DWI_img = DWI_img(:,:,1);
                end
                gt_imagename = strcat(CTP_gt_path,patient.name,"/",imagename.name);
                gt_imagename = replace(gt_imagename, ".png", ".tiff");
                CTP_img = imread(gt_imagename);
                if isa(CTP_img,"uint16")
                    CTP_img = CTP_img./256;
                end
                if length(size(CTP_img))>2
                    CTP_img = CTP_img(:,:,1);
                end
                intersectImg = double(DWI_img>0) .* double(CTP_img>200);
            
                f = figure('visible','off');
                imshow(intersectImg,[0,1])
                hold on
                contour(DWI_img>0,"-blue")
                contour(CTP_img>200,"-red")
                hold off
                saveas(f, strcat(strcat(save_intersections,patient.name),"/",imagename.name));
            end
        end
    end
end