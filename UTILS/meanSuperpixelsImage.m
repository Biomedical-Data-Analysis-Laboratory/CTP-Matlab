function [outputImage] = meanSuperpixelsImage(inputImage,L,N)
%MEANSUPERPIXELS Summary of this function goes here
%   Detailed explanation goes here

outputImage = zeros(size(inputImage),'like',inputImage);
idx = label2idx(L);

for labelVal = 1:N
    redIdx = idx{labelVal};
    outputImage(redIdx) = mean(inputImage(redIdx));
end    

% figure, imshow(outputImage,'InitialMagnification',67)

end

