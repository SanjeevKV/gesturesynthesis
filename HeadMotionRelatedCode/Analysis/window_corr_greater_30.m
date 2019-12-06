clc;
close all;
clear all;
file=input('file ','s');
number=input('number');

[angles1001,angles1002,angles1003,p,nzIntervals,nzIntervals1,nzIntervals2,nzIntervals3,nzIntervals4,nzIntervals5]=corr_coefff_window3(file,number);
 corr_value21_=[];
  corr_value20_=[];
   corr_value19_=[];
   corr_value21_1=[];
   corr_value20_1=[];
   corr_value19_1=[];
%    col_=[];
% %    col_1=[];
%    col_1=cell(1,21);
% for i=1:length(nzIntervals5)
%     
%   b1=p(nzIntervals5(i,1):nzIntervals5(i,2));
%    
%   if ((nzIntervals5(i,1)>101) && nzIntervals5(i,2)<(length(angles1001)-101))
%       win=nzIntervals5(i,2)-nzIntervals5(i,1);
%       k=0;
%       for j=nzIntervals5(i,1)-50:10:nzIntervals5(i,1)-30
%           k=k+1;
%          a1=angles1001(j:j+win);
%          a2=angles1002(j:j+win);
%          a3=angles1003(j:j+win);
%          
%          
%             col=[a1';a2';a3';b1'];
%             
%            col_1{k}=[col_1{k},col];
% 
%  
%       end
%       
%        for j=nzIntervals5(i,1)-25:5:nzIntervals5(i,1)-10
%           k=k+1;
%          a1=angles1001(j:j+win);
%          a2=angles1002(j:j+win);
%          a3=angles1003(j:j+win);
%          
%          
%             col=[a1';a2';a3';b1'];
%             
%            col_1{k}=[col_1{k},col];
% 
%        end
%         for j=nzIntervals5(i,1)-7:2:nzIntervals5(i,1)-3
%           k=k+1;
%          a1=angles1001(j:j+win);
%          a2=angles1002(j:j+win);
%          a3=angles1003(j:j+win);
%          
%          
%             col=[a1';a2';a3';b1'];
%             
%            col_1{k}=[col_1{k},col];
% 
%         end
%    for j=nzIntervals5(i,1)
%           k=k+1;
%          a1=angles1001(j:j+win);
%          a2=angles1002(j:j+win);
%          a3=angles1003(j:j+win);
%          
%          
%             col=[a1';a2';a3';b1'];
%             
%            col_1{k}=[col_1{k},col];
% 
%    end
%   
%    for j=nzIntervals5(i,1)+3:2:nzIntervals5(i,1)+7
%           k=k+1;
%          a1=angles1001(j:j+win);
%          a2=angles1002(j:j+win);
%          a3=angles1003(j:j+win);
%          
%          
%             col=[a1';a2';a3';b1'];
%             
%            col_1{k}=[col_1{k},col];
% 
%    end
% 
%         for j=nzIntervals5(i,1)+10:5:nzIntervals5(i,1)+25
%           k=k+1;
%          a1=angles1001(j:j+win);
%          a2=angles1002(j:j+win);
%          a3=angles1003(j:j+win);
%          
%          
%             col=[a1';a2';a3';b1'];
%             
%            col_1{k}=[col_1{k},col];
%         end
%    
%       for j=nzIntervals5(i,1)+30:10:nzIntervals5(i,1)+50
%           k=k+1;
%          a1=angles1001(j:j+win);
%          a2=angles1002(j:j+win);
%          a3=angles1003(j:j+win);
%          
%          
%             col=[a1';a2';a3';b1'];
%             
%            col_1{k}=[col_1{k},col];
% 
%  
%         
%        end
%           
% %          col_1=[col_1,col_];
% %          col_=[];
% 
% end
% end
% 
% for i=1:length(nzIntervals5)
%     
%   b1=p(nzIntervals5(i,1):nzIntervals5(i,2));
%    
%   if ((nzIntervals5(i,1)>101) && nzIntervals5(i,2)<(length(angles1002)-101))
%       win=nzIntervals5(i,2)-nzIntervals5(i,1);
%       
%       for j=nzIntervals5(i,1)-100:10:nzIntervals5(i,1)+100
%           
%          a1=angles1002(j:j+win);
%          
%             corr_value20=corrcoef(a1,b1);
%             
%            corr_value20_=[corr_value20_;corr_value20(1,2)];
% 
%  
%       end
%   end
%   
%          corr_value20_1=[corr_value20_1,corr_value20_];
%          corr_value20_=[];
% 
% end

for i=1:length(nzIntervals5)
    
  b1=p(nzIntervals5(i,1):nzIntervals5(i,2));
   
  if ((nzIntervals5(i,1)>101) && nzIntervals5(i,2)<(length(angles1003)-101))
      win=nzIntervals5(i,2)-nzIntervals5(i,1);
      
      for j=nzIntervals5(i,1)-100:10:nzIntervals5(i,1)+100
          
         a1=angles1001(j:j+win);
          a2=angles1002(j:j+win);
            a3=angles1003(j:j+win);
         
            corr_value19=corrcoef(a1,b1);
             corr_value20=corrcoef(a1,b1);
              corr_value21=corrcoef(a1,b1);
               corr_value19_=[corr_value19_;corr_value19(1,2)];
                corr_value20_=[corr_value20_;corr_value20(1,2)];
           corr_value21_=[corr_value21_;corr_value21(1,2)];

 
      end
  end
  
         corr_value19_1=[corr_value19_1,corr_value19_];
         corr_value19_=[];

         corr_value20_1=[corr_value20_1,corr_value20_];
         corr_value20_=[];
         
         corr_value21_1=[corr_value21_1,corr_value21_];
         corr_value21_=[];
end

mean19=mean(abs(corr_value19_1)');
mean20=mean(abs(corr_value20_1)');
mean21=mean(abs(corr_value21_1)');
mea_noverall=[mean19;mean20;mean21];

stdev19=std(abs(corr_value19_1)');
stdev20=std(abs(corr_value20_1)');
stdev21=std(abs(corr_value21_1)');
stdev_overall=[stdev19;stdev20;stdev21];
