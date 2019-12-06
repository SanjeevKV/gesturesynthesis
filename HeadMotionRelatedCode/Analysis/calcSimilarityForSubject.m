function stats=calcSimilarityForSubject(Lang, Sub, interval)

k=100;

% 8 measures, mean and std dev for each. 1st row L1, 2nd L2, 3rd combo
stats=zeros(3,16);

DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';

%basesNonPauseDIR=([DIR Lang '/' Sub '/Ctxt_NMF_Non_pause/' num2str(k) '/'])
%basesPauseDIR=([DIR Lang '/' Sub '/Ctxt_NMF_pause/' num2str(k) '/'])
basesDIR=([DIR Lang '/' Sub '/Ctxt_NMF/' num2str(interval) '/' num2str(k) '/']);

allWL1 = dir([basesDIR '*' Lang(1) '*_W.mat']);
allWL2 = dir([basesDIR '*En_W.mat']);

L1measures=zeros(10,8);
count=0;
for i=1:length(allWL1)
    for j=i:length(allWL1)
        count=count+1;
        A=load([basesDIR allWL1(i).name]);A=A.W;
        B=load([basesDIR allWL1(j).name]);B=B.W;
        L1measures(count,:)=getSimilarityMeasures(A,B);
    end
end
stats(1,1:8) = mean(L1measures);
stats(1,9:16) = std(L1measures);

L2measures=zeros(10,8);
count=0;
for i=1:length(allWL2)
    for j=i:length(allWL2)
        count=count+1;
        A=load([basesDIR allWL2(i).name]);A=A.W;
        B=load([basesDIR allWL2(j).name]);B=B.W;
        L2measures(count,:)=getSimilarityMeasures(A,B);
    end
end
stats(2,1:8) = mean(L2measures);
stats(2,9:16) = std(L2measures);

L1L2measures=zeros(25,8);
count=0;
for i=1:length(allWL1)
    for j=1:length(allWL2)
        count=count+1;
        A=load([basesDIR allWL1(i).name]);A=A.W;
        B=load([basesDIR allWL2(j).name]);B=B.W;
        L1L2measures(count,:)=getSimilarityMeasures(A,B);
    end
end
stats(3,1:8) = mean(L1L2measures);
stats(3,9:16) = std(L1L2measures);

end