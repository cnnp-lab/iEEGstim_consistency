function [AUC, initM, maxM, interM] = summariseConsist(curves, rValues)
%SUMMARISECONSIST Summarises consistency curves
%  It gets a set of consistency curves (cell array) with their 
%  radius values (cell array) and produces
%  summarised consistency measures from them.
%
% The summary measures are the Area Under the Curve, value at radius 0 and
% maximal value.

nCurves = length(curves);
nRAxes = length(rValues);

if nCurves ~= nRAxes
    error('not compatible inputs')
end

for i = 1:nRAxes
    if var(diff(rValues{i})) > 1e-10
        error('check r values. not linearly spaced')
    end
end


AUC = zeros(nCurves,1);
initM = zeros(nCurves,1);
maxM = zeros(nCurves,1);
interM = zeros(nCurves,1);
for i = 1:nCurves
    curves{i}(isnan(curves{i}))=0;
    curves{i}(isinf(curves{i}))=0;

    % note: we have to take into consideration the different steps in
    % rValues from curve to curve
    rValues{i} = round(rValues{i},1);
    
    AUC(i) = sum((rValues{i}(2) - rValues{i}(1)) * curves{i});
    
%     maxM(i) = max(curves{i});     % originally used (flawed)
    [~,mI] = max(abs(curves{i}));
    maxM(i) = curves{i}(mI);
    
    initM(i) = curves{i}(rValues{i}==0);
    
    try
        interM(i) = curves{i}(rValues{i}==3);
    catch
        interM(i) = NaN;
    end
    
end

if rValues{i}(1)< 0 
    warning('this definition of AUC is suggested only for +ive rValues (circle of exclusion)')
end

end

