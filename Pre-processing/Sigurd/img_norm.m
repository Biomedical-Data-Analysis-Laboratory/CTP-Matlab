function [s] = img_norm(image, newmin, newmax)


[r, c] = size(image);
Min =min(image(:));
Max =max(image(:));

for j=1:r
    
    for k=1:c
        R=image(j,k);
        s(j,k)=(R-Min).*((newmax-newmin)./(Max-Min))+newmin;
        
    end
end

end
