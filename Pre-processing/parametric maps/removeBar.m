function [Im,bar,bar2]=removeBar(Im)

bar=Im(129:384,455,:);
Im(:,432:end,:)=0;
Im(119:126,429:431,:)=0;
for i=1:3
    if i==1
        bar2(:,i)=bar(:,:,1);
    elseif i==2
        bar2(:,i)=bar(:,:,2);
    else
        bar2(:,i)=bar(:,:,3);
    end
end
% bar2(~any(bar2,2),:)=[];
% bar3(:,:,1)=bar2(:,1:50);
% bar3(:,:,2)=bar2(:,51:100);
% bar3(:,:,3)=bar2(:,101:150);
% imshow2(bar3)
end