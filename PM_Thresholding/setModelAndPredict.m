function [statsClassific] = setModelAndPredict(SAVED_MODELS_FOLDER,SUFFIX_RES,pIndex,p,STEPS,totalTableData,totalNImages,...
    penumbra_color,core_color,SUPERVISED_LEARNING,statsClassific,patient,saveFolder,subfolderToSave,suffix,...
    predictionMasks,MANUAL_ANNOTATION_FOLDER,PREDICT,SHOW_IMAGES,image_suffix,USESUPERPIXELS) %#ok<*INUSL>
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

% train the model and predict
for step=1:STEPS
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

    if contains(SUFFIX_RES,'tree')
        Mdl = fitctree(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
            'Weights',"weights",...
            'PredictorNames',predictorNames,...
            'AlgorithmForCategorical','PullLeft',... 
            'SplitCriterion','deviance',...
            'MaxNumSplits',50,...
            'MinLeafSize',1,...
            'NumVariablesToSample',size(totalTableData,1)/8);
    elseif contains(SUFFIX_RES,'SVM')
        if STEPS == 1
            % multiclass models for support vector machines
            Mdl = fitcecoc(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
                'Weights',"weights",...
                'ClassNames',classNames,...
                'PredictorNames',predictorNames,...
                'Options',options,...
                'Verbose',1);
        else
            Mdl = fitcsvm(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
                'Weights',"weights",...
                "outlierfraction", 0.1,...
                'ClassNames',classNames,...
                'PredictorNames',predictorNames,...
                'KernelFunction','linear',...
                'IterationLimit',150000,...
                'Verbose',1);
        end
    elseif contains(SUFFIX_RES,"randomForest")
        Mdl = TreeBagger(100,totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
            'Weights',"weights",...
            'PredictorNames',predictorNames,...
            'Method','classification',...
            'MaxNumSplits',50,...
            'MinLeafSize',1,...
            'NumPrint',1,...
            'NumPredictorsToSample',size(totalTableData,1)/8);
        
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

