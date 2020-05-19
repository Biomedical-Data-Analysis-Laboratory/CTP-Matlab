function [statsClassific] = setModelAndPredict(SAVED_MODELS_FOLDER,SUFFIX_RES,pIndex,p,STEPS,totalTableData,totalNImages,...
    penumbra_color,core_color,SUPERVISED_LEARNING,statsClassific,patient,saveFolder,subfolderToSave,suffix,...
    predictionMasks,MANUAL_ANNOTATION_FOLDER,PREDICT,SHOW_IMAGES) %#ok<*INUSL>
%SETMODELANDPREDICT Summary of this function goes here
%   Detailed explanation goes here

p_string = pIndex;
if strcmp(p_string,"-1")
    p_string = "ALL";
end

flagToSaveImage = 0;
predictorNames = {'tmax','tmax_superpixels','ttp','ttp_superpixels','oldInfarction'};
%     predictorNames = {'tmax','ttp','oldInfarction'};
outputColumn = 'output';
costMatrix = [0,15;2,0];

% train the model and predict
for step=1:STEPS
    if step==STEPS
        flagToSaveImage = 1;
        predictorNames = {'cbv','cbv_superpixels','cbf','cbf_superpixels'};
%             predictorNames = {'cbv','cbf'};
        outputColumn = 'outputPenumbraCore';
        costMatrix = [0,1;5,0];
    end

    %% train the model 
    options = statset('UseParallel',false);

    if contains(SUFFIX_RES,'tree')
        Mdl = fitctree(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
            'Weights',"weights",...
            'PredictorNames',predictorNames,...
            'AlgorithmForCategorical','PullLeft',...
            'MaxNumSplits',15,...
            'MinLeafSize',1,...
            'SplitCriterion','deviance',...
            'NumVariablesToSample',5,...
            'Cost',costMatrix);
    elseif contains(SUFFIX_RES,'SVM')
        Mdl = fitcsvm(totalTableData((totalTableData.patient ~= str2double(pIndex)),:),outputColumn,...
            'Weights',"weights",...
            'PredictorNames',predictorNames,...
            'KernelFunction','gaussian',...
            'IterationLimit',100000,...
            'OutlierFraction',0.01,...
            'Cost',costMatrix,...
            'RemoveDuplicates',true,...
            'Verbose',1);
    end

    %% add the Mdl to MODELS for predictions without ground truth
    if step==1
        save(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_2steps_",SUFFIX_RES,"_",p_string,".mat"), 'Mdl', '-v7.3');
    elseif step==STEPS
        save(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_2steps_",SUFFIX_RES,"_",p_string,".mat"), 'Mdl', '-v7.3');
    end
    new_suffix = strcat(suffix, "_", pIndex);

    %% predict based on the model
    if PREDICT 
        tic
        [~,statsClassific,pred_img] = predictFromModel(Mdl,...
            totalTableData((totalTableData.patient == str2double(pIndex)),1:end-2),...
            totalNImages{1,p},predictionMasks{step,p}, ...
            MANUAL_ANNOTATION_FOLDER,pIndex,penumbra_color,core_color,SUPERVISED_LEARNING, ...
            statsClassific,new_suffix,patient,saveFolder,subfolderToSave,flagToSaveImage);
        toc

        % update the prediction mask cell with the new predictions
        predictionMasks{step+1,p} = pred_img;
    else
        % update the prediction mask cell with the old ones (if NO PREDICTIONS)
        predictionMasks{step+1,p} = predictionMasks{step,p};
    end
end

end

