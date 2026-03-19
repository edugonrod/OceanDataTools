function windrose(wdir, wspeed, dirbin, speedbin)
% WINDROSE Classical stacked wind rose
%
% windrose(wdir, wspeed)
% windrose(wdir, wspeed, dirbin)
% windrose(wdir, wspeed, dirbin, speedbin)
%
% INPUT
%   wdir   : wind direction (deg, meteorological convention)
%   wspeed : wind speed
%
% OPTIONAL
%   dirbin   : directional bin size (deg), default = 15
%   speedbin : wind speed bins, default = [0 2 4 6 8 inf]
%
% DESCRIPTION
%   Computes a frequency matrix of wind direction vs wind speed and
%   plots a stacked wind rose in polar coordinates.
%
% EGR + AI 2026

if nargin < 3 || isempty(dirbin)
    dirbin = 15;
end
if nargin < 4 || isempty(speedbin)
    speedbin = [0 2 4 6 8 inf];
end
% remove NaN
ix = ~isnan(wdir) & ~isnan(wspeed);
wdir = wdir(ix);
wspeed = wspeed(ix);
% direction bins
dir_edges = 0:dirbin:360;
ndir = length(dir_edges)-1;
nspeed = length(speedbin)-1;
% frequency matrix
F = zeros(ndir, nspeed);
for i = 1:ndir
    dmask = wdir >= dir_edges(i) & wdir < dir_edges(i+1);
    for j = 1:nspeed
        smask = wspeed >= speedbin(j) & wspeed < speedbin(j+1);
        F(i,j) = sum(dmask & smask);
    end
end
% normalize to %
F = 100 * F / sum(F(:));
% sector centers
theta = deg2rad(dir_edges(1:end-1) + dirbin/2);
% plot
figure
pax = polaraxes;
hold on
colors = lines(nspeed);
colors(1,:) = [0.6 0.8 1]; % azul claro
for i = 1:ndir
    r0 = 0;
    for j = 1:nspeed
        r1 = r0 + F(i,j);
        polarplot([theta(i) theta(i)], [r0 r1], ...
            'Color', colors(j,:), ...
            'LineWidth', 8)
        r0 = r1;
    end
end
pax.ThetaDir = 'clockwise';
pax.ThetaZeroLocation = 'top';
title('Wind Rose')
legendStrings = strings(nspeed,1);
for j = 1:nspeed
    legendStrings(j) = sprintf('%g–%g m/s',speedbin(j),speedbin(j+1));
end
legend(legendStrings,'Location','southoutside')
