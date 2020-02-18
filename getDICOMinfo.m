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
    for pm = parametricMaps
        informationValues.PARAMETRICMAPS.(pm) = "";
    end
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
            if isfolder(fullfile(subPatientFold.folder, subPatientFold.name, 'DICOM'))
                dicomFolder = dir((fullfile(subPatientFold.folder, subPatientFold.name, 'DICOM')));
                              
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
%                                                                      if strcmp(pm, "MIP") % angiography images
%                                                                          if contains(info.SeriesDescription, pm) && contains(info.SeriesDescription, 'RGB')
%                                                                             information.(pm) = dicomFile.folder;
%                                                                          end
%                                                                      elseif contains(info.SeriesDescription, pm) 
                                                                     if contains(info.SeriesDescription, pm) && contains(info.SeriesDescription, 'RGB')
                                                                         
                                                                         informationValues.PARAMETRICMAPS.(pm) = dicomFile.folder;
                                                                         
                                                                         if ~strcmp(pm, "MIP") % angiography images (?)
                                                                            mkdir(strcat(patFolder, "/", pm));        
                                                                         
                                                                             for el = dir(dicomFile.folder)'
                                                                                 if ~strcmp(el.name, '.') && ~strcmp(el.name, '..')
                                                                                     info = dicominfo(fullfile(dicomFile.folder, el.name));
                                                                                     image = dicomread(fullfile(dicomFile.folder, el.name));
                                                                                     imgidx = num2str(info.InstanceNumber);
                                                                                     if info.InstanceNumber<10
                                                                                        imgidx = strcat("0", num2str(info.InstanceNumber));
                                                                                     end
                                                                                     imwrite(mat2gray(image), strcat(patFolder, "/", pm, "/", imgidx, ".png"));  
                                                                                 end
                                                                             end
                                                                         end
                                                                     end
                                                                 end
                                                            end

                                                            
                                                            if isfield(info, keyField) 
                                                                
                                                                if isfield(info, 'SeriesDescription')
                                                                    % disp(info.SeriesDescription);
                                                                    
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
                                                                    if isfield(info, 'SliceThickness')
                                                                        if info.SliceThickness==5
                                                                            information.CTPfolder5mm = "X";
                                                                            
                                                                            informationValues.PERFUSIONCT5.filename = dicomFile.folder;
                                                                            informationValues.PERFUSIONCT5.numImages = numel(dir(dicomFile.folder))-2;
                                                                            informationValues.PERFUSIONCT5.SliceThickness = info.SliceThickness;

                                                                            if isfield(info, 'SeriesDescription')
                                                                                informationValues.PERFUSIONCT5.SeriesDescription = info.SeriesDescription;
                                                                            end  
                                                                            if isfield(info, 'StudyDescription')
                                                                                informationValues.PERFUSIONCT5.StudyDescription = info.StudyDescription;
                                                                            end
                                                                            if isfield(info, 'KVP')
                                                                                informationValues.PERFUSIONCT5.KVP = info.KVP;
                                                                            end
                                                                            if isfield(info, 'ExposureTime')
                                                                                informationValues.PERFUSIONCT5.ExposureTime = info.ExposureTime;
                                                                            end
                                                                            if isfield(info, 'XrayTubeCurrent')
                                                                                informationValues.PERFUSIONCT5.XrayTubeCurrent = info.XrayTubeCurrent;
                                                                            end
                                                                            if isfield(info, 'Exposure')
                                                                                informationValues.PERFUSIONCT5.Exposure = info.Exposure;
                                                                            end
                                                                            if isfield(info, 'FilterType')
                                                                                informationValues.PERFUSIONCT5.FilterType = info.FilterType;
                                                                            end
                                                                            if isfield(info, 'GeneratorPower')
                                                                                informationValues.PERFUSIONCT5.GeneratorPower = info.GeneratorPower;
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
                                                                 
                                                                 
%                                                                  if isfield(info, 'SeriesDescription')
%                                                                     disp(info.SeriesDescription);
%                                                                  end
                                                                 
                                                             end
                                                             % don't loop all
                                                             break
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
    end
    
    if numel(fieldnames(informationValues.PARAMETRICMAPS))-1==numel(parametricMaps)
        information.ParametricMapsFolders = "X";
    end
end

