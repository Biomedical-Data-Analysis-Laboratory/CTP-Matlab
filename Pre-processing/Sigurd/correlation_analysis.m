
%% DATA EXTRACTED FROM FREEHAND-DRAWINGS
sammenlagt_strl = [398.70	245.30	177.82	494.49	485.10	242.97 ...	
    311.10	441.40	376.43	335.90	536.10];

snitt_strl = [30.67	22.3	16.17	38.04	37.32	23.3	28.28 ...	
    36.78	20.91	25.84	44.68];

max_single_pen =[43.80	34.10	22.10	54.20	49.70	33.40	45.00	51.70	28.60	35.70	65.40];


%%
D_alle = cell2mat(D_alle);
%%
d_haar = D_alle(1,:);
d_db4 = D_alle(2,:);
d_c4 = D_alle(3,:);
trapz_haar = trapz(1:1:30,d_haar)
trapz_db4 = trapz(1:1:30,d_db4)
trapz_c4 = trapz(1:1:30,d_c4)
%% TRAPEZOID INTEGRALS FOR DIFFERENT WAVELETS, NORMALIZED, ALL PATIENTS
Integral_haar = [ 5.2794 7.4929 5.7473 7.6919 5.6375 6.4438 5.7825 5.8221 ...
  7.4013 7.4324 5.9777 ];

Integral_db4 = [6.8122 8.8943 6.9748 9.4305 7.2241 7.5641 7.3949 8.0070 ...
     9.0502 9.4414 7.7084];
          

Integral_coif4 = [10.2299 12.4122 9.7796 13.3741 10.6051 10.4856 10.6282 8.0070 ...  
          13.0680 13.6113 11.0885];


%%
[R_haar_all, p_haar_all ] = corrcoef(Integral_haar, sammenlagt_strl);
[R_haar_snitt, p_haar_snitt ] = corrcoef(Integral_haar, snitt_strl);
%%
[R_db4_all, p_db4_all ] = corrcoef(Integral_db4, sammenlagt_strl);
[R_db4_snitt, p_db4_snitt ] = corrcoef(Integral_db4, snitt_strl);
%%
[R_coif4_all, p_coif4_all ] = corrcoef(Integral_coif4, max_single_pen)
[R_coif4_snitt, p_coif4_snitt ] = corrcoef(Integral_coif4, snitt_strl);
%%
%% TRAPEZOID INTEGRALS FOR DIFFERENT WAVELETS, ALL PATIENTS

Integral_haar = [4.1121e09 5.1381e09 3.9999e09 6.2764e09 4.5604e09 ...
            4.2732e09 4.2762e09 4.0334e09 5.7015e09 5.0462e09 4.1441e09];

Integral_db4 = [4.1548e09 5.2065e09 4.0403e09 6.3968e09 4.6611e09 ... 
            4.3286e09 4.3071e09 4.1414e09 5.7032e09 5.0620e09 4.1674e09];

Integral_coif4 = [4.1017e09 5.1466e09 3.9842e09 6.3117e09 4.5634e09 ...
            4.3124e09 4.3090e09 4.0856e09 5.6698e09 5.1466e09 4.1807e09];
       

[R_haar_all, p_haar_all ] = corrcoef(Integral_haar, sammenlagt_strl);
[R_haar_snitt, p_haar_snitt ] = corrcoef(Integral_haar, snitt_strl);

[R_db4_all, p_db4_all ] = corrcoef(Integral_db4, sammenlagt_strl);
[R_db4_snitt, p_db4_snitt ] = corrcoef(Integral_db4, snitt_strl);

[R_coif4_all, p_coif4_all ] = corrcoef(Integral_coif4, sammenlagt_strl);
[R_coif4_snitt, p_coif4_snitt ] = corrcoef(Integral_coif4, snitt_strl);


%% TRAPEZOID INTEGRALS FOR DIFFERENT LBPs, ALL PATIENTS


LBP_r2 = [6.54E-03	2.85E-02	3.45E-03	3.28E-02	7.08E-03	7.91E-03	1.51E-02	7.38E-03	3.68E-03	7.84E-03	4.87E-03];
LBP_r3 = [7.91E-03	2.92E-02	4.22E-03	3.34E-02	8.51E-03	7.95E-03	1.48E-02	9.86E-03	4.12E-03	1.41E-02	6.15E-03];
LBP_r4 = [1.03E-02	3.14E-02	6.47E-03	3.65E-02	1.08E-02	8.16E-03	1.55E-02	1.28E-02	5.22E-03	1.92E-02	8.30E-03];
LBP_r5 = [1.23E-02	3.47E-02	1.06E-02	3.89E-02	1.29E-02	8.56E-03	1.67E-02	1.42E-02	6.67E-03	2.09E-02	1.16E-02];
%%
sammenlagt_strl = [398.70	245.30	177.82	494.49	485.10	242.97 ...	
    311.10	441.40	376.43	335.90	536.10];

snitt_strl = [30.67	22.3	16.17	38.04	37.32	23.3	28.28 ...	
    36.78	20.91	25.84	44.68];

max_single_pen =[43.80	34.10	22.10	54.20	49.70	33.40	45.00	51.70	28.60	35.70	65.40];
%%
[R_r2, P_r2] = corrcoef(LBP_r2,max_single_pen );
[R_r3, P_r3] = corrcoef(LBP_r3, max_single_pen);
[R_r4, P_r4] = corrcoef(LBP_r4, snitt_strl)
[R_r5, P_r5] = corrcoef(LBP_r5, max_single_pen);

