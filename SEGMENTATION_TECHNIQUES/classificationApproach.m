% function [statsClassific, MODELS] = classificationApproach(realValueImages,skullMasks, PREDICT_WITH_OTHER_MODElS, ...
%     MANUAL_ANNOTATION_FOLDER, patient, penumbra_color, core_color, saveFolder, suffix, statsClassific, MODELS)

function [data,tableData,nImages] = classificationApproach(realValueImages,skullMasks, PREDICT_WITH_OTHER_MODElS, ...
    MANUAL_ANNOTATION_FOLDER, patient, penumbra_color, core_color, saveFolder, suffix, statsClassific, MODELS)

%CLASSIFICATIONAPPROACH Summary of this function goes here
%   Detailed explanation goes here

close all;

pIndex = patient(end-1:end);
nImages = size(realValueImages,2);

%% prepare the data 
[data,output,tableData,weights] = prepareDataForModel(realValueImages,skullMasks,MANUAL_ANNOTATION_FOLDER,pIndex);

% LearnRate = ["linear", "quadratic", "diaglinear", "diagquadratic", "pseudolinear", "pseudoquadratic"];
% Gamma = [0,1,0,1,0,1];
% numDT = numel(DiscrimType);
% HyperparameterOptimizationOptions = struct('UseParallel', true, 'Verbose', 2, ...
%   'Holdout',0.3, 'Optimizer','randomsearch');
% Mdl = cell(1,numDT);
% predictions = cell(1,numDT);
% for k=1:numDT
%     Mdl{1,k} = fitcdiscr(data,output(:), 'Weights', weights(:), ...
%         'DiscrimType', DiscrimType(k), 'Gamma', Gamma(k), ...
%         'HyperparameterOptimizationOptions', HyperparameterOptimizationOptions);
%     predictions{1,k} = predict(Mdl{1,k},data);
%     disp("MSE:");
%     disp(immse(output(:), predictions{1,k}));
% end

% % t = templateLinear('LearnRate', 0.01, 'Verbose',1);
% % Mdl = fitcecoc(data,output(:), 'Weights', weights(:), 'Learners', t);
% Mdl = fitcdiscr(data,output(:), 'Weights', weights(:));

% % % if ~PREDICT_WITH_OTHER_MODElS
% % %     %% create the folders if it don't exist
% % %     if ~ exist(strcat(saveFolder, patient, '/CLUSTER'),'dir')
% % %         mkdir(strcat(saveFolder, patient, '/CLUSTER'));
% % %     end
% % %     
% % %     %% train the model 
% % %     t = templateTree('MaxNumSplits',150);
% % %     Mdl = fitcensemble(tableData,"output", "Method","AdaBoostM2", "Learner",t, 'Weights', weights(:));
% % %     MODELS{1,str2double(pIndex)} = Mdl; %add the Mdl to MODELS for predictions without ground truth
% % % 
% % %     %% predict from model
% % %     [predictions,statsClassific] = predictFromModel(Mdl,data,nImages, ...
% % %         MANUAL_ANNOTATION_FOLDER,pIndex,penumbra_color,core_color, ...
% % %         statsClassific,suffix,patient,saveFolder, '/CLUSTER/');
% % %     
% % %     %% display MEAN SQUARE ERROR (MSE)
% % %     disp("MSE:");
% % %     disp(immse(output(:), predictions));
% % % 
% % %     % [lb,center] = clusteringParametricMaps(cbf,cbv,tmax,ttp, size(realValueImages,2));
% % %     % disp(center);
% % %     % for t=1:nImages
% % %     %     figure, imshow(lb{1,t},[]);
% % %     % end
% % % else
% % %     % load the saved models
% % %     load(strcat(saveFolder,"MODELS.mat"));
% % %     
% % %     if ~ exist(strcat(saveFolder, patient, '/CLUSTER_OTHER_PATIENTS'),'dir')
% % %         mkdir(strcat(saveFolder, patient, '/CLUSTER_OTHER_PATIENTS'));
% % %     end
% % %     
% % %     for mdl_idx = 1:size(MODELS,2)
% % %         % only if the index is different from the current patient and ~= patient 1
% % %         if (mdl_idx ~= str2double(pIndex)) && (mdl_idx ~= 1)
% % %             currentMDL = MODELS(mdl_idx);
% % %             
% % %             indexModel = num2str(mdl_idx);
% % %             if length(indexModel) == 1
% % %                 indexModel = strcat('0', indexModel);
% % %             end
% % %     
% % %             new_suffix = strcat(suffix, "_", indexModel);
% % %             
% % %             [predictions,statsClassific] = predictFromModel(currentMDL{1},data,nImages, ...
% % %                 MANUAL_ANNOTATION_FOLDER,pIndex,penumbra_color,core_color, ...
% % %                 statsClassific,new_suffix,patient,saveFolder, '/CLUSTER_OTHER_PATIENTS/');
% % %             
% % %             %% display MEAN SQUARE ERROR (MSE)
% % %             disp("MSE:");
% % %             disp(immse(output(:), predictions));
% % %         end
% % %     end
% % % end

end

