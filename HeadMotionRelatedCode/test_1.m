direct='/media/prr/PRR/Optitrack/Data/Tamil/Ashwini/FBX';
list = dir([direct ,'/*Data.mat']);
c=1;
for i=1:length(list)
   if(isempty(strfind((list(i).name),'Zero')))
       s=strsplit(list(i).name,'_');
       eval(['load ' direct '/' list(i).name]);
       for j=1:6
       freq(j)=compute_energy(data(:,18+j),0.9,120);
       end
       str=strcat(s{3},'_',s{4});
      
       cell_s(c,:)={str(1:end-8),freq};
       c=c+1;
       
   end
end
   

