clear;
clc % clear command window
close all force;

listofpatients = ["CTP_01_001", "CTP_01_002"];%,"CTP_00_006","CTP_00_007","CTP_00_009"];

MAIN_PATH = "D:\Preprocessed-SUS2020_v2\";
perfusionCTFolder = MAIN_PATH+"Parametric_maps\";

for p_fold = dir(perfusionCTFolder)'
    if sum(cellfun(@any,strfind(listofpatients,p_fold.name)))==1
        for dayfold = dir(strcat(p_fold.folder, "/", p_fold.name))'
            if ~strcmp(dayfold.name, '.') && ~strcmp(dayfold.name, '..')
                cbv = cell(0);
                cbf = cell(0);
                for subfold = dir(strcat(dayfold.folder, "/", dayfold.name))'
                    idx_img = 1;
                    if strcmp(subfold.name, "CBV")
                        for image = dir(strcat(subfold.folder, "/", subfold.name))'
                            if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                img = imread(strcat(image.folder, "/", image.name));
                                cbv{1,idx_img} = img;
                                idx_img = idx_img +1;
                            end
                        end
                    elseif strcmp(subfold.name, "CBF")
                        for image = dir(strcat(subfold.folder, "/", subfold.name))'
                            if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                                img = imread(strcat(image.folder, "/", image.name));
                                cbf{1,idx_img} = img;
                                idx_img = idx_img +1;
                            end
                        end
                    end
                end
            end
        end
    end
end
