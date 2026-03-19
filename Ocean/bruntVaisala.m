function N2 = bruntVaisala(P, T, S, n, method, params)
% BRUNTVAISALA Brunt–Väisälä frequency squared (N^2) with optional smoothing
%
%   N2 = bruntVaisala(P,T,S)
%   N2 = bruntVaisala(P,T,S,n)
%   N2 = bruntVaisala(P,T,S,n,method)
%   N2 = bruntVaisala(P,T,S,n,method,params)
%
% Computes the Brunt–Väisälä frequency squared (N^2) from CTD profiles
% using the TEOS-10 GSW toolbox and optionally applies smoothing to
% reduce instrumental noise.
%
% INPUT
%   P : pressure [dbar]
%   T : temperature [°C] (ITS-90)
%   S : Absolute Salinity [g/kg]
%
%   n : number of Hanning passes (default = 6)
%
%   method : smoothing method
%       'hanning' (default)
%       'sgolay'
%       'median'
%
%   params : optional parameters
%       sgolay → [window order] (default [11 2])
%       median → window (default 5)
%
% OUTPUT
%   N2 : Brunt–Väisälä frequency squared [s^-2]
%
% DESCRIPTION
%   The Brunt–Väisälä frequency measures the stability of a stratified
%   water column. It is computed using TEOS-10:
%
%       N^2 = -(g/ρ) dρ/dz
%
%   The GSW function gsw_Nsquared is used internally. The result is
%   optionally smoothed to reduce noise commonly present in CTD data.
%
% REQUIREMENTS
%   TEOS-10 Gibbs SeaWater (GSW) toolbox
%
% EXAMPLE
%   N2 = bruntVaisala(P,T,S);
%
%   plot(N2,P(1:end-1))
%   set(gca,'ydir','reverse')
%
% SEE ALSO
%   gsw_Nsquared, sgolayfilt, medfilt1
%
% EGR 2016–2025
% defaults
if nargin < 4 || isempty(n)
    n = 6;
end
if nargin < 5 || isempty(method)
    method = 'hanning';
end
if nargin < 6
    params = [];
end
method = lower(method);

% validation
validateattributes(P,{'numeric'},{'vector','nonempty'})
validateattributes(T,{'numeric'},{'vector','nonempty'})
validateattributes(S,{'numeric'},{'vector','nonempty'})
validateattributes(n,{'numeric'},{'scalar','integer','nonnegative'})
P = P(:);
T = T(:);
S = S(:);
if any(diff(P)<=0)
    error('P must be strictly increasing.')
end
if ~isequal(numel(P),numel(T),numel(S))
    error('P, T and S must have the same length.')
end
if ~ismember(method,{'hanning','sgolay','median'})
    error('method must be: hanning, sgolay or median')
end

% compute N²
[N2,~] = gsw_Nsquared(S,T,P);
% smoothing
switch method
    case 'hanning'
        x = [N2(1); N2];
        for k = 1:n
            y = x;
            y(1) = mean(x(1:2));
            for i = 2:length(x)-1
                y(i) = 0.25*(x(i-1) + x(i+1)) + 0.5*x(i);
            end
            y(end) = mean(x(end-1:end));
            x = y;
        end
        N2 = x(2:end);
    case 'sgolay'
        if isempty(params)
            window = 11;
            order  = 2;
        else
            window = params(1);
            order  = params(2);
        end
        if mod(window,2)==0
            error('sgolay window must be odd')
        end

        if window <= order
            error('sgolay window must be > order')
        end
        idx = isfinite(N2);
        if sum(idx) >= window
            N2(idx) = sgolayfilt(N2(idx),order,window);
        end
    case 'median'
        if isempty(params)
            window = 5;
        else
            window = params(1);
        end
        N2 = medfilt1(N2,window,'truncate');
end
% clean output
N2(~isfinite(N2)) = NaN;
