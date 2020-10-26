function [predictions,statsClassific,pred_img] = predictWithUnsupervisedLearning(p,pIndex,suffix,totalTableData,predictionMasks,...
    MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING,totalNImages,...
    statsClassific,patientSubFold,saveFolder,subsavefolder,SHOW_IMAGES,...
    SAVED_MODELS_FOLDER,SUFFIX_RES,STEPS,USE_UNIQUE_MODEL,image_suffix, MODELS)
%PREDICTWITHUNSUPERVISEDLEARNING Summary of this function goes here
%   Detailed explanation goes here

for step=1:STEPS
    flagToSaveImage = 0;
    if step==STEPS
        flagToSaveImage = 1;
    end

    p_string = pIndex;
    %% load separate model if the USE_UNIQUE_MODEL flag is set to false
    if ~USE_UNIQUE_MODEL
        if step==1
            if strcmp(SUFFIX_RES,'SVM_tree')
                load(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",int2str(STEPS),"steps_SVM_",p_string,".mat"));
            else
                load(strcat(SAVED_MODELS_FOLDER,"MODELS_PENUMBRA_",int2str(STEPS),"steps_",SUFFIX_RES,"_",p_string,".mat"));
            end
        elseif step==STEPS
            if strcmp(SUFFIX_RES,'SVM_tree')
                load(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",int2str(STEPS),"steps_tree_",p_string,".mat"));
            else
                load(strcat(SAVED_MODELS_FOLDER,"MODELS_CORE_",int2str(STEPS),"steps_",SUFFIX_RES,"_",p_string,".mat"));
            end
        end
        MODELS(1,step) = Mdl;
    end
    new_suffix = strcat(suffix, "_", pIndex);

    tic
    [predictions,statsClassific,pred_img] = predictFromModel(MODELS{1,step},...
        totalTableData((totalTableData.patient == str2double(pIndex)),1:end-2),...
        totalNImages{1,p},predictionMasks(:,p),step,STEPS, ...
        MANUAL_ANNOTATION_FOLDER,penumbra_color,core_color,SUPERVISED_LEARNING, ...
        statsClassific,new_suffix,patientSubFold,saveFolder,subsavefolder,flagToSaveImage,SHOW_IMAGES,image_suffix);
    toc

    % update the prediction mask cell with the new predictions
    predictionMasks{step+1,p} = pred_img;
end

end

