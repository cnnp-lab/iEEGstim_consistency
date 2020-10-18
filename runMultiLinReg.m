function runMultiLinReg(filename)
% use multiple linear regression to build a model and apply ANOVA to
% compare the independent variables of the model

disp('multi regression will be applied on STIM consistency results')

load(filename)


% 10 independent variables 
nIndy = 10;


tbl = table(AUCstim_,initMstim_,maxMstim_,interMstim_,amplDiff_,avStimAmpl_,linDT_,stimDepth_,meanDiff_,stdDiff_,taskDiff_, avMinEff, avMaxEff, avStimFreq_,...
    'VariableNames',{'AUC','initCons','maxCons','interCons','amplD','avAmpl', 'timeD', 'stDepth','baseMeanD', 'baseStdD', 'taskD', 'avMin', 'avMax', 'avFreq'});

tbl.taskD = categorical(tbl.taskD);


% build the model
lm = fitlm(tbl, 'maxCons~1 + amplD + avAmpl + timeD + stDepth + baseMeanD + baseStdD + taskD + avMin + avMax + avFreq');


disp('Running ANOVA on the model')
MM = anova(lm);



% bar plot of F measure
categX = categorical(MM.Properties.RowNames(1:nIndy));
anovaF = double(MM.F(1:nIndy));
figure(4)
bar(categX , anovaF)
ylabel('ANOVA effect')

end 





