function boxPlotsOfEffect(filename, bandI)
% prepare the boxplots of effect for bandI, both during stim and baseline
% fluctuations

load(filename, 'eff9Map', 'eff8Map','validityMap')

numSessions = size(eff9Map, 1);
for i = 1: numSessions
    B = squeeze(eff9Map(i,:,:));
    VM = logical(validityMap(i,:));
    maxB(i,:) = max(B(VM,:));
    minB(i,:) = min(B(VM,:));
    
    S = squeeze(eff8Map(i,:,:));
    maxS(i,:) = max(S(VM,:));
    minS(i,:) = min(S(VM,:));
   
end

bands = {'\delta' '\theta' '\alpha' '\beta' '\gamma'};


subplot(2,2,1)
myScatterBoxPlot([], minB(:,bandI), minS(:,bandI))
xlim([1 2])
ylim([-8 1])
box off
title(['min effect on ' bands{bandI} ' power'])
ylabel('U')
set(gca,'XTickLabel', 'stim')

subplot(2,2,3)
histogram(minS(:,bandI)-minB(:,bandI),'BinWidth',0.5)
xlim([-6 6])
box off
title(['paired differences on min effect on '  bands{bandI}])
xlabel('U')

subplot(2,2,2)
myScatterBoxPlot([], maxB(:,bandI), maxS(:,bandI))
xlim([1 2])
ylim([-1 8])
box off
title(['max effect on ' bands{bandI} ' power'])
ylabel('U')
set(gca,'XTickLabel', 'stim')

subplot(2,2,4)
histogram(maxS(:,bandI)-maxB(:,bandI),'BinWidth',0.5)
xlim([-6 6])
box off
title(['paired differences on max effect on ' bands{bandI}])
xlabel('U')


