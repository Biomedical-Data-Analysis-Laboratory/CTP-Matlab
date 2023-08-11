function calculateSSIM(Image,patients,workspaceFolder,ISLISTOFDIR,directory,flag)
%CALCULATESSIM Summary of this function goes here
%   Detailed explanation goes here

save_prefix = flag+"_SSIM.";

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
        SSIM = cell(length(Image{p}),length(Image{p}{1})-1);

        disp(strcat("Patient: ", p_id));

        for s = 1:length(Image{p})
            for i = 1:length(Image{p}{s})-1
                SSIM{s,i} = ssim(Image{p}{s}{i+1},Image{p}{s}{i});
                if SSIM{s,i}<0.4
                    disp(strcat(num2str(SSIM{s,i}), " - ", num2str(i), " - ", num2str(s)));
                end
            end
        end

        save(fname,'SSIM','-v7.3');
    end
end
end

