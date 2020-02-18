close all
clc
clear
load sortMaps


slices=[19 ones(1,7)*13 22 14 14];

figs=0; % Vis figurar? 1=ja, 0=nei
tic
name={'CBF' 'CBV' 'TTP' 'TMAX'};
pasient=cell(1, 11);
bilde=cell(1, 22);
map=[0 255 255;0 0 153]/255; % Fargar for penumbra og kjerne
for p=1:11
    if p<10
        pasient{p}=['0' num2str(p)];
    else
        pasient{p}=num2str(p);
    end
end

for k=0:21
    if k<10
        bilde{k+1}=['0' num2str(k)];
    else
        bilde{k+1}=num2str(k);
    end
end



for k=1:22
    if k<10
        bilde2{k}=['0' num2str(k)];
    else
        bilde2{k}=num2str(k);
    end
end
%% Terskelverdiar
tCBF=30;    % tal mellom 0 og 100. Absolutt.
tCBV=1.25;     % tal mellom 0 og 6
tTTP=15;     % tal mellom 0 og 20
tTMAX=6;    % tal mellom 0 og 12
rCBF=0.25    ;  % Relativ CBF, tal mellom 0 og 1.
%% Structuring elements
seTMAX = strel('disk',12);
seCBF = strel('disk',5);
seCBV = strel('disk',5);
%% Angir intervall for dei ulike parametra
tCBF_range_orig=linspace(100,0,256);
tCBV_range_orig=linspace(6,0,256);
tTTP_range_orig=linspace(20,0,256);
tTMAX_range_orig=linspace(12,0,256);
uu=zeros(11,24,4);
%% Heile driten

for p=1:1
    a=dir(['PerfusionCT2/PA' num2str(pasient{p}) '/ST000000/SE000005/']);
    info=dicominfo(['PerfusionCT2/PA' num2str(pasient{p}) '/ST000000/SE000005/IM000000']);
    pixelarea=info.PixelSpacing;
    pixelarea=pixelarea(1)*pixelarea(2);
    for k=slices(p):-1:1
        %str2double(a(end).name(end-2:end))
%         sortMaps{p}(k,2)
        [imCBF,imCBV,imTTP,imTMAX]=readMaps(pasient{p},bilde{sortMaps{p}(k,2)});
        
        % figure
        % subplot(2,2,1), imshow(imCBF), title('CBF')
        % subplot(2,2,2), imshow(imCBV), title('CBV')
        % subplot(2,2,3), imshow(imTTP), title('TTP')
        % subplot(2,2,4), imshow(imTMAX), title('TMAX')
        
        [imCBF,barCBF,~]=removeBar(imCBF);
        [imCBV,barCBV,barC]=removeBar(imCBV);
        [imTTP,barTTP,barT]=removeBar(imTTP);
        [imTMAX,barTMAX,~]=removeBar(imTMAX);
%         figure
%         imshow(imTTP)
        if 1
        if figs
            figure
            subplot(141),imshow(imCBF),title('CBF')
            subplot(142),imshow(imCBF(:,:,1)),title('Red')
            subplot(143),imshow(imCBF(:,:,2)),title('Green')
            subplot(144),imshow(imCBF(:,:,3)),title('Blue')
            
            figure
            subplot(141),imshow(imTMAX),title('TMAX')
            subplot(142),imshow(imTMAX(:,:,1)),title('Red')
            subplot(143),imshow(imTMAX(:,:,2)),title('Green')
            subplot(144),imshow(imTMAX(:,:,3)),title('Blue')
        end
        if k==0
            barCBF_orig=barCBF;
            barCBV_orig=barCBV;
            barTTP_orig=barTTP;
            barTMAX_orig=barTTP;
        end
        dimCBV=size(imCBV);


        %% Legg til fargeverdiar som ikkje er i skalaen
        for j=1:4
            im_Reshape=reshape(eval(['im' name{j}]),dimCBV(1)*dimCBV(2),3);
            t_range=eval(['t' name{j} '_range_orig']);
            
            if j==1 || j== 2
                bar=barC;
            elseif j==3 || j==4
                bar=barT;
            end
            bar_orig=reshape(bar,256,1,3);
            im_Reshape( all(~im_Reshape,2), : ) = [];
            [C,~,~] = unique(im_Reshape,'rows');
            uu(p,k+1,j)=length(C);
            C(:,4)=NaN;
            barHSV=reshape(rgb2hsv(bar_orig),256,3,1);
            %             medlem=ismember(reshape(C(:,1:3),length(C),3,1),reshape(bar_orig,256,3,1),'rows');
            %             medlem=find(~medlem);
            %             medlem=length(medlem);
            %             uuu(k,m+1,j)=medlem;
            range2=[barHSV t_range'];
            range=double(cat(1,range2,double(C)));
            
            Chsv=reshape(range(257:end,1:3),length(range(257:end,1:3)),1,3);
            hsvans=reshape(rgb2hsv(uint8(Chsv)),length(rgb2hsv(Chsv)),3,1);
            
            hsvans(:,4)=NaN;
            range(257:end,:)=hsvans;
            range3=range;
            range=sortrows(range,[1 -2 3]);
            range3=range;
            for i=1:length(range)
                if isnan(range(i,4))
                    if i==1
                        range(i,4)=max(range2(:,4));
                    elseif i<length(range)
                        indD=i;
                        indI=i;
                        while indD>1 && isnan(range(indD,4))
                            indD=indD-1;
                        end
                        while indI<length(range) && isnan(range(indI,4))
                            indI=indI+1;
                        end
                        if indD==1
                            range(i,4)=max(range2(:,4));
                        elseif indI==length(range)
                            range(i,4)=0;
                        else
                            range(i,4)=mean([range(indD,4) range(indI,4)]);
                        end
                    elseif i==length(range)
                        range(i,4)=0;
                    end
                end
            end
            
            range=sortrows(range,-4);
            t_range=range(:,4);
            bar=uint8(hsv2rgb(reshape(range(:,1:3),length(range(:,1:3)),1,3))*255);
            eval(['bar' name{j} '=bar;']);
            eval(['t' name{j} '_range=t_range;']);
            %             bars
        end
        
        %% Indeks for terskelverdiar
        [~,i_tCBF]=min(abs(tCBF_range-tCBF));
        [~,i_tCBV]=min(abs(tCBV_range-tCBV));
        [~,i_tTTP]=min(abs(tTTP_range-tTTP));
        [~,i_tTMAX]=min(abs(tTMAX_range-tTMAX));
        %% Lagar maske ut frå terskling, TMAX
        maskTMAX=threshold(imTMAX,barTMAX,i_tTMAX,'over');
        %% Finn ROI ut frå TMAX
        if k==slices(p)
            midt=round(size(maskTMAX,2)/2);
            left=numel(find(maskTMAX(:,midt:end)));
            right=numel(find(maskTMAX(:,1:midt-1)));
            
            if left>right
                ROI='L';
                maskTMAX(:,1:midt-1)=0;
                imCBF_cl=imCBF(:,midt:end,:); % CBF i frisk hjernehalvdel
            else
                ROI='R';
                maskTMAX(:,midt:end)=0;
                imCBF_cl=imCBF(:,1:midt-1,:); % CBF i frisk hjernehalvdel
            end
            
            %         disp(['Slag lokalisert i ' ROI ' hjernehalvdel'])       
        else
            if ROI=='L'
                maskTMAX(:,1:midt-1)=0;
                imCBF_cl=imCBF(:,midt:end,:);
            else
                maskTMAX(:,midt:end)=0;
                imCBF_cl=imCBF(:,1:midt-1,:);
            end
                
        end
        %% Finn contralateral CBF
        dim_imCBF_cl=size(imCBF_cl);
        imCBF_cl=reshape(imCBF_cl,dim_imCBF_cl(1)*dim_imCBF_cl(2),3);
        imCBF_cl( all(~imCBF_cl,2), : ) = [];
        mean_CBF_cl=uint8(mean(imCBF_cl));
        barCBFHSV=rgb2hsv(barCBF);
        mean_CBF_clHSV=rgb2hsv(reshape(mean_CBF_cl,1,1,3));
        
        
        barCBFHSV=[reshape(barCBFHSV,length(barCBFHSV),3,1) tCBF_range];
        mean_CBF_clHSV=[reshape(mean_CBF_clHSV,1,3,1) NaN];
        barCBFHSV=[barCBFHSV;mean_CBF_clHSV];
        barCBFHSV=sortrows(barCBFHSV,1);
        ind=find(isnan(barCBFHSV(:,4)));
        if ind<length(barCBF)
            meanCBF=mean([barCBFHSV(ind+1,4) barCBFHSV(ind-1,4)]);
            tCBF=rCBF*meanCBF;
            met='Relativ';
        else
            disp('nei')
            tCBF=30;
            met='Absolutt';
        end
        %% Filtrerer maske, TMAX
        maskTMAX=uint8(maskTMAX);
        if figs
            figure
            subplot(3,3,1)
            
            imshow(maskTMAX,[]),title('MaskeTMAX før filtrering')
        end
        maskTMAX = imclose(maskTMAX,seTMAX);
        
        maskTMAX = imgaussfilt(maskTMAX,5);
        
        maskTMAX=bwareafilt(logical(imfill(maskTMAX,8)),1);
        if figs
            subplot(3,3,2)
            imshow(maskTMAX,[]),title('MaskeTMAX etter filtrering')
        end
        %% Lagar maske ut frå terskling, CBF
        maskCBF=threshold(imCBF,barCBF,i_tCBF,'under');
        % imshow2(maskCBF),title('maskCBF')
        % imshow2(imfuse(imCBF,maskCBF,'blend')), title('imCBF,maskCBF')
        %% Lagar maske ut frå terskling, CBV
        maskCBV=threshold(imCBV,barCBV,i_tCBV,'under');
        % imshow2(maskCBV),title('maskCBV')
        % imshow2(imfuse(imCBV,maskCBV,'blend')), title('imCBV,maskCBV')
        %% Filtrerer maske, CBV
        maskCBV=uint8(maskCBV&maskTMAX);
        if figs
            subplot(3,3,7)
            imshow(maskCBV,[]),title('MaskeCBV før filtrering')
        end
        maskCBV=imfill(maskCBV,8);
        
        maskCBV = imgaussfilt(maskCBV,4);
        
        maskCBV = imclose(maskCBV,seCBV);
        
        maskCBV=imgaussfilt(maskCBV,3);
        maskCBV=bwareafilt(logical(maskCBV),1);
        if figs
            subplot(3,3,8)
            imshow(maskCBV,[]),title('MaskeCBV etter filtrering')
        end
        %% Filtrerer maske, CBF
        maskCBF=uint8(maskCBF&maskTMAX);
        if figs
            subplot(3,3,4)
            imshow(maskCBF,[]),title('MaskeCBF før filtrering')
        end
%         maskCBF=imfill(maskCBF,8);
        
%         maskCBF = imgaussfilt(maskCBF,4);
        
%         maskCBF = imclose(maskCBF,seCBF);
        
        maskCBF=imgaussfilt(maskCBF,5);
%         maskCBF=bwareafilt(logical(maskCBF),1);
        
        if figs
            subplot(3,3,5)
            imshow(maskCBF,[]),title('MaskeCBF etter filtrering')
        end
        %% Filtrerer maske, TMAXCBF
        %Bestemmer penumbra og infarktkjerne ut frå TMAX-CBV mismatch
        if figs
            subplot(3,3,3)
            imshow(imfuse(imTMAX,maskTMAX,'blend')),title('ROI')
        end
        labels=label2rgb(uint8(maskTMAX)*1+uint8(maskCBF)*1,map);
        if figs
            subplot(3,3,6)
            imshow(labels),title(['Kjerne og penumbra, TMAX-CBF ' met])
        end
        labels2=label2rgb(uint8(maskTMAX)*1+uint8(maskCBV)*1,map);
        if figs
            subplot(3,3,9)
            imshow(labels2),title('Kjerne og penumbra, TMAX-CBV')
        end
        if 1

                MIP_markering=imread(['CT_perfusion_markering/Patient' pasient{p} '/' pasient{p} bilde2{k} '.jpg'] );
                

                
         
            dim=size(MIP_markering);
            % (dim(2)-512)/2
            MIP_markering_ny=imresize(MIP_markering,512/dim(1));
            dim2=size(MIP_markering_ny);
            MIP_markering_ny(:,1:round((dim2(2)-512)/2),:)=[];
            MIP_markering_ny(:,513:end,:)=[];
%             figure
%             imshow(MIP_markering_ny)
%             hold on
%             visboundaries(bwboundaries(maskTMAX),'color','c','LineWidth',1,'EnhanceVisibility',false), title('Countor of the brain')
%             hold on
%             visboundaries(bwboundaries(maskCBV),'color','m','LineWidth',1,'EnhanceVisibility',false), title('Countor of the brain')
            areal{p}{k}=numel(find(maskTMAX==1))*pixelarea;
            
            arealCore{p}{k}=numel(find(maskCBV==1))*pixelarea;
            if (p==3 & k==11) | (p==1 & k==19)  | (p==5 & k==7) | (p==8 & k==8)
                disp('ja')
                areal{p}{k}=0;
                arealCore{p}{k}=0;
            end
%             title(num2str(areal{p}{k}))
        end
        %print(['Figurer/PA' pasient{k} '_IM' bilde{m+1}],'-dpng')
        end
    end
end
toc