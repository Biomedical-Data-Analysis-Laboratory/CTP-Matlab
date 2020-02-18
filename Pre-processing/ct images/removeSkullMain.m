% Main script to remove the skull. Use function removeSkull2 to use
% wavelet coefficient thresholding. Use function removeSkull to use
% traditional edge detection.

close all
warning off
% clear all
load ImageRegistered.mat
Image = ImageRegistered;
slices = ones(1,8)*13;
slices = [slices 22 14 14];

ImageSkullRemoved = cell(1,11);
%%
close all

for p = 2
    figure
    for k = 1:slices(p)
        for i = 1:1
            if i == 1
                Im_in = ImageRegistered{p}{k}{i};
                %[ImageSkullRemoved{p}{k}{i},bw] = removeSkull(Im_in); %Trad. edge detection
                [ImageSkullRemoved{p}{k}{i},bw] = removeSkull2(Im_in,14); % Wave.coeff thresh.    
            else
                ImageSkullRemoved{p}{k}{i} = Im_out;
            end
        end
        if 1
            if 0
                figure(p*100+k)
            end
            
            if p~=9
                subplot(4,4,k)
            else
                subplot(5,5,k)
            end
%             imshow(ImageSkullRemoved{p}{k}{i},[])
% %                      hold on
% %                      visboundaries(bwboundaries(bw),'color','r','LineWidth',1,'EnhanceVisibility',false)
% %                              hold on
% %                                      visboundaries(bwboundaries(bw),'color','c','LineWidth',1,'EnhanceVisibility',false), title('Countor of the brain')
%             hold on
%             visboundaries(bwboundaries(bw),'color','c',...
%                 'LineWidth',1,'EnhanceVisibility',false),
%             
%             title([{'Countor of the brain.'},...
%                 {['Patient 0' num2str(p) ', slice '...
%                 num2str(k)]}])
        end
    end
end

if 0
    save('ImageSkullRemoved.mat','ImageSkullRemoved','-v7.3');
end