function effectVsStimAmpl_minmaxSuppl(filename0, bandI)
% scatter plots the minima and the maxima of the effect against stim
% amplitude. This includes supplementary analysis reported in suplpementary
% material


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


% % alternative grouping
% % 3 groups: stimAmpl<1mA, stimAmpl=1mA , stimAmpl>1mA
% %               1               2           3
% altGroups = stimAmplPerSes;
% altGroups(altGroups<1000) = 1;
% altGroups(altGroups==1000) = 2;
% altGroups(altGroups>1000) = 3;


% alternative grouping
% 2 groups: stimAmpl<1.5=mA , stimAmpl>1.5mA
%               1               2         
altGroups = stimAmplPerSes;
altGroups(altGroups<=1500) = 1;
altGroups(altGroups>1500) = 2;



% get the medians from each ampl group
uniqAmps = unique(stimAmplPerSes);
amplgroups = stimAmplPerSes;
highs0 = highs;
lows0 = lows;
for i = 1:length(uniqAmps)
    lowsM(i) = median(lows(stimAmplPerSes==uniqAmps(i)));
    highsM(i) = median(highs(stimAmplPerSes==uniqAmps(i)));
    amplgroups(stimAmplPerSes==uniqAmps(i))=i;
    highs0(stimAmplPerSes==uniqAmps(i)) = highs(stimAmplPerSes==uniqAmps(i)) - highsM(i);
    lows0(stimAmplPerSes==uniqAmps(i)) = lows(stimAmplPerSes==uniqAmps(i)) - lowsM(i);
end

disp('correlation between ampl and medians of highs?')
[r,p]=corr(uniqAmps, highsM')

disp('correlation between ampl and medians of lows?')
[r,p]=corr(uniqAmps, lowsM')


% Test for variance equality
% Brown-Forsythe's Test for Equality of Variances
%  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2003). BFtest: Brown-Forsythe's test for homogeneity of 
%    variances. A MATLAB file. [WWW document]. URL http://www.mathworks.com/matlabcentral/fileexchange/
%    loadFile.do?objectId=3412&objectType=FILE
BFtest([highs0 altGroups])
BFtest([lows0 altGroups])



ax(1)= subplot(1,2,2);
boxplot( highs0, stimAmplPerSes);    
ylabel('max effect (U)')
xlabel('amplitude (\muA)')
%xlim([0 4])
% lsline(ax(1))

ax(2)= subplot(1,2,1);
boxplot(lows0, stimAmplPerSes)  
ylabel('min effect (U)')
xlabel('amplitude (\muA)')
%xlim([0 4])
% lsline(ax(2))


end

