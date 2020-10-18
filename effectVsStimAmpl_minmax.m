function effectVsStimAmpl_minmax(filename0, bandI)
% scatter plots the minima and the maxima of the effect against stim
% amplitude

load(filename0, 'stimAmplPerSes', 'eff8Map')


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
scatter(stimAmplPerSes/1000, highs,...
                        'filled', ...
                        'MarkerEdgeColor','none',   ...
                        'MarkerFaceAlpha',0.3 );    
ylabel('max effect (U)')
xlabel('stim amplitude (mA)')
xlim([0 4])
% lsline(ax(1))

ax(2)= subplot(1,2,1);
scatter(stimAmplPerSes/1000, lows,...
                        'filled', ...
                        'MarkerEdgeColor','none',   ...
                        'MarkerFaceAlpha',0.3 );    
ylabel('min effect (U)')
xlabel('stim amplitude (mA)')
xlim([0 4])
% lsline(ax(2))


end

