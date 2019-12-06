function allEucldL1L2=plotEucldAllPairs(Language, Subject, k)

interval=15;
DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
basesDIR=([DIR Language '/' Subject '/Ctxt_NMF/' num2str(interval) '/' num2str(k) '/']);

allWL1 = dir([basesDIR '*' Language(1) '*_W.mat']);
allWL2 = dir([basesDIR '*En_W.mat']);

count=0;
allEucldL1L2=cell(25,1);

for i=1:length(allWL1)
    for j=1:length(allWL2)
        count=count+1;
        A=load([basesDIR allWL1(i).name]);A=A.W;
        B=load([basesDIR allWL2(j).name]);B=B.W;
        [measures, eucld, corr]=getSimilarityMeasures(A,B);
        t_eucld=reshape(eucld,[1,10000]);
        allEucldL1L2{count} = t_eucld;
    end
end

count=0;
allEucldL1=cell(10,1);
for i=1:length(allWL1)
    for j=i:length(allWL1)
        count=count+1;
        A=load([basesDIR allWL1(i).name]);A=A.W;
        B=load([basesDIR allWL1(j).name]);B=B.W;
        [measures, eucld, corr]=getSimilarityMeasures(A,B);
        t_eucld=reshape(eucld,[1,10000]);
        allEucldL1{count} = t_eucld;
    end
end

count=0;
allEucldL2=cell(10,1);
for i=1:length(allWL2)
    for j=i:length(allWL2)
        count=count+1;
        A=load([basesDIR allWL2(i).name]);A=A.W;
        B=load([basesDIR allWL2(j).name]);B=B.W;
        [measures, eucld, corr]=getSimilarityMeasures(A,B);
        t_eucld=reshape(eucld,[1,10000]);
        allEucldL2{count} = t_eucld;
    end
end

[n,x]=hist(t_eucld,100);plot(x,n/sum(n),'*-')
hold on;
for i=1:25
    [n,x]=hist(allEucldL1L2{i},100);plot(x,n/sum(n),'*-');
end

for i=1:10
    [n,x]=hist(allEucldL1{i},100);plot(x,n/sum(n),'r*-');
end

for i=1:10
    [n,x]=hist(allEucldL2{i},100);plot(x,n/sum(n),'m*-');
end

end