function ImageRegistered = reg_ct(ImageFolder, ISLISTOFDIR, Image, patients, usePhaseCorrelation, SAVE, workspaceFolder, suffix, suffix_workspace)
% Register images using one of the optimizers and similarity metrics
% available in the Image Processing Toolbox. The phase correlation is
% comptued to estimate an initial geometric transform. If the modality
% 'multimodal' is selected, the One-Plus-One evolutionary optimizer
% optimizing the Matte's mutual information is used. To improve the
% registration results, the default parameters can be adjusted by a
% scaling:
%
%     optimizer.InitialRadius = optimizer.InitialRadius/scaling;
%     optimizer.Epsilon = optimizer.Epsilon/scaling;
%     optimizer.GrowthFactor = (optimizer.GrowthFactor-1)/scaling+1;
%     optimizer.MaximumIterations = optimizer.MaximumIterations*scaling;
%
% The images used in the skull removal and segmentation are registered with
% the Similarity transform and treated as multimodal images with scaling=8.
% It is preferable to have enough computational power available, as it is
% ~4000 images that are registered with an iterative algorithm.
%
% If the Parallel Computing Toolbox not is installed, the 'parfor' in the
% inner loop will have to be replaced with 'for'.

save_prefix = ['02_Registered' suffix '.'];

modality = {'monomodal' 'multimodal'};
modind = 2;
transform = 'similarity'; % geometric transform

[optimizer, metric] = imregconfig(modality{modind});

scaling = 0.25;

if modind==2
    optimizer.InitialRadius = optimizer.InitialRadius/(scaling*10);
    optimizer.Epsilon = optimizer.Epsilon/scaling;
    optimizer.GrowthFactor = (optimizer.GrowthFactor-1)/scaling+1;
end
optimizer.MaximumIterations = optimizer.MaximumIterations*scaling;

for p = patients
    if ~ISLISTOFDIR
        p_id = num2str(p);
        if p<10
            fname = ([workspaceFolder save_prefix suffix 'PA0' p_id '.mat']);
        else
            fname = ([workspaceFolder save_prefix suffix 'PA' p_id '.mat']);
        end
    else 
        folderPath = ImageFolder{p}; 
        if strcmp(folderPath,"") % == there is no patient 
            ImageRegistered{p} = [];
            continue
        end
        p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));        
        fname = workspaceFolder + convertCharsToStrings(save_prefix) + p_id + ".mat";
    end
    
    disp("Registering patient: " + p_id);
    if exist(fname, 'file')==2
        load(fname);
        ImageRegistered{p} = patImage;
        continue
    end
    tic
       
    ImageRegistered{p} = [];
    Imp = Image(p);
    kLength = length(Image{p});
    
    for k = 1:kLength
        Imk = Imp{1}{k};
        fixed = Imk{1};
        
        parfor i = 2:length(Imk)
            moving = Imk{i};
            if ~usePhaseCorrelation 
                movingReg{i} = imregister(moving, fixed, transform, optimizer, metric);
            else
                movingReg{i} = imregister(moving, fixed, transform, optimizer, metric,'InitialTransformation',imregcorr(moving,fixed));
            end

        end
        movingReg{1} = fixed;
        ImageRegistered{p}{k} = movingReg;
        
        disp(['Currently registering p=' num2str(p) ', k=' num2str(k)])
    end
    
    if SAVE
        patImage = ImageRegistered{p};
        save(fname,'patImage','-v7.3')
    end
    toc
end

if SAVE
    save(strcat(workspaceFolder, 'ImageRegistered', suffix, suffix_workspace, '.mat'),'ImageRegistered','-v7.3')
end
