function analyzeErrorsFromLanguageBases(interval,k)

DIR='F:\IIScProjectMain\Optitrack\Analysis\LanguageBasesForSpeakers\';
Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
saveDIR=[DIR '\results\' num2str(interval) '_' num2str(k) '\'];
mkdir(saveDIR);

story1=struct();
story1.errEnEn=[];story1.errEnL1=[];story1.errL1L1=[];story1.errL1En=[];
story2=struct();
story2.errEnEn=[];story2.errEnL1=[];story2.errL1L1=[];story2.errL1En=[];
story3=struct();
story3.errEnEn=[];story3.errEnL1=[];story3.errL1L1=[];story3.errL1En=[];
story4=struct();
story4.errEnEn=[];story4.errEnL1=[];story4.errL1L1=[];story4.errL1En=[];
story5=struct();
story5.errEnEn=[];story5.errEnL1=[];story5.errL1L1=[];story5.errL1En=[];

for i=1:length(Languages)
    Subjects=dir([DIR Languages{i}]);
    for j=3:length(Subjects)
        dataDIR=[DIR Languages{i} '\' Subjects(j).name '\' num2str(interval) '_' num2str(k) '\'];
        res=load([dataDIR 'totErr.mat']);
        res=res.res;
        
        story1.errEnEn=[story1.errEnEn;res.errEnEn(1,:)];
        story1.errEnL1=[story1.errEnL1;res.errEnL1(1,:)];
        story1.errL1L1=[story1.errL1L1;res.errL1L1(1,:)];
        story1.errL1En=[story1.errL1En;res.errL1En(1,:)];
        
        story2.errEnEn=[story2.errEnEn;res.errEnEn(2,:)];
        story2.errEnL1=[story2.errEnL1;res.errEnL1(2,:)];
        story2.errL1L1=[story2.errL1L1;res.errL1L1(2,:)];
        story2.errL1En=[story2.errL1En;res.errL1En(2,:)];
        
        story3.errEnEn=[story3.errEnEn;res.errEnEn(3,:)];
        story3.errEnL1=[story3.errEnL1;res.errEnL1(3,:)];
        story3.errL1L1=[story3.errL1L1;res.errL1L1(3,:)];
        story3.errL1En=[story3.errL1En;res.errL1En(3,:)];
        
        story4.errEnEn=[story4.errEnEn;res.errEnEn(4,:)];
        story4.errEnL1=[story4.errEnL1;res.errEnL1(4,:)];
        story4.errL1L1=[story4.errL1L1;res.errL1L1(4,:)];
        story4.errL1En=[story4.errL1En;res.errL1En(4,:)];
        
        story5.errEnEn=[story5.errEnEn;res.errEnEn(5,:)];
        story5.errEnL1=[story5.errEnL1;res.errEnL1(5,:)];
        story5.errL1L1=[story5.errL1L1;res.errL1L1(5,:)];
        story5.errL1En=[story5.errL1En;res.errL1En(5,:)];
    end
end

save([saveDIR 'story1.mat'],'story1');
save([saveDIR 'story2.mat'],'story2');
save([saveDIR 'story3.mat'],'story3');
save([saveDIR 'story4.mat'],'story4');
save([saveDIR 'story5.mat'],'story5');

end