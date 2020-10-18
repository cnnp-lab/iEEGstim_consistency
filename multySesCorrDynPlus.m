function [consCurves, rAxes, prctiles, maxD0, avmin, avmax, avabseff] = multySesCorrDynPlus(M3D, plotflag, circleType, measureOpt)
% It produces the combinations of sessions (pairs) and calls the consistency
% function for each pair.
% The output is a set of consistency curves (cell array), 
% one for each pair.
% The condistency curve expresses the pair consistency for varying values
% of circle radius.


% choice of circle type :
% 1 for circle fo exclusion
% -1 for circle of inclusion
% 0 for both

% measureOption
% 1 for typical R2 defintion
% 2 for alternative R2 definition (aver residual)
% 3 for alternative correlation coefficient (0-centered)

numSes = size(M3D, 1);

combs =  nchoosek(1:numSes , 2);

consCurves = cell(size(combs, 1),1);
rAxes = cell(size(combs, 1),1);
prctiles = zeros(size(combs, 1),2);
maxD0 = zeros(size(combs, 1), 1);
avmin = zeros(size(combs, 1), 1);
avmax = zeros(size(combs, 1), 1);
avabseff = zeros(size(combs, 1), 1);

for i  = 1 : size(combs, 1)
    M3D_1 = squeeze(M3D(combs(i,1), :, :))';
    M3D_2 = squeeze(M3D(combs(i,2), :, :))';
    
    % distance from 0,0
    D = pdist2([0 0], [M3D_1(:), M3D_2(:)]);
    
    switch circleType
        case 0
            minmaxRadius = [ -max(D) max(D)];
        case 1
            minmaxRadius = [ 0 max(D)];
        case -1
            minmaxRadius = [-max(D) -0.001];
    end
    
    if measureOpt == 3
        % for correlation measure
        [consCurves{i}, rAxes{i}] = sesPairConsistency(M3D_1(:), M3D_2(:), ...
                                                        plotflag, measureOpt, minmaxRadius);
    else
        error('measureOpt should be 3. Other options are obsolete')
    end
    

    % plus: get the max low percentile between the two sessions and 
    % the min high percentile between them 
    prctiles(i,1) = max([prctile(M3D_1(:), 2) prctile(M3D_2(:), 2)]);
    prctiles(i,2) = min([prctile(M3D_1(:), 98) prctile(M3D_2(:), 98)]);

    % max distance from 0,0
    maxD0(i) = max(D);
    
    % average maxima and minima between the two sessions
    avmin(i) = mean([min(M3D_1(:)) min(M3D_2(:))]);
    avmax(i) = mean([max(M3D_1(:)) max(M3D_2(:))]);
    
    avabseff(i) = mean([max(abs(M3D_1(:))) max(abs(M3D_2(:)))]);
    
end


end

