function [EnEnAll,L1L1All,EnL1All]=compareQuadrantVariationL1L2All(thresh, order)

Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
%Languages={'Hindi'};
DIR='F:/IIScProjectMain/Optitrack/Analysis/AngleQuadrant/';

EnEnAll=[];
L1L1All=[];
EnL1All=[];

for i=1:length(Languages)
    Subjects=dir([DIR Languages{i}]);
    for j=3:length(Subjects)
        lang=Languages{i};
        sub=Subjects(j).name
        [EnEn,L1L1,EnL1]=compareQuadrantVariationL1L2(lang, sub, thresh, order);
        EnEnAll=[EnEnAll;EnEn];
        L1L1All=[L1L1All;L1L1];
        EnL1All=[EnL1All;EnL1];
    end
end

mean(EnEnAll)
mean(L1L1All)
mean(EnL1All)


end