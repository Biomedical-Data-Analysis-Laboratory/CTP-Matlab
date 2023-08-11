clear;
clc;
close all;

addpath('NIfTI_20140122');

pathNCCTImage = ['NCCT.nii.gz'];
PathNCCT_Brain = ['NCCT_brain.nii.gz'];

disp(['Strip skull of patient ' pathNCCTImage]);

% load the subject image
ImgSubj_nii = load_untouch_nii(pathNCCTImage);
ImgSubj_hdr = ImgSubj_nii.hdr;
ImgSubj = ImgSubj_nii.img;
%ImgSubj = double(ImgSubj);

% skull stripping
NCCT_Thr = 100; % for NCCT images
CTA_Thr = 400; % for CTA images

[brain] = SkullStripping(double(ImgSubj),NCCT_Thr);

% save image
Output_nii.hdr = ImgSubj_hdr;
Output_nii.img = int16(brain);
save_nii(Output_nii, PathNCCT_Brain);

disp([pathNCCTImage '----skull tripping finished']);


skullStripList = zeros(512,512,30);
c = 1;
for i = patImage{1, 1}
    if c==1
        figure,imhist(int16(i{1,1}) * 1 - 1024)
    end
    skullStripList(:,:,c) = int16(i{1,1}) * 1 - 1024;
    c = c+1;
end

CTP_Thr = 600; % for CTA images
brainList = SkullStripping(skullStripList,CTP_Thr);

figure,imshow(int16(brainList(:,:,brainIdx)),[])
figure,imshow(double(brainList(:,:,brainIdx)))
for brainIdx = 1:size(brainList,3)
figure,imshow(int16(brainList(:,:,brainIdx)),[])
figure,imshow(double(brainList(:,:,brainIdx)))
end