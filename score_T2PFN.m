function score=score_T2PFN(T2PFN)
if(size(T2PFN,2)~=6)
    disp('error in the score function')
    return
end
mu=T2PFN(:,1);
f=T2PFN(:,2);
g=T2PFN(:,3);
nu=T2PFN(:,4);
F=T2PFN(:,5);
G=T2PFN(:,6);

score=(mu.^2-nu.^2)-1/4*abs((f.^2-g.^2)-(F.^2-G.^2));
end