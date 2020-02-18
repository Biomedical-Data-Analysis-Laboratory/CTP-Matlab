%% CALCULATE GLCMs FROM THE IMAGES OF HEMISPHERES
for i=1:rows
    for j = 1:columns
     
        GLCM2_frisk{i,j} = graycomatrix(roi_left{i,j},'Offset',[3 0]);
        GLCM2_syk{i,j}   = graycomatrix(roi_right{i,j},'Offset',[3 0]);
    end
end
%%
glcm_healthy_temp = cell2mat(GLCM2_frisk);
glcm_imapired_temp = cell2mat(GLCM2_syk);
%%

glcm_healthy_temp = permute(reshape(glcm_healthy_temp, 8, rows, 240), [1 3 2]);
glcm_imapired_temp = permute(reshape(glcm_imapired_temp, 8, rows, 240), [1 3 2]);

glcm_frisk = mean(glcm_healthy_temp,3);
glcm_syk = mean(glcm_imapired_temp,3);

%%
[rows, columnsglcm] =  size(glcm_frisk)
for i=1:columnsglcm/8
    stats_healthy(i) = GLCM_Features1(glcm_frisk(:,(i-1)*8+1:i*8),0)
    stats_impaired(i) = GLCM_Features1(glcm_syk(:,(i-1)*8+1:i*8),0)
    
end