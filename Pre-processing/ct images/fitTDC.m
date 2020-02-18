function [A,TTP,bFit,L]  =  fitTDC(imdiff, L, ImAll, realTTP)

% A curve fitting of the most prominent TDC in each vessel candidate
% segment is performed. If the TDC fits bad to a Gaussian or has
% unreasonable parameters, the segment is probably not a vessel - then it
% is removed.

n = max(max(L));
A = NaN(1,n);
TTP = NaN(1,n);
bFit = NaN(1,n);

eq = 'a*exp(-0.5*((x-b)/c)^2)+d';
y = linspace(1,30,30);

for i = 1:n
    [row,col,v] = find(imdiff.*uint16(L == i));
    
    
    [~,ind] = maxk(v,10);
    %     figure
    curves = zeros(10,30);
    for j = 1:length(ind)
        curves(j,:) = reshape(ImAll(row(ind(j)),col(ind(j)),:),1,30);
        %         plot(curves(j,:))
        %         hold on
    end
    
    
    x = mean(curves,1);
    
    % figure
    % plot(curves')
    x_orig = x;
    [cA,~] = swt(x,1,'coif5');
    x = iswt(cA,zeros(1,30),'coif5');
    
    [m,ind] = max(x);
    m = m-mean(x(1:5));
    initCoeff  =  [m ind 1 1060];
    
    [f,gof] = fit(y',x',eq,'Start',initCoeff);
    
    coeff = coeffvalues(f);
    a = coeff(1);
    b = coeff(2);
    c = coeff(3);
    d = coeff(4);
    
    if a<30 || b<6 || b>30.5 || abs(c)>6.5 || d<1000 || d>1300 || gof.rsquare<0.8
        %         figure
        %         subplot(311)
        % imshow(imdiff.*uint16(L == i),[0 100])
        L(L == i) = 0;
        %         remove(i) = 1;
        %         if a>300
        % if i == 17
        
        % %                 figure
        %    subplot(312)
        %             plot(y,x_orig)
        %                     hold on
        %         plot(f)
        %         title(num2str([a b c d gof.rsquare]))
        %         subplot(313)
        %         plot(curves')
        %
        %
        %         title([num2str(i) ' ' num2str(b) ' ' num2str(c) ' ' num2str(d) ' ' num2str(gof.rsquare) ' ' num2str(i)])
        %         end
    else
        A(i) = a;
        TTP(i) = realTTP(round(uint8(b)));
        bFit(i) = b;
        
    end
end
% BW = L>0;
