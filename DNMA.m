function [Rank,DN,DN1,DN2,DN3]=DNMA(X,benefit,weight,phi,gamma)
%Input: X is Decison Matrix
%       benefit binary vector indicating the type of the criteria
if nargin ==3
    phi=0.5; %parameter given for combination
    gamma=[1/3,1/3,1/3]; % weights for CCM UCM and ICM
end

[m,n]=size(X);
if(iscolumn(weight))
    weight=weight';
end


Ideal=zeros(n);
[Y1,Y2]=deal(zeros(m,n));
for j=1:n
    if(benefit(j)==1)
        Ideal(j)=max(X(:,j));
    elseif(benefit(j)==0)
        Ideal(j)=min(X(:,j));
    else
        disp('error in DNMA function')
        return
    end
    temp=abs(X(:,j)-Ideal(j));
    Y1(:,j)=1-temp/(max(temp));
    Y2(:,j)=1-temp/norm(temp);
end
W=repmat(weight,m,1);
%The complete compensatory model (CCM)
U1=sum(Y1.*W,2);
R1=rankWithDuplicates(U1,'descend')';
%The un-compensatory model (UCM)
U2=max((1-Y1).*W,[],2);
R2=rankWithDuplicates(U2,'ascend')';
%The target-based vector normalization (ICM)
U3=prod(Y2.*W,2);
R3=rankWithDuplicates(U3,'descend')';

%% Normalize the vectors
U1=U1./norm(U1);
U2=U2./norm(U2);
U3=U3./norm(U3);
%%The final utility value of each alternative
DN1=phi*(U1/max(U1)).^2+(1-phi)*((m-R1+1)/m).^2;
DN2=phi*(U2/max(U2)).^2+(1-phi)*(R2/m).^2;
DN3=phi*(U3/max(U3)).^2+(1-phi)*((m-R3+1)/m).^2;
DN=gamma(1)*sqrt(DN1)-gamma(2)*sqrt(DN2)+gamma(3)*sqrt(DN3);
Rank=rankWithDuplicates(DN,'descend')';
end