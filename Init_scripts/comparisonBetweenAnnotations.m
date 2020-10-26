clear;
close all force;

brain_color = 85;
penumbra_color = brain_color*2;
core_color = 255;

add = "";
MAIN_PATH = "D:\Preprocessed-SUS2020_v2\";
%     MAIN_PATH = "C:\Users\Luca\Desktop\Matlab_tmp_folder\";
perfusionCTFolder = MAIN_PATH+"Parametric_maps\";
saveFolder = MAIN_PATH+"Thresholding_Methods" + add + "\";
workspaceFolder = MAIN_PATH+"Workspace_thresholdingMethods\";
SAVED_MODELS_FOLDER = MAIN_PATH+"Workspace_thresholdingMethods\";

stats = table();

compare_folder = "D:\Preprocessed-SUS2020_v2\FINALIZE_PMS\FINALIZE_PM_Comparison_Kathinka\";
name_workspace = "comparison_manual_annotation_Kathinka.mat";
% compare_folder = strcat("D:\Preprocessed-SUS2020_v2\FINALIZE_PMS\FINALIZE_PM_Comparison_Liv\");
% name_workspace = "comparison_manual_annotation_Liv.mat";


for folder = dir(compare_folder)'
    if ~strcmp(folder.name, '.') && ~strcmp(folder.name, '..')
        orig_folder = strcat("D:\Preprocessed-SUS2020_v2\FINALIZE_PMS\FINALIZE_PM_TIFF\", folder.name, "\");
    
        for image = dir(orig_folder)'
            if ~strcmp(image.name, '.') && ~strcmp(image.name, '..')
                X = imread(strcat(image.folder,"\",image.name));
                Y = imread(strcat(compare_folder,"\",folder.name,"\",image.name));
                X = im2uint8(X);
                Y = im2uint8(Y);

                index_no_back_X = find(X~=0); %% 0==background!
                index_no_back_Y = find(Y~=0); %% 0==background!

                %% penumbra
                X_penumbra = (X>=penumbra_color-10 & X<=penumbra_color+10);
                X_penumbra_no_back = (X(index_no_back_X)>=penumbra_color-10 & X(index_no_back_X)<=penumbra_color+10);
                Y_penumbra = (Y>=penumbra_color-10 & Y<=penumbra_color+10);
                Y_penumbra_no_back = (Y(index_no_back_Y)>=penumbra_color-10 & Y(index_no_back_Y)<=penumbra_color+10);

                %% core
                X_core = (X>=core_color-10 & X<=core_color+10);
                X_core_no_back = (X(index_no_back_X)>=core_color-10 & X(index_no_back_X)<=core_color+10);
                Y_core = (Y>=core_color-10 & Y<=core_color+10);
                Y_core_no_back = (Y(index_no_back_Y)>=core_color-10 & Y(index_no_back_Y)<=core_color+10);

                if numel(X_penumbra_no_back)~=numel(Y_penumbra_no_back)
                    if numel(X_penumbra_no_back)>numel(Y_penumbra_no_back)
                        diff = numel(X_penumbra_no_back)-numel(Y_penumbra_no_back)-1;
                        disp(strcat("diff penumbra: ", num2str(diff)));
                        X_penumbra_no_back(end-diff:end) = [];
                    else
                        diff = numel(Y_penumbra_no_back)-numel(X_penumbra_no_back)-1;
                        disp(strcat("diff penumbra: ", num2str(diff)));
                        Y_penumbra_no_back(end-diff:end) = [];
                    end
                end

                if numel(X_core_no_back)~=numel(Y_core_no_back)
                    if numel(X_core_no_back)>numel(Y_core_no_back)
                        diff = numel(X_core_no_back)-numel(Y_core_no_back)-1;
                        disp(strcat("diff core: ", num2str(diff)));
                        X_core_no_back(end-diff:end) = [];
                    else
                        diff = numel(Y_core_no_back)-numel(X_core_no_back)-1;
                        disp(strcat("diff core: ", num2str(diff)));
                        Y_core_no_back(end-diff:end) = [];
                    end
                end

                X_penumbraCore = X_penumbra+X_core;
                X_penumbraCore_no_back = (X_penumbra_no_back+X_core_no_back)>=1;
                Y_penumbraCore = Y_penumbra+Y_core;
                Y_penumbraCore_no_back = (Y_penumbra_no_back+Y_core_no_back)>=1;


                CM_penumbra = confusionmat(reshape(X_penumbra,1,[]), reshape(Y_penumbra,1,[]));
                if numel(CM_penumbra)==1
                    CM_penumbra = double(reshape([CM_penumbra, 0, 0, 0], 2,2));
                end
                CM_core = confusionmat(reshape(X_core,1,[]),reshape(Y_core,1,[]));
                if numel(CM_core)==1
                    CM_core = double(reshape([CM_core, 0, 0, 0], 2,2));
                end
                CM_both = confusionmat(reshape(X_penumbraCore,1,[]),reshape(Y_penumbraCore,1,[])); % CM_penumbra+CM_core;
                if numel(CM_both)==1
                    CM_both = double(reshape([CM_both, 0, 0, 0], 2,2));
                end

                CM_penumbra_noback = confusionmat(reshape(X_penumbra_no_back,1,[]), reshape(Y_penumbra_no_back,1,[]));
    %             CM_penumbra_noback = [0,0;0,0];
                if numel(CM_penumbra_noback)==1
                    CM_penumbra_noback = double(reshape([CM_penumbra_noback, 0, 0, 0], 2,2));
                end
                CM_core_noback = confusionmat(reshape(X_core_no_back,1,[]),reshape(Y_core_no_back,1,[]));
    %             CM_core_noback = [0,0;0,0];
                if numel(CM_core_noback)==1
                    CM_core_noback = double(reshape([CM_core_noback, 0, 0, 0], 2,2));
                end
                CM_both_noback = confusionmat(reshape(X_penumbraCore_no_back,1,[]),reshape(Y_penumbraCore_no_back,1,[])); % CM_penumbra+CM_core;
    %             CM_both_noback = [0,0;0,0];
                if numel(CM_both_noback)==1
                    CM_both_noback = double(reshape([CM_both_noback, 0, 0, 0], 2,2));
                end

                [severity,~] = getSeverityAndNIHSSfromPatient(folder.name);
                rowToAdd = {severity,...
                    CM_penumbra(1,1), ... "tn_p"
                    CM_penumbra(2,1), ... "fn_p"
                    CM_penumbra(1,2), ... "fp_p"
                    CM_penumbra(2,2), ... "tp_p"
                    CM_core(1,1), ... "tn_c"
                    CM_core(2,1), ... "fn_c"
                    CM_core(1,2), ... "fp_c"
                    CM_core(2,2), ... "tp_c"
                    CM_both(1,1), ... "tn_pc"
                    CM_both(2,1), ... "fn_pc"
                    CM_both(1,2), ... "fp_pc"
                    CM_both(2,2), ... "tp_pc"
                    CM_penumbra_noback(1,1), ... "tn_p"
                    CM_penumbra_noback(2,1), ... "fn_p"
                    CM_penumbra_noback(1,2), ... "fp_p"
                    CM_penumbra_noback(2,2), ... "tp_p"
                    CM_core_noback(1,1), ... "tn_c"
                    CM_core_noback(2,1), ... "fn_c"
                    CM_core_noback(1,2), ... "fp_c"
                    CM_core_noback(2,2), ... "tp_c"
                    CM_both_noback(1,1), ... "tn_pc"
                    CM_both_noback(2,1), ... "fn_pc"
                    CM_both_noback(1,2), ... "fp_pc"
                    CM_both_noback(2,2) ... "tp_pc"
                };

                stats = [stats; rowToAdd];
            end
        end
    end
end

calculateStats(stats,SAVED_MODELS_FOLDER,name_workspace,0)


