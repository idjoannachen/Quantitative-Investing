function [beta,error,sterrbeta,R2,tstat,param,varbeta]=ordleast(Y,X)
% Computes Ordinary Least Squares projection of Y on X.
%----------------------------------------------------------------

L=length(X(:,1));

% Adds a column of ones to variable matrix, which will estimate the
% constant.
K=[ ones(L,1) X];

b=(inv(K'*K))*(K'*Y);
beta=b;
error=Y-K*b;

% Calculates the sum of squared errors
sse=sum(error.^2);

tmp=sse/(sqrt(length(Y)-length(K(1,:))));
sdevk=std(K);
sterrbetamat=sqrt(error'*error*inv(K'*K))/sqrt(length(Y)-length(K(1,:)));

% Calculates the standard error of beta.
sterrbeta=diag(sterrbetamat);

varbetamat=(error'*error*inv(K'*K))/(length(Y)-length(K(1,:)));
varbeta=diag(varbetamat);
Ym=Y-mean(Y);
rsqr1 = sse;
rsqr2 = Ym'*Ym;

% Calculates R2 of the regression.
R2=1-(rsqr1/rsqr2);

% Calcualtes tstats of the estimated coefficents.
tstat = beta./sterrbeta;

param=zeros(1,3*length(K(1,:))+1);

% Stores the beta, tstat, and standard error of beta for each coefficient
% in a vector param.
for i=1:length(K(1,:))
    param(3*i-2)=b(i);
    param(3*i-1)=tstat(i);
    param(3*i)=sterrbeta(i);
    param(3*length(K(1,:))+1)=R2;
end
