clear;
close all force;
clc;

brain_color = 85;
core_color = 255;
prefix_annot = "superpixels2steps_tree_";

DWI_folder = "D:\DWI annotations\";
FINALFOLDER_DWI = "D:\Preprocessed-SUS2020_v2\FINAL_DWI\";
DWI_GT = "D:\Preprocessed-SUS2020_v2\DWI_GT\";

% for each patient
for patientFold = dir(DWI_folder)' 
if ~strcmp(patientFold.name, '.') && ~strcmp(patientFold.name, '..')
    n_fold = 0;
    % for each date folder
    for subfold = dir(patientFold.folder + "/" + patientFold.name)'
    if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')
        % for each subfolder study
        n_fold = n_fold + 1;
        for study_fold = dir(subfold.folder + "/" + subfold.name)'
        if ~strcmp(study_fold.name, '.') && ~strcmp(study_fold.name, '..')
            if contains(study_fold.name, " - Annotations")
                annot_folder = dir(study_fold.folder + "/" + study_fold.name);
                n_elem = numel(annot_folder)-2;
                if n_elem > 0 || strcmp(patientFold.name, "CTP_01_003") || strcmp(patientFold.name, "CTP_01_009") ...
                        || strcmp(patientFold.name, "CTP_02_006") || strcmp(patientFold.name, "CTP_02_015") ...
                        || strcmp(patientFold.name, "CTP_02_044") || strcmp(patientFold.name, "CTP_02_058")% there is something in the annotations folder
                    disp(study_fold.folder + "/" + study_fold.name);
                    
                    % create the folder to save the correct DWI images
                    if ~isfolder(FINALFOLDER_DWI+patientFold.name) || ~isfolder(DWI_GT+patientFold.name)
                        mkdir(FINALFOLDER_DWI+patientFold.name)
                        mkdir(DWI_GT+patientFold.name)
                        correctDWIfolder = dir(study_fold.folder + "/" + extractBefore(study_fold.name, " - Annotations"))';
                        imagenames = {correctDWIfolder(3:end).name}';
                        % sort the images
                        cleanimagenames = cell(length(imagenames),1);
                        for n=1:length(imagenames)
                            cleanimagenames{n} = str2double(extractBefore(imagenames{n},".png"));
                        end
                        [A,I] = sort(cell2mat(cleanimagenames(:)));
                        if strcmp(patientFold.name, 'CTP_01_066')
                            n_fold = "";
                        end
                        for Iidx = 1:length(I)
                            index = num2str(Iidx);
                            if length(index) == 1
                                index = strcat('0', index);
                            end
                            imgname = correctDWIfolder(I(Iidx)+2);
                            img = imread(imgname.folder+"/"+imgname.name);
                            imwrite(img, strcat(FINALFOLDER_DWI,patientFold.name,"/",index,'.png'))
    
                            p_index = getIndexFromPatient(patientFold.name, n_fold);
                            % search if there is an annotations saved
                            annot_name = strcat(study_fold.folder, "/", study_fold.name, "/", prefix_annot, p_index, "_", extractBefore(imgname.name,".png"), "_core.png");
                            annot = zeros(size(img));
                            if exist(annot_name,"file")
                                annot = imread(annot_name);
                            end

                            imwrite(annot,strcat(DWI_GT+patientFold.name,"/",index,'.png'))
                        end
                    end
                end
            end
        end
        end
    end
    end
end
end