function [Image, sortedK] = rearrangeImages(ImageFolder, ISLISTOFDIR, patients, SAVE, ...
workspaceFolder, suffix, suffix_workspace, CONVERT_TO_DOUBLE)
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
        p_id = num2str(p);
        if p<10
            fname = strcat(workspaceFolder,save_prefix,suffix,'PA0',p_id,'.mat');
        else
            fname = strcat(workspaceFolder,save_prefix,suffix,'PA',p_id,'.mat');
        end
        if p<9
            folderPath = strcat(ImageFolder,'PA0',num2str(p),'/ST000000/SE000001/');
        else
            if p == 9
                folderPath = strcat(ImageFolder,'PA0',num2str(p),'/ST000000/SE000000/');
            else
                folderPath = strcat(ImageFolder,'PA',num2str(p),'/ST000000/SE000000/');
            end
        end
    else % new patients 
        folderPath = ImageFolder{p};
        if strcmp(folderPath,"")
            Image{p} = []; % the images of the current patient can NOT be retrieved
            continue
        end
        p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));        
        fname = workspaceFolder + convertCharsToStrings(save_prefix) + p_id + ".mat";
    end
   
    disp(strcat("Patient: ", p_id));
    if exist(fname, 'file')==2
        load(fname);
        Image{p} = patImage;
        sortedK{p} = sortInfo;
        continue
    end
    
    n = numel(dir(folderPath))-2;
    info = cell(1,n);
    SL = zeros(1,n);
    AC_N = zeros(1,n);
    IN_N = zeros(1,n);
    SR_N = zeros(1,n);
    CONT_T = zeros(1,n);
    
    prefix = 'IM'; % (SIEMENS System)
    
    if ~ISLISTOFDIR
        for i = 1:n
            if i<11
                info_tmp = dicominfo(strcat(folderPath,prefix,'00000',num2str(i-1)));
            elseif i<101
                info_tmp = dicominfo(strcat(folderPath,prefix,'0000',num2str(i-1)));
            else
                info_tmp = dicominfo(strcat(folderPath,prefix,'000',num2str(i-1)));
            end
            slice_index = info_tmp.InstanceNumber;
            info{slice_index} = info_tmp;
            
            SL(slice_index) = info{slice_index}.SliceLocation;
            AC_N(slice_index) = info{slice_index}.AcquisitionNumber;
            IN_N(slice_index) = info{slice_index}.InstanceNumber;
            SR_N(slice_index) = info{slice_index}.SeriesNumber;
            CONT_T(slice_index) = str2double(info{slice_index}.ContentTime);
            if ~isequal(info{slice_index}.AcquisitionTime,info{slice_index}.ContentTime)
                disp('Nei')
            end
        end
    else % we already have the list of folder file
        DICOMinfoFold = dir(folderPath);
        for dicomFile = DICOMinfoFold'
             if ~strcmp(dicomFile.name, '.') && ~strcmp(dicomFile.name, '..')
                info_tmp = dicominfo(fullfile(dicomFile.folder, dicomFile.name));
                slice_index = info_tmp.InstanceNumber;
                info{slice_index} = info_tmp;

                SL(slice_index) = info{slice_index}.SliceLocation;
                AC_N(slice_index) = info{slice_index}.AcquisitionNumber;
                IN_N(slice_index) = info{slice_index}.InstanceNumber;
                SR_N(slice_index) = info{slice_index}.SeriesNumber;
                CONT_T(slice_index) = str2double(info{slice_index}.ContentTime);
                if ~isequal(info{slice_index}.AcquisitionTime,info{slice_index}.ContentTime)
                    disp('Nei')
                end
             end
        end
    end
    
    SL = SL';
    u = unique(SL);
    n = length(u);
    
    %Finn indeks til bilete tatt i same posisjon
    a = cell(1,n);
    for i = 1:n
        a{i} = find(u(i) == SL);
    end
       
    for k = 1:n
        %% sort the index based on the instance number! 
        [sorted,same_index] = sort(IN_N(a{k}));
        count = 1;
        for i = same_index
            j = sorted(count);
            
            Image{p}{k}{i} = dicomread(info{j}.Filename);
            
            if CONVERT_TO_DOUBLE
                I = double(Image{p}{k}{i});
            else
                I = im2uint16(Image{p}{k}{i});
                % need these 2 lines otherwise the skullstripping
                % algoritmh does NOT work
%                     I = I.*uint16(bwareafilt(I>400,1));
%                     I(I<800) = 0;
            end
            Image{p}{k}{i} = I;
            count = count+1;
            
        end

        c = CONT_T(sorted);
        newc = zeros(size(c));
        for cc = length(c):-1:2
            endt = c(cc);
            startt = c(cc-1);
            diff = endt-startt;
            if diff>40
                diff = diff - 40;
            end
            newc(cc) = diff;
        end
        sortedK{p}{k} = newc;
    end
    
    if SAVE
        patImage = Image{p};
        sortInfo = sortedK{p};
        save(fname,'patImage','sortInfo','-v7.3')
    end
end
