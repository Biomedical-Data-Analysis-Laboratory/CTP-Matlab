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

    if ~ISLISTOFDIR
        if p<9
            folderPath = ([ImageFolder 'PA0' num2str(p) '/ST000000/SE000001/']);
        else
            if p == 9
                folderPath = ([ImageFolder 'PA0' num2str(p) '/ST000000/SE000000/']);
            else
                folderPath = ([ImageFolder 'PA' num2str(p) '/ST000000/SE000000/']);
            end
        end
    else 
        folderPath = ImageFolder{p};
        if strcmp(folderPath,"")
            Image{p} = []; % the images of the current patient can NOT be retrieved
            continue
        end
    end
   
    n = numel(dir(folderPath))-2;
    n22 = n;
    info = cell(1,n);
    SL = zeros(1,n);
    %     time = zeros(1,n);
    
    prefix = 'IM'; % (SIEMENS System)
    if p>100 % for the italian Patients (GE system) 
        prefix = 'CT';
    end
      
    if ~ISLISTOFDIR
        for i = 1:n
            if i<11
                info{i} = dicominfo([folderPath prefix '00000' num2str(i-1)]);
            elseif i<101
                info{i} = dicominfo([folderPath prefix '0000' num2str(i-1)]);
            else
                info{i} = dicominfo([folderPath prefix '000' num2str(i-1)]);
            end

            ny1{i} = i;
            ny2{i} = info{i}.SliceLocation;
            ny4{i} = info{i}.AcquisitionTime;

            ny3{i} = info{i}.MediaStorageSOPInstanceUID;
            if length(ny3{i}) == 51
                indn(i) = str2num(ny3{i}(end));
            elseif length(ny3{i}) == 52
                indn(i) = str2num(ny3{i}(end-1:end));
            elseif length(ny3{i}) == 53
                indn(i) = str2num(ny3{i}(end-2:end));
            end
            %         ny4{i,1} = ny3{i}(55:57);
            SL(i) = info{i}.SliceLocation;
            %         time(i) = str2num(info{i}.AcquisitionTime);
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
                
                ny1{i} = i;
                ny2{i} = info{i}.SliceLocation;
                ny4{i} = info{i}.AcquisitionTime;

                ny3{i} = info{i}.MediaStorageSOPInstanceUID;
                if length(ny3{i}) == 51
                    indn(i) = str2num(ny3{i}(end));
                elseif length(ny3{i}) == 52
                    indn(i) = str2num(ny3{i}(end-1:end));
                elseif length(ny3{i}) == 53
                    indn(i) = str2num(ny3{i}(end-2:end));
                end
                %         ny4{i,1} = ny3{i}(55:57);
                SL(i) = info{i}.SliceLocation;
                %         time(i) = str2num(info{i}.AcquisitionTime);
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
    %     figure
    %     subplot(211)
    %     plot(time)
    %     subplot(212)
    %     plot(SL)
    
    %Finn indeks til bilete tatt i same posisjon
    a = cell(1,n);
    for i = 1:n
        a{i} = find(u(i) == SL)-1;
    end
    
    same_index = length(a{i});
    contT = cell(same_index,4);
    
    for k = 1:n
        sec = zeros(same_index,1);
        for i = 1:same_index
            contT{i,1} = info{a{k}(i)+1}.ContentTime;
            contT{i,2} = i;
            contT{i,3} = a{k}(i);
            
            contT{i,4} = info{a{k}(i)+1}.MediaStorageSOPInstanceUID;
            H = str2double(contT{i,1}(1:2))*3600;
            M = str2double(contT{i,1}(3:4))*60;
            S = str2double(contT{i,1}(5:end));
            sec(i,1) = H+M+S;
        end
        
        contT = sortrows(contT);
        
        contentTime = contT(:,1);
        acqTime = str2double(contT(:,1));
        %         timesec{p}{k} = acqTime-acqTime(1);
        sec = sortrows(sec);
        timesec{p}{k} = sec-sec(1);
        for i = 1:same_index
            tempNumb(i) = contT{i,3};
            tempNumbOrig(i) = contT{i,2};
        end
        tempOrder{p}{k} = tempNumb';
        tempOrderOrig{p}{k} = tempNumbOrig';
    end
    
    if 1
        for k = 1:n
            for i = 1:same_index
                j = a{k}(i);
                
                if ~ISLISTOFDIR
                    if j<10
                        Image{p}{k}{i} = dicomread([folderPath prefix '00000' num2str(j)]);
                        infoo = dicominfo([folderPath prefix '00000' num2str(j)]);
                        acqTime(i) = str2double(infoo.AcquisitionTime);
                    elseif j<100
                        Image{p}{k}{i} = dicomread([folderPath prefix '0000' num2str(j)]);
                        infoo = dicominfo([folderPath prefix '0000' num2str(j)]);
                        acqTime(i) = str2double(infoo.AcquisitionTime);
                    else
                        Image{p}{k}{i} = dicomread([folderPath prefix '000' num2str(j)]);
                        infoo = dicominfo([folderPath prefix '000' num2str(j)]);
                        acqTime(i) = str2double(infoo.AcquisitionTime);
                    end
                else 
                    Image{p}{k}{i} = dicomread(info{j+1}.Filename);
                    infoo = info{j+1};
                    acqTime(i) = str2double(infoo.AcquisitionTime);
                end
                
                I = uint16(Image{p}{k}{i});
                I = I.*uint16(bwareafilt(I>400,1));
                I(I<800) = 0;
                Image{p}{k}{i} = I;
                
            end
            timesec{p}{k} = acqTime-acqTime(1);
            
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


% if SAVE
%     save(strcat(workspaceFolder, 'timesec', suffix_workspace, '.mat'),'timesec')    
% end

if SAVE
    save(strcat(workspaceFolder, 'Image', suffix_workspace, '.mat'),'Image','-v7.3')
end
