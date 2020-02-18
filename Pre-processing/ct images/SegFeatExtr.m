function [D,c,imdiff_origs,imdiffF] = SegFeatExtr(Im)
% Finds vessel-like segments using feature extraction. 
%
% This method relies on the work of Midas Meijs, Ajay Patel, Sil C. van de
% Leemput, Mathias Prokop, Ewoud J. van Dijk, Frank-Erik de Leeuw,
% Frederick J. A. Meijer, Bram van Ginneken & Rashindra Manniesing in
% "Robust Segmentation of the Full Cerebral Vasculature in 4D CT of
% Suspected Stroke Patients", available here:
% https://www.nature.com/articles/s41598-017-15617-w

se = strel('disk',1); % Structuring element used in a local neighborhood.

n = length(Im);

TVF = cell(1,n);
TV_STDF = cell(1,n);
TV_EF = cell(1,n);
BF = cell(1,n);
meanF = cell(1,n);
Im1F = cell(1,n);
imdiffF = cell(1,n);

imdiff_origs = cell(1,n);

for i = 1:n
    ImAll = Im{i}; % All the temporal images in a slice
    Im1 = ImAll(:,:,1); % The first temporal image
    
    maxIP = max(ImAll,[],3);
    minIP = min(ImAll,[],3);
    [~,~,v] = find(minIP);
    minIP(minIP<900 & minIP>100) = mean(v);
    [~,~,v] = find(maxIP);
    maxIP(maxIP<900 & maxIP>100) = mean(v);
    
    imdiff = (imabsdiff(maxIP,minIP));
    imdiff = imbilatfilt(imdiff,'degreeOfSmoothing',100,'SpatialSigma',3);
    imdiff = imdiff.*uint16(~bwperim(imdiff>1));
    
    imdiff_orig = imdiff;
    
    imdiff(imdiff>750 | imdiff<15) = 0;
    imdiffMask = imdiff>0;
    [~,~,v] = find(imdiff);
    imdiff(imdiff<3) = mean(v);
    
    TV = uint16(var(double(ImAll),0,3)).*uint16(imdiffMask);
    
    % Local entropy calculation of TV in the neighboorhood defined by se
    TV_E = entropyfilt(TV,se.Neighborhood);
    TV_STD = stdfilt(TV,se.Neighborhood);
    
    B = fibermetric(TV,linspace(2,18,9),'StructureSensitivity',15);
    
    % The feature vectors
    imdiffF{i} = reshape(double(imdiffMask).*double(imdiff),512^2,1);
    TVF{i} = reshape(double(imdiffMask).*double(TV),512^2,1);
    BF{i} = reshape(double(imdiffMask).*double(B),512^2,1);
    Im1F{i} = reshape(double(imdiffMask).*double(Im1),512^2,1);
    meanF{i} = reshape(double(imdiffMask).*double(mean(double(ImAll),3)),512^2,1);
    TV_STDF{i} = reshape(double(imdiffMask).*double(TV_STD),512^2,1);
    TV_EF{i} = reshape(double(imdiffMask).*double(TV_E),512^2,1);
    
    % Set the non-zero elements to NaN, so they don't interfere with the
    % clustering.
    TVF{i}(imdiffF{i} == 0) = NaN;
    TV_STDF{i}(imdiffF{i} == 0) = NaN;
    TV_EF{i}(imdiffF{i} == 0) = NaN;
    BF{i}(imdiffF{i} == 0) = NaN;
    meanF{i}(imdiffF{i} == 0) = NaN;
    Im1F{i}(imdiffF{i} == 0) = NaN;
    imdiffF{i}(imdiffF{i} == 0) = NaN;
    imdiff_origs{i} = imdiff_orig;
end

D = normalize([...
    reshape(cell2mat(TVF),2^18*length(TVF),1)...
    reshape(cell2mat(imdiffF),2^18*length(TVF),1)...
    reshape(cell2mat(BF),2^18*length(TVF),1)...
    reshape(cell2mat(TV_STDF),2^18*length(TVF),1)...
    reshape(cell2mat(TV_EF),2^18*length(TVF),1)...
    reshape(cell2mat(meanF),2^18*length(TVF),1)...
    reshape(cell2mat(Im1F),2^18*length(TVF),1)],...
    1,'norm');
%
c = kmeans(D,2,'Distance','cosine','Replicates',10);
% cMat = reshape(c,512,512,1);