function consistVsEffect(filename)
% runs through the groups of sessions (at least 2) and
% calculates the consistency  curves for both stim and baseline
% can be used for t-stat(effOpt=0) or z-val(effOpt~=0) 
%   


% load the results and the electrode info
load(filename)

% unique set of subjects
subjU = unique(subjV,'stable');

% placeholder for all cons measures + eff size
AUCstim_ = [];
initMstim_ = [];
maxMstim_ = [];
interMstim_ = [];

AUCbase_ = [];
initMbase_ = [];
maxMbase_ = [];
interMbase_ = [];

avMinEff = [];
avMaxEff = [];
avAbsEff = [];

avMinEffBase = [];
avMaxEffBase = [];
avAbsEffBase = [];

avStimFreq_ = [];
linDT_ = [];
stimDepth_ = [];
amplDiff_ = [];
avStimAmpl_ = [];

meanDiff_ = [];
stdDiff_ = [];
taskDiff_ = [];


for i = 1: length(subjU)
    q = find(subjV == subjU(i), 1, 'first');
    currSubj = infoPerSes{q,1};
    
    
    subjStimChU = unique(subjStimChV(subjV==subjU(i)), 'stable');
    
    
    for j =1: length(subjStimChU)
        k = find(subjStimChV == subjStimChU(j), 1, 'first');
        currChanList = chanListPerSes{k,1};
        currChanLabels = chanListPerSes{k,2};
        currStimChans = chanListPerSes{k,3};

        % extract baseline conditions
        Mmean = meanBMap(subjStimChV==subjStimChU(j), :, :);  
        Mstd = stdBMap(subjStimChV==subjStimChU(j), :, :);
        
        % extract task info
        Minfo = infoPerSes(subjStimChV==subjStimChU(j), :);        
        
        % count the sessions and check for inconcistencies
        sesCountSubj = sum(subjV==subjU(i));
        sesCountStim = sum(subjStimChV==subjStimChU(j));
        
        % stim freq for the current subset of sessions
        stimFreq = stimFreqPerSes(subjStimChV==subjStimChU(j));
        
        % stim amplitude for the current subset of sessions
        stimAmpl = stimAmplPerSes(subjStimChV==subjStimChU(j))/1000;        
        
        % effect maps, stim and baseline
        Mstim = eff8Map(subjStimChV==subjStimChU(j), :, :);
        Mbase = eff9Map(subjStimChV==subjStimChU(j), :, :);  
        
        % counting channels
        numChans = size(Mstim ,2);        
        
        VM  = logical(validityMap(subjStimChV==subjStimChU(j),:));
        % the rows of VM are not identical in most cases due to diff 
        % artifacts in deifferent seesions 
        % Get the AND of it. A channel needs to be valid in all to be
        % considered valid for the group
        VM = all(VM, 1);
        missingChans = find(~VM);
        

    
        
        if sesCountStim>1
            
            % matrix of timestamp differences
            TS = timestampsV(subjStimChV == subjStimChU(j));
            TS = double(TS)/3600000;
            DT = ones(length(TS), 1)*TS' - TS*ones(1,length(TS));
            linDT = squareform(DT);
            
            % all combinations of sessions (their indices)
            combs =  nchoosek(1:sesCountStim , 2);
                        
            freqDiff = [];
            avStimFreq = [];
            amplDiff = [];
            avStimAmpl = [];
            meanDiff = zeros(size(combs,1) , 1);
            stdDiff = zeros(size(combs,1) , 1);
            taskDiff = zeros(size(combs,1) , 1);            
            for kk = 1:size(combs,1)
                freqDiff(end+1) = abs(stimFreq(combs(kk,1)) - stimFreq(combs(kk,2)));
                avStimFreq(end+1) = mean([stimFreq(combs(kk,1)) stimFreq(combs(kk,2))]);
                amplDiff(end+1) = abs(stimAmpl(combs(kk,1)) - stimAmpl(combs(kk,2)));
                avStimAmpl(end+1) = mean([stimAmpl(combs(kk,1)) stimAmpl(combs(kk,2))]);   
                
                Mmean1 = squeeze(Mmean(combs(kk,1),VM,:));
                Mmean2 = squeeze(Mmean(combs(kk,2),VM,:));

                Mstd1 = squeeze(Mstd(combs(kk,1),VM,:));
                Mstd2 = squeeze(Mstd(combs(kk,2),VM,:));

                meanDiff(kk) = mean(abs(Mmean1(:)- Mmean2(:)));
                stdDiff(kk) = mean(abs(Mstd1(:) - Mstd2(:)));
                
                % is the task different between this pair?
                if ~strcmp(Minfo{combs(kk,1), 2}, Minfo{combs(kk,2), 2})
                    taskDiff(kk) = 1;
                end
            end
            
            
            stimDepth = mean(stimPialDPerSes(subjStimChV==subjStimChU(j)));
            stimDepth = stimDepth*ones(size(combs,1),1);
            
            
            %-------------------------------------------
            
            
            [curvesStim,rAxesStim,~,~,avmin,avmax,avabseff] = multySesCorrDynPlus(Mstim(:,VM,:), 0, 1, 3);
            [curvesBase,rAxesBase,~,~,avminBase,avmaxBase,avabseffB] = multySesCorrDynPlus(Mbase(:,VM,:), 0, 1, 3);

            % summary of consistency measure
            [AUCstim, initMstim, maxMstim, interMstim] = summariseConsist(curvesStim, rAxesStim);
            [AUCbase, initMbase, maxMbase, interMbase] = summariseConsist(curvesBase, rAxesBase);
            
            
            %---------------------------------------------

            % append the results of the current stim location to the overall
            AUCstim_ = [AUCstim_; AUCstim];
            initMstim_ = [initMstim_; initMstim];
            maxMstim_ = [maxMstim_; maxMstim];
            interMstim_ = [interMstim_; interMstim];
            
            AUCbase_ = [AUCbase_; AUCbase];
            initMbase_ = [initMbase_; initMbase];
            maxMbase_ = [maxMbase_; maxMbase];
            interMbase_ = [interMbase_; interMbase];                  
            
            avMinEff = [avMinEff; avmin];
            avMaxEff = [avMaxEff; avmax];
            avAbsEff = [avAbsEff; avabseff];

            avMinEffBase = [avMinEffBase; avminBase];
            avMaxEffBase = [avMaxEffBase; avmaxBase];
            avAbsEffBase = [avAbsEffBase; avabseffB];
            
            avStimFreq_ = [avStimFreq_; avStimFreq'];
            linDT_ = [linDT_; abs(linDT')];
            stimDepth_ = [stimDepth_; stimDepth];  
            amplDiff_ = [amplDiff_; amplDiff'];
            avStimAmpl_ = [avStimAmpl_; avStimAmpl'];
            
            meanDiff_ = [meanDiff_; meanDiff];
            stdDiff_ = [stdDiff_; stdDiff];
            taskDiff_ = [taskDiff_; taskDiff];


            %---------------------------------------------


            for jj = 1:size(curvesStim,1)


                % plot the curves
                subplot(3,4,1:3)
                hold on
                plot(rAxesStim{jj}, curvesStim{jj}, 'b')
                plot(rAxesBase{jj}, curvesBase{jj}, 'r')

                xlabel('radius of excl. circle')
                ylabel('correlation coeff')


                subplot(3,4,4)
                hold on
                plot(rAxesStim{jj}, curvesStim{jj}, 'b')
                plot(rAxesBase{jj}, curvesBase{jj}, 'r')
                xlim([1 3])
                xlabel('radius of excl. circle')
            end


            % scatter the summary measures vs aver stim ampl
            subplot(3,4,5)
            hold on
            scatter(avmin, AUCstim, 'b')
            scatter(avminBase, AUCbase, 'r')
            ylabel('AUC')
            xlabel('av min effect')

            subplot(3,4,6)
            hold on
            scatter(avmin, maxMstim, 'b')
            scatter(avminBase, maxMbase, 'r')
            ylabel('consistency coeff.')
            xlabel('av min effect')

            subplot(3,4,7)
            hold on
            scatter(avmin, initMstim, 'b')
            scatter(avminBase, initMbase, 'r')
            ylabel('consistency at r=0')
            xlabel('av min effect')

            subplot(3,4,8)
            hold on
            scatter(avmin, interMstim, 'b')
            scatter(avminBase, interMbase, 'r')
            ylabel('consistency at r=3')
            xlabel('av min effect')




            % scatter the summary measures vs abs stim diff
            ax(1)=subplot(3,4,9);
            hold on
            scatter(avmax, AUCstim, 'b')
            scatter(avmaxBase, AUCbase, 'r')
            ylabel('AUC')
            xlabel('av max effect')

            ax(2)=subplot(3,4,10);
            hold on
            scatter(avmax, maxMstim, 'b')
            scatter(avmaxBase, maxMbase, 'r')
            ylabel('consistency coeff.')
            xlabel('av max effect')
            

            ax(3)=subplot(3,4,11);
            hold on
            scatter(avmax, initMstim, 'b')
            scatter(avmaxBase, initMbase, 'r')
            ylabel('consistency at r=0')
            xlabel('av max effect')

            ax(4)=subplot(3,4,12);
            hold on
            scatter(avmax, interMstim, 'b')
            scatter(avmaxBase, interMbase, 'r')
            ylabel('consistency at r=3')
            xlabel('av max effect')
            
            
                
            
            subplot(3,4,1:3)
            title('zero centered correlation')
            
        
        end
        

    end
    disp([i j])
end
linkaxes(ax, 'x')

save ConsResults.mat ...
    AUCbase_ initMbase_ maxMbase_ interMbase_ ...
    AUCstim_ initMstim_ maxMstim_ interMstim_ ...
    avMaxEff avMinEff avAbsEff...
    avMinEffBase avMaxEffBase avAbsEffBase...
    avStimFreq_ linDT_ stimDepth_...
    avStimAmpl_ amplDiff_...
    meanDiff_ stdDiff_  taskDiff_
    

disp('Blue indicates consistency between stim responses')
disp('Red indicates consistency between the baseline fluctuations')
end

