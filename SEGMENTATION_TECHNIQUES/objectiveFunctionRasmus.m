function [V, out] = objectiveFunctionRasmus(V, nTimes, sizeImage)
    
    out = [];

    options = optimset('MaxIter',nTimes);%, 'PlotFcns',@optimplotfval);
    
%         V{v} = double(V{v});
%         
%         preC0 = var(double(V{v}));
        
    for repetition = 1:10 
        for chann = 1:3

            for imgIdx=1:4
                aggXI = cell(1, sizeImage(1));
                arrC = [];
                arrXHAT = [];
                tmpOut = 0;

                for v=1:size(V,2)

                    xi = double(V{v}(:,chann));
                    xhat = mean(xi);
            %             C0 = preC0(chann);
                    C0 = var(nonzeros(xi));

                    arrXHAT = cat(2, arrXHAT, xhat);
                    arrC = cat(2, arrC, C0);

                    pixelsPerImage = numel(xi)/4; % divide the set per image to have the pixels of each image

                    tmpXI = xi(pixelsPerImage*(imgIdx-1)+1:pixelsPerImage*(imgIdx));


                    splitVect = numel(tmpXI)/sizeImage(1); % each row!
                    for splitIdx=1:sizeImage(1)
                        splitXI = tmpXI(splitVect*(splitIdx-1)+1:splitVect*(splitIdx));
                        aggXI{1,splitIdx} = cat(2, aggXI{1,splitIdx}, splitXI);

    %                     C = fminsearch(@(C) minimizeRasmus(splitXI, xhat, C), C0, options);
    %                     x = fminsearch(@(setX) minimizeRasmus(setX, xhat, C), splitXI, options);
    % 
    % 
    %                     tmpOut = tmpOut + minimizeRasmus(x, xhat, C);
    % 
    %                     tmpXI(splitVect*(splitIdx-1)+1:splitVect*(splitIdx)) = x;

                    end

    %                 out = cat(1, out, tmpOut);
    %                 xi(pixelsPerImage*(imgIdx-1)+1:pixelsPerImage*(imgIdx)) = tmpXI;
                end

                for splitIdx=1:sizeImage(1)
                    splitXI = aggXI{1,splitIdx};

                    newX = zeros(size(splitXI));

                    for row=1:size(splitXI,1)
                        splitRow = splitXI(row,:);
    %                     C = fminsearch(@(C) minimizeRasmus(splitRow, arrXHAT, C), arrC, options);
                        x = fminsearch(@(setX) minimizeRasmus(setX, arrXHAT, arrC), splitRow, options);

                        newX(row,:) = x;
                        tmpOut = tmpOut + minimizeRasmus(x, arrXHAT, arrC);
                    end

                    for v=1:size(V,2)
                        xi = double(V{v}(:,chann));

                        pixelsPerImage = numel(xi)/4; % divide the set per image to have the pixels of each image
                        tmpXI = xi(pixelsPerImage*(imgIdx-1)+1:pixelsPerImage*(imgIdx));
                        splitVect = numel(tmpXI)/sizeImage(1); % each row!
                        tmpXI(splitVect*(splitIdx-1)+1:splitVect*(splitIdx)) = newX(:,v);
                        xi(pixelsPerImage*(imgIdx-1)+1:pixelsPerImage*(imgIdx)) = tmpXI;
                        V{v}(:,chann) = xi;
                    end

                end

    %             V{v}(:,chann) = xi;
            end
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
    out = 0;
    for k=1:3
        diffXi = setX(:,k) - xhat(k);
        
        for x=1:numel(diffXi)
            out = out + ( transpose(diffXi(x)) .* (C(k) .* diffXi(x)) );
        end
    end
end

