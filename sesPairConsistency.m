function [consistCurve, radiusAxis] = sesPairConsistency(X, Y, demo, option, radiusR)
% computes the consistency curve for a session pair. It also returns the
% values of radius used to produce the curve.


if nargin < 5 || isempty(radiusR)
    radiusR =0;
end


if length(size(X))>2 || min(size(X))~=1
    error('X is not a vector')
end

if length(size(Y))>2 || min(size(Y))~=1
    error('Y is not a vector')
end

% check whether they are equal in length
if length(X) ~= length(Y) || length(X)<20
    error('unequal or very small dataset')
end

if size(X,2)>1
    X= X';
end

if size(Y,2)>1
    Y= Y';
end

% find the center of mass
% c = [median(X) median(Y)];
c = [0 0];

% set of coupled datapoints
S0 = [X Y];
S = S0;

% prepare the vector of radius values
if length(radiusR) == 2 
    
    if max([std(X) std(Y)]) > 1
        step = 0.3;
    else
        step = 0.2;
    end
    r_bound = max(abs(radiusR)) + step;
    r_ = 0 : step :r_bound;
    r = [ -r_(end:-1: 2) r_(1:end) ];
    r = r(r>=radiusR(1)-0.99*step & r<=radiusR(2));
    
    D = pdist2(c, S);
    N = length(D);
    for i = length(r): -1 : length(r)/2
        if sum(D>r(i)) > 0.02*N
            break
        else
            r(i)=[];
        end
    end

else
    r = radiusR;
end


% allocate vector for the measure results
m = zeros(size(r));

if demo 
    figure(10)
end

% it should always run through the values of r from low to high
for i = 1:length(r)
    
    if demo
        % demonstration through visualisation
        rectC = [c(1)-abs(r(i)) c(2)-abs(r(i)) 2*abs(r(i)) 2*abs(r(i))];
        
        subplot(1,2,1)
        hold off
        scatter(S0(:,1), S0(:,2), ...
                        'filled', ...
                        'MarkerEdgeColor','none',   ...
                        'MarkerFaceAlpha',0.6 );
        hold on 
        plot([-1 1], [0 0], 'k--')
        plot([0 0], [-1 1], 'k--')
        if r(i)>=0
            rectangle('Position', rectC, 'EdgeColor', 'r', 'FaceColor',[1 1 1 0.65],'Curvature',[1 1]);
        else
            rectangle('Position', rectC, 'EdgeColor', 'none', 'FaceColor',[1 0 0 0.65],'Curvature',[1 1]);
        end
        axis equal
    end
    
    if r(i)==0
        S = S0;
    end
    
    D = pdist2(c, S);  
    if r(i) < 0
        S = S( D < abs(r(i)) , :);
    else
        S = S( D > r(i) , :);
    end
    
    N = size(S,1);
    
    switch option
        case 1
            % Typical R2 definition
            m(i) = 1 - sum((S(:,1) - S(:,2)).^2)/sum((mean(S(:,2)) - S(:,2)).^2);
        case 2
            % Alternative - this is the average residual
            m(i) = sum(abs(S(:,1) - S(:,2)))/ N;
        case 3
            % alternative correlation measure
            cov0= (sum(S(:,1) .* S(:,2)))/N;
            std0x = sqrt( sum(S(:,1).^2)/N );
            std0y = sqrt( sum(S(:,2).^2)/N );
            m(i) = atanh(cov0/(std0x*std0y));   % applying Fisher transform
    end
    
    
    
    if demo
        % demonstration through visualisation
        
        subplot(1,2,1)
        title(['including ' num2str(N) ' points'])
        plot([-3 3], [-3 3])
        
        subplot(1,2,2)
        hold off
        plot(r(1:i), m(1:i))
        xlim([r(1)-0.1 r(end)+0.1])
        
        if demo==2
            pause(0.2)
        end
        
    end
    
end


if demo
    subplot(1,2,2)
    hold on
    plot([r(1) r(end)], [0 0], ':' )
    
    if all(r<0)
        xlabel('circle of radius (inclusion)')
    elseif all(r>=0)
        xlabel('circle of radius (exclusion)')
    else
        xlabel({'radius of circle'; 'inclusion  -0-  exclusion'})
    end
end

consistCurve = m;
radiusAxis = r;

end

