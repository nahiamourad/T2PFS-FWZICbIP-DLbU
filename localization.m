function X_localized=localization(X,ns,benefit)
%Input: X is a decision matrix to be localized over ns Likert Scale
%       benefit is a vector determining the type of each criteria
%!!!!!!!!!!!!!!This localization gives Highest number to most important!!!!
eps=10^-9;
Xmax=max(X)+eps;
Xmin=min(X)-eps;
interval=(Xmax-Xmin)/ns;
[~,n]=size(X);
X_localized=zeros(size(X));
for j=1:n
    if(benefit(j)==1)
        X_localized(:,j)=ceil((X(:,j)-Xmin(j))/interval(j));
    elseif(benefit(j)==0)
        X_localized(:,j)=ns-floor((X(:,j)-Xmin(j))/interval(j));
    else
        disp('error in localization function')
        return
    end
end
