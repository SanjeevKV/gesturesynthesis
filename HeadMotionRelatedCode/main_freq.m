path='/media/prr/PRR/Optitrack/Data';
list=dir(path);
p=0.9;
fileID = fopen(['test_results_' num2str(p*100) '.txt'],'w');
c=1;

for i=4:9
   list_2=dir([path '/' list(i).name]); 
   for j=3:6
       list_3=dir([path '/' list(i).name '/' list_2(j).name]);
       if(isempty(strfind(list_3(3).name ,'May')))
           d=[path '/' list(i).name '/' list_2(j).name '/' list_3(3).name ];
           L1 = length(dir([d ,'/*Data.mat']));
           L2 = length(dir([d ,'/*ZeroData.mat']));
            %fprintf(fileID,'%s\t%s\n',list_2(j).name,d);
            %if(L1==L2)
            prepare_all_data(d);
            %list_2(j).name
            %end
            cells=compute_freq([path '/' list(i).name '/' list_2(j).name '/' list_3(3).name ],p);
            c=c+1;
            k=1;
            for k=1:10
                    fprintf(fileID,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t\n',cells{k,1},cells{k,2});
                    fprintf(fileID,'%s\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f\t\n','Mean',cells{k,3});
            end
                    fprintf(fileID,'---------------------------------------------------\n');
       else
           list_4=dir([path '/' list(i).name '/' list_2(j).name '/' list_3(3).name ]);
           if(~isempty(strfind(list_4(3).name ,'FBX'))) 
               d=[path '/' list(i).name '/' list_2(j).name '/' list_3(3).name '/' list_4(3).name];
               L1 = length(dir([d ,'/*Data.mat']));
               L2 = length(dir([d ,'/*ZeroData.mat'])); 
               %fprintf(fileID,'%s\t%s\n',list_2(j).name,d); 
               %if(L1==L2)
               prepare_all_data(d);
               %list_2(j).name
               %end
               
                cells=compute_freq([path '/' list(i).name '/' list_2(j).name '/' list_3(3).name '/' list_4(3).name],p);
                c=c+1;
                k=1;
                for k=1:10
                    fprintf(fileID,'%s\t%f\t%f\t%f\t%f\t%f\t%f\t\n',cells{k,1},cells{k,2});
                    fprintf(fileID,'%s\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f\t\n','Mean',cells{k,3});
                end
                    fprintf(fileID,'---------------------------------------------------\n');
           end
       end
   end
end
fclose(fileID);