function ImageRegistered = extractFromFakePatient(directory, SAVE, workspaceFolder, suffix_workspace, SAVE_AS_TIFF)
%EXTRACTFROMFAKEPATIENT Summary of this function goes here
%   Detailed explanation goes here

save_prefix = '01_Extract.';
suffixsave = ".png";
if SAVE_AS_TIFF
    suffixsave = ".tiff";
end

n_fake = numel(dir(directory))-2;
id_pat = 1;

ImageRegistered = cell(1,n_fake);
for fake_p = dir(directory)'
    if ~strcmp(fake_p.name,".") && ~strcmp(fake_p.name,"..")
        patientFolder = dir(strcat(directory, fake_p.name));

        name = num2str(id_pat);
        if length(name) == 1
            name = strcat('0', name);
        end

        fname = workspaceFolder + convertCharsToStrings(save_prefix) + name + suffix_workspace + ".mat";
        if exist(fname, 'file')==2
            load(fname);
            ImageRegistered{id_pat} = patImage;
            id_pat = id_pat + 1;
            continue
        end
    
        n_slices = numel(patientFolder)-2;
        ImageRegistered{id_pat} = cell(1,n_slices);
        for subfold = patientFolder'
            if ~strcmp(subfold.name, '.') && ~strcmp(subfold.name, '..')
                k = str2double(subfold.name);
                subsubfold = dir(strcat(subfold.folder, '\', subfold.name));
                
                count = numel(subsubfold)-2;
                ImageRegistered{id_pat}{k} = cell(1,count);
                i = 1;
                for image = subsubfold'
                    if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                        img = imread(strcat(image.folder,"\",image.name));
                        if length(size(img))>2
                            img = img(:,:,1);
                        end
                        ImageRegistered{id_pat}{k}{i} = double(img);

                        i = i + 1;
                    end
                end

                k = k + 1;
            end
        end

        if SAVE
            patImage = ImageRegistered{id_pat};
            save(fname,'patImage','-v7.3')
        end

        id_pat = id_pat + 1;
    end
end

end

