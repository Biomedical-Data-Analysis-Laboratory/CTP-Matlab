warning('off','all')

%% APPLE
% USER = '/Users/lucatomasetti/';
%% WINDOWS 
USER = 'C:\Users\Luca\';

folder = 'D:\';
register_folder = strcat(USER, 'Desktop\New_Registered_patients\');
patientsFolder = dir(fullfile(folder, '*/'));
workspaceFolder = strcat(register_folder, 'Workspaces/');
previousNumPatiens = 11;

args.directory = folder;
args.annotatedImagesFolder = ""; % strcat(root_folder, 'CT_perfusion_markering_processed/CROPPED/');
args.save = 1;
args.saveRegisteredFolder = strcat(register_folder, 'Registered_images/');
args.workspaceFolder = workspaceFolder; 

mkdir(workspaceFolder);

% if exist(strcat(workspaceFolder, workspaceName), 'file') == 2 
%     load(strcat(workspaceFolder, workspaceName))
% else
    allInfo = [];
    allInfoValuesHALSKAR = [];
    allInfoValuesCTCAPUT = [];
    allInfoValuesPERFUSIONCT5 = [];
    allInfoValuesPERFUSIONCT1point5 = [];
    allInfoValuesPARAMETRICMAPS = [];
    allInfoValuesMRI = [];
    count = 1;

    for patientFold = patientsFolder'
        if ~strcmp(patientFold.name, '.') && ~strcmp(patientFold.name, '..') && ~strcmp(patientFold.folder, 'D:\$RECYCLE.BIN')
            patIndex = count+previousNumPatiens;
            if patIndex<10
                patIndex = strcat("PA0", num2str(patIndex));
            else
                patIndex = strcat("PA", num2str(patIndex));
            end
            patFolder = strcat(args.workspaceFolder, patIndex);
            mkdir(patFolder);
            
            CTPField = {'ConvolutionKernel', 'H20f'};
            
            tic
            
            [info, infoValues] = getDICOMinfo(patientFold, CTPField, patFolder);
            
            disp(strcat("Patient ", num2str(count), " -- ", patIndex));
            
            if numel(info) > 0
                count = count+1;
            end
            
            toc;

            allInfo = [allInfo, info];
            allInfoValuesHALSKAR = [allInfoValuesHALSKAR, infoValues.HALSKAR];
            allInfoValuesCTCAPUT = [allInfoValuesCTCAPUT, infoValues.CTCAPUT];
            allInfoValuesPERFUSIONCT5 = [allInfoValuesPERFUSIONCT5, infoValues.PERFUSIONCT5];
            allInfoValuesPERFUSIONCT1point5 = [allInfoValuesPERFUSIONCT1point5, infoValues.PERFUSIONCT1point5];
            allInfoValuesPARAMETRICMAPS = [allInfoValuesPARAMETRICMAPS, infoValues.PARAMETRICMAPS];
            allInfoValuesMRI = [allInfoValuesMRI, infoValues.MRI];
            
%             infoAdded = 0;
%             for i = 1:numel(info)
%                 if numel(fieldnames(info{i})) == 23 % NUMBER OF INFO FIELD, CHANGE IT IF YOU ADD NEW INFO
%                     allInfo = [allInfo, info{i}];
%                     infoAdded = infoAdded + 1;
%                 end
%             end
%             if infoAdded==0
%                 disp(strcat("-------------------NO INFO for Patient: ", patIndex));
%             end

        end
    end
% end

allInforCell = struct2cell(allInfo);
writetable(struct2table(allInfo), 'patient_list.csv', 'Delimiter','tab')
% save the info
save(strcat(workspaceFolder, 'allInfo.mat'), 'allInfo');
save(strcat(workspaceFolder, 'allInfoValuesHALSKAR.mat'), 'allInfoValuesHALSKAR');
save(strcat(workspaceFolder, 'allInfoValuesCTCAPUT.mat'), 'allInfoValuesCTCAPUT');
save(strcat(workspaceFolder, 'allInfoValuesPERFUSIONCT5.mat'), 'allInfoValuesPERFUSIONCT5');
save(strcat(workspaceFolder, 'allInfoValuesPERFUSIONCT1point5.mat'), 'allInfoValuesPERFUSIONCT1point5');
save(strcat(workspaceFolder, 'allInfoValuesPARAMETRICMAPS.mat'), 'allInfoValuesPARAMETRICMAPS');
save(strcat(workspaceFolder, 'allInfoValuesMRI.mat'), 'allInfoValuesMRI');


% listDICOMfolders = allInforCell(1,:); % 1=index of filename !!! 
% 
% args.DICOMfolders = listDICOMfolders;
% args.patients = double(previousNumPatiens+1:previousNumPatiens+numel(allInfo));

% 
% MAIN_PREPROCESSING(args);

