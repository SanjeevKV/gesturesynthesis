%system(['cd ',audio_path]);
result={};
C1=dir([audio_path,'*_*.wav']);
C2=dir([marker_path,'*.fbx.mat']);
for n=1:length(C1)
    
   X=strsplit(C1(n).name,'_');
   Y=C1(n).name(length(X{1})+2:end);
   Y=strsplit(Y,'.');
   Subject=X{1};
   result{n,1}= lower(X{1});
   result{n,2}= Y{1};
   result{n,3}= C1(n).name;
end
for n=1:length(C2)
    pos=strfind(lower(C2(n).name),lower(Subject));
    Str=C2(n).name(pos:end);
    X=strsplit(Str,'_');
    Y=Str(length(X{1})+2:end);
    Y=strsplit(Y,'.');
     
    for k=1:length(result)
       if(strcmp(lower(result{k,2}),lower(Y{1})))
       result{k,4} = Y{1};    
       result{k,5} = C2(n).name; 
       if(~isempty(strfind(Y{1},'_')))
           result{k,6}='No'
       else
           result{k,6}='Clean'
       end
    end
    end
end
%system(['cd ',marker_path]);

