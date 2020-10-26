function Image = rearrangeImages(ImageFolder, ISLISTOFDIR, patients, SAVE, workspaceFolder, suffix_workspace)
% Rearrange images, so that they are sorted  spatially and temporally.
% ImageFolder specifies the folder name where the patient folders are
% located. The code is meant to function with the dataset used in the
% thesis.
%
% In addition, a simple preprocessing of the images is performed:
%     -Keep only the largest region with intensity values above 400.
%     -Set pixels below 800 to zero.

save_prefix = '01_Rearrage.';

for p = patients
    if ~ISLISTOFDIR % old patients
        if p<9
            folderPath = ([ImageFolder 'PA0' num2str(p) '/ST000000/SE000001/']);
        else
            if p == 9
                folderPath = ([ImageFolder 'PA0' num2str(p) '/ST000000/SE000000/']);
            else
                folderPath = ([ImageFolder 'PA' num2str(p) '/ST000000/SE000000/']);
            end
        end
    else % new patients 
        folderPath = ImageFolder{p};
        if strcmp(folderPath,"")
            Image{p} = []; % the images of the current patient can NOT be retrieved
            continue
        end
    end
   
    n = numel(dir(folderPath))-2;
    info = cell(1,n);
    SL = zeros(1,n);
    
    prefix = 'IM'; % (SIEMENS System)
    
    if ~ISLISTOFDIR
        for i = 1:n
            if i<11
                info{i} = dicominfo([folderPath prefix '00000' num2str(i-1)]);
            elseif i<101
                info{i} = dicominfo([folderPath prefix '0000' num2str(i-1)]);
            else
                info{i} = dicominfo([folderPath prefix '000' num2str(i-1)]);
            end

            SL(i) = info{i}.SliceLocation;
            if ~isequal(info{i}.AcquisitionTime,info{i}.ContentTime)
                disp('Nei')
            end
        end
    else % we already have the list of folder file
        DICOMinfoFold = dir(folderPath);
        i = 1;                  
        
        p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));
        disp(p_id);
        
        if exist(workspaceFolder + convertCharsToStrings(save_prefix) + p_id + ".mat", 'file')==2
            load(workspaceFolder + convertCharsToStrings(save_prefix) + p_id + ".mat");
            Image{p} = patImage;
            continue
        end
        
        for dicomFile = DICOMinfoFold'
             if ~strcmp(dicomFile.name, '.') && ~strcmp(dicomFile.name, '..')
                info{i} = dicominfo(fullfile(dicomFile.folder, dicomFile.name));

                SL(i) = info{i}.SliceLocation;
                if ~isequal(info{i}.AcquisitionTime,info{i}.ContentTime)
                    disp('Nei')
                end

                i=i+1; 
             end
        end
    end
    
    SL = SL';
    u = unique(SL);
    n = length(u);
    
    %Finn indeks til bilete tatt i same posisjon
    a = cell(1,n);
    for i = 1:n
        a{i} = find(u(i) == SL)-1;
    end
    
    same_index = length(a{i});
    
    if 1
        for k = 1:n
            for i = 1:same_index
                j = a{k}(i);
                
                if ~ISLISTOFDIR
                    if j<10
                        Image{p}{k}{i} = dicomread([folderPath prefix '00000' num2str(j)]);
                    elseif j<100
                        Image{p}{k}{i} = dicomread([folderPath prefix '0000' num2str(j)]);
                    else
                        Image{p}{k}{i} = dicomread([folderPath prefix '000' num2str(j)]);
                    end
                else 
                    Image{p}{k}{i} = dicomread(info{j+1}.Filename);
                end
                
                I = uint16(Image{p}{k}{i});
                I = I.*uint16(bwareafilt(I>400,1));
                I(I<800) = 0;
                Image{p}{k}{i} = I;
            end
        end
        if SAVE
            if ~ISLISTOFDIR
                if p<10
                    fname = ([workspaceFolder save_prefix 'PA0' num2str(p) '.mat']);
                else
                    fname = ([workspaceFolder save_prefix 'PA' num2str(p) '.mat']);
                end
            else
                fname = workspaceFolder + convertCharsToStrings(save_prefix) + p_id + ".mat";
            end
            patImage = Image{p};
            save(fname,'patImage','-v7.3')
        end
    end
end

if SAVE
    save(strcat(workspaceFolder, 'Image', suffix_workspace, '.mat'),'Image','-v7.3')
end
