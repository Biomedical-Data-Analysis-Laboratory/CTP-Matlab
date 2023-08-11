function ImageRegistered = reg_ct(ImageFolder, ISLISTOFDIR, Image, sortedK, ...
    patients, usePhaseCorrelation, SAVE, workspaceFolder, suffix, ...
    suffix_workspace, MRIFolder)
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

REGISTER_CT = 1;
REGISTER_MRI_TO_CT = 0;

%% register the CT images with themselfs
if REGISTER_CT
    save_prefix = strcat('02_Registered',suffix,'.');
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
                fname = strcat(workspaceFolder,save_prefix,suffix,'PA0',p_id,'.mat');
            else
                fname = strcat(workspaceFolder,save_prefix,suffix,'PA',p_id,'.mat');
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
            disp(fname);
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

            parfor ii = 2:length(Imk)
                moving = Imk{ii};
                if ~usePhaseCorrelation 
                    movingReg{ii} = imregister(moving, fixed, transform, optimizer, metric);
                else
                    movingReg{ii} = imregister(moving, fixed, transform, optimizer, metric,'InitialTransformation',imregcorr(moving,fixed));
                end

            end
            movingReg{1} = fixed;
            ImageRegistered{p}{k} = movingReg;

            disp(['Currently registering p=' num2str(p) ', k=' num2str(k)])

            disp("Interpolation...")
            %% interpolation
            % for i = 1:21
            %     if i==1 % first time point remains the same
            %         NewImageRegistered{p}{k}{i} = ImageRegistered{p}{k}{i};
            %     else
            %         distpoint = sqrt((sortedK{p}{k}(i)-1)^2);
            %         distorig = sqrt((sortedK{p}{k}(i-1)-1)^2);
            %         tot = distorig+distpoint;
            % 
            %         NewImageRegistered{p}{k}{i} = ImageRegistered{p}{k}{i-1} .* (distpoint/tot) + ImageRegistered{p}{k}{i} .* (distorig/tot);
            %     end
            % end
            for i = 1:19
                NewImageRegistered{p}{k}{i} = ImageRegistered{p}{k}{i};
            end
            add = 0;
            for i = 20:length(ImageRegistered{p}{k})
                % distpoint = sqrt((sortedK{p}{k}(i)-1)^2);
                % distorig = sqrt((sortedK{p}{k}(i-1)-1)^2);
                % tot = distorig+distpoint;
                % NewImageRegistered{p}{k}{i+add} = ImageRegistered{p}{k}{i-1} .* (distpoint/tot) + ImageRegistered{p}{k}{i} .* (distorig/tot);
                NewImageRegistered{p}{k}{i+add} = ImageRegistered{p}{k}{i};
                add = add + 1;
                if (i+add)>40
                    break
                end
                distpoint = sqrt((sortedK{p}{k}(i)-2)^2);
                distorig = sqrt((sortedK{p}{k}(i-1)-2)^2);
                tot = distorig+distpoint;
                NewImageRegistered{p}{k}{i+add} = ImageRegistered{p}{k}{i-1} .* (distpoint/tot) + ImageRegistered{p}{k}{i} .* (distorig/tot);
            end
        end

        ImageRegistered{p} = NewImageRegistered{p};

        if SAVE
            patImage = ImageRegistered{p};
            save(fname,'patImage','-v7.3')
        end
        toc
    end
end

if REGISTER_MRI_TO_CT
    [optimizer,metric] = imregconfig('multimodal');
    save_prefix = strcat('02_MRI-CT_',suffix,'.');
    for p = patients
        if ~ISLISTOFDIR
            p_id = num2str(p);
            if p<10
                fname = strcat(workspaceFolder,save_prefix,suffix,'PA0',p_id,'.mat');
                mri_id = strcat('PA0',p_id);
            else
                fname = strcat(workspaceFolder,save_prefix,suffix,'PA',p_id,'.mat');
                mri_id = strcat('PA',p_id);
            end
        else 
            folderPath = ImageFolder{p}; 
            if strcmp(folderPath,"") % == there is no patient 
                ImageRegistered{p} = [];
                continue
            end
            p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));        
            fname = workspaceFolder + convertCharsToStrings(save_prefix) + p_id + ".mat";
            mri_id = p_id;
        end
        
        disp("Registering MRI to CT for patient: " + p_id);
        if exist(fname, 'file')==2
            disp(fname);
            load(fname);
            ImageRegistered{p} = patImage;
            continue
        end
        
        if ~isfolder(strcat(MRIFolder,mri_id))
            continue
        end
        
        tic

        ImageRegistered{p} = [];
        Im = Image(p);
        
        toc
    end
end
