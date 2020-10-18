function effectVsStimDur_minmax(filename0, bandI)
% scatter plots the minima and the maxima of the effect against stim
% duration (supplementary results)
% statistical test also applied


load(filename0, 'eff8Map', 'stimDurPerSes')



% get the max and min of effect in each session
highs = zeros(size(eff8Map,1), 1);
lows = zeros(size(eff8Map,1), 1);
for  i  = 1: size(eff8Map,1)
    if bandI
        B = eff8Map(i,:,bandI);
    else
        B = eff8Map(i,:,:);
    end
    C = B(:);
    C(C==0)=NaN;
    highs(i) = max(C);
    lows(i) = min(C);
end


ax(1)= subplot(1,2,2);
scatter(stimDurPerSes, highs,...
                        'filled', ...
                        'MarkerEdgeColor','none',   ...
                        'MarkerFaceAlpha',0.3 );    
ylabel('max effect (U)')
xlabel('stim duration (sec)')
lsline(ax(1))

ax(2)= subplot(1,2,1);
scatter(stimDurPerSes, lows,...
                        'filled', ...
                        'MarkerEdgeColor','none',   ...
                        'MarkerFaceAlpha',0.3 );    
ylabel('min effect (U)')
xlabel('stim duration (sec)')
lsline(ax(2))

disp('pvalue of ranksum test between the max effect values between the 2 groups of stim duration');
[p,~,stats] = ranksum(highs(stimDurPerSes==0.5), highs(stimDurPerSes==4.6))



disp('pvalue of ranksum test between the min effect values between the 2 groups of stim duration');
[p,~,stats] = ranksum(lows(stimDurPerSes==0.5), lows(stimDurPerSes==4.6))



end

