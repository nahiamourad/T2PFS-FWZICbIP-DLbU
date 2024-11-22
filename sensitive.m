function [ws,e_c,ranks_I,cor_I,ranks_E,cor_E]=sensitive(n_A,w,ns,benefit,lambda,rank_I,D_I,n_E,rank_E,D_E)
[ws,e_c]=genrate_weight(w,ns);
ranks_I=zeros(n_A,ns+1);
ranks_I(:,1)=rank_I;
ranks_E=zeros(n_A,ns+1);
ranks_E(:,1)=rank_E;
for i=1:ns
    %%%%%Internal aggregation Sensitivity analysis
    [kappas]=CoCoSo(D_I,ws(i,:),benefit,lambda);
    ranks_I(:,i+1)=rankWithDuplicates(kappas,'descend')';
    %%%%%External aggregation Sensitivity analysis
    kappa=zeros(n_A,n_E);
    for k=1:n_E
        [kappa(:,k)]=CoCoSo(D_E{k},ws(i,:),benefit,lambda);
    end
    kappas=mean(kappa,2);
    ranks_E(:,i+1)=rankWithDuplicates(kappas,'descend')';
end
cor_I=corr(rank_I,ranks_I);
cor_E=corr(rank_E,ranks_E);
end