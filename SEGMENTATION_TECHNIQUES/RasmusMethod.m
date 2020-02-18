function out = RasmusMethod(maskPenumbra, maskCore, iCBV, iCBF, iTTP, iTMAX)
%RASMUSMETHOD Summary of this function goes here
%   Detailed explanation goes here
    PAR_MAPS = {};
    PAR_MAPS{1} = iCBV;
    PAR_MAPS{2} = iCBF;
    PAR_MAPS{3} = iTTP;
    PAR_MAPS{4} = iTMAX;
    maskImage = uint8(ones(size(maskPenumbra)));
    
    %     zeroMatrix = uint8(zeros(512,512,3));
    
    maskPenumbra = uint8(maskPenumbra);
    RGBMaskPenumbra = repmat(maskPenumbra, [1,1,3]);
    %maskPenumbra = cat(3, maskPenumbra, maskPenumbra, maskPenumbra);
    maskCore = uint8(maskCore);
    RGBMaskCore = repmat(maskCore, [1,1,3]);
    %maskCore = cat(3, maskCore, maskCore, maskCore);
   
%     imageCBV = double(imageCBV);
%     imageCBF = double(imageCBF);
%     imageTTP = double(imageTTP);
%     imageTMAX = double(imageTMAX);

    maskImage = uint8(maskImage & (~maskPenumbra & ~maskCore));
    RGBMaskImage = repmat(maskImage, [1,1,3]);
    
    V = {};
    V{1} = [];
    V{2} = [];
    V{3} = [];
%     V{1} = cat(4, RGBMaskImage, RGBMaskImage, RGBMaskImage, RGBMaskImage);
%     V{2} = cat(4, RGBMaskPenumbra, RGBMaskPenumbra, RGBMaskPenumbra, RGBMaskPenumbra);
%     V{3} = cat(4, RGBMaskCore, RGBMaskCore, RGBMaskCore, RGBMaskCore);
    
    
    adding = [0,3,6,9];
    
    for y=[1,2,3,4]
        image = PAR_MAPS{y};
        
        for x=[1,2,3]
            if x==1
                mask =  maskImage .* image;
            elseif x==2
                mask = maskPenumbra .* image;
            else
                mask = maskCore .* image;
            end
            
            tmpV1 = reshape(mask(:,:,1), [numel(maskImage),1]);
            tmpV2 = reshape(mask(:,:,2), [numel(maskImage),1]);
            tmpV3 = reshape(mask(:,:,3), [numel(maskImage),1]);
            tmpV = cat(2, tmpV1, tmpV2, tmpV3);
            V{x} = cat(1, V{x}, tmpV);
%             V{x}(:,:,:,y) = V{x}(:,:,:,y).*image;
            
%             C{x}(:,:,x+adding(y)) = diag(var(double(V{x}(:,:,x+adding(y)))));
%             [out] = fminsearch(@objectiveFunctionRasmus,[V,C]);
        end
    end
    
%     for i=1:size(V,2)
%         V{i} = double(V{i});
%     end
%     
%     V = [double(V1), double(V2), double(V3)];
%     C = [double(C1), double(C2), double(C3)];
    
    oldV = reshapeV(V, size(maskImage));
    
    for y=[1,2,3,4]
        for x=[1,2,3]
            subplot(4,6,x+adding(y)), imshow(oldV{x,y})
        end
    end
    
    [newV, out] = objectiveFunctionRasmus(V, 10, size(maskImage));
    
    generatedImages = reshapeV(newV, size(maskImage));
    
    for y=[1,2,3,4]
        for x=[1,2,3]
            subplot(4,6,12+x+adding(y)), imshow(generatedImages{x,y})
        end
    end
%     for y=[1,2,3,4]
%         for x=[1,2,3]
%             subplot(4,6,12+x+adding(y))
%             %imshow(out{x}(:,:,:,y))
%             imshow(~ rgb2gray(out{x}(:,:,:,y)))
%         end
%     end
end


function [IMGS] = reshapeV(V, sizeImage)
    IMGS = cell(3,4);
    for v=1:size(V,2)
        for imgIdx=1:4
            IMGS{v,imgIdx} = uint8(zeros([sizeImage,3]));
            
            for chann = 1:size(V{v},2)
                row = V{v}(:,chann);
                pixelsPerImage = numel(row)/4;
                
                img = row(pixelsPerImage*(imgIdx-1)+1:pixelsPerImage*(imgIdx));
                
                IMGS{v,imgIdx}(:,:,chann) = reshape(img, sizeImage);
            end
        end
    end
end


