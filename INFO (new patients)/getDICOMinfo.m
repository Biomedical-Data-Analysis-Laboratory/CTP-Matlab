function [information, informationValues] = getDICOMinfo(mainFolder, field, patFolder)
%GETDICOMINFO Summary of this function goes here
%   Detailed explanation goes here
    
    parametricMaps = ["MTT", "CBF", "CBV", "TMAX", "TTP", "MIP"];
    
    patientsFolder = dir(fullfile(mainFolder.folder, mainFolder.name));
    keyField = field{1};
    valueField = field{2};

    information = struct;
    
    information.patientFolder = mainFolder.name;
    information.HalskarFolder = "";
    information.CTCaputFolder = "";
    information.MRIISOREGFolder = "";
    information.MRIdADCFolder = "";
    information.MRIT2starFolder = "";
    information.CTPfolder5mm = "";
    information.CTPfolder1point5mm = "";
    information.CTCaputAXFolder = "";
    information.CTCaputCORFolder = "";
    information.CTCaputSAGFolder = "";
    information.ParametricMapsFolders = "";

    information.PatientID = "";
    information.PatientName = "";
    information.PatientBirthName = "";
    information.PatientMotherBirthName = "";
    information.PatientAge = "";
    information.PatientSex = "";
    information.FolderToDelete = "";
    
    % structures that MUST be present
    informationValues = struct;
    
    informationValues.HALSKAR = struct;
    informationValues.CTCAPUT = struct;
    informationValues.PERFUSIONCT5 = struct;
    informationValues.PERFUSIONCT1point5 = struct;
    informationValues.PARAMETRICMAPS = struct;
    informationValues.MRI = struct;
    % HALSKAR parameters 
    informationValues.HALSKAR.patientFolder = mainFolder.name;
    informationValues.HALSKAR.Modality = "";
    informationValues.HALSKAR.filename = "";
    informationValues.HALSKAR.numImages = 0; % not fixed!
    informationValues.HALSKAR.ConvolutionKernel = "";
    informationValues.HALSKAR.SeriesDescription = "";
    informationValues.HALSKAR.StudyDescription = "";
    informationValues.HALSKAR.SliceThickness = "";
	informationValues.HALSKAR.KVP = "";
    % CTCAPUT parameters  % axial, cor, sag, <- 0.6 J30s
    informationValues.CTCAPUT.patientFolder = mainFolder.name;
    informationValues.CTCAPUT.Modality = "";
    informationValues.CTCAPUT.filename = "";
    informationValues.CTCAPUT.StudyDescription = "";
    informationValues.CTCAPUT.ConvolutionKernel = "";
    informationValues.CTCAPUT.SeriesDescription = "";
    informationValues.CTCAPUT.COR = "";
    informationValues.CTCAPUT.CORSeriesDescription = "";
    informationValues.CTCAPUT.SAG = "";
    informationValues.CTCAPUT.SAGSeriesDescription = "";
    informationValues.CTCAPUT.AXIAL = "";
    informationValues.CTCAPUT.AXIALSeriesDescription = "";
    % PERFUSION CT parameters 5mm
    informationValues.PERFUSIONCT5.patientFolder = mainFolder.name;
    informationValues.PERFUSIONCT5.filename = "";
    informationValues.PERFUSIONCT5.numImages = 0;
    informationValues.PERFUSIONCT5.SliceThickness = "";
    informationValues.PERFUSIONCT5.SeriesDescription = "";
    informationValues.PERFUSIONCT5.StudyDescription = "";
    informationValues.PERFUSIONCT5.KVP = "";
    informationValues.PERFUSIONCT5.ExposureTime = "";
    informationValues.PERFUSIONCT5.XrayTubeCurrent = "";
    informationValues.PERFUSIONCT5.Exposure = "";
    informationValues.PERFUSIONCT5.FilterType = "";
    informationValues.PERFUSIONCT5.GeneratorPower = "";    
    informationValues.PERFUSIONCT5.SliceLocation = "";
    informationValues.PERFUSIONCT5.AcquisitionTime = "";
    informationValues.PERFUSIONCT5.MediaStorageSOPInstanceUID = "";
    informationValues.PERFUSIONCT5.ContentTime = "";
    informationValues.PERFUSIONCT5.ColorType = "";
    informationValues.PERFUSIONCT5.AcquisitionDate = "";
    % PERFUSION CT parameters 1.5mm
    informationValues.PERFUSIONCT1point5.patientFolder = mainFolder.name;
    informationValues.PERFUSIONCT1point5.SliceThickness = "";
    informationValues.PERFUSIONCT1point5.filename = "";
    informationValues.PERFUSIONCT1point5.frames = "";
    informationValues.PERFUSIONCT1point5.SeriesDescription = "";
    informationValues.PERFUSIONCT1point5.StudyDescription = "";
    informationValues.PERFUSIONCT1point5.KVP = "";
    informationValues.PERFUSIONCT1point5.ExposureTime = "";
    informationValues.PERFUSIONCT1point5.XrayTubeCurrent = "";
    informationValues.PERFUSIONCT1point5.Exposure = "";
    informationValues.PERFUSIONCT1point5.FilterType = "";
    informationValues.PERFUSIONCT1point5.GeneratorPower = "";
    % PARAMETRICMAPS folders 
    informationValues.PARAMETRICMAPS.patientFolder = mainFolder.name;
    informationValues.PARAMETRICMAPS.pm = struct;
% %     for pm = parametricMaps
% %         informationValues.PARAMETRICMAPS.(pm) = "";
% %     end
    % MRI parameters 
    informationValues.MRI.patientFolder = mainFolder.name;
    informationValues.MRI.Modality = "";
    informationValues.MRI.StudyDescription = "";
    informationValues.MRI.filenameISOREG = "";
    informationValues.MRI.SeriesDescriptionISOREG = "";
    informationValues.MRI.filenameT2star = "";
    informationValues.MRI.SeriesDescriptionT2star = "";
    informationValues.MRI.filenameDADC = "";
    informationValues.MRI.SeriesDescriptionDADC = "";

    for subPatientFold = patientsFolder'
        if ~strcmp(subPatientFold.name, '.') && ~strcmp(subPatientFold.name, '..')           
            if isfolder(fullfile(subPatientFold.folder, subPatientFold.name)) && strcmp(subPatientFold.name, 'DICOM') %, 'DICOM'))
                dicomFolder = dir((fullfile(subPatientFold.folder, subPatientFold.name))); %, 'DICOM')));
                              
                for subDICOMfold = dicomFolder'
                if ~strcmp(subDICOMfold.name, '.') && ~strcmp(subDICOMfold.name, '..')
                    subsubDICOMfold = dir(fullfile(subDICOMfold.folder, subDICOMfold.name));

                for subsubsubDICOMfold = subsubDICOMfold'
                if ~strcmp(subsubsubDICOMfold.name, '.') && ~strcmp(subsubsubDICOMfold.name, '..')
                    subsubsubsubDICOMfold = dir(fullfile(subsubsubDICOMfold.folder, subsubsubDICOMfold.name));

                for fileFolders = subsubsubsubDICOMfold'
                if ~strcmp(fileFolders.name, '.') && ~strcmp(fileFolders.name, '..')
                    fileFolder = dir(fullfile(fileFolders.folder, fileFolders.name));

                for DICOMinfo = fileFolder'
                if ~strcmp(DICOMinfo.name, '.') && ~strcmp(DICOMinfo.name, '..')
                    DICOMinfoFold = dir(fullfile(DICOMinfo.folder, DICOMinfo.name));

                %if strcmp(DICOMinfo.name, "0000AE83")
                                    
                for dicomFile = DICOMinfoFold'
                if ~strcmp(dicomFile.name, '.') && ~strcmp(dicomFile.name, '..')    
               
                if ~contains(dicomFile.name, '._')
                    info = dicominfo(fullfile(dicomFile.folder, dicomFile.name));

                    % information about the patient (they should be anonymous)
                    if information.PatientID=="" && isfield(info, 'PatientID') 
                        information.PatientID = info.PatientID;
                    end
                    if information.PatientName=="" && isfield(info, 'PatientName')
                        information.PatientName = info.PatientName.FamilyName;
                    end
                    if information.PatientBirthName=="" && isfield(info, 'PatientBirthName')
                        information.PatientBirthName = info.PatientBirthName.FamilyName;
                    end
                    if information.PatientMotherBirthName=="" && isfield(info, 'PatientMotherBirthName')
                        information.PatientMotherBirthName = info.PatientMotherBirthName.FamilyName;
                    end
                    if information.PatientAge=="" && isfield(info, 'PatientAge')
                        information.PatientAge = info.PatientAge;
                    end
                    if information.PatientSex=="" && isfield(info, 'PatientSex')
                        information.PatientSex = info.PatientSex;
                    end

                    if isfield(info, 'SeriesDescription')

                     %% delete the folder and the element inside because they contain information about the patient
                        if strcmp(info.SeriesDescription, "Results CT Neuro Perfusion")
                            information.FolderToDelete = dicomFile.folder;

                            for f = dir(dicomFile.folder)'
                                if ~strcmp(f.name, '.') && ~strcmp(f.name, '..')
                                    delete(fullfile(dicomFile.folder, f.name));
                                end
                            end
                         end

                         %% for searching the parametric maps
                         for pm = parametricMaps                           
                             if contains(info.SeriesDescription, pm) && contains(info.SeriesDescription, 'RGB')
                                 
%                                  % display information descripition 
%                                 disp(info.SeriesDescription);
%                                 disp(numel(dir(dicomFile.folder)')-2);

                                % check if they have a date (in the folder description) and extract it if necessary
                                indexDate = strfind(info.SeriesDescription, "#");
                                if isempty(indexDate)
                                    dayAndHour = "no_date";
                                else
                                    dayAndHour = extractAfter(info.SeriesDescription, indexDate);
                                end
                                
                                fieldPMname = "f_"+replace(convertCharsToStrings(dayAndHour),["-","(",")"," "],["","","",""]);
                                
                                if ~isfield(informationValues.PARAMETRICMAPS.pm, fieldPMname)
                                    informationValues.PARAMETRICMAPS.pm.(fieldPMname) = struct;
                                end
                                
                                informationValues.PARAMETRICMAPS.pm.(fieldPMname).(pm) = dicomFile.folder;
                                mkdir(strcat(patFolder, "/", dayAndHour));
                                mkdir(strcat(patFolder, "/", dayAndHour, "/", pm));

                                flagStartZero = 0;
                                for el = dir(dicomFile.folder)'
                                    if ~strcmp(el.name, '.') && ~strcmp(el.name, '..')
                                        info = dicominfo(fullfile(dicomFile.folder, el.name));
                                        image = dicomread(fullfile(dicomFile.folder, el.name));

                                        imgidx = num2str(info.InstanceNumber);
                                        if info.InstanceNumber<10
                                            if info.InstanceNumber == 0
                                                flagStartZero = 1;
                                            end
                                            imgidx = strcat("0", num2str(info.InstanceNumber));
                                        end

                                        imwrite(mat2gray(image), strcat(patFolder, "/", dayAndHour, "/", pm, "/", imgidx, ".png"));  
                                    end
                                end

                                % rename all the images if they start with 00
                                if flagStartZero
                                    mkdir(strcat(patFolder, "/", dayAndHour, "/tmp_", pm, "/"))
                                    movefile(strcat(patFolder, "/", dayAndHour, "/", pm, "/*"), strcat(patFolder, "/", dayAndHour, "/tmp_", pm))
                                    files = dir(strcat(patFolder, "/", dayAndHour, "/tmp_", pm, "/*.png"));
                                    for fn_id = 1:length(files)
                                        [~, f] = fileparts(files(fn_id).name);
                                        num = num2str(str2double(f)+1);
                                        if str2double(f)+1<10
                                            num = strcat("0", num);
                                        end
                                        movefile(strcat(files(fn_id).folder, "/", files(fn_id).name), strcat(patFolder, "/", dayAndHour, "/", pm, "/", num, ".png"))
                                    end
                                end

                                if exist(strcat(patFolder, "/", dayAndHour, "/tmp_", pm, "/"),'dir')
                                    rmdir(strcat(patFolder, "/", dayAndHour, "/tmp_", pm, "/"))
                                end
                             end
                         end
                    end

                    if isfield(info, keyField) 
                        if isfield(info, 'SeriesDescription')
                            if contains(info.SeriesDescription, "Halskar") && contains(info.SeriesDescription, "0.6")
                                information.HalskarFolder = "X"; 

                                informationValues.HALSKAR.Modality = info.Modality;
                                informationValues.HALSKAR.filename = dicomFile.folder;
                                informationValues.HALSKAR.numImages = numel(dir(dicomFile.folder))-2; 
                                informationValues.HALSKAR.ConvolutionKernel = info.ConvolutionKernel;
                                informationValues.HALSKAR.SeriesDescription = info.SeriesDescription;
                                informationValues.HALSKAR.SliceThickness = info.SliceThickness;
                                informationValues.HALSKAR.KVP = info.KVP;
                            elseif contains(info.SeriesDescription, "Hode") 
                                if contains(info.SeriesDescription, "J30s")
                                    information.CTCaputFolder = "X";

                                    informationValues.CTCAPUT.Modality = info.Modality;
                                    informationValues.CTCAPUT.filename = dicomFile.folder;
                                    informationValues.CTCAPUT.ConvolutionKernel = info.ConvolutionKernel;
                                    informationValues.CTCAPUT.SeriesDescription = info.SeriesDescription;
                                    informationValues.CTCAPUT.StudyDescription = info.StudyDescription;
                                elseif contains(lower(info.SeriesDescription), "cor")
                                    information.CTCaputCORFolder = "X";

                                    informationValues.CTCAPUT.COR = dicomFile.folder;
                                    informationValues.CTCAPUT.CORSeriesDescription = info.SeriesDescription;
                                elseif contains(lower(info.SeriesDescription), "sag")
                                    information.CTCaputSAGFolder = "X";

                                    informationValues.CTCAPUT.SAG = dicomFile.folder;
                                    informationValues.CTCAPUT.SAGSeriesDescription = info.SeriesDescription;
                                elseif contains(lower(info.SeriesDescription), "ax")
                                    information.CTCaputAXFolder = "X";

                                    informationValues.CTCAPUT.AXIAL = dicomFile.folder;
                                    informationValues.CTCAPUT.AXIALSeriesDescription = info.SeriesDescription;
                                end
                            end
                        end

                        %% field to search for PERFUSION CT
                        if strcmp(info.(keyField), valueField)  
                            if isfield(info, 'SliceThickness') && isfield(info, 'SliceLocation') ...
                                    && isfield(info, 'AcquisitionTime') && isfield(info, 'MediaStorageSOPInstanceUID') ...
                                    && isfield(info, 'ContentTime') && isfield(info, 'ColorType')
                                if info.SliceThickness==5 && strcmpi(info.ColorType,'grayscale') && numel(DICOMinfoFold)>100
                                    information.CTPfolder5mm = information.CTPfolder5mm + "X";
                                    % the filename must remain the second column in this struct !!!
                                    informationValues.PERFUSIONCT5.filename = dicomFile.folder;
                                    informationValues.PERFUSIONCT5.numImages = numel(dir(dicomFile.folder))-2;
                                    informationValues.PERFUSIONCT5.SliceThickness = info.SliceThickness;
                                    informationValues.PERFUSIONCT5.SliceLocation = info.SliceLocation;
                                    informationValues.PERFUSIONCT5.AcquisitionTime = info.AcquisitionTime;
                                    informationValues.PERFUSIONCT5.MediaStorageSOPInstanceUID = info.MediaStorageSOPInstanceUID;
                                    informationValues.PERFUSIONCT5.ContentTime = info.ContentTime;
                                    informationValues.PERFUSIONCT5.ColorType = info.ColorType;
                                    informationValues.PERFUSIONCT5.AcquisitionDate = info.AcquisitionDate;
    
                                    % optional information field 
                                    optfields = ["SeriesDescription", "StudyDescription", "KVP", "XrayTubeCurrent", ...
                                        "ExposureTime", "Exposure", "FilterType", "GeneratorPower"];
                                    for f = 1:numel(optfields)
                                        current_field = optfields(f);
                                        if isfield(info, current_field)
                                            informationValues.PERFUSIONCT5.(current_field)= info.(current_field);
                                        else
                                            informationValues.PERFUSIONCT5.(current_field) = "";
                                        end  
                                    end

                                elseif info.SliceThickness==1.5
                                    information.CTPfolder1point5mm = "X";
                                    informationValues.PERFUSIONCT1point5.SliceThickness = info.SliceThickness;

                                    informationValues.PERFUSIONCT1point5.filename = [informationValues.PERFUSIONCT1point5.filename, dicomFile.folder];
                                    informationValues.PERFUSIONCT1point5.frames = [informationValues.PERFUSIONCT1point5.frames, numel(dir(dicomFile.folder))-2];

                                    if isfield(info, 'SeriesDescription')
                                        informationValues.PERFUSIONCT1point5.SeriesDescription = [informationValues.PERFUSIONCT1point5.SeriesDescription, info.SeriesDescription];
                                    end  
                                    if isfield(info, 'StudyDescription')
                                        informationValues.PERFUSIONCT1point5.StudyDescription = [informationValues.PERFUSIONCT1point5.StudyDescription, info.StudyDescription];
                                    end
                                    if isfield(info, 'KVP')
                                        informationValues.PERFUSIONCT1point5.KVP = [informationValues.PERFUSIONCT1point5.KVP, info.KVP];
                                    end
                                    if isfield(info, 'ExposureTime')
                                        informationValues.PERFUSIONCT1point5.ExposureTime = [informationValues.PERFUSIONCT1point5.ExposureTime, info.ExposureTime];
                                    end
                                    if isfield(info, 'XrayTubeCurrent')
                                        informationValues.PERFUSIONCT1point5.XrayTubeCurrent = [informationValues.PERFUSIONCT1point5.XrayTubeCurrent, info.XrayTubeCurrent];
                                    end
                                    if isfield(info, 'Exposure')
                                        informationValues.PERFUSIONCT1point5.Exposure = [informationValues.PERFUSIONCT1point5.Exposure, info.Exposure];
                                    end
                                    if isfield(info, 'FilterType')
                                        informationValues.PERFUSIONCT1point5.FilterType = [informationValues.PERFUSIONCT1point5.FilterType, info.FilterType];
                                    end
                                    if isfield(info, 'GeneratorPower')
                                        informationValues.PERFUSIONCT1point5.GeneratorPower = [informationValues.PERFUSIONCT1point5.GeneratorPower, info.GeneratorPower];
                                    end
                                else
                                    disp(strcat("---SLICE THICKENSS: ", int2str(info.SliceThickness)))
                                end
                            end
                        end
                     else
                         if isfield(info, 'StudyDescription')
                            % disp(info.StudyDescription);

                            if contains(info.StudyDescription, "MR Hode")
                                %% for MRI 
                                if isfield(info, 'Modality')
                                    informationValues.MRI.Modality = info.Modality;
                                end
                                
%                                 if isfield(info,'DiffusionBValue')
%                                     disp("DiffusionBValue");
%                                     disp(info.DiffusionBValue);
%                                 end
%                                 
%                                 if isfield(info,'Private_2001_1001')
%                                     disp("Private_2001_1001");
%                                     disp(info.Private_2001_1001);
%                                 end
%                                 
%                                 if isfield(info,'Private_0019_100c')
%                                     if info.Private_0019_100c>0
%                                         disp("Private_0019_100c");
%                                     end
%                                 end
                                
                                informationValues.MRI.StudyDescription = info.StudyDescription;

                                if isfield(info, 'SeriesDescription')
                                    if contains(info.SeriesDescription, "isoReg")
                                        information.MRIISOREGFolder = "X";

                                        informationValues.MRI.filenameISOREG = dicomFile.folder;
                                        informationValues.MRI.SeriesDescriptionISOREG = info.SeriesDescription;                                                                                
                                    elseif contains(info.SeriesDescription, "dADC")
                                        information.MRIdADCFolder = "X";

                                        informationValues.MRI.filenameDADC = dicomFile.folder;
                                        informationValues.MRI.SeriesDescriptionDADC = info.SeriesDescription;
                                    elseif contains(info.SeriesDescription, "T2*")
                                        information.MRIT2starFolder = "X";

                                        informationValues.MRI.filenameT2star = dicomFile.folder;
                                        informationValues.MRI.SeriesDescriptionT2star = info.SeriesDescription;
                                    end
                                end
                            end   
                         end
                     end
                     % don't loop all
                     break
                end
                
                %end
                
                end
                end
                end
                end
                end
                end
                end  
                end
                end
                end
            end
        end
    end
    
    fieldsPM = fieldnames(informationValues.PARAMETRICMAPS.pm);
    for f = 1:numel(fieldsPM)
        if  sum(contains(fieldnames(informationValues.PARAMETRICMAPS.pm.(fieldsPM{f})), parametricMaps(2:end)))==(numel(parametricMaps)-1)
            information.ParametricMapsFolders = information.ParametricMapsFolders + "X";
        else
            disp("# PM --- " + fieldsPM{f});
            disp(numel(fieldnames(informationValues.PARAMETRICMAPS.pm.(fieldsPM{f}))));
        end
    end
end

