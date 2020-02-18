function [D_slice] = VesselClustering(D_slice,kkk)
% Clustering of vessel segments to determine if it is an artery or a vein.
% The features used are the time to peak (ttp) and maximal change in
% attenuation (A).
figure

for kkk=1:4

D = cell2mat(D_slice);
D_orig = D;
numseg = cellfun('length',D_slice);

D = normalize(D,1);

if kkk>2
    D = [D(:,3) D(:,2)];
% end
else
    D = [D(:,1) D(:,2)];
end
if kkk==2 || kkk==4
    [c1,centr] = kmeans(D(:,1),2,'Distance','sqeuclidean','Replicates',4);
else
    [c1,centr] = kmeans(D,2,'Distance','sqeuclidean','Replicates',3);
end

D = D_orig;

subplot(2,2,kkk)

centrTTP=[centr];
[~,ind] = min(centrTTP);

if ind==1
    plot(D(c1 == 1,1),D(c1 == 1,2),'r.','MarkerSize',12)
    hold on
    plot(D(c1 == 2,1),D(c1 == 2,2),'b.','MarkerSize',12)
    legend('Artery','Vein')
    
else
    c1 = mod(c1,2)+1;
%     disp('nei')
    
    plot(D(c1 == 1,1),D(c1 == 1,2),'r.','MarkerSize',12)
    hold on
    plot(D(c1 == 2,1),D(c1 == 2,2),'b.','MarkerSize',12)
    legend('Artery','Vein')
end

xlabel('TTP')
ylabel('A')
% 
title(['(' num2str(kkk) ')'])
end

for i = 1:length(numseg)
    if i == 1  
%         c1(1:numseg(i))
        D_slice{i}(:,3) = c1(1:numseg(i));
    else
        D_slice{i}(:,3) = c1(sum(numseg(1:i-1))+1:sum(numseg(1:i-1))+numseg(i));
%         length
    end
end