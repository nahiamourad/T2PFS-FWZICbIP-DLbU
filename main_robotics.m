%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% User can modify this section to read the input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clc;
%clear;
filename=char('Modular_Robotics.xlsx');
sheet_criteria=char('Criteria');

m=50;%number of alternatives
n=6;%number of  criteria
benefit=ones(1,n); %All criteria are benfit-type
letter=char(('A':'Z').').';

ns=5;%Likert scale to be used
Scenarios=9;% #Scenarios for Sensitivity Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Fuzzy Numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T2PFN{5}=[0.9, 0.9, 0.4, 0.1, 0.5, 0.1];
T2PFN{4}=[0.8, 0.8, 0.4, 0.3, 0.7, 0.2];
T2PFN{3}=[0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
T2PFN{2}=[0.3, 0.2, 0.7, 0.8, 0.4, 0.8];
T2PFN{1}=[0.1, 0.1, 0.5, 0.9, 0.4, 0.9];

min_score=-1; %%Lower bound of the score function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Criteria Weight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Read the Expert Decision matrix
EDM=readmatrix(filename,'Sheet',sheet_criteria,'Range','B2:G4');

%%%Calculate the weights by FWZIC_SWARA
[weight,EDM_fuzzy,EDM_agg,Scores]=FWZIC_SWARA(EDM,T2PFN,'agg_T2PFN','score_T2PFN',min_score);

%%%Write the obtained results
writematrix([Scores;weight],filename,'Sheet',sheet_criteria,'Range','B5:G6')
writematrix(cell2mat(EDM_fuzzy),filename,'Sheet',sheet_criteria,'Range','B19:AK21')
writematrix(cell2mat(EDM_agg),filename,'Sheet',sheet_criteria,'Range','B22:AK22')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creating the Decision Matrices. (Augmented Data for Future Direction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for i=1:3 %% three decision matrices for three different experts
%     C=letter((i-1)*n+2*i); %C="B" for i =1; C="J" for i=2; C="R" for i=3
%     A=50+5*randi([1,10],m,n);
%     B=unique(A,'rows');
%     while(size(A,1)~=size(B,1))
%         A=50+5*randi([1,10],m,n);
%         B=unique(A,'rows');
%     end
%     writematrix(A/100,filename,'Sheet','Utility','Range',char([C,'2']));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Reading the Decision Matrices -> Fuzzification -> Aggregation -> Score
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[DM,DM_local,DM_fuzzy]=deal(cell(3,1));
for i=1:3 %% three decision matrices for three different experts
    C=letter((i-1)*n+2*i); %C="B" for i =1; C="J" for i=2; C="R" for i=3
    C2=letter((i)*n+2*i-1); %C2="G" for i =1; C2="O" for i=2; C2="W" for i=3

    DM{i}=readmatrix(filename,'sheet','Utility','Range',char([C,'2:',C2,num2str(m+1)]));
    DM_local{i}=localization(DM{i},ns,benefit);
    writematrix(DM_local{i},filename,'sheet','Dynamic','Range',char([C,'2:',C2,num2str(m+1)]));
    DM_fuzzy{i}=Fuzzification(DM_local{i},T2PFN); %Fuzification
end

%Aggregation over the 3 experts' opinions
DM_agg=cell(m,n);
DM_score=zeros(m,n);
for i=1:m
    for j=1:n
        DM_agg{i,j}=agg_T2PFN({DM_fuzzy{1}{i,j};DM_fuzzy{2}{i,j};DM_fuzzy{3}{i,j}},ones(1,3)/3);
        DM_score(i,j)=score_T2PFN(DM_agg{i,j});
    end
end
writecell(DM_agg,filename,'Sheet','DM Aggregated','Range',char([letter(2),'3']));
writematrix(DM_score,filename,'Sheet','DM Scores','Range',char([letter(2),'2']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Ranking the alternatives by DNMA method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Rank,DN,DN1,DN2,DN3]=DNMA(DM_score,benefit,weight);
writematrix([DN1,DN2,DN3,DN,Rank],filename,'Sheet','DM Scores','Range',char([letter(3+n),'2']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sensitivity Analysis on the weight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[W_sens,alph,boundry,delta]=genrate_weight(weight,Scenarios-1);
writematrix([W_sens;alph],filename,'Sheet','Sensitivity','Range',char([letter(2),'3']));
writematrix(boundry',filename,'Sheet','Sensitivity','Range',char([letter(2),'14']))

Rank_sens=zeros(m,Scenarios);
[rho_Pearson,rho_Spearman]=deal(zeros(Scenarios,1));
Rank_sens(:,1)=Rank;
for i=1:Scenarios
    [Rank_sens(:,i),~]=DNMA(DM_score,benefit,W_sens(i+1,:));
    rho_Pearson(i)=corr(Rank,Rank_sens(:,i));
    rho_Spearman(i)=corr(Rank,Rank_sens(:,i),'Type','Spearman');
end

writematrix([Rank,Rank_sens],filename,'Sheet','Sensitivity','Range',char([letter(2),'19']));
writematrix([rho_Pearson,rho_Spearman],filename,'Sheet','Sensitivity','Range',char([letter(15),'20']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sensitivity Analysis on the DNMA parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rank_sens_par=zeros(m,36);
gamma=zeros(36,3);
[rho_Pearson_par,rho_Spearman_par]=deal(zeros(36,1));
count=0;
for i=1:10
    for j=1:10
        k=10-(i+j);
        if k>0
            count=count+1;
            gamma(count,:)=[i,j,k]/10;
            [Rank_sens_par(:,count),~]=DNMA(DM_score,benefit,weight,0.5,gamma(count,:));
            rho_Pearson_par(count)=corr(Rank,Rank_sens_par(:,count));
            rho_Spearman_par(count)=corr(Rank,Rank_sens_par(:,count),'Type','Spearman');
        end
    end
end

writematrix(Rank_sens_par,filename,'Sheet','Sensitivity_DNMA','Range',char([letter(2),'19']));
writematrix([gamma,rho_Pearson_par,rho_Spearman_par],filename,'Sheet','Sensitivity_DNMA','Range',char([letter(1),letter(20),'20']));