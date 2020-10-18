function myScatterBoxPlot(groupLabels, M1, M2)
% combination of boxplot and scatter plot
%
% M1 and M2 are considered to be organized in groups in columns
% They need to have the same number of columns

if nargin == 3
    if size(M1,2) ~= size(M2,2)
        error('The number of columns should be the same')
    end
end


nCol = size(M1,2);

if nargin == 2
    X = [1:nCol]';
    boxplot(M1, 'positions', X, 'Widths', 0.3, 'labels', groupLabels)
    hold on
    for i=1:nCol
        scatter(X(i)*ones(size(M1(:,i)))-0.2+0.4*rand(size(M1(:,i))), M1(:,i), 'g.')
    end
    maxMedian = max(median(M1));
    minMedian = min(median(M1));
    minmax = maxMedian-minMedian;
    meanV = mean([maxMedian minMedian]);
    
    % set the ylim such that it focuses mostly around the medians
    % ignoring outliers
    try 
        if min(min(M1))>0
            ylim([0 meanV+10*(maxMedian-meanV)])
        else
            if max(max(M1))<0
                ylim([meanV-00*(meanV-minMedian) 0])
            else
                ylim([meanV-10*(meanV-minMedian) meanV+10*(maxMedian-meanV)])
            end
        end
    catch
    end
end

if nargin == 3
    X1 = 1.5*[1:nCol]-0.2;
    X2 = 1.5*[1:nCol]+0.2;
    boxplot(M1, 'positions', X1, 'Widths',0.3, 'labels', groupLabels)
    hold on
    boxplot(M2, 'positions', X2, 'Widths',0.3, 'labels', groupLabels)
    for i=1:nCol
        scatter(X1(i)*ones(size(M1(:,i)))-0.1+0.2*rand(size(M1(:,i))), M1(:,i), 'g.')
        scatter(X2(i)*ones(size(M2(:,i)))-0.1+0.2*rand(size(M2(:,i))), M2(:,i), [], [255 215 0]/255, '.')
    end
    maxMedian = max(median(M1));
    maxMedian = max([median(M2) maxMedian]);
    minMedian = min(median(M1));
    minMedian = min([median(M1) minMedian]);
    minmax = maxMedian-minMedian;
    meanV = mean([maxMedian minMedian]);

    % set the ylim such that it focuses mostly around the medians
    % ignoring outliers    
    try
        if min(min(M1))>0 && min(min(M2))>0
            ylim([0 meanV+10*(maxMedian-meanV)])
        else
            if max(max(M1))<0 && max(max(M2))<0
                ylim([meanV-10*(meanV-minMedian) 0])
            else
                ylim([meanV-10*(meanV-minMedian) meanV+10*(maxMedian-meanV)])
            end
        end
    catch
    end
end

end

