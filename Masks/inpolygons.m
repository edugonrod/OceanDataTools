function in = inpolygons(x,y,xv,yv)
% INPOLYGONS Perform INPOLYGON tests for multiple NaN-separated polygons.
%
%   in = inpolygons(x,y,xv,yv)
%
% Evaluates whether points lie inside one or more polygons defined by
% NaN-separated vertex vectors. The function applies MATLAB's INPOLYGON
% to each polygon and returns a logical array indicating membership.
%
% INPUTS
%   x, y
%       Coordinates of the query points. They can be:
%
%           • matrices of the same size
%           • vectors defining grid coordinates
%
%       If vectors are provided, they are expanded internally using
%       MESHGRID.
%
%   xv, yv
%       Polygon vertex coordinates stored as vectors. Individual polygons
%       must be separated by NaN values.
%
% OUTPUT
%   in
%       Logical array indicating whether each point lies inside each
%       polygon.
%
%       Size:
%
%           size(x) × number_of_polygons
%
%       where:
%
%           in(:,:,k) = true for points inside polygon k
%
% DESCRIPTION
%   The function splits NaN-separated polygon vectors into individual
%   polygons, ensures consistent vertex orientation, and evaluates
%   INPOLYGON for each polygon separately.
%
%   This is useful when working with datasets containing multiple regions
%   defined in a single NaN-separated coordinate vector.
%
% NOTES
%   • Polygons must be separated by NaN values in XV and YV.
%   • Polygon orientation is corrected internally to ensure consistent
%     results.
%
% EXAMPLE
%   in = inpolygons(x,y,xv,yv);
%
% SEE ALSO
%   INPOLYGON, POLYSPLIT
%
% EGR

if isvector(x) && isvector(y)
    [x, y] = meshgrid(x, y);
end

[xsplit, ysplit] = polysplit(xv(:), yv(:));
[xsplit, ysplit] = poly2ccw(xsplit, ysplit);%corrige poligonos que no son ccw
isCw = ~ispolycw(xsplit, ysplit);%Aqui puse una negacion para que funcione EGR 20170819
np = find(isCw);% Number of polygons

in = zeros([size(x), numel(np)]);
for P = 1:numel(np)
    xp = cell2mat(xsplit(P));
    yp = cell2mat(ysplit(P));
    lonlim = [min(xp) max(xp)];
    latlim = [min(yp) max(yp)];
    idx = x >= lonlim(1) & x <= lonlim(2) & y >= latlim(1) & y <= latlim(2);
    if any(idx(:))
        tmp = false(size(x));
        tmp(idx) = inpolygon(x(idx), y(idx), xp, yp);
        in(:,:,P) = tmp;
    end
end
in = squeeze(logical(in));
