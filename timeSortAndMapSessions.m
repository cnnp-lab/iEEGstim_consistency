function timeSortAndMapSessions(filename)
% this function sorts and transforms the results in resPerSessD.mat and
% creates the sorted result file resPerSessD_sorted.mat.
%
% The sorting is based on the start times of the sessions: the sessions
% across all subjects are temporally sorted from the most distant to the most
% recent session.
%
% The results are also trasformed , generally from cell arrays to 2 or 3
% dimensional matrices , in order to make the visualization and subsequent
% analysis more convinient.
%
%
% Effect matrices have 3 dimensions: numSess x maxNumChannels x numBands
% additional column vectors (numSess long) are produced:
%   one indicating the subject label (subjL)
%   one indicating the band/ freq range (freqV)
%   one indicating the stimchannels (stimChV)
%   one combining subj and stim chanels indicators (subjStimChV)
%
% This function also produces a validity map: a binary map that indicates
% for each session which channels have a valid measure of effect ( the stim
% channels are not considered valid). notice that 2 sessions from the same
% subject can have recordings from the same set of channels but the set of
% valid channels can be different because some channels might have
% artifacts in one session but not the other. Subsequent analyses on pairs
% of sessions(in other functions) always consider the intersection of valid
% channels between the 2 sessions.
% 
%
% freqV is defined assuming that the freq ranges are ranges between
% integer numbers



            
% load data 
load(filename);


numSes = size(infoPerSes,1);
numBands = size(freq_ranges, 1);

% find the min and max channel number across all channel lists
maxChID = 0;     
minChID = 999; 
for j = 1: size(chanListPerSes, 1)
    maxChID = max([chanListPerSes{j,1}; maxChID]);
    minChID = min([chanListPerSes{j,1}; minChID]);
end

% using mapExtend rather than maxChID to accomodate channel 0 but, at
% least for this dataset, it doesn't matter: channel 0 is never used. 
% mapExtend should accomodate all channels from the lowest channel ID to
% the highest channel ID; even if intermediate channels are missing
mapExtend = maxChID - minChID + 1; 


% define all result matrices/maps
meanBMap = zeros(numSes, mapExtend, numBands);
stdBMap = zeros(numSes, mapExtend, numBands);
meanDBMap = zeros(numSes, mapExtend, numBands);
stdDBMap = zeros(numSes, mapExtend, numBands);
meanPreMap = zeros(numSes, mapExtend, numBands);
stdPreMap = zeros(numSes, mapExtend, numBands);
meanPostMap = zeros(numSes, mapExtend, numBands);
stdPostMap = zeros(numSes, mapExtend, numBands);
meanDMap = zeros(numSes, mapExtend, numBands);
stdDMap = zeros(numSes, mapExtend, numBands);
eff1Map = zeros(numSes, mapExtend, numBands);
eff4Map = zeros(numSes, mapExtend, numBands);
eff7Map = zeros(numSes, mapExtend, numBands);
eff8Map = zeros(numSes, mapExtend, numBands); % map for effect: z-statistic of paired non-parametric test between pre post of stim
eff9Map = zeros(numSes, mapExtend, numBands); % map for effect: z-statistic of paired non-parametric test between pre post of baseline
validityMap = zeros(numSes, mapExtend);
distanceMap = 999*ones(numSes, mapExtend);
subjV = uint32(zeros(numSes, 1));
freqV = zeros(numBands, 1);
stimChV = uint32(zeros(numSes, 1));
subjStimChV = uint32(zeros(numSes, 1));

% sorting is based on the start time of the session
[timestampsV, tI] = sort(timestampsPerSes(:,1));

% in the for loop the sortIndices tI are used sequentially for extracting  
% and then index i is used for storing
for i = 1:size(infoPerSes,1)
    

    currChanList = chanListPerSes{tI(i),1};
    currStim = chanListPerSes{tI(i),3};

    chanListWithoutStim = setdiff(currChanList, currStim );
    
    
    for j = 1:size(freq_ranges, 1)

        meanBMap(i, chanListWithoutStim, j) = baseCondPerSes{tI(i),1}(j,:);
        stdBMap(i, chanListWithoutStim, j) = baseCondPerSes{tI(i),2}(j,:);
        meanDBMap(i, chanListWithoutStim, j) = baseCondPerSes{tI(i),3}(j,:);
        stdDBMap(i, chanListWithoutStim, j) = baseCondPerSes{tI(i),4}(j,:);
        meanPreMap(i, chanListWithoutStim, j) = stimMisc{tI(i),1}(j,:);
        stdPreMap(i, chanListWithoutStim, j) = stimMisc{tI(i),2}(j,:);
        meanPostMap(i, chanListWithoutStim, j) = stimMisc{tI(i),3}(j,:);
        stdPostMap(i, chanListWithoutStim, j) = stimMisc{tI(i),4}(j,:);   
        meanDMap(i, chanListWithoutStim, j) = stimMisc{tI(i),5}(j,:);
        stdDMap(i, chanListWithoutStim, j) = stimMisc{tI(i),6}(j,:); 
        
        eff1Map(i, chanListWithoutStim, j) = effectPerSession{tI(i),1}(j,:);
        eff4Map(i, chanListWithoutStim, j) = effectPerSession{tI(i),2}(j,:);
        eff7Map(i, chanListWithoutStim, j) = effectPerSession{tI(i),3}(j,:);
        eff8Map(i, chanListWithoutStim, j) = effectPerSession{tI(i),4}(j,:);
        eff9Map(i, chanListWithoutStim, j) = effectPerSession{tI(i),5}(j,:);
        

        
        if i == 1
            freqV(j) = str2num(strrep(num2str(freq_ranges(j,:)),' ',''));
        end
    end
    
    
    validityMap(i, chanListWithoutStim) = 1;
    distanceMap(i,currChanList) = chanListPerSes{tI(i),4};
    distanceMap(i,currStim) = 0;
    
    subjV(i) = sscanf(infoPerSes{tI(i),1},'R%d');
    stimChV(i) = str2num(strrep(num2str(currStim),' ',''));
    subjStimChV(i) = str2num(strrep(num2str([subjV(i) stimChV(i)]),' ',''));
end

stimDurPerSes = stimDurPerSes(tI);
stimAmplPerSes = stimAmplPerSes(tI);
stimFreqPerSes = stimFreqPerSes(tI);
stimPialDPerSes = stimPialDPerSes(tI);
chanListPerSes = chanListPerSes(tI, :);
infoPerSes = infoPerSes(tI, :);
bandPowers = bandPowers(tI, :);

savefilename = [filename(1:end-4) '_sorted.mat'];
save(savefilename,...
    'eff1Map','eff4Map', 'eff7Map', 'eff8Map', 'eff9Map',...
    'subjV', 'freqV', 'stimChV', 'stimAmplPerSes', ...
    'subjStimChV', 'infoPerSes', 'chanListPerSes', 'validityMap', ...
    'timestampsV', 'stimDurPerSes',...
    'meanBMap', 'stdBMap', 'meanDBMap', 'stdDBMap', ...
    'meanPreMap', 'stdPreMap', 'meanPostMap', 'stdPostMap', ...
    'meanDMap', 'stdDMap', 'bandPowers', ...
    'distanceMap', 'stimPialDPerSes', 'stimFreqPerSes');

