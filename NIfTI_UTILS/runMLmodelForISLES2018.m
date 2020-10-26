function Mdl = runMLmodelForISLES2018(args, tableData)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

tic
%% train the model 
outputColumn = 'output';
costMatrix = [0,500;10,0];
classNames = [0 255];

%% use the superpixels columns or not
if args.superpixels 
    predictorNames = {'tmax','tmax_superpixels','mtt','mtt_superpixels','cbv','cbv_superpixels','cbf','cbf_superpixels'};
else
    predictorNames = {'tmax','mtt','cbv','cbf'};
end

%% optimize hyperparameters or not
if args.hyperparameterOptimizationFlag 
    optimizeHyperparameters = 'auto';
    hyperparameterOptimizationOptions = struct('AcquisitionFunctionName','expected-improvement-plus','MaxTime',10000,'Holdout',0.3,'UseParallel',true);
else
    optimizeHyperparameters = 'none';
    hyperparameterOptimizationOptions = struct();
end

%% use the cross validation options ?
if args.CROSS_VALIDATION
    crossVal = 'on';
else
    crossVal = 'off';
end

if contains(args.SUFFIX_RES,'tree') % DECISION TREE
    
    Mdl = fitctree(tableData,outputColumn,...
        'Weights',"weights",...
        'ClassNames',classNames,...
        'PredictorNames',predictorNames,...
        'AlgorithmForCategorical','PullLeft',... 
        'SplitCriterion','deviance',...
        'MaxNumSplits',50,...
        'NumVariablesToSample',size(tableData,1)/8,...
        'Surrogate','on',...
        'Reproducible',true,...
        'CrossVal',crossVal,...
        'OptimizeHyperparameters',optimizeHyperparameters,...
        'HyperparameterOptimizationOptions',hyperparameterOptimizationOptions,...
        'Cost',costMatrix);
    
elseif contains(args.SUFFIX_RES,'SVM') % SUPPORT VECTOR MACHINE
    
    Mdl = fitcsvm(tableData,outputColumn,...
        'Weights',"weights",...
        'ClassNames',classNames,...
        'PredictorNames',predictorNames,...
        'KernelFunction','gaussian',...
        'IterationLimit',100000,...
        'Cost',costMatrix,...   
        'RemoveDuplicates',true,...
        'CrossVal',crossVal,...
        'OptimizeHyperparameters',optimizeHyperparameters,...
        'HyperparameterOptimizationOptions',hyperparameterOptimizationOptions,...
        'Verbose',1);
    
elseif contains(args.SUFFIX_RES,'random_forest') % random forest
    
    t = templateTree('Weights',"weights",...
        'ClassNames',classNames,...
        'PredictorNames',predictorNames,...
        'AlgorithmForCategorical','PullLeft',... 
        'SplitCriterion','gdi',...
        'MaxNumSplits',15,...
        'PredictorSelection''interaction-curvature',...
        'NumVariablesToSample',size(tableData,1)/8,...
        'Surrogate','on',...
        'Reproducible',true,...
        'Cost',costMatrix);
    
    rng(1); % for reproducibility
    Mdl = fitcensemble(tableData,outputColumn,...
        'Method','Bag',...
        'Resample','on',...
        'ClassNames',classNames,...
        'PredictorNames',predictorNames,...
        'NumLearningCycles',200,...
        'Learner',t,...
        'Weights',"weights",...
        'Cost',costMatrix);
end

toadd = "";
if args.superpixels 
	toadd = "superpixels_";
end

%% save the model
save(strcat(args.workspaceFolder,"MODELS_CORE_",toadd,args.SUFFIX_RES,"_ALL.mat"), 'Mdl', '-v7.3');

toc

end
