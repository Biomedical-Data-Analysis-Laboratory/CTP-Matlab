clear;
clc % clear command window
close all force;

patientinfo = readtable("C:\Users\2921329\OneDrive - Universitetet i Stavanger\Luca\PhD\PAPERS\05 - DWI & CTH\Recanalization + NAWM.xlsx");
save_folder = "D:\Preprocessed-SUS2020_v2\NAWM_ROI\";

if ~isfolder(save_folder)
    mkdir(save_folder)
end

for patient = dir("D:\Preprocessed-SUS2020_v2\Parametric_maps\")'
    if strcmp(patient.name, ".") || strcmp(patient.name, "..") || strcmp(patient.name, "CTP_00_007") || strcmp(patient.name, "CTP_00_009")
        continue
    end 

    disp(patient.name)

    index = -1;
    for k = 1:numel(patientinfo.Var1)
        if (convertCharsToStrings(patientinfo.Var1{k}) == convertCharsToStrings(patient.name)) > 0
            index = k;
            break
        end
    end
    if index>-1
        roi_slice = patientinfo.ROINAWM_SlideNumber(k);
        roi_slice = num2str(roi_slice);
        if length(roi_slice) == 1
            roi_slice = strcat("0", roi_slice);
        end
    
        for subfold = dir(strcat(patient.folder+"\",patient.name))'
            if strcmp(subfold.name, ".") || strcmp(subfold.name, "..")
                continue
            end
    
            % disp(subfold.name)
            annotation_folder = subfold.folder + "\" + subfold.name + "\Annotations\";
            for imgname = dir(annotation_folder)'
                if strcmp(imgname.name, ".") || strcmp(imgname.name, "..")
                    continue
                end
                if contains(imgname.name, "core")
                    img = imread(strcat(annotation_folder+"\",imgname.name));
                    
                    name = roi_slice+".png";
                    if contains(imgname.name, "_"+roi_slice+"_core")
                        penumbra_roiname = replace(imgname.name, "core", "penumbra");
                        penumbra_img = imread(strcat(annotation_folder+"\",penumbra_roiname));
                        actual_roi = ~penumbra_img & img;
                        regions = regionprops(actual_roi);
    
                        for r = size(regions,1):-1:1
                            if regions(r).Area < 50 
                                regions(r) = [];
                            end
                        end
                            
                        disp(length(regions))
                        if length(regions)==1
                            save_folder_patient = save_folder+patient.name;
                            if ~isfolder(save_folder_patient)
                                mkdir(save_folder_patient)
                            end
                            imwrite(im2uint16(actual_roi),save_folder_patient+"\"+name)
                            break
                        end
                    end
                end
            end
        end
    else
        disp(strcat("NOTHING for: ", patient.name))
    end
    
end