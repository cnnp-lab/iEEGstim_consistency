function visualiseMap(filename, visOpt, condOpt)
%VISUALCOMBSIGNIF gets the filename of significance results combining all
% bands and visualizes the results 
% visualization subject by subject and different figures for different stim
% channels
%   
% visOpt is for choosing what is visualized:
% 0 : z-value on stim
% 1 : z-value on baseline
% the default value is 0
%
% condOpt is for choosing the background condition used:
% 0 : mean of band power
% 1 : std of band power
% the default value is 0



if nargin < 3
    % default value for the mean of band power as the condition
    condOpt = 0;
end


% set the default option if needed
if nargin< 2 || visOpt < 0 || visOpt > 1
    visOpt = 0;
end


%load colormap
load unionjack.mat

% load the results and the electrode info
load(filename)

% figure position 
figPos = [7         20        1200         900];
subC = 6;
subR = 7;

% counting channels and bands
numChans = size(eff4Map ,2);


numBands = length(freqV);

% unique set of subjects
subjU = unique(subjV,'stable');


switch visOpt
    case 0
        disp('visualizing: z-stat on stim')
    case 1
        disp('visualizing: z-stat on baseline')
end

switch condOpt
    case 0
        disp('baseline conditions visualized: mean of baseline bandpowers')
    case 1
        disp('baseline conditions visualized: SD of baseline bandpowers')
end

% give the chance to skip to a particular subject
skipK = input('Enter index of subj to skip to, or 4-digit subj code, or leave empty to start from first: ', 's');
if length(skipK)==4 && skipK(1)=='1'
    % subj code entered
    skipK = num2str(find(subjU == str2num(skipK)));
    if isempty(skipK)
        warning('subject code not found')
        skipK = '1';
    end
end

if isempty(skipK) || (ischar(skipK) && str2num(skipK)<1)
    skipK = '1';
end
skipK = floor(str2num(skipK));


for i = skipK: length(subjU)
    q = find(subjV == subjU(i), 1, 'first');
    currSubj = infoPerSes{q,1};
    
    
    subjStimChU = unique(subjStimChV(subjV==subjU(i)), 'stable');
    
    for j =1: length(subjStimChU)
        k = find(subjStimChV == subjStimChU(j), 1, 'first');
        currChanList = chanListPerSes{k,1};
        currChanLabels = chanListPerSes{k,2};
        currStimChans = chanListPerSes{k,3};
        

        % count the sessions and check for inconcistencies
        sesCountSubj = sum(subjV==subjU(i));
        sesCountStim = sum(subjStimChV==subjStimChU(j));
        
        stimAmpl = stimAmplPerSes(subjStimChV==subjStimChU(j))/1000;
        
        % setting of what is being visualized
        switch visOpt
            case 0
                M = eff8Map(subjStimChV==subjStimChU(j), :, :);
            case 1
                M = eff9Map(subjStimChV==subjStimChU(j), :, :);   
        end
        
        if condOpt
            C = stdBMap(subjStimChV==subjStimChU(j), :, :);
        else
            C = meanBMap(subjStimChV==subjStimChU(j), :, :);
        end
        
        VM  = logical(validityMap(subjStimChV==subjStimChU(j),:));
        % the rows of VM are not identical in most cases due to diff 
        % artifacts in deifferent seesions 
        % Get the AND of it. A channel needs to be valid in all to be
        % considered valid for the group
        VM = all(VM, 1);
        missingChans = find(~VM);
        
        D  = distanceMap(subjStimChV==subjStimChU(j),:);
        % considering that the default value for D is 999 for disabled/bad
        % channels and considering that different sessions can have
        % different valid channels due to artifacts, the D vector that
        % represents a group of sessions is taken as the max of the
        % channel-specific Ds
        % It should be equivalent as setting 999 all channels that are
        % invalided according to the VM above
        D = max(D,[],1); 
        
    
        fh = figure;
        set(fh, 'Position', figPos - (j-1)*[0 200 0 0])
        set( fh,'PaperSize',[29.7 21.0])
        
        
        
        ax1 = subplot(subR,subC,[1 2 7 8 13 14 19 20]);      % --------------------------------------------
        
        C(:,~VM,:) = 0;     %zero anything outside the validity map
        minV = min(min(min( C(:,VM,:) )));
        Cvis = C;
        Cvis(Cvis==0) = minV;
        imagesc(reshape2visualise(Cvis));
        colormap(ax1,whiteRed)
        
        % annotate map
        hold on
        bl = 5*sesCountStim+0.5;
        bar(missingChans, bl*ones(1,length(missingChans)), 'k','FaceAlpha',0.6, 'EdgeColor','none');
        bar([currStimChans(1)-1 currStimChans], [0 bl*ones(1,length(currStimChans))], 'g','FaceAlpha',0.9, 'EdgeColor','none');
        for jj= 1: sesCountStim-1
            line([0 numChans+0.5], [5*jj+0.5 5*jj+0.5], 'Color', 'k')
        end


        title('baseline conditions')
        ylabel('bands')
        set(gca,'TickDir','out');
        ylabels={'\delta' '\theta' '\alpha' '\beta' '\gamma'};
        set(gca, 'YTick', 1:5*sesCountStim, 'YTickLabel', ylabels);
        xTicks = get(gca, 'XTick');
        set(gca, 'XTickLabel', [])
        box off

        
        ax2 = subplot(subR,subC,[3 4 9 10 15 16 21 22]);      % --------------------------------------------
        M(:,~VM,:) = 0;     %zero anything outside the validity map

        Mvis = M;

        if visOpt == 0 || max(abs(M(:)))==0 
            maxV = max([max(abs(M(:))) 1]);
        else
            maxV = max(abs(M(:)));
        end
        imagesc(reshape2visualise(Mvis), [-maxV maxV]);
        colormap(ax2,unionjack_whitish)

        % annotate map
        hold on
        bl = 5*sesCountStim+0.5;
        bar(missingChans, bl*ones(1,length(missingChans)), 'k','FaceAlpha',0.6, 'EdgeColor','none');
        bar([currStimChans(1)-1 currStimChans], [0 bl*ones(1,length(currStimChans))], 'g','FaceAlpha',0.9, 'EdgeColor','none');
        for jj= 1: sesCountStim-1
            line([0 numChans+0.5], [5*jj+0.5 5*jj+0.5], 'Color', 'k')
        end


        if sesCountStim~=sesCountSubj
            titlec = 'r';
        else
            titlec = 'k';
        end
        title({[currSubj ': ' num2str(sesCountStim) ' of ' num2str(sesCountSubj) ' sessions']...
            '---------------------------------'},'Color',titlec)
        set(gca,'TickDir','out');
        if visOpt~=6
            set(gca, 'YTick', 1:5*sesCountStim, 'YTickLabel', ylabels);
        else
            set(gca, 'YTick', 1:sesCountStim)
        end
        set(gca, 'XTickLabel', [])
        box off
  
        
        ax3 = subplot(subR,subC,[5 6 11 12 17 18 23 24]);      % --------------------------------------------
        [~, sortedCh] = sort(D);

        Mr = M(:,sortedCh,:);
        
        Mrvis = Mr;

        imagesc(reshape2visualise(Mrvis),[-maxV maxV]);
        colormap(ax3,unionjack_whitish)
        hold on
        
        bar(find(ismember(sortedCh , missingChans)), bl*ones(1,length(missingChans)), 'k','FaceAlpha',0.6, 'EdgeColor','none');
        bar(find(ismember(sortedCh , currStimChans)), bl*ones(1,length(currStimChans)), 'FaceColor', [1 0.84 0],'FaceAlpha',0.9, 'EdgeColor','none');
        for jj= 1: sesCountStim-1
            line([0 numChans+0.5], [5*jj+0.5 5*jj+0.5], 'Color','k')
        end
        
        title({'alternative ordering:'  'increasing euclidean dist from stim loc'})
            
        % ylabel('bands')
        set(gca,'TickDir','out');
        if visOpt~=6
            set(gca, 'YTick', 1:5*sesCountStim, 'YTickLabel', ylabels);
        else
            set(gca, 'YTick', 1:sesCountStim)
        end
        set(gca, 'XTickLabel', [])
        box off
        
        
        ax4 = subplot(subR,subC,[25 26 31 32]);  % ------------------------------------------------
        meanCvis = squeeze(mean(Cvis, 1))';
        minV2 = min(min(meanCvis(:,VM)));
        meanCvis(meanCvis==0) = minV2;
        imagesc(meanCvis)
        colormap(ax4,whiteRed)
        hold on
        bar(missingChans, bl*ones(1,length(missingChans)), 'k','FaceAlpha',0.6, 'EdgeColor','none');
        bar([currStimChans(1)-1 currStimChans], [0 bl*ones(1,length(currStimChans))], 'FaceColor', [1 0.84 0],'FaceAlpha',0.9, 'EdgeColor','none');

        ylabel('mean across sessions')
        xlabel('channels')
        set(gca,'TickDir','out');
        set(gca, 'YTick', 1:5, 'YTickLabel', ylabels);
        % set(gca, 'XTickLabel', [])
        box off
        if sesCountStim==1
            rectangle('Position',[numChans/10,0.75,0.8*numChans,1], 'FaceColor',[1 1 1])
            text(numChans/6, 1, 'Same as above')
        end
        
        
        ax5 = subplot(subR,subC,[27 28 33 34]);  % ------------------------------------------------
        

        meanM = squeeze(mean(M, 1))';
        

        meanMvis = meanM;

        if visOpt == 0 || max(abs(M(:)))==0
            maxV = max([max(abs(meanM(:))) 1]);
        end
        imagesc(meanMvis, [-maxV maxV])
        colormap(ax5,unionjack_whitish)
        hold on
        bar(missingChans, bl*ones(1,length(missingChans)), 'k','FaceAlpha',0.6, 'EdgeColor','none');
        bar([currStimChans(1)-1 currStimChans], [0 bl*ones(1,length(currStimChans))], 'FaceColor', [1 0.84 0],'FaceAlpha',0.9, 'EdgeColor','none');

        set(gca,'TickDir','out');
        if visOpt~=6
            set(gca, 'YTick', 1:5, 'YTickLabel', ylabels);
        else
            set(gca, 'YTick', 1:sesCountStim)
        end
        set(gca, 'XTickLabel', [])
        box off

        if sesCountStim==1
            rectangle('Position',[numChans/10,0.75,0.8*numChans,1], 'FaceColor',[1 1 1])
            text(numChans/6, 1, 'Same as above')
        end
        
       
        ax6 = subplot(subR,subC,[29 30 35 36]);  % ------------------------------------------------
        

        meanMr = squeeze( mean(Mr, 1))';
        
        
        meanMrvis = meanMr;


        if visOpt == 0 || max(abs(M(:)))==0
            maxV = max([max(abs(meanM(:))) 1]);
        end
        imagesc(reshape2visualise(meanMrvis),[-maxV maxV])
        colormap(ax6,unionjack_whitish)
        hold on
        bar(find(ismember(sortedCh , missingChans)), bl*ones(1,length(missingChans)), 'k','FaceAlpha',0.6, 'EdgeColor','none');
        bar(find(ismember(sortedCh , currStimChans)), bl*ones(1,length(currStimChans)), 'FaceColor', [1 0.84 0],'FaceAlpha',0.9, 'EdgeColor','none');


        set(gca,'TickDir','out');
        if visOpt~=6
            set(gca, 'YTick', 1:5, 'YTickLabel', ylabels);
        else
            set(gca, 'YTick', 1:sesCountStim)
        end
        set(gca, 'XTickLabel', [])
        box off
        
        if sesCountStim==1
            rectangle('Position',[numChans/10,0.75,0.8*numChans,1], 'FaceColor',[1 1 1])
            text(numChans/6, 1, 'Same as above')
        end

        %------------------------------------------------------------------------------
        
        if visOpt~=6
            meanmeanM = mean(squeeze(mean(M, 1))');
            posI = find(meanmeanM>=0);
            negI = find(meanmeanM<0);

            meanMpos = meanmeanM;
            meanMpos(meanMpos<0)=0;
            meanMneg = meanmeanM;
            meanMneg(meanMneg>0)=0;        

            subplot(subR,subC,[39 40]);   % ------------------------------------------------
            bar(sort([posI negI]), meanMpos, 'FaceColor', 'r', 'EdgeColor', 'k');
            hold on
            bar(sort([posI negI]), meanMneg, 'FaceColor', 'b', 'EdgeColor', 'k');
            ylabel({'channel-specific' 'mean'})           
            xlabel('channels')
            xlim([0.5 numChans+0.5])
            set(gca, 'XTick', xTicks)



            meanmeanMr = mean(squeeze( mean(Mr, 1))');

            posI = find(meanmeanMr>=0);
            negI = find(meanmeanMr<0);

            meanMrpos = meanmeanMr;
            meanMrpos(meanMrpos<0)=0;
            meanMrneg = meanmeanMr;
            meanMrneg(meanMrneg>0)=0;  

            subplot(subR,subC,[41 42]);   % ------------------------------------------------
            bar(sort([posI negI]), meanMrpos, 'FaceColor', 'r', 'EdgeColor', 'k');
            hold on
            bar(sort([posI negI]), meanMrneg, 'FaceColor', 'b', 'EdgeColor', 'k');
            % ylabel({'channel-specific' 'mean'})              
            xlabel('channels')
            xlim([0.5 numChans+0.5])
            set(gca, 'XTick', xTicks)
            set(gca, 'YTickLabels', [])
        end
        

    end
    disp(i)
    
    contKey = input('Enter q to quit or anything else to continue with the next subject:','s');
    if strcmp(contKey, 'q') || strcmp(contKey, 'Q')
        break
    end
    close all
end
close all
end

