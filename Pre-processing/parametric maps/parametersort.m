close all
clear all
times=blanks(13);
slices=[19 ones(1,7)*13 22 14 14];
for p=9:9
    if p<10
    sti=['PerfusionCT2/PA0' num2str(p) '/ST000000/SE000007/'];
    else
        sti=['PerfusionCT2/PA' num2str(p) '/ST000000/SE000007/'];
    end
    info=cell(1);
    ny3=cell(1);
    ny4=0;
    for i=1:slices(p)
        %     figure
        %     info{i+1}=dicominfo(['PerfusionCT2/PA02/ST000000/SE000007/IM00000' num2str(i)]);
%         sti='PerfusionCT2/PA02/ST000000/SE000007/IM00000'
        if i<11
            %         imshow(dicomread(['PerfusionCT2/PA02/ST000000/SE000007/IM00000' num2str(i-1)]))
            info{i}=dicominfo([sti 'IM00000' num2str(i-1)]);
            
        else
            %         imshow(dicomread(['PerfusionCT2/PA02/ST000000/SE000007/IM0000' num2str(i-1)]))
            info{i}=dicominfo([sti 'IM0000' num2str(i-1)]);
            
        end
        
        ny3{i}=info{i}.MediaStorageSOPInstanceUID;
        ny4(i)=str2num(ny3{i}(end-2:end));
    end
    
    ny4=ny4'-min(ny4);
    
    aaa{p}=sortrows([ny4 linspace(1,slices(p),slices(p))']);
    % sort([ny ny2])
    
    
    % cell2mat(arrrr)
end
%%
if 1
    close all
    for i=1:slices(p)
        figure
        %     info{i+1}=dicominfo(['PerfusionCT2/PA02/ST000000/SE000007/IM00000' num2str(i)]);
        j=aaa{p}(i,2)-1;
        %     j=i-1;
        if j<10
            imshow(dicomread([sti 'IM00000' num2str(j)]))
            %         info{i}=dicominfo(['PerfusionCT2/PA02/ST000000/SE000007/IM00000' num2str(i-1)]);
            
        else
            imshow(dicomread([sti 'IM0000' num2str(j)]))
            %         info{i}=dicominfo(['PerfusionCT2/PA02/ST000000/SE000007/IM0000' num2str(i-1)]);
            
        end
        
    end
end
