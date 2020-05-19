function [outputArg1,outputArg2] = getMAINinfo(patientsFolder,rawDataFolder,workspaceFolder,appUIFIGURE)
%GETMAININFO Summary of this function goes here
%   Detailed explanation goes here

previousNumPatiens = 0;
if nargin<4
    appUIFIGURE = uifigure;
    previousNumPatiens = 11;
end

wb = uiprogressdlg(appUIFIGURE,'Title','Please Wait',...
    'Message','Start analyzing DICOM folders...');

allInfo = [];
allInfoValuesHALSKAR = [];
allInfoValuesCTCAPUT = [];
allInfoValuesPERFUSIONCT5 = [];
allInfoValuesPERFUSIONCT1point5 = [];
allInfoValuesPARAMETRICMAPS = [];
allInfoValuesMRI = [];
count = 1;

n_patients = numel(patientsFolder')-2;

for patientFold = patientsFolder'
    if ~strcmp(patientFold.name, '.') && ~strcmp(patientFold.name, '..') && ~strcmp(patientFold.folder, 'D:\$RECYCLE.BIN')
        patIndex = count+previousNumPatiens;
        
        patFolder = strcat(rawDataFolder, patientFold.name);
        mkdir(patFolder);

        CTPField = {'ConvolutionKernel', 'H20f'};

        wb.Value = count/n_patients;
        wb.Message = strcat("Checking folder ", num2str(count), "/", num2str(n_patients)); 
        tic 
%         if strcmp(patientFold.name, "CTP_01_059") 
        %% get the DICOM information + save the parametric maps 
        [info, infoValues] = getDICOMinfo(patientFold, CTPField, patFolder);

        allInfo = [allInfo, info];
        allInfoValuesHALSKAR = [allInfoValuesHALSKAR, infoValues.HALSKAR];
        allInfoValuesCTCAPUT = [allInfoValuesCTCAPUT, infoValues.CTCAPUT];
        allInfoValuesPERFUSIONCT5 = [allInfoValuesPERFUSIONCT5, infoValues.PERFUSIONCT5];
        allInfoValuesPERFUSIONCT1point5 = [allInfoValuesPERFUSIONCT1point5, infoValues.PERFUSIONCT1point5];
        allInfoValuesPARAMETRICMAPS = [allInfoValuesPARAMETRICMAPS, infoValues.PARAMETRICMAPS];
        allInfoValuesMRI = [allInfoValuesMRI, infoValues.MRI];

%         else
%             info = [];
%             infoValues = [];
%         end

        disp(strcat("Patient ", patientFold.name));
        if numel(info) > 0
            count = count+1;
        end
        
        toc
    end
end
% end

allInforCell = struct2cell(allInfo);
writetable(struct2table(allInfo), strcat(workspaceFolder,'patient_list_NEW.csv'), 'Delimiter','tab')
% save the info
save(strcat(workspaceFolder, 'allInfo.mat'), 'allInfo');
save(strcat(workspaceFolder, 'allInfoValuesHALSKAR.mat'), 'allInfoValuesHALSKAR');
save(strcat(workspaceFolder, 'allInfoValuesCTCAPUT.mat'), 'allInfoValuesCTCAPUT');
save(strcat(workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
save(strcat(workspaceFolder, 'allInfoValuesPERFUSIONCT1point5.mat'), 'allInfoValuesPERFUSIONCT1point5');
save(strcat(workspaceFolder, 'allInfoValuesPARAMETRICMAPS.mat'), 'allInfoValuesPARAMETRICMAPS');
save(strcat(workspaceFolder, 'allInfoValuesMRI.mat'), 'allInfoValuesMRI');

end

