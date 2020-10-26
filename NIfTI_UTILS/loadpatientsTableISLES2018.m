function tableData = loadpatientsTableISLES2018(args)
%RUNMLMODELFORISLES2018 Summary of this function goes here
%   Detailed explanation goes here

% nCluster = 101; 
% realMaxValues = [100, 6, 10, 12];
tableData =  table();
multiplyBack = -1;
suffix_images = ".tiff";

wb = uiprogressdlg(uifigure,'Title','Please Wait',...
    'Message','Start analyzing ISLES2018 patients...');

for p_idx = 1:size(args.patients,1)
    tic
    patient_name = args.patients(p_idx,:);
    wb.Value = p_idx/size(args.patients,1);
    wb.Message = strcat("Loading patient ", patient_name, " - " , num2str(p_idx), "/", num2str(size(args.patients,1)));
    
    cbf = []; cbv = []; tmax = []; mtt = []; ttp = []; oldInfactionMask = []; 
    cbf_superpixels = []; cbv_superpixels = []; tmax_superpixels = []; mtt_superpixels = []; ttp_superpixels = [];
    output = []; 
    
    patient = dir(strcat(args.directory,"/",patient_name))';
    
    sortImages = cell(numel(args.folders_subnames),1);
    realValueImages = cell(numel(args.folders_subnames),1);
    
    %% get the images and the real vales (after clustering)
    for subfold_patient = patient
        if ~isempty(find(strcmp(args.folders_subnames, subfold_patient.name), 1)) % if the parametric map folder exists
            pm_index = find(strcmp(args.folders_subnames, subfold_patient.name));
            n = numel(dir(strcat(subfold_patient.folder,"/",subfold_patient.name)))-2;
            
            sortImages{pm_index} = cell(1,n);
            for i=1:n
                imagename = strcat('/',num2str(i));
                if i<10
                    imagename = strcat('/0',num2str(i));
                end
                
                sortImages{pm_index}{i} = imread(strcat(subfold_patient.folder,"/",subfold_patient.name,imagename,suffix_images));
                
                realValueImages{pm_index}{i} = double(sortImages{pm_index}{i});
                
%                 pixel_labels = imsegkmeans(sortImages{pm_index}{i},nCluster,'NumAttempts',3);
% 
%                 realValueImages{pm_index}{i} = zeros(size(sortImages{pm_index}{i},1), size(sortImages{pm_index}{i},2));
%                 
%                 for pix_idx=1:nCluster
%                     
%                     if pixel_labels(1,1)~=pix_idx
%                         maskVal = pixel_labels==pix_idx;
%                         
%                         %% replace realMaxValues(pm_idx) with 1 if you want values 0~1!
%                         maskVal = maskVal * (realMaxValues(pm_index)*(pix_idx-1));
%                         realValueImages{pm_index}{i} = realValueImages{pm_index}{i}+maskVal;
%                     end
%                 end
            end
        end
    end
    
    %% get the superpixels, the pixels and the output
    for pm_idx = 1:size(realValueImages,1)
        
        for index = 1:size(realValueImages{pm_idx},2)
            slice_index = num2str(index);
            if length(slice_index) == 1
                slice_index = strcat('0', slice_index);
            end
            
            %% binary mask
            pm_mask = realValueImages{pm_idx}{index}>0;
        
            %% superpixels feature of the real values ? 
            [L,N] = superpixels(realValueImages{pm_idx}{index},100);
            pm_mask_superpixels = meanSuperpixelsImage(realValueImages{pm_idx}{index},L,N);
            pm_mask_superpixels = double(imfill(pm_mask_superpixels)) .* double(pm_mask);
            
            if pm_idx==1 % == CBF
                cbf = cat(1, cbf(:), realValueImages{pm_idx}{index}(:));
                cbf_superpixels = cat(1, cbf_superpixels(:), pm_mask_superpixels(:));
            elseif pm_idx==2 % == CBV
                cbv = cat(1, cbv(:), realValueImages{pm_idx}{index}(:));
                cbv_superpixels = cat(1, cbv_superpixels(:), pm_mask_superpixels(:));
            elseif pm_idx==3 % == MTT
                mtt = cat(1, mtt(:), realValueImages{pm_idx}{index}(:));
                mtt_superpixels = cat(1, mtt_superpixels(:), pm_mask_superpixels(:));
            elseif pm_idx==4 % == Tmax
                tmax = cat(1, tmax(:), realValueImages{pm_idx}{index}(:));
                tmax_superpixels = cat(1, tmax_superpixels(:), pm_mask_superpixels(:));
            elseif pm_idx==5 % == TTP
                ttp = cat(1, ttp(:), realValueImages{pm_idx}{index}(:));
                ttp_superpixels = cat(1, ttp_superpixels(:), pm_mask_superpixels(:));
            end
             
            % if  we are in the last index
            if pm_idx==size(realValueImages,1)
                if args.SUPERVISED_LEARNING % if it is supervised 
                    filename = strcat(args.groundTruth_folder, patient_name, "/OT/", slice_index,suffix_images);
                    Igray = imread(filename);
                    if ndims(Igray)==3
                        Igray = rgb2gray(Igray);
                    end
                    Igray = double(Igray);
                    output = cat(1, output(:), Igray(:));
                else
                    fake_output = ones(512,512);
                    output = cat(1, output(:), fake_output(:));
                end
            end
        end        
    end 
    
    %% set weights and output
    weights = ones(size(output));
    weights(output==255) = floor(numel(output)/sum(weights(output==255))); % core == 255
    
    %% create the table
    indexPatient = ones(size(cbf(:))) .* p_idx;
    
    tmpTableData = table(indexPatient,...
        cbf(:),cbf_superpixels(:),...
        cbv(:),cbv_superpixels(:),...
        mtt(:), mtt_superpixels(:),...
        tmax(:),tmax_superpixels(:),...
        ttp(:),ttp_superpixels(:),...
        weights(:),output(:),... 
        'VariableNames', ["patient","cbf","cbf_superpixels",...
        "cbv","cbv_superpixels","mtt","mtt_superpixels",...
        "tmax","tmax_superpixels","ttp","ttp_superpixels","weights","output"]);
     
    tableData = [tableData; tmpTableData];
    
    toc
end

end

