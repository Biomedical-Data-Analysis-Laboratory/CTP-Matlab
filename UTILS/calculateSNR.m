function SNR_tot = calculateSNR(Image,patients,workspaceFolder,ISLISTOFDIR,directory,flag)
%CALCULATESNR Summary of this function goes here
%   Detailed explanation goes here
save_prefix = flag+"_SNR.";
SNR_tot = [];

for p = patients
    if ~ISLISTOFDIR % old patients
        p_id = num2str(p);
         if p<10
            fname = strcat(workspaceFolder,save_prefix,'PA0',p_id,'.mat');
        else
            fname = strcat(workspaceFolder,save_prefix,'PA',p_id,'.mat');
        end
    else
        folderPath = directory{p};
        p_id = convertCharsToStrings(folderPath(strfind(folderPath, "CTP_"):strfind(folderPath, "CTP_")+9));        
        fname = workspaceFolder + save_prefix + p_id + ".mat";
    end
    
    if ~exist(fname, 'file')
        SNR = [];
        disp(strcat("Patient: ", p_id));

        for s = 1:length(Image{p})
            for i = 1:length(Image{p}{s})
                signal = mean(Image{p}{s}{i}(:));
                noise = std(Image{p}{s}{i}(:));
                if noise==0 % empty mask
                    continue
                end
                SNR = [SNR; signal/noise];
            end
        end
        SNR = mean(SNR);
        save(fname,'SNR','-v7.3');
    else
        load(fname);
    end
    SNR_tot = [SNR_tot; SNR];
end

disp("Mean SNR: ");
disp(mean(SNR_tot));
disp("SD SNR: ")
disp(std(SNR_tot));
end

