function dmsContrast(dataFileA, dataFileB, name)
% stroopContrast(dataFileA, matFileB,name)
if nargin < 3, name = 'DataA vs. DataB';end
[Aacc,Art] = dmsSummary(dataFileA);
[Bacc,Brt] = dmsSummary(dataFileB);
 acc = [Aacc,Bacc];
 rt =  [Art,Brt];
 
 figure
 subplot(1,2,1);
 bar(acc)
 axis square
 ylabel('Accuracy');
 set(gca,'xtick',1:2,'xtickLabel',{'DataA','DataB'})
 title(name);
 
 subplot(1,2,2);
 bar(rt)
 axis square
 ylabel('Reaction time(ms)');
 set(gca,'xtick',1:2,'xtickLabel',{'DataA','DataB'});
 title(name);


