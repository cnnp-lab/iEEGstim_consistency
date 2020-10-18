function effDiffVSamplDiff(resultsFile)
% effDiffVSamplDiff test for correlation between the effect difference
% between two sessions
% and stim amplitude difference between sessions
% Only pairs of sessions with the same stim location in the same patient are considered.
%   

% load the results and the electrode info
load(resultsFile)


% effect maps for stim and baseline
M = eff8Map;
MB = eff9Map;


% unique set of subjects
subjU = unique(subjV,'stable');

amplDiff = [];
effectDiff = []; 
effectDiffB = []; 


for i = 1: length(subjU)

    subjStimChU = unique(subjStimChV(subjV==subjU(i)), 'stable');
    
    for j =1: length(subjStimChU)

        % count the sessions and check for inconcistencies
        sesCountStim = sum(subjStimChV==subjStimChU(j));
        currSessions = find(subjStimChV==subjStimChU(j));
        stimAmpl = stimAmplPerSes(subjStimChV==subjStimChU(j))/1000;
        
      
        % common band/channel effect maps, use of validity maps
        VM  = logical(validityMap(subjStimChV==subjStimChU(j),:));
        VM = all(VM, 1);

        Mcomm = M(currSessions, VM, :);
        MBcomm = MB(currSessions, VM, :);
       


        %------------------------------------------------------------------------------

        
        if sesCountStim>1
            
            combs =  nchoosek(1:sesCountStim , 2);

            for kk = 1:size(combs,1)
                

                % reshaped band power matrices into vectors
                lin1 = reshape(Mcomm(combs(kk,1),:,:), 1, []);
                lin2 = reshape(Mcomm(combs(kk,2),:,:), 1, []);

                lin1B = reshape(MBcomm(combs(kk,1),:,:), 1, []);
                lin2B = reshape(MBcomm(combs(kk,2),:,:), 1, []);


                % see http://www.biostathandbook.com/pairedttest.html for the justification
                % of the use of paired t-test on absolute values here.
                % the distribution of the differences needs to be normal,
                % which it is

                amplDiff(end+1) = stimAmpl(combs(kk,1)) - stimAmpl(combs(kk,2));

                [~,~,~,stats] = ttest(abs(lin1), abs(lin2));
                effectDiff(end+1) = stats.tstat;

                [~,~,~,stats] = ttest(abs(lin1B), abs(lin2B));
                effectDiffB(end+1) = stats.tstat;                    

            end
        end
    end
end

figure(1)
subplot(2,1,1)
hold on
scatter(amplDiff, effectDiff,...
                        'filled', ...
                        'MarkerEdgeColor','none',   ...
                        'MarkerFaceAlpha',0.4 );
plot([-2 2], [0 0], 'k:')
plot([0 0], [-30 30], 'k:')
xlabel('\Delta amplitude')
ylabel('\Delta effect')
% xlim([-1 2 ])
% ylim([-25 25])
title('Stim')

subplot(2,1,2)
hold on
scatter(abs(amplDiff), abs(effectDiff),...
                        'filled', ...
                        'MarkerEdgeColor','none',   ...
                        'MarkerFaceAlpha',0.4 );
xlim([-0.1 1.6])
xlabel('|\Delta amplitude|')
ylabel('|\Delta effect|')


% % the following is for baseline only
% figure(2)
% subplot(2,1,1)
% hold on
% scatter(amplDiff, effectDiffB,...
%                         'filled', ...
%                         'MarkerEdgeColor','none',   ...
%                         'MarkerFaceAlpha',0.4 );
% plot([-2 2], [0 0], 'k:')
% plot([0 0], [-30 30], 'k:')
% xlabel('\Delta amplitude')
% ylabel('\Delta effect')
% % xlim([-1 2 ])
% % ylim([-25 25])
% title('Baseline')
% 
% subplot(2,1,2)
% hold on
% scatter(abs(amplDiff), abs(effectDiffB),...
%                         'filled', ...
%                         'MarkerEdgeColor','none',   ...
%                         'MarkerFaceAlpha',0.4 );
% xlim([-0.1 1.6])
% xlabel('|\Delta amplitude|')
% ylabel('|\Delta effect|')
% 
% 
% 
% end

