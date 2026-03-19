function [hlin, htop, hbot] = shadeanomaly(x, y, varargin)
%SHADEANOMALY  Plots anomalies as shaded regions above/below a threshold.
%
%   SHADEANOMALY(x, y) plots a line with red fill above zero and blue fill below zero.
%
%   SHADEANOMALY(..., 'thresh', T) specifies the threshold(s). T can be a scalar
%   or a two-element vector [low high]. Defaults to 0.
%
%   SHADEANOMALY(..., 'topcolor', C1, 'bottomcolor', C2) sets the fill colors for
%   values above and below the threshold. Colors can be RGB triplets or short names.
%
%   [hlin, htop, hbot] = SHADEANOMALY(...) returns handles to the line and shaded patches.
%
%   This function works with numeric or datetime x-values.
%
%   Example:
%       t = datetime(2023,1,1) + calmonths(0:11);
%       y = sin(2*pi*(0:11)/12) + 0.1*randn(1,12);
%       shadeanomaly(t, y, 'thresh', 0, 'topcolor', [1 0 0], 'bottomcolor', [0 0 1]);

% Author: Adapted and simplified by egonzale@cicese.mx, EGR 2025
% Based on original idea by Chad A. Greene

% ------------------ Error checks ------------------
narginchk(2, inf);
assert(numel(x) == numel(y), 'x and y must have the same number of elements.');
assert(isvector(x), 'x and y must be vectors.');

% ------------------ Default values ------------------
thresh = 0;
topcolor = [0.7848 0.4453 0.3341];     % Reddish
bottomcolor = [0.3267 0.5982 0.7311];  % Bluish

% ------------------ Parse inputs ------------------
for i = 1:2:length(varargin)
    switch lower(varargin{i})
        case {'thresh', 'threshold'}
            thresh = varargin{i+1};
        case 'topcolor'
            topcolor = varargin{i+1};
        case 'bottomcolor'
            bottomcolor = varargin{i+1};
    end
end

% ------------------ Prepare data ------------------
x = x(:);
y = y(:);

% Convert datetime to datenum if necessary
if isa(x, 'datetime')
    xdt = x;
else
    xdt = datetime(x, 'ConvertFrom', 'datenum');
end

% Handle threshold(s)
if isscalar(thresh)
    lo = thresh; hi = thresh;
else
    thresh = sort(thresh);
    lo = thresh(1);
    hi = thresh(2);
end

% Prepare top fill
ytop = y;
ytop(y <= hi) = hi;
xtop = [xdt; flipud(xdt)];
ytop = [ytop; flipud(repmat(hi, size(y)))];

% Prepare bottom fill
ybot = y;
ybot(y >= lo) = lo;
xbot = [xdt; flipud(xdt)];
ybot = [ybot; flipud(repmat(lo, size(y)))];

% ------------------ Plot ------------------
hld = ishold;
hold on;

htop = fill(xtop, ytop, topcolor, 'EdgeColor', 'none');
hbot = fill(xbot, ybot, bottomcolor, 'EdgeColor', 'none');
hlin = plot(xdt, y, 'k', 'LineWidth', 1.2);

if ~hld
    hold off;
end

% Clear outputs if not requested
if nargout == 0
    clear hlin htop hbot
end
end
