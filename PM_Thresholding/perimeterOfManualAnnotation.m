clear;
close all;

patients = 8;
% WINDOWS
FOLDER = 'C:/Users/Luca/OneDrive - Universitetet i Stavanger/Master_Thesis/CT_perfusion_markering_processed_2.0/COMBINED_GRAYAREA_2.0/';


core = 150;
penumbra = 76;

listOfPatients = cell(size(patients));

for p=1:numel(patients)
    name = num2str(patients(p));
    if length(name) == 1
        name = strcat('0', name);
    end
    listOfPatients{p} = "Patient" + name;
end 

for patient = listOfPatients
    subFolder = strcat(FOLDER, patient{1});
    elements = dir(subFolder);
    
    for idx=1:numel(elements)
        if idx <=2 
           continue 
        end
        
        I = imread(strcat(subFolder, '/', elements(idx).name));
        Igray = rgb2gray(I);
        I_penumbra = Igray==penumbra; 
        I_core = Igray==core; 
        
        imshow(I);
        hold on
        visboundaries(I_penumbra,'Color','b'); 
        visboundaries(I_core,'Color','magenta'); 
    end
end