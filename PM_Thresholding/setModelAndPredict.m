function [statsClassific] = setModelAndPredict(SAVED_MODELS_FOLDER,SUFFIX_RES,pIndex,p,STEPS,totalTableData,totalNImages,...
    penumbra_color,core_color,SUPERVISED_LEARNING,statsClassific,patient,saveFolder,subfolderToSave,suffix,...
    predictionMasks,MANUAL_ANNOTATION_FOLDER,PREDICT,SHOW_IMAGES,image_suffix,USESUPERPIXELS,USEHYPERPARAMETERS, HYPERPARAMETERS) %#ok<*INUSL>
%SETMODELANDPREDICT Summary of this function goes here
%   Detailed explanation goes here

p_string = pIndex;
if strcmp(p_string,"-1")
    p_string = "ALL";
end

flagToSaveImage = 0;
if USESUPERPIXELS
    if USESUPERPIXELS==1 || USESUPERPIXELS==3
        predictorNames = {'tmax','tmax_superpixels','ttp','ttp_superpixels','oldInfarction','NIHSS'};
    elseif USESUPERPIXELS==2 || USESUPERPIXELS==4
        predictorNames = {'tmax_superpixels','ttp_superpixels','oldInfarction','NIHSS'};
    end
else
    predictorNames = {'tmax','ttp','oldInfarction','NIHSS'};
end

outputColumn = 'outputPenumbraCore';
classNames = [1,2];

if contains(SUFFIX_RES,'SVM')
    classNames = [-1,1];
    totalTableData.(outputColumn)(totalTableData.outputPenumbraCore==1) = -1;
    totalTableData.(outputColumn)(totalTableData.outputPenumbraCore>1) = 1;
end

%% train the model and predict
disp(strcat("--MODEL INFO: ", num2str(STEPS), ": steps - ", ...
    num2str(USESUPERPIXELS), ": flag superpixels - ", ...
    SUFFIX_RES, " model - ", ...
    num2str(USEHYPERPARAMETERS), ": use hyperparameters."));

for step=1:STEPS
    suffix_struct = 'one';
    if step==2
        suffix_struct = 'two';
    end
    % if the model is already saved
    if step==1 && STEPS == 2 && exist(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",suffix,"_",p_string,".mat"),'file')==2
        continue
    elseif step==STEPS && STEPS == 2 && exist(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",suffix,"_",p_string,".mat"),'file')==2
        continue
    end
    
    if step==1
        if STEPS == 1
            disp(strcat(SAVED_MODELS_FOLDER,"MODELS_UNIQUE_",suffix,"_",p_string,".mat"));
        else
            disp(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",suffix,"_",p_string,".mat"));
        end
    elseif step==STEPS
        disp(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",suffix,"_",p_string,".mat"));
    end      
    
    if step==STEPS
        flagToSaveImage = 1;
        if STEPS == 1 % use ALL predictors because we classify penumbra&core together
            if USESUPERPIXELS
                if USESUPERPIXELS==1 || USESUPERPIXELS==3
                    predictorNames = {'tmax','tmax_superpixels','ttp','ttp_superpixels','cbv',...
                        'cbv_superpixels','cbf','cbf_superpixels','oldInfarction','NIHSS'};
                elseif USESUPERPIXELS==2 || USESUPERPIXELS==4
                    predictorNames = {'tmax_superpixels','ttp_superpixels',...
                        'cbv_superpixels','cbf_superpixels','oldInfarction','NIHSS'};
                end
            else 
                predictorNames = {'tmax','ttp','cbv','cbf','oldInfarction','NIHSS'};
            end
            
            outputColumn = 'output';
            classNames = [1,2,3];
            
        else % use the core predictor names
            if USESUPERPIXELS
                if USESUPERPIXELS==1 || USESUPERPIXELS==3
                    predictorNames = {'cbv','cbv_superpixels','cbf','cbf_superpixels','NIHSS'};            
                elseif USESUPERPIXELS==2 || USESUPERPIXELS==4
                    predictorNames = {'cbv_superpixels','cbf_superpixels','NIHSS'};
                end
            else
                predictorNames = {'cbv','cbf','NIHSS'};
            end
    
            outputColumn = 'outputCore';
            classNames = [1,3];
          
            if contains(SUFFIX_RES,'SVM')
                classNames = [-1,1];
                totalTableData.(outputColumn)(totalTableData.outputPenumbraCore==1) = -1;
                totalTableData.(outputColumn)(totalTableData.outputPenumbraCore>1) = 1;
            end
        end
    end

    %% train the model 
    options = statset('UseParallel',false);
    hyperparam = 'none';
    hyperparam_struct = struct();
   
    if USEHYPERPARAMETERS
        hyperparam = 'all';
        hyperparam_struct.ShowPlots = false;
        hyperparam_struct.Verbose = 1;
    end
    
    if contains(SUFFIX_RES,'tree')
        Mdl = fitctree(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
            'Weights',"weights",...
            'PredictorNames',predictorNames,...
            'AlgorithmForCategorical','Exact',... 
            'SplitCriterion',HYPERPARAMETERS.(suffix_struct).SplitCriterion,...
            'MaxNumSplits',HYPERPARAMETERS.(suffix_struct).MaxNumSplits,...
            'MinLeafSize',HYPERPARAMETERS.(suffix_struct).MinLeafSize,...
            'OptimizeHyperparameters',hyperparam,...
            'HyperparameterOptimizationOptions',hyperparam_struct,...
            'NumVariablesToSample','all');
    elseif contains(SUFFIX_RES,'SVM')       
        if STEPS == 1
            
            tplSVM = templateSVM('Solver','SMO',...  
                'DeltaGradientTolerance',1e-5,...
                'BoxConstraint',HYPERPARAMETERS.(suffix_struct).BoxConstraint,...
                'KernelScale',HYPERPARAMETERS.(suffix_struct).KernelScale,...
                'KernelFunction',HYPERPARAMETERS.(suffix_struct).KernelFunction,...
                'Standardize',HYPERPARAMETERS.(suffix_struct).Standardize,...
                'RemoveDuplicates',true);
            
            % multiclass models for support vector machines
            Mdl = fitcecoc(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
                'Weights',"weights",...
                'ClassNames',classNames,...
                'PredictorNames',predictorNames,...
                'Options',options,...
                'Learners',tplSVM,...
                'OptimizeHyperparameters',hyperparam,...
                'HyperparameterOptimizationOptions',hyperparam_struct,...
                'Verbose',1);
        else
            Mdl = fitcsvm(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
                'Weights',"weights",...
                'Solver','SMO',...
                'PredictorNames',predictorNames,...
                'BoxConstraint',HYPERPARAMETERS.(suffix_struct).BoxConstraint,...
                'KernelScale',HYPERPARAMETERS.(suffix_struct).KernelScale,...
                'KernelFunction',HYPERPARAMETERS.(suffix_struct).KernelFunction,...
                'Standardize',HYPERPARAMETERS.(suffix_struct).Standardize,...
                'DeltaGradientTolerance',1e-5,...
                'OptimizeHyperparameters',hyperparam,...
                'RemoveDuplicates',true,...
                'HyperparameterOptimizationOptions',hyperparam_struct,...
                'Verbose',0);
        end
    elseif contains(SUFFIX_RES,"randomForest")
        
        tree = templateTree('AlgorithmForCategorical','Exact',... 
            'Type','classification',...
            'SplitCriterion',HYPERPARAMETERS.(suffix_struct).SplitCriterion,...
            'MaxNumSplits',HYPERPARAMETERS.(suffix_struct).MaxNumSplits,...
            'NumVariablesToSample','all',...
            'MinLeafSize',HYPERPARAMETERS.(suffix_struct).MinLeafSize);
        
        if USEHYPERPARAMETERS
            nPred = height(totalTableData((totalTableData.patient ~= str2double(pIndex)),:));
            hyperparam = hyperparameters('fitcensemble',totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,tree);
            for ii = 1:length(hyperparam)
                if strcmp(hyperparam(ii).Name, 'NumLearningCycles')
                    hyperparam(ii).Range = [10, 250];
                    hyperparam(ii).Optimize = true;
                elseif strcmp(hyperparam(ii).Name, 'MaxNumSplits')
                    hyperparam(ii).Range = [1, max(2,floor(nPred/2))];
                    hyperparam(ii).Optimize = true;
                elseif strcmp(hyperparam(ii).Name, 'MinLeafSize')
                    hyperparam(ii).Range = [1, max(2,floor(nPred/4))];
                    hyperparam(ii).Optimize = true;
                elseif strcmp(hyperparam(ii).Name, 'SplitCriterion')
                    hyperparam(ii).Optimize = true;
                elseif strcmp(hyperparam(ii).Name, 'NumVariablesToSample')
                    hyperparam(ii).Optimize = false;
                elseif strcmp(hyperparam(ii).Name, 'Method')
                    hyperparam(ii).Optimize = false;
                elseif strcmp(hyperparam(ii).Name, 'LearnRate')
                    hyperparam(ii).Optimize = false;
                end
            end
            hyperparam_struct.ShowPlots = false;
            hyperparam_struct.Verbose = 1;
        end
                
        Mdl = fitcensemble(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
            'Method','Bag',...
            'Weights',"weights",...
            'PredictorNames',predictorNames,...
            'NumLearningCycles',HYPERPARAMETERS.(suffix_struct).NumLearningCycles,...
            'Resample','on',...
            'Learners',tree,...
            'OptimizeHyperparameters',hyperparam,...
            'HyperparameterOptimizationOptions',hyperparam_struct);
        
%         Mdl = TreeBagger(100,totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
%             'Weights',"weights",...
%             'PredictorNames',predictorNames,...
%             'Method','classification',...
%             'MaxNumSplits',50,...
%             'MinLeafSize',1,...
%             'NumPrint',1,...
%             'OptimizeHyperparameters',hyperparam,...
%             'HyperparameterOptimizationOptions',hyperparam_struct,...
%             'NumPredictorsToSample','all');
        
    elseif contains(SUFFIX_RES,"naiveBayes")
        Mdl = fitcnb(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
            'DistributionNames','kernel',...
            'Weights',"weights",...
            'PredictorNames',predictorNames);
    end

    %% add the Mdl to MODELS for predictions without ground truth
    if step==1
        if STEPS == 1
            save(strcat(SAVED_MODELS_FOLDER,"MODELS_UNIQUE_",suffix,"_",p_string,".mat"), 'Mdl', '-v7.3');
        else
            save(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",suffix,"_",p_string,".mat"), 'Mdl', '-v7.3');
        end
    elseif step==STEPS
        save(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",suffix,"_",p_string,".mat"), 'Mdl', '-v7.3');
    end
    new_suffix = strcat(suffix, "_", pIndex);

    %% predict based on the model
    if PREDICT 
        tic
        [~,statsClassific,pred_img] = predictFromModel(Mdl,...
            totalTableData((totalTableData.patient == str2double(pIndex)),1:end-2),...
            totalNImages{1,p},predictionMasks(:,p),step,STEPS, ...
            MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING, ...
            statsClassific,new_suffix,patient,saveFolder,subfolderToSave,flagToSaveImage,image_suffix);
        toc

        % update the prediction mask cell with the new predictions
        predictionMasks{step+1,p} = pred_img;
    else
        % update the prediction mask cell with the old ones (if NO PREDICTIONS)
        predictionMasks{step+1,p} = predictionMasks{step,p};
    end
end

end

