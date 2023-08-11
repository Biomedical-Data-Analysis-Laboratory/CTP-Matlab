clear;
clc % clear command window
close all force;

global root 

%% Luca's external disk
root = "D:\From Cercare\Patients\";
manual_annotation_folder = "D:\Preprocessed-SUS2020_v2\FINALIZE_PMS\FINALIZE_PM_TIFF\";
pm_folder = "D:\Preprocessed-SUS2020_v2\Parametric_maps\";
save_plots_path = "D:\From Cercare\plots\";
save_cercare_fold = "D:\From Cercare\Cercare_EXPORT\";
%% Unix server
if isunix
    root = "/home/prosjekt/PerfusionCT/StrokeSUS/CERCARE/Raw/";
    manual_annotation_folder = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/GT_TIFF/";
    pm_folder = "/home/prosjekt/PerfusionCT/StrokeSUS/ORIGINAL/Parametric_Maps/";
    save_plots_path = "/home/stud/lucat/CERCARE/plots/";
    save_cercare_fold = "/home/prosjekt/PerfusionCT/StrokeSUS/CERCARE/Processed/";
    addpath(pwd);
end

infor = [];

for patient = dir(root)'
    if ~strcmp(patient.name, '.') && ~strcmp(patient.name, '..')
        disp(patient.name);
        for studyfolder = dir(strcat(patient.folder,"/",patient.name))'
            if ~strcmp(studyfolder.name, '.') && ~strcmp(studyfolder.name, '..')
                for imagename = dir(strcat(studyfolder.folder,"/",studyfolder.name))'
                    if ~strcmp(imagename.name, '.') && ~strcmp(imagename.name, '..')
                        imginfo = dicominfo(strcat(imagename.folder,"/",imagename.name));
                        if isfield(imginfo,"SeriesDescription") && ~isempty(imginfo.Width) && ~isempty(imginfo.Height)
                            saveFoldName = "";
                            if contains(imginfo.SeriesDescription, "CTH")
                                saveFoldName = "CTH";
                                i.SliceThickness = imginfo.SliceThickness;
                                i.PixelSpacing = imginfo.PixelSpacing;
                                i.flag = saveFoldName;
                                i.patient = patient.name;
                                infor = [infor; i];
%                                 disp(imginfo.SliceThickness)
%                                 disp(imginfo.PixelSpacing)
                                break
%                             elseif contains(imginfo.SeriesDescription, "Core/Hypoperfusion Lesion")
%                                 saveFoldName = "Core_Hypoperfusion Lesion";
%                             elseif contains(imginfo.SeriesDescription, "rCBV")
%                                 saveFoldName = "CBV";
%                             elseif contains(imginfo.SeriesDescription, "rCBF")
%                                 saveFoldName = "CBF";
%                             elseif contains(imginfo.SeriesDescription, "MaxIP")
%                                 saveFoldName = "MIP";
%                             elseif contains(imginfo.SeriesDescription, "MTT")
%                                 saveFoldName = "MTT";
%                             elseif contains(imginfo.SeriesDescription, "TTP")
%                                 saveFoldName = "TTP";
%                             elseif contains(imginfo.SeriesDescription, "Core Lesion")
%                                 saveFoldName = "Core Lesion";
%                             elseif contains(imginfo.SeriesDescription, "Hypoperfusion Lesion")
%                                 saveFoldName = "Hypoperfusion Lesion";
                            elseif contains(imginfo.SeriesDescription, "COV")
                                saveFoldName = "COV";
                                i.SliceThickness = imginfo.SliceThickness;
                                i.PixelSpacing = imginfo.PixelSpacing;
                                i.flag = saveFoldName;
                                i.patient = patient.name;
%                                 disp(imginfo.SliceThickness)
%                                 disp(imginfo.PixelSpacing)
                                infor = [infor; i];
                                break
                            else
                                %disp(imginfo.SeriesDescription);
                                break
                            end
                            
%                             if ~strcmp(saveFoldName, "")
%                                 img = dicomread(strcat(imagename.folder,"/",imagename.name));
%                                 indeximage = imginfo.InstanceNumber+1;
%                                 if indeximage<10
%                                     indeximage = strcat("0", num2str(indeximage));
%                                 end
%                                 % save the image 
%                                 if ~isfolder(save_cercare_fold)
%                                     mkdir(save_cercare_fold)
%                                 end
%                                 if ~isfolder(strcat(save_cercare_fold,patient.name))
%                                     mkdir(strcat(save_cercare_fold,patient.name))
%                                 end
%                                 if ~isfolder(strcat(save_cercare_fold,patient.name,"/",saveFoldName))
%                                     mkdir(strcat(save_cercare_fold,patient.name,"/",saveFoldName))
%                                 end
%                                 if isa(img,"uint16") && ~strcmp(saveFoldName,"Core Lesion")
%                                     img = img./256;
%                                 end
%                                 imwrite(mat2gray(img),strcat(save_cercare_fold,patient.name,"/",saveFoldName,"/",num2str(indeximage),".tiff"))
%                             end
                        end
                    end
                end
            end
        end
    end
end

save(strcat(save_cercare_fold, 'infoCercarePatients.mat'), 'infor');