function [V, out] = objectiveFunctionRasmus(V, nTimes, sizeImage)
    
    out = [];

    options = optimset('MaxIter',nTimes); %, 'PlotFcns',@optimplotfval);
    
    for v=1:size(V,2)
        V{v} = double(V{v});
        
        preC0 = var(double(V{v}));
        
        for chann = 1:size(V{v},2)
            xi = V{v}(:,chann);
            xhat = mean(xi);
%             C0 = preC0(chann);
            C0 = var(nonzeros(xi));

            pixelsPerImage = numel(xi)/4; % divide the set per image to have the pixels of each image
            for imgIdx=1:4
                tmpXI = xi(pixelsPerImage*(imgIdx-1)+1:pixelsPerImage*(imgIdx));
                tmpOut = 0;
                
                splitVect = numel(tmpXI)/sizeImage(1); % each row!
                for splitIdx=1:sizeImage(1)
                    splitXI = tmpXI(splitVect*(splitIdx-1)+1:splitVect*(splitIdx));

                    C = fminsearch(@(C) minimizeRasmus(splitXI, xhat, C), C0, options);
                    x = fminsearch(@(setX) minimizeRasmus(setX, xhat, C), splitXI, options);
                    

                    tmpOut = tmpOut + minimizeRasmus(x, xhat, C);
                    
                    tmpXI(splitVect*(splitIdx-1)+1:splitVect*(splitIdx)) = x;

                end
    
                out = cat(1, out, tmpOut);
                xi(pixelsPerImage*(imgIdx-1)+1:pixelsPerImage*(imgIdx)) = tmpXI;
            end
            
            V{v}(:,chann) = xi;
        end
    end
        
end
    
    
%     for v=1:size(V,2)
%         V{v} = double(V{v});
%         for chann = 1:size(V{v},3)
%             preC0 = var(double(V{v}));
%             xi = V{v};
%             
%             for imgIdx = 1:size(preC0,4)
%                 C0 = preC0(:,:,chann,imgIdx);
%                 C = fminsearch(@(C) norm(minimizeRasmus(xi, chann, imgIdx, C)), C0, options);
%                 
%                 %xi = 
%                 V{v}(:,:,chann,imgIdx) = minimizeRasmus(xi, chann, imgIdx, C);
%             end
%             
%         end
%     end
%         
% end
% 
% 
function out = minimizeRasmus(setX, xhat, C)
    diffXi = setX - xhat;
    out = 0;
    for x=1:numel(diffXi)
        out = out + ( transpose(diffXi(x)) .* (C .* diffXi(x)) );
    end
end

