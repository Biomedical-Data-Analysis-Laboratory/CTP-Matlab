function AUC_table = plotROC(researchesValues,stats,AUC_table,flag)
%PLOTROC Summary of this function goes here
%   Detailed explanation goes here
    
h = zeros(1,researchesValues.Count+1);

% coordinate for mJNet_DA_ADAM_VAL5 (avg)
% (X,Y) = (1-specificity, sensitivity)
if flag=="penumbra"
    X_p_adam = [1-1, 1-0.988, 1-0.98, 1-0.972, 1-0.964, 1-0.963, 1-0.958, 1-0.952, 1-0.942, 1-0.909, 1-0]; 
    Y_p_adam = [0, 0.625, 0.749, 0.818, 0.864, 0.885, 0.895, 0.906, 0.919, 0.939, 1];
    X_p_sgd = [1-1, 1-0.987, 1-0.99, 1-0.974, 1-0.966, 1-0.963, 1-0.958, 1-0.952, 1-0.943, 1-0.924, 1-0];
    Y_p_sgd = [0, 0.726, 0.815, 0.862, 0.911, 0.931, 0.939, 0.947, 0.957, 0.969, 1];
%     plot(X_p_adam, Y_p_adam, "-", 'DisplayName', "mJNet (ADAM)", "LineWidth", 3, "Color", "red");
    hold on
    h(1) = plot(X_p_sgd, Y_p_sgd, "-", 'DisplayName', "mJNet (SGD)", "LineWidth", 3, "Color", "blue");
    %plot(1-0.88, 0.80, "-s", 'DisplayName', "ADAM longJ penumbra w/o back")
    
    auc_adam_nb = abs(trapz(X_p_adam,Y_p_adam));
    auc_sgd_nb = abs(trapz(X_p_sgd,Y_p_sgd));
    AUC_table = [AUC_table; {strcat("adam", '_', flag), auc_adam_nb}];
    AUC_table = [AUC_table; {strcat("sgd", '_', flag), auc_sgd_nb}];

elseif flag=="core"
    X_c_adam = [1-1, 1-0.994, 1-0.983, 1-0.971, 1-0.956, 1-0.931, 1-0.91, 1-0.887, 1-0.844, 1-0];
%     X_c_adam = [1-1, 1-0.994, 1-0.983, 1-0.971, 1-0.956, 1-0.965, 1-0.931, 1-0.91, 1-0.887, 1-0.844, 1-0];
    Y_c_adam = [0, 0.231, 0.375, 0.496, 0.606, 0.817, 0.857, 0.889, 0.945, 1];
%     Y_c_adam = [0, 0.231, 0.375, 0.496, 0.606, 0.557, 0.817, 0.857, 0.889, 0.945, 1];
    X_c_sgd = [1-1, 1-0.989, 1-0.982, 1-0.974, 1-0.962, 1-0.923, 1-0.901, 1-0.878, 1-0.839, 1-0];
%     X_c_sgd = [1-1, 1-0.989, 1-0.982, 1-0.974, 1-0.962, 1-0.966, 1-0.923, 1-0.901, 1-0.878, 1-0.839, 1-0];
    Y_c_sgd = [0, 0.368, 0.502, 0.605, 0.69, 0.881, 0.91, 0.928, 0.952, 1];
%     Y_c_sgd = [0, 0.368, 0.502, 0.605, 0.69, 0.578, 0.881, 0.91, 0.928, 0.952, 1];
%     plot(X_c_adam, Y_c_adam, "-", 'DisplayName', "mJNet (ADAM)", "LineWidth", 3, "Color", "red");
    hold on
    h(1) = plot(X_c_sgd, Y_c_sgd, "-", 'DisplayName', "mJNet (SGD)", "LineWidth", 3, "Color", "blue");
    %plot(1-0.97, 0.85, "-s", 'DisplayName', "ADAM longJ core w/o back")
    
    auc_adam_nb = abs(trapz(X_c_adam,Y_c_adam));
    auc_sgd_nb = abs(trapz(X_c_sgd,Y_c_sgd));
    AUC_table = [AUC_table; {strcat("adam", '_', flag), auc_adam_nb}];
    AUC_table = [AUC_table; {strcat("sgd", '_', flag), auc_sgd_nb}];
end

count = 2;
for suff = researchesValues.keys
    suffix = suff{1};
    
    if ~strcmp(suffix, "Shaefer_2014") && ~strcmp(suffix, "Murphy_2006") 
        isUP = 0;
        processIT = 0;
        for info = researchesValues(suffix)
            arrayToCheck = struct2array(info);
            if ~isempty(find(arrayToCheck==flag, 1))
                processIT = 1;
                indexFlag = find(arrayToCheck==flag, 1);
                if arrayToCheck(indexFlag-1) == "up"
                    isUP = 1;
                end
            end
        end

        indices = contains(stats.name, suffix);
        rowsTable = stats(indices,:);
        if processIT
            if flag=="penumbra"
                X_p_nb = 1-rowsTable.specificity_p_nb;
                Y_p_nb = rowsTable.sensitivity_p_nb;

                if ~strcmp(num2str(X_p_nb(end)),'1') && ~strcmp(num2str(X_p_nb(1)),'1') 
                    X_p_nb(end) = 1;
                end
                if ~strcmp(num2str(Y_p_nb(end)),'1') && ~strcmp(num2str(Y_p_nb(1)),'1') 
                    Y_p_nb(end) = 1;
                end
                if strcmp(suffix, "Cereda_2015")
                    Y_p_nb([2 end-1]) = Y_p_nb([2 end-1]) - 0.01;
                    Y_p_nb(Y_p_nb<0) = 0;
                end

                if isUP==1
                    X_p_nb([1 end]) = X_p_nb([end 1]);
                    Y_p_nb([1 end]) = Y_p_nb([end 1]);
                end

                suff_for_legend = strrep(suffix, "_", " ");
                suff_for_legend = extractBefore(suff_for_legend, " ");
                h(count) = plot(X_p_nb,Y_p_nb,"-", 'DisplayName',strcat(suff_for_legend, " "), "LineWidth", 2)

        %         auc = trapz(X_p,Y_p);
                auc_adam_nb = abs(trapz(X_p_nb,Y_p_nb));
                AUC_table = [AUC_table; {strcat(suffix, '_', flag), auc_adam_nb}];
            elseif flag=="core"
                X_c_nb = 1-rowsTable.specificity_c_nb;
                Y_c_nb = rowsTable.sensitivity_c_nb;

                if ~strcmp(suffix,"Cambell_2012")
                    if ~strcmp(num2str(X_c_nb(end)),'1') && ~strcmp(num2str(X_c_nb(1)),'1') 
                        X_c_nb(end) = 1;
                    end
                    if ~strcmp(num2str(Y_c_nb(end)),'1') && ~strcmp(num2str(Y_c_nb(1)),'1') 
                        Y_c_nb(end) = 1;
                    end
                end
                
                if strcmp(suffix, "Cereda_2015")
                    Y_c_nb([2 end-1]) = Y_c_nb([2 end-1]) - 0.01;
                    Y_c_nb(Y_c_nb<0) = 0;
                end
                
                if isUP==1
                    X_c_nb([1 end]) = X_c_nb([end 1]);
                    Y_c_nb([1 end]) = Y_c_nb([end 1]);
                end

                suff_for_legend = strrep(suffix, "_", " ");
                suff_for_legend = extractBefore(suff_for_legend, " ");
                h(count) = plot(X_c_nb,Y_c_nb,"-",'DisplayName',strcat(suff_for_legend," "), "LineWidth", 2)

        %         auc = trapz(X_c,Y_c);
                auc_adam_nb = abs(trapz(X_c_nb,Y_c_nb));
                AUC_table = [AUC_table; {strcat(suffix, '_', flag), auc_adam_nb}];
            end
            
            count = count + 1;
        end

        legend('Location','southeast','NumColumns',2)
        title(strcat("ROC - ", flag));
        xlabel('False positive rate'); ylabel('True positive rate');
    end
end

if flag=="core"
    h(end-1) = plot(1-0.65, 0.91, "x", "DisplayName", "Kasasbeh", "LineWidth", 2);
end

h(end) = plot([0,0.5, 1], [0,0.5, 1], "--", "DisplayName", "", "LineWidth", 1, "Color",  "black");

h(h==0) = [];
legend(h(1:end-1));
%% put a breakpoint here for saving both the figures!
close




end

