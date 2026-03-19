function polys = drawgeopolygons(np)
%DRAWGEOPOLYGONS Draw geographic polygons interactively.
%
%   POLYS = DRAWGEOPOLYGONS(NP) allows the user to interactively draw one
%   or more polygons on the current axes. The polygons are defined by
%   clicking on the map and are returned as NaN-separated longitude and
%   latitude coordinates.
%
%   NP specifies the number of polygons to draw. Default is 1.
%
%   Input
%       NP      Number of polygons to draw interactively.
%
%   Output
%       POLYS   Nx2 matrix containing polygon coordinates in the form
%               [longitude latitude]. Individual polygons are separated
%               by rows of NaNs.
%
%   Notes
%       • The function requires a georeferenced map (longitude, latitude)
%         already displayed in the current axes.
%       • Axis limits are temporarily expanded to allow drawing near the
%         edges of the map.
%       • Polygons are closed automatically by repeating the first vertex.
%       • Temporary interactive ROI objects are removed after drawing.
%
%   Example
%       imagesc(lon, lat, data)
%       axis xy
%       polys = drawgeopolygons(2);
%
%   See also DRAWPOLYGON, GCA, AXIS
%
%   EGR 2026

if nargin < 1
    np = 1;
end

ax = gca;

% Get current axis limits (works for any map type)
xlims = xlim(ax);
ylims = ylim(ax);

xMin = xlims(1);
xMax = xlims(2);
yMin = ylims(1);
yMax = ylims(2);

% Save hold state
holdState = ishold(ax);

% Expand limits temporarily (5%)
xPad = 0.05 * (xMax - xMin);
yPad = 0.05 * (yMax - yMin);
axis(ax, [xMin-xPad, xMax+xPad, yMin-yPad, yMax+yPad]);
hold(ax,'on');

lonpoly = [];
latpoly = [];

hpolys = cell(np,1);   % ← IMPORTANTE

for k = 1:np
    title(ax, sprintf('Draw polygon %d of %d', k, np), 'FontSize', 12);
    hpolys{k} = drawpolygon(ax);
    polipts = hpolys{k}.Position;
    lonpoly = [lonpoly; polipts(:,1); polipts(1,1); NaN];
    latpoly = [latpoly; polipts(:,2); polipts(1,2); NaN];
end

delete([hpolys{:}])   % elimina TODOS los ROI

% Restore axis and state
axis(ax, [xMin xMax yMin yMax]);
title(ax,'');

if ~holdState
    hold(ax,'off');
end

polys = [lonpoly, latpoly];
