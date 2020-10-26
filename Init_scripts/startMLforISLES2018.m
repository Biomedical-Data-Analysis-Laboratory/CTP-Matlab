clear;
close all force;

%% LOCAL SYSYEM
flag = 'TRAINING';
% flag = 'TESTING';


args.SUPERVISED_LEARNING = 0;
args.SUFFIX_RES = "tree"; 
args.superpixels = 1;
args.hyperparameterOptimizationFlag = 0;
args.CROSS_VALIDATION = 0;

toadd = "";
if args.superpixels 
    toadd = "superpixels_";
end

args.patientindex = double(1:94);

if ispc % windows
    ISLES2018Folder = "D:/ISLES2018/";
    args.directory = strcat(ISLES2018Folder, 'NEW_', flag, '/');
    args.predictDirectory = strcat(ISLES2018Folder, "Predict_", toadd, args.SUFFIX_RES, '_', flag, "/");
    args.originalDirectory = strcat(ISLES2018Folder, flag, '/');
    args.workspaceFolder = strcat(ISLES2018Folder, 'Workspace/'); 
    args.groundTruth_folder = args.directory;
elseif isunix % unix sistem (gorina)
    ISLES2018Folder = "/home/student/lucat/PhD_Project/";
    args.directory = strcat(ISLES2018Folder, 'Stroke_segmentation/PATIENTS/ISLES2018/NEW_', flag, "_TIFF/");
    args.predictDirectory = strcat(ISLES2018Folder, "Matlab_Repository/Predict_", toadd, args.SUFFIX_RES, '_', flag, "/");
    args.originalDirectory = strcat(ISLES2018Folder, 'Stroke_segmentation/PATIENTS/ISLES2018/', flag, '/');
    args.workspaceFolder = strcat(ISLES2018Folder, 'Matlab_Repository/Workspace/'); 
    args.groundTruth_folder = args.directory; 
else
    disp("It is not supposed to arrive here!");
    return
end
    
args.suffix_folder = "PA";

args.folders_subnames = ["CBF", "CBV", "MTT", "Tmax", "TTP"]; % "CT." % ["CBF", "CBV", "MTT", "Tmax", "OT"];
args.suffix_workspace = "_nifti_ISLES2018";

%% get the list of patients     
args.patients = [];
for p=dir(args.directory)'
    if contains(p.name,args.suffix_folder)
        index = str2double(extractAfter(p.name, args.suffix_folder));
        if ~isempty(find([args.patientindex]==index, 1)) 
            args.patients = [args.patients; p.name];
        end
    end
end

if ~isfolder(args.predictDirectory)
    mkdir(args.predictDirectory);
end

%% if tableData does NOT exist, create it; otherwise, load it
if ~exist(strcat(args.workspaceFolder,"tableData_",flag,args.suffix_workspace,".mat"),'file')
    tableData = loadpatientsTableISLES2018(args);
    save(strcat(args.workspaceFolder,"tableData_",flag,args.suffix_workspace,".mat"), "tableData", '-v7.3');
else
    load(strcat(args.workspaceFolder,"tableData_",flag,args.suffix_workspace,".mat"),"tableData");
end

%tableData = tall(tableData);

toadd = "";
if args.superpixels 
    toadd = "superpixels_";
end

%% if the model does NOT exist, create it; otherwise load it
if ~exist(strcat(args.workspaceFolder,"MODELS_CORE_",toadd,args.SUFFIX_RES,"_ALL.mat"),'file')
    Mdl = runMLmodelForISLES2018(args, tableData);
else
    load(strcat(args.workspaceFolder,"MODELS_CORE_",toadd,args.SUFFIX_RES,"_ALL.mat"),"Mdl");
end

%% prediction images based on the model
if ~args.CROSS_VALIDATION % if we create a cross validate model, the prediction is different
    imagePixels = 512*512;

    for p_idx = args.patientindex
        tic
        disp(strcat("Predicting patient: ", num2str(p_idx)));
        
        data = tableData((tableData.patient == p_idx),contains(tableData.Properties.VariableNames,Mdl.PredictorNames));
        %data = gpuArray(table2array(data));
        
        nImages = size(data,1)/imagePixels;
        V = uint16(zeros(256,256,nImages));
        
        for i = 1:nImages
            tic
            img = uint16(zeros(512,512));
            img_data = data(((i-1)*imagePixels)+1:(i*imagePixels),:);
            predictions = predict(Mdl,img_data); 
            img =  reshape(predictions, [512,512]);
             
%             divide_img = size(img_data,1)/4;
%             for r = 1:4
%                 part_img = img_data(((r-1)*divide_img)+1:(r*divide_img),:);
%                 predictions = predict(Mdl,part_img); 
%                 img((r-1)*(divide_img/512)+1:r*(divide_img/512),:) = reshape(predictions, [divide_img/512,512]);
%             end

            V(:,:,i) = imresize(img, [256,256]); % format accepted by ISLES2018
            toc
        end
        
        structOrigCase =  dir(strcat(args.originalDirectory, "case_", num2str(p_idx), "/*CT.*/*.nii"));
        structOrigSMIRID =  dir(strcat(args.originalDirectory, "case_", num2str(p_idx), "/*MTT.*/*.nii"));

        info = niftiinfo(strcat(structOrigCase.folder, "/", structOrigCase.name));
        SMIRID = split(structOrigSMIRID.name,".");
        SMIRID = SMIRID{end-1};

        % write the prediction in a NIFTI format
        filename = strcat(args.predictDirectory, "SMIR.", num2str(p_idx), "_", args.SUFFIX_RES, "_prediction.", SMIRID, ".nii");
        niftiwrite(V, filename);

        % clear the previous images 
        close all force;
        toc
    end
end

