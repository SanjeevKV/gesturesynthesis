function [measures, eucld, corr]=getSimilarityMeasures(bases1, bases2)
%% Two measures are calculated euclidean distance and correlation coefficient
%  In turn mean, median, max and min (Stored in the same order)for both which makes 8 values
%  These are put into a 1x8 matrix measures with 1st 4 containing
%  euclidean distance measures and next 4 coefficient measures.

% Assume sizes are same
    k=size(bases1,2);
    eucld=zeros(k,k);
    corr=zeros(k,k);
    
    for i=1:size(bases1,2)
        col1 = bases1(:,i);
        for j=1:size(bases2,2)
            col2=bases2(:,j);
            eucld(i,j)=norm(col1-col2);
            temp=corrcoef(col1,col2);
            corr(i,j)=temp(2,1);
        end
    end
    
    measures = zeros(1,8);
    measures(1,1) = mean(mean(eucld));
    measures(1,2) = median(median(eucld));
    measures(1,3) = max(max(eucld));
    measures(1,4) = min(min(eucld));
    
    measures(1,5) = mean(mean(corr));
    measures(1,6) = median(median(corr));
    measures(1,7) = max(max(corr));
    measures(1,8) = min(min(corr));
    
end