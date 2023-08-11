function [prec,rec,acc,f1,dice,mcc] = getStatsFromCM(fn,fp,tn,tp)
%GETSTATSFROMCM Summary of this function goes here
%   Detailed explanation goes here
prec = tp/(tp+fp);
rec = tp/(tp+fn);
spec = tn/(tn+fp);
acc = (tp+tn)/(tp+tn+fp+fn);
f1 = 2*((prec*rec)/(prec+rec));
dice = (2*tp)/((2*tp)+fp+fn);
mcc = (tn*tp - fp*fn)/ sqrt((tn+fn)*(fp+tp)*(tn+fp)*(fn+tp));

if isnan(prec)
    prec = 0;
end
if isnan(rec)
    rec = 0;
end
if isnan(spec)
    spec = 0;
end
if isnan(acc)
    acc = 0;
end
if isnan(f1)
    f1 = 0;
end
if isnan(dice)
    dice = 0;
end
if isnan(mcc)
    mcc = 0;
end

end

