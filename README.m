% The published analysis code starts from the data file resPerSessD.mat
% This data file is produced right after the processing of the raw data.
% The two main components in this file: a cell array for the band powers and
% another cell array for the stim and baseline effects (1 cell row for
% each session  -  numSes = 165).

% Full list of elements:

% - effectPerSession (numSes x 5) -  5 effect measures:
%       z-statistic of unpaired non-param test btw stimDiff and baselineDiff 
%       t-statistic of parametric test between pre post of stim
%       t-statistic of parametric test between pre post of baseline
%       z-statistic of paired non-parametric test between pre post of stim
%       z-statistic of paired non-parametric test between pre post of baseline
%       (only the last 2 were used for further analysis)
%       (each cell contains a matrix of effect measure structured as 
%       freq.bands x channels)


% - bandPowers (numSes x 4) : 4 columns for band powers at different segm.
%       pre stim band powers
%       post stim band powers
%       pre baseline band powers
%       post baseline band powers
%       (each cell includes a matrix organised as channels x trials x
%       bands)
%     % -these bandPowers can be used to recalculate the effects above 
%     % -example:
%     % chid=34;  %channel ID
%     % sid=5;    %session ID
%     % 
%     % chanListWithoutStim = setdiff(chanListPerSes{sid,1} , chanListPerSes{sid,3});
%     % predelta=bandPowers{sid,1}(chanListWithoutStim==chid,:,1);
%     % postdelta=bandPowers{sid,2}(chanListWithoutStim==chid,:,1);
%     % [p,h,stats]=signrank(predelta,postdelta)
%     % % compare with this:
%     % eff8Map(sid,chid,1)

% - freq_ranges: frequency ranges [Hz] used for the band power calculations


% - baseCondPerSes: baseline conditions per session (numSes x 4) - 4 measur
%       mean baseline band powers (pre and post together)
%       SD of baseline band powers (pre and post together)
%       mean of baseline band power differences (not used)
%       SD of baseline band power differences (not used)
%       (each cell contains a matrix structured as 
%       freq.bands x channels)

% - stimMisc: measures of stim band powers (numSes x 6) - 6 measures
%       mean band power of pre segments
%       SD band power of pre segments
%       mean band power of post segments
%       SD band power of post segments
%       mean band power of post-pre differences 
%       SD band power of post-pre differences 
%       (each cell contains a matrix structured as 
%       freq.bands x channels)

% - stimPialDPerSes: distance of stim loc from pial for each session

% - timestampsPerSes: timestamps of ses start and finish for each session
% 	([start_timepoint_in_ms finish_timepoint_in_ms])

% - stimFreqPerSes: stim frequency for each session

% - stimAmplPerSes: stim amplitude for each session

% - infoPerSes: information for each session: subject,experiment,ses index

% - chanListPerSes: channel list per session (numSes x 4)
%       channel list -  numbers
%       (removed channel labels)
%       stim channel numbers
%       euclidean distance of each channel from the stim


% Get the preprocessed data file resPerSessD.mat:
% https://drive.google.com/file/d/1RzW_QRfWtEcUVFgbXcwQoZewSUxVv-FV/view?usp=sharing

% The results in resPerSessD.mat need to be sorted and transformed for
% any subsequent visualization and analysis. Use the following line:
timeSortAndMapSessions('resPerSessD.mat')

% The mat file resPerSessD_sorted.mat is now created

% You can now visualise the effects (like in Fig 2 and 5) using:
visualiseMap('resPerSessD_sorted.mat')


% reproduce the results in fig3 with :
bandI=1;
boxPlotsOfEffect('resPerSessD_sorted', bandI)
% where bandI an integer from 1 to 5 for the band specific results of
% bands in order: {'\delta' '\theta' '\alpha' '\beta' '\gamma'};


% reproduce the results in fig4A with :
effectVsStimAmpl_minmax('resPerSessD_sorted', bandI)
% use bandI 1 through 5 for band-specific results or 0 for considering all bands

% reproduce the results in fig4B with :
effDiffVSamplDiff('resPerSessD_sorted')

% for the production of consistency curves (fig 6ABC) 
% first and second panel
% ConsResults.mat is produced
consistVsEffect('resPerSessD_sorted.mat')

% for the multiple linear regression analysis (fig 6D) use:
runMultiLinReg('ConsResults.mat')




% ---- additional functions for supplementary results -----

% effect vs stim amplitude 
% additional analysis: includes test for variance equality
effectVsStimAmpl_minmaxSuppl('resPerSessD_sorted', bandI)

% effect vs stim duration
effectVsStimDur_minmax('resPerSessD_sorted', bandI)

% effect vs stim frequency
effectVsStimFreq_minmax('resPerSessD_sorted', bandI)