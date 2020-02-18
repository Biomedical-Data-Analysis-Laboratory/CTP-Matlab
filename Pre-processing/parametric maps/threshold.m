function mask = threshold(im, bar, i_t, range)
[m,n,~]=size(im);
mask=false(m,n);
BW={false(m,n,3)};
T=zeros(1,3);
if isequal(range,'over')
    for i=1:i_t
        for j=1:3
            T(j)=bar(i,1,j);
            BW{:,:,j}=im(:,:,j)==T(j);
        end
        mask=mask|(BW{1}&BW{2}&BW{3});
    end
elseif isequal(range,'under')
    for i=i_t:length(bar)
        for j=1:3
            T(j)=bar(i,1,j);
            BW{:,:,j}=im(:,:,j)==T(j);
        end
        mask=mask|(BW{1}&BW{2}&BW{3});
    end
end