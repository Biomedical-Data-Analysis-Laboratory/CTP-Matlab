function ImageSkullRemoved = generalSkullRemoval(ImageRegistered, patients, SAVE, workspaceFolder)
%GENERALSKULLREMOVAL 
%   Function to remove the skull from the images of the patients

    ImageSkullRemoved = cell(1,length(ImageRegistered));
    
%     disp(strcat('Patients: ', num2str(numPatients)))
    for patient=patients
        ImageSkullRemoved{patient} = cell(1,length(ImageRegistered{patient}));
%         disp(strcat("Slices:", num2str(length(ImageRegistered{patient}))))
        
        for slice=1:length(ImageRegistered{patient})
            ImageSkullRemoved{patient}{slice} = cell(1,length(ImageRegistered{patient}{slice}));
%             disp(strcat("Images:", num2str(length(ImageRegistered{patient}{slice}))))
            
            for image=1:length(ImageRegistered{patient}{slice})
                Im_in = ImageRegistered{patient}{slice}{image};
%                 [ImageSkullRemoved{patient}{slice}{image},bw] = removeSkull(Im_in); %Trad. edge detection
                [ImageSkullRemoved{patient}{slice}{image},~] = removeSkull2(Im_in,'bior1.5',14); % Wave.coeff thresh.    
%                 [ImageSkullRemoved{patient}{slice}{image},~] = removeSkull2(Im_in,'bior1.5',14); % Wave.coeff thresh.    
            end
        end
    end
    
    if SAVE
        save(strcat(workspaceFolder, 'ImageSkullRemoved.mat'),'ImageSkullRemoved','-v7.3');
    end

end

