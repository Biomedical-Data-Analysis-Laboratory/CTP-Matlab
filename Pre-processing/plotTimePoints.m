function [outputArg1,outputArg2] = plotTimePoints(args)
%PLOTTIMEPOINTS Summary of this function goes here
%   Detailed explanation goes here

%% 0 - Arguments 
directory = args.directory; % Directory of the images
patients = args.patients; % Array of patients to process
annotatedImagesFolder = args.annotatedImagesFolder; % Directory of the annotated images
saveRegisteredFolder = args.saveRegisteredFolder; % Directory for saving the final registered images
workspaceFolder = args.workspaceFolder; % Directory to save and load the workspaces
previousNumPatiens = 0;
INITIAL_STEP = args.INITIAL_STEP; % start from this step!
%% flags
ISLISTOFDIR = 0; 
SAVE = args.save; % Save the workspace? (1=yes, 0=no)
isNIfTI = 0; % flag for the NIfTI format
isISLES2018 = 0; % flag for the ISLES2018 dataset
newIDFormat = false;
SAVE_INTERMEDIATE_STEPS = args.SAVE_INTERMEDIATE_STEPS; % flag to save the intermediate steps and to load the intermediate images if they are already saved
suffix_workspace = "";

%% optional field
if isfield(args, 'isNIfTI')
    isNIfTI = args.isNIfTI;
    if isNIfTI
        suffix_workspace = suffix_workspace + "_nifti";
    end
end
if isfield(args, 'isISLES2018')
    isISLES2018 = args.isISLES2018;
    if isISLES2018
        suffix_workspace = suffix_workspace+ "_ISLES2018";
    end
end
if isfield(args, 'newIDFormat')
    newIDFormat = args.newIDFormat;
end
if isfield(args, "DICOMfolders") % var containing the folderS with the DICOM images (extracted with extractINFOfromNewPatients.m
    directory = args.DICOMfolders;
    ISLISTOFDIR = 1;
end
if isfield(args, "previousNumPatiens") % var containing the number of patients to add when creating the new folders
    previousNumPatiens = args.previousNumPatiens;
end

%% -------------------------------------------------------------
if ~isfolder(workspaceFolder)
    mkdir(workspaceFolder)
end

maxTimePoints = zeros(0,numel(patients));
current_row = 1;

if isNIfTI && isISLES2018 % for the isles dataset 
    justinfo = 1;
    [~, info] = extractNIfTIImagesISLES2018(directory, 0, workspaceFolder, suffix_workspace, "4DPWI", 0, "", "", justinfo);
    infotable = struct2table(info);
    figure,histogram(infotable.slices);
    figure,histogram(infotable.slice_start);
    figure,histogram(infotable.slice_end);
    figure,histogram(infotable.slice_code);
    figure,histogram(infotable.slice_duration);
else % for the SUS dataset
    for p = patients
        if ~ISLISTOFDIR
            if p<9
                folderPath = ([directory 'PA0' num2str(p) '/ST000000/SE000001/']);
            else
                if p == 9
                    folderPath = ([directory 'PA0' num2str(p) '/ST000000/SE000000/']);
                else
                    folderPath = ([directory 'PA' num2str(p) '/ST000000/SE000000/']);
                end
            end
        else 
            folderPath = directory{p};
            if strcmp(folderPath,"")
                Image{p} = []; % the images of the current patient can NOT be retrieved
                continue
            end
        end

        n = numel(dir(folderPath))-2;
        info = cell(1,n);
        SL = zeros(1,n);
        AT = cell(1,n);

        if ~ISLISTOFDIR
            prefix = 'IM'; % (SIEMENS System)
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

            p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));
            disp(p_id);

            i = 1;
            for dicomFile = DICOMinfoFold'
                 if ~strcmp(dicomFile.name, '.') && ~strcmp(dicomFile.name, '..')
                    info{i} = dicominfo(fullfile(dicomFile.folder, dicomFile.name));
                    SL(i) = info{i}.SliceLocation;
                    AT{i} = info{i}.AcquisitionTime;
                    i=i+1; 
                 end
            end
        end 
    
        SL = SL';
        u = unique(SL);
        n = length(u);

        a = cell(1,n);
        for i = 1:n
            a{i} = find(u(i) == SL);
        end

        same_index = length(a{i});
        maxTimePoints(p) = same_index;
        time = cell(n,same_index);
        acqNum = cell(n,same_index);
        orig_sec = zeros(n,same_index);
        sec = zeros(n,same_index);
        norm_sec = zeros(n,same_index);

        for k = 1:n
            for i = 1:same_index
                time{k,i} = info{a{k}(i)}.ContentTime;
                acqNum{k,i} = info{a{k}(i)}.AcquisitionNumber;

                % https://dicom.innolitics.com/ciods/cr-image/general-image/00080033
                H = str2double(time{k,i}(1:2))*3600;
                M = str2double(time{k,i}(3:4))*60;
                S = str2double(time{k,i}(5:end));
                
                orig_sec(k,i) = M+S;
                sec(k,i) = H+M+S;
            end

            orig_sec(k,:) = sort(orig_sec(k,:));
            sec(k,:) = sort(sec(k,:));
            norm_sec(k,:) = normalize(sort(sec(k,:)),'range');
        end

        plotPatients(current_row:current_row+n-1,1:same_index) = sec;
        norm_plotPatients(current_row:current_row+n-1,1:same_index) = norm_sec;
        current_row = current_row+n;
    end
    
    orig_sec = orig_sec - min(min(orig_sec));
    figure,bar(orig_sec')
    figure,bar(plotPatients')
    figure,bar(norm_plotPatients')
    figure,plot(norm_plotPatients')
    
end

for x=1:size(orig_sec,1)
    figure,bar(double(1:30),orig_sec(x,:)')
end

end

