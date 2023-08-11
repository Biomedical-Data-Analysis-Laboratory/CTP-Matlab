function [patients] = getPatients(app, MORE_TRAINING_DATA, TRAIN, TEST_SECRETDATASET, THRESHOLDING)
%GETPATIENTS Summary of this function goes here
%   Detailed explanation goes here

patients = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO NOT TOUCH THEM (if you just want to test)
use = [2, 39, 32, 8];
tot = [2, 75, 60, 15]; 
% tot = [4, 77, 63, 15]; <-- before was like this; removed: (CTP_02_052 +
% CTP_01_054 + CTP_01_077) (remove also CTP_02_046 & CTP_02_049 due to
% difference in the CTP slice number)
skip = [0,0,0,0];

if MORE_TRAINING_DATA
    use = [2, 27, 24, 6];

    % based on LIV and KATHINKA inter-oberver variability
    % 33 patients: 
    % - 19 LVO, 
    % - 11 without LVO,
    % - 3 WVO.
    secret_testdataset = ["CTP_01_001","CTP_01_007","CTP_01_013","CTP_01_019","CTP_01_025","CTP_01_031",...
        "CTP_01_037","CTP_01_044","CTP_01_049","CTP_01_053","CTP_01_061","CTP_01_067","CTP_01_074",...
        "CTP_02_001","CTP_02_007","CTP_02_013","CTP_02_019","CTP_02_025","CTP_02_031","CTP_02_036",...
        "CTP_02_043","CTP_02_050","CTP_02_055","CTP_02_062","CTP_03_003","CTP_03_010","CTP_03_014",...
        "CTP_01_057","CTP_01_059","CTP_01_066","CTP_01_068","CTP_01_071","CTP_01_073"];
else
    % secret testing dataset:
    % - 6 LVO,
    % - 6 without LVO,
    % - 3 WVO
    secret_testdataset = ["CTP_01_010","CTP_01_025","CTP_01_037","CTP_01_057","CTP_01_061",...
        "CTP_01_066","CTP_02_001","CTP_02_004","CTP_02_009","CTP_02_016","CTP_02_020",...
        "CTP_02_027","CTP_03_003","CTP_03_010","CTP_03_014"];
    % before:
    % secret_testdataset = ["CTP_01_010","CTP_01_025","CTP_01_037","CTP_01_057","CTP_01_061",...
    %     "CTP_01_066","CTP_01_077","CTP_02_001","CTP_02_004","CTP_02_009","CTP_02_016","CTP_02_020",...
    %     "CTP_02_027","CTP_03_003","CTP_03_010","CTP_03_014"];
end

if ~TRAIN % for testing
    if THRESHOLDING
        use = tot;
    else
        skip = use;
        use = abs(tot-use);
    end
end

%% get patients name folder (not create a fixed one)
infopatients.n_00.use = use(1); % 2% master's thesis patients (TOT:4)
infopatients.n_01.use = use(2); % 39% LVO (TOT:77)
infopatients.n_02.use = use(3); % 32% SVO (TOT:63)
infopatients.n_03.use = use(4); % 8% WVO (TOT:15)

infopatients.n_00.skip = skip(1); % USED for training
infopatients.n_01.skip = skip(2); % USED for training
infopatients.n_02.skip = skip(3); % USED for training
infopatients.n_03.skip = skip(4); % USED for training

patients_struct = dir(app.perfusionCTFolder)';
% set the seed and shuffle the patient struct 
rng(10);
rnd_indexes = randperm(length(patients_struct));
for p_idx=rnd_indexes 
    p = patients_struct(p_idx);        
    if ~strcmp(p.name, '.') && ~strcmp(p.name, '..')  
        process = 0;

        if TEST_SECRETDATASET
            if sum(cellfun(@any,strfind(secret_testdataset,p.name)))>0
                process = 1;
            end
        elseif app.option>=10 % for Liv and Kathinka annotations 
            process = 1; 
        else
            % exclude the patient inside the secret_testdataset list
            if THRESHOLDING || sum(cellfun(@any,strfind(secret_testdataset,p.name)))==0
                if ~isempty(strfind(p.name, "_00_"))
                    if infopatients.n_00.skip>0
                        infopatients.n_00.skip = infopatients.n_00.skip - 1;
                    else 
                        if infopatients.n_00.use>0
                            process = 1;
                            infopatients.n_00.use = infopatients.n_00.use - 1;
                        end
                    end
                elseif ~isempty(strfind(p.name, "_01_"))
                    if infopatients.n_01.skip>0
                        infopatients.n_01.skip = infopatients.n_01.skip - 1;
                    else 
                        if infopatients.n_01.use>0
                            process = 1;
                            infopatients.n_01.use = infopatients.n_01.use - 1;
                        end
                    end
                elseif ~isempty(strfind(p.name, "_02_")) 
                    if infopatients.n_02.skip>0
                        infopatients.n_02.skip = infopatients.n_02.skip - 1;
                    else 
                        if infopatients.n_02.use>0
                            process = 1;
                            infopatients.n_02.use = infopatients.n_02.use - 1;
                        end
                    end
                elseif ~isempty(strfind(p.name, "_03_")) 
                    if infopatients.n_03.skip>0
                        infopatients.n_03.skip = infopatients.n_03.skip - 1;
                    else 
                        if infopatients.n_03.use>0
                            process = 1;
                            infopatients.n_03.use = infopatients.n_03.use - 1;
                        end
                    end
                end
            end
        end

        if process
            patients = [patients; convertCharsToStrings(p.name)];
        end
    end
end
end

