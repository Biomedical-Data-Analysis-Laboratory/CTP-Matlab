function [imCBF,imCBV,imTTP,imTMAX] = readMaps(pasient,bilde)
%% Les inn parametriske kart
sti = (['D:\SUS2020\PA' pasient '/ST000000/SE00000']);

indCBF = 4;
indCBV = 5;
if pasient == '07'
    indTMAX = 7;
    indTTP = 8;
else
    indTMAX = 6;
    indTTP = 7;
end

imCBF = dicomread([sti num2str(indCBF) '/IM0000' bilde]);
imCBV = dicomread([sti num2str(indCBV) '/IM0000' bilde]);
imTTP = dicomread([sti num2str(indTTP) '/IM0000' bilde]);
imTMAX = dicomread([sti num2str(indTMAX) '/IM0000' bilde]);

name = num2str(str2double(bilde)+1);
if length(name) == 1
    name = strcat('0', name);
end


imwrite(imCBF, strcat('D:\Preprocessed-SUS2020_v2\Parametric_maps\CTP_00_007\20200701-152200\CBF\', name, '.png'));
imwrite(imCBV, strcat('D:\Preprocessed-SUS2020_v2\Parametric_maps\CTP_00_007\20200701-152200\CBV\', name, '.png'));
imwrite(imTTP, strcat('D:\Preprocessed-SUS2020_v2\Parametric_maps\CTP_00_007\20200701-152200\TTP\', name, '.png'));
imwrite(imTMAX, strcat('D:\Preprocessed-SUS2020_v2\Parametric_maps\CTP_00_007\20200701-152200\TMAX\', name, '.png'));