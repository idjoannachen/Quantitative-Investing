%Solution to Pset 1 %
%  Moskowitz MGT595  %
%   Jan 11, 2016    %
% ================= %

%%

clc;
clear all;
close all;

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Part 1 %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load ps1.mat;
% Data is monthly returns

T = length(mkt);
	
ew_ports(:,1) = mean(stocks(:,1:5),2);
ew_ports(:,2) = mean(stocks(:,1:10),2);
ew_ports(:,3) = mean(stocks(:,1:25),2);
ew_ports(:,4) = mean(stocks(:,1:50),2);

mean_ew_ports = mean(ew_ports,1);
std_ew_ports = std(ew_ports,1);

Results = [mean_ew_ports; std_ew_ports];
Row_Heads = ['  N  '; 'Mean '; 'Stdev'];
Col_Heads = {' 5 '; ' 10'; ' 25'; ' 50'};
disp('Question 1a: Mean & Stdev by # of stocks in portfolio')
make_table(Row_Heads,Col_Heads, Results, 10, 3);

figure
plot([5,10,25,50], std_ew_ports, '*--');
    title('1a. Estimated standard deviation');% 
    xlabel('Number of stocks in portfolio')
saveas(gcf,'1a.tif')

%% Question 1b.

total_var = var(ew_ports,1);

var_contribution(1) = mean(var(stocks(:,1:5),1))/5;
var_contribution(2) = mean(var(stocks(:,1:10),1))/10;
var_contribution(3) = mean(var(stocks(:,1:25),1))/25;
var_contribution(4) = mean(var(stocks(:,1:50),1))/50;

covar_contribution = total_var - var_contribution;

percent_var_contribution = var_contribution./total_var;

Results = [total_var; var_contribution; covar_contribution];
Row_Heads = ['         N        '; 'Sample variance   '; 'var contribution  '; 'covar contribution'];
Col_Heads = {' 5 '; ' 10'; ' 25'; ' 50'};
disp('Question 1b: Variance Decomposition')
make_table(Row_Heads,Col_Heads, Results, 10, 2);

percent_covar_contribution = covar_contribution./total_var;
figure
    plot([5,10,25,50], percent_var_contribution, '*--');
    title('1b. Percent of portfolio variance due to variance of individual security');% 
    xlabel('Number of stocks in portfolio')
saveas(gcf,'1b_1.tif') 
   
figure
plot([5,10,25,50], total_var, '--o', [5,10,25,50], var_contribution, '*--', [5,10,25,50], covar_contribution, '^--');
title('1b. Decomposition of variance ');
xlabel('N');
legend('Sample var.', 'Var. contribution', 'Covar. Contribution', 'Location', 'Best');
saveas(gcf,'1b_2.tif') 

%% Question 1d
t_statistics = mean_ew_ports ./ (std_ew_ports/sqrt(T-1));
p_values = (1-tcdf(t_statistics, T - 1))*2;  % multiply by 2 for two-tailed test

Results = [t_statistics; p_values];
Row_Heads = ['        N       '; 't statistic     '; '2-tailed p-value'];
Col_Heads = {' 5 '; ' 10'; ' 25'; ' 50'};
disp('Question 1d: Are returns different from zero: t-tests')
make_table(Row_Heads,Col_Heads, Results, 10, 4);

%% Question 1e
% [H,P,JBSTAT,CV] = jbtest(X,alpha)
three_assets = [stocks(:,1), ew_ports(:,4), mkt];
normality_tests(1,:) = max(three_assets);
normality_tests(2,:) = min(three_assets);
normality_tests(3,:) = normality_tests(1,:) - normality_tests(2,:);
normality_tests(4,:) = std(three_assets);
normality_tests(5,:) = normality_tests(3,:)./normality_tests(4,:);
normality_tests(6,:) = skewness(three_assets);
normality_tests(7,:) 	= kurtosis(three_assets);
for i=1:3
    [H,P,JBSTAT,CV] = jbtest(three_assets(:,i),.05) 
    normality_tests(8,i) = P;
end

Row_Heads = ['          '; 'Max       '; 'Min       '; 'Range     '; 'Stdev     '; 'Stu Range '; 'Skewness  '; 'Kurtosis  '; 'JB p-value'];
Col_Heads = {'CTL'; '50-stocks'; 'Market';};
disp('Question 1e: Are returns normally distributed')
make_table(Row_Heads,Col_Heads, normality_tests, 10, 4);


%% Question 1f
for i = 1:10;
    [beta,error,sterrbeta,R2,tstat,param,varbeta] = ordleast(stocks(:,i),mkt);
    beta_and_R2(1,i) = R2;
    beta_and_R2(2:3,i)= beta;
    beta_and_R2(4,i) = inv(mkt'*mkt)*mkt'*stocks(:,i);
end
Row_Heads = ['Stocks      '; 'R-squared   ';  'Alpha       '; 'Beta        '; 'Beta, no int';];
% CTL	T	CSCO	FCX	XL	IVZ	AMT	WHR	IR	WFT
Col_Heads = {'CTL'; 'T'; 'CSCO'; 'FCX'; 'XL'; 'IVZ'; 'AMT'; 'WHR'; 'IR'; 'WFT'};
% Col_Heads1 = {'CNE'; 'NSH'; 'PMS'; 'FLT'; 'ARX'; 'SDW'; 'MCL'; 'MCCRK'; 'ACCOB'; 'CUR'};
disp('Question 1f: Betas & R-squared of first 10 stocks')
make_table(Row_Heads,Col_Heads(1:5), beta_and_R2(:,1:5), 10, 3);
make_table(Row_Heads,Col_Heads(6:10), beta_and_R2(:,6:10), 10, 3);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Part 2 %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

load ps1.mat;

csco = stocks(:,3);

T = length(mkt);

for t = 12:T
    vol_csco(t-11, 1) = std(csco(1:t));
    vol_csco(t-11, 2) = std(csco(t-11:t));
    vol_mkt(t-11, 1) = std(mkt(1:t));
    vol_mkt(t-11, 2) = std(mkt(t-11:t));
    
    % function [beta,error,sterrbeta,R2,tstat,param,varbeta]=ordleast(Y,X)
    [beta,error,sterrbeta,R2,tstat,param,varbeta] = ordleast(csco(1:t),mkt(1:t));
    beta_csco(t-11, 1:3) = [beta(2), beta(2)-2*sterrbeta(2), beta(2)+2*sterrbeta(2)];
            % +/- 2 standard errors is approximate 95% confidence interval
    [beta,error,sterrbeta,R2,tstat,param,varbeta] = ordleast(csco(t-11:t),mkt(t-11:t));
    beta_csco(t-11, 4:6) = [beta(2), beta(2)-2*sterrbeta(2), beta(2)+2*sterrbeta(2)];
end

T_vol = length(vol_csco);

year_1 = floor(date(1)/100);
year_end = floor(date(end)/100)+1;
date_axis = [year_1+1 : (year_end-year_1-1)/T_vol : year_end];
date_axis = date_axis(1:end-1);     %% Note: this only works if first date is beginning of a year, & last date is end of a year;

figure
  subplot(2,1,1)
    plot(date_axis, vol_csco(:,1), date_axis, vol_csco(:,2), '--')
    title('2a. Volatility of CSCO')
    legend('Trailing ALL months', 'Trailing 12 months', 'best')
  subplot(2,1,2)
    plot(date_axis, vol_mkt(:,1), date_axis, vol_mkt(:,2), '--')
    title('2a. Volatility of Market')
    legend('Trailing ALL months', 'Trailing 12 months', 'best')
saveas(gcf,'2a.tif') 

figure
    subplot(2,1,1)
        plot(date_axis, beta_csco(:,1), '.', date_axis, beta_csco(:,4), '--')
        legend('Trailing ALL months','Trailing 12 months', 'best')
        title('2b. Beta of CSCO')
        ylabel('Estimated Beta')
    subplot(2,1,2)
        plot(date_axis, beta_csco(:,1:3), '.', date_axis, beta_csco(:,4:6), '--')
        title('with 95% confidence intervals')
        ylabel('Estimated Beta')
        xlabel('Year')
saveas(gcf,'2b.tif') 

