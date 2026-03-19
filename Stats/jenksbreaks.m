function [breaks, k, GF] = jenksbreaks(x, k)
% JENKSBREAKS Jenks natural breaks classification with optional auto-k.
%
%   breaks = jenksbreaks(x,k)
%   [breaks,k,GF] = jenksbreaks(x)
%
% Computes optimal class breaks using the Jenks Natural Breaks method.
% If k is omitted, the function automatically determines the number of
% classes by maximizing the Goodness of Variance Fit (GVF).
%
% INPUT
%   x : numeric vector
%       Data to classify.
%
%   k : number of classes (optional)
%
% OUTPUT
%   breaks
%       Class boundaries (length k+1).
%
%   k
%       Number of classes used.
%
%   GF
%       Goodness of variance fit (0–1).
%
% DESCRIPTION
%   Jenks Natural Breaks minimizes variance within classes while
%   maximizing variance between classes.
%
%   If k is not provided, the algorithm increases the number of classes
%   until the improvement in GVF becomes small (< 0.05).
%
% EXAMPLE
%   x = randn(1000,1);
%   [breaks,k,GF] = jenksbreaks(x);
%
%   histogram(x)
%   hold on
%   xline(breaks(2:end-1),'r')
%
% REFERENCES
%   Jenks, G.F. (1967)
%   The Data Model Concept in Statistical Mapping.
%  EGR 2026 + IA

x = x(:);
x = x(~isnan(x));
x = sort(x);
n = numel(x);
if nargin < 2
    auto = true;
    kmax = min(10, floor(n/5));
else
    auto = false;
    kmax = k;
end

bestGF = 0;
bestBreaks = [];
bestK = 2;
for kk = 2:kmax
    [breaks_tmp,GF_tmp] = jenks_core(x,kk);
    if auto
        if kk > 2
            if (GF_tmp - bestGF) < 0.05
                break
            end
        end
    end
    bestGF = GF_tmp;
    bestBreaks = breaks_tmp;
    bestK = kk;
end
breaks = bestBreaks;
k = bestK;
GF = bestGF;
end


function [breaks, GF] = jenks_core(x,k)
n = numel(x);
lower = zeros(n+1,k+1);
var = inf(n+1,k+1);
for i=1:k+1
    lower(1,i)=1;
    var(1,i)=0;
end

for i=2:n+1
    var(i,1)=0;
end

for l=2:n+1
    s1=0; s2=0; w=0;
    for m=1:l-1
        i=l-m;
        val=x(i);
        s1=s1+val;
        s2=s2+val^2;
        w=w+1;
        v=s2-(s1^2)/w;
        if i~=1
            for j=2:k+1
                if var(l,j) >= v + var(i,j-1)
                    lower(l,j)=i;
                    var(l,j)=v + var(i,j-1);
                end
            end
        end
    end
    lower(l,1)=1;
    var(l,1)=v;
end

breaks=zeros(k+1,1);
breaks(k+1)=x(end);
breaks(1)=x(1);
count=n+1;
for j=k+1:-1:2
    id=lower(count,j)-1;
    breaks(j-1)=x(id);
    count=lower(count,j);
end

SDAM=sum((x-mean(x)).^2);
SDCM=var(n+1,k+1);
GF=(SDAM-SDCM)/SDAM;
end
