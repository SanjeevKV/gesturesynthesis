function cell_s=compute_freq(direct,p)
list = dir([direct ,'/*Data.mat']);
c=1;
for i=1:length(list)
   if(isempty(strfind((list(i).name),'Zero')))
       s=strsplit(list(i).name,'_');
       eval(['load ' direct '/' list(i).name]);
       for j=1:6
       [freq(j),m(j)]=compute_energy(data(:,18+j),p,120);
       end
       str=strcat(s{3},'_',s{4});
       if(isempty(strfind((str),'Data')))
       cell_s(c,:)={str,freq,m};
       c=c+1;
       else
       cell_s(c,:)={str(1:end-8),freq,m};
       c=c+1;
       end
       
   end
end
end