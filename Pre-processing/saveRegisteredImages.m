function saveRegisteredImages(NewImageRegistered, saveRegisteredFolder, patients)
%SAVEREGISTEREDIMAGES Summary of this function goes here
%   Detailed explanation goes here
    for p=patients
        if p<10
            newFolder = strcat("PA0", num2str(p));
        else
            newFolder = strcat("PA", num2str(p));
        end
        status = mkdir(char(saveRegisteredFolder), char(newFolder));
        
        if status 
            for k=1:length(NewImageRegistered{p})
                subFolder = char(strcat(saveRegisteredFolder, newFolder, '/'));
                status1 = mkdir(subFolder, char(num2str(k)));
                if status1
                    for i=1:length(NewImageRegistered{p}{k})
                        index = num2str(i);
                        if i<10
                            index = strcat("0", num2str(i));
                        end
                        
                        imwrite(mat2gray(NewImageRegistered{p}{k}{i}),char(strcat(subFolder, num2str(k), "/", index, ".png")));
                    end
                end
                
            end
        end
        
    end
end

