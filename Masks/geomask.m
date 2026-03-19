function mask = geomask
%GEOMASK Create a mask from an interactively drawn geographic polygon.
%
%   MASK = GEOMASK allows the user to draw a polygon interactively on the
%   current map and returns a mask based on that polygon.
%
%   The function requires that an image referenced by longitude and
%   latitude coordinates is already displayed in the current axes. The
%   polygon is drawn interactively and the resulting mask has the same
%   size as the displayed grid.
%
%   Output
%       MASK    Matrix the same size as the displayed data grid. Values
%               inside the drawn polygon are set to NaN and values outside
%               are zero.
%
%   Notes
%       • The function searches for the image object currently displayed
%         in the axes to obtain its longitude and latitude coordinates.
%       • Axis limits are temporarily expanded to allow drawing near the
%         edges of the map.
%       • The polygon is drawn interactively using IMPOLY.
%
%   Example
%       imagesc(lon, lat, data)
%       axis xy
%       mask = geomask;
%
%       maskedData = data + mask;
%
%   See also IMPOLY, INPOLYGON
%
%   EGR 20250306

fig = get(groot,'CurrentFigure');
if isempty(fig)
    return;
end
holdState = ishold(ax);  % guarda el estado original

if ~holdState
    hold(ax,'on');       % activar hold solo si estaba apagado
end

hImg = findobj(gca, 'Type', 'Image');
lons = hImg.XData;  % [xMin xMax]
lats = hImg.YData;  % [yMin yMax]
[Lon, Lat] = meshgrid(lons, lats);

% límites actuales
xMin = min(lons(:));
xMax = max(lons(:));
yMin = min(lats(:));
yMax = max(lats(:));
% Calcular márgenes del 7.5%
xPad = 0.05 * (xMax - xMin);
yPad = 0.05 * (yMax - yMin);
% Nuevos límites
xLim = [xMin - xPad, xMax + xPad];
yLim = [yMin - yPad, yMax + yPad];
axis([xLim yLim]);

hold on
TH = title('Make the polygon', 'FontSize', 18);
poli = impoly;
polipts = getPosition(poli);
TH.delete% Delete the title
axis([xMin, xMax, yMin, yMax]);
delete(poli)

%Crea mascara
in = inpolygon(Lon, Lat, polipts(:,1), polipts(:,2));
mask = zeros(size(in));
mask(in) = nan;

if ~holdState
    hold(ax,'off');
end
