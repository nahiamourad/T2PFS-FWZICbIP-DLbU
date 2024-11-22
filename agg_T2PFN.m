function agg_T2PFN=agg_T2PFN(T2PFNs,w)
%%% T2PFNs is a column array of cells containing the T2PFNs to be aggregated
%%% w is the weight of aggregation

if(size(T2PFNs)~=size(w))
    if(isrow(w))
        w=w';
    end
    if(isrow(T2PFNs))
        T2PFNs=T2PFNs';
    end
else
    disp('Incorrect Aggregartion. Check aggregation function');
    return
end


M=cell2mat(T2PFNs');
mu=M(:,1);
f=M(:,2);
g=M(:,3);
nu=M(:,4);
F=M(:,5);
G=M(:,6);

agg_T2PFN(1)=sqrt(1-prod((1-mu.^2).^w));
agg_T2PFN(2)=sqrt(1-prod((1-f.^2).^w));
agg_T2PFN(3)=prod(g.^w);
agg_T2PFN(4)=prod(nu.^w);
agg_T2PFN(5)=sqrt(1-prod((1-F.^2).^w));
agg_T2PFN(6)=prod(G.^w);
end
