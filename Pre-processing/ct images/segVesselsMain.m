% This is the main script of the vessel segmentation and clustering.

clear all
close all
warning off

slices = [ones(1,8,'uint8')*13 22 14 14];
thickness2 = linspace(2,6,3);
load timesec

se = strel('disk',2);

FeatExtr = 1; % feature extraction segmentation = 1, adaptive threshold segmentation = 0
seg3D = 1; % Perform the cluster-based segmentation in 3D.
%%
close all

tic
for p = 2
    D_Slice = cell(slices(p),1);
    if p<10
        load(['ImagesPA0' num2str(p)])
    else
        load(['ImagesPA' num2str(p)])
    end
    
    imdiff_orig = cell(1,slices(p));
    L_slice = imdiff_orig;
    ImmS = cell(1,slices(p));
    for k = 1:slices(p)
        I = Im{k};
        
        Imm = zeros(512,512,30,'uint16');
        ImmOrig = false(512,512,30);
        
        for i = 1:30
            Imm(:,:,i) = I{i};
            im = Imm(:,:,i);
            ImmOrig(:,:,i) = im>0;
            [~,~,v2] = find(im);
            im(im == 0) = mean(v2);
            Imm(:,:,i) = im;
        end
        
        Imm = imgaussfilt3(Imm,[0.25 0.25 1]);
        ImS{k} = Imm.*uint16(ImmOrig);

        if ~seg3D
            
            if FeatExtr
                [BW,imdiff,imdiff_orig{k}] = SegFeatExtr(ImS);
            else
                [BW,imdiff,imdiff_orig{k}] = SegAdaptThresh(Imm);
            end
            
            BW = imclose(BW,se);
            BW = logical(uint8(bwareaopen(BW,10)));
            %% 
            % This section uses code from
            % "Watershed transform question from tech support", by Steve Eddins
            % Available here: https://blogs.mathworks.com/steve/2013/11/19/watershed-transform-question-from-tech-support/
            
            D = -bwdist(~-BW);
            
            H_min = imhmin(D,4);
            BW_min = imregionalmin(H_min);
            
            D = imimposemin(D,BW_min);
            
            D(~BW)  =  Inf;
            L = watershed(D);
            L(~BW) = 0;
            %%
            realTTP = timesec{p}{k}(:)';
            
            [A,TTP,bFit,L] = fitTDC(imdiff,L,Imm,realTTP);
            L_slice{k} = L;
            D_Slice{k,:} = [TTP;A;bFit]';
        end
    end
    %%
    if FeatExtr && seg3D
        [D,c,imdiff_orig,imdiffF] = SegFeatExtr(ImS);
        
        cNy = reshape(c,2^18,length(imdiffF),1);
        cNy = reshape(cNy,512,512,length(imdiffF));
        
        for kk = 1:length(imdiffF)
            figure
            subplot(121)
            imshow(imdiff_orig{kk},[0 100])
            hold on
            [~,ind] = min([numel(find(cNy(:,:,kk) == 1)) numel(find(cNy(:,:,kk) == 2))]);
            
            bw = imclose(cNy(:,:,kk) == ind,se);
            bw = bwareaopen(bw,10);
            visboundaries(bwboundaries(bw),'color','g','LineWidth',1)
            subplot(122)
            imshow(bw)
        end
        
    end
    
    %% Cluster vessel segments and show the results
    if ~(FeatExtr && seg3D)
        close all
        
        [D] = VesselClustering(D_Slice);
        
        for k = 1:slices(p)
            
            figure
            imshow(imdiff_orig{k},[0 100])
            hold on
            
            Bwart = false(512,512);
            Bwven = false(512,512);
            
            for i = 1:max(max(L_slice{k}))
                if D{k}(i,3) == 1
                    Bwart = (L_slice{k} == i)|Bwart;
                elseif D{k}(i,3) == 2
                    Bwven = (L_slice{k} == i)|Bwven;
                end
            end
            
            visboundaries(bwboundaries(Bwart),'Color','r','LineWidth',1,'EnhanceVisibility',true)
            hold on
            visboundaries(bwboundaries(Bwven),'Color','b','LineWidth',1,'EnhanceVisibility',true)
        end
    end
end

