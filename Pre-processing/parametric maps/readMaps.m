function [imCBF,imCBV,imTTP,imTMAX] = readMaps(pasient,bilde)
%% Les inn parametriske kart
sti = (['PerfusionCT2/PA' pasient '/ST000000/SE00000']);

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