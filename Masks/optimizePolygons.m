function polys = optimizePolygons(x, y, tolerance)
% OPTIMIZEPOLYGONS Optimize NaN-separated polygons for fast map plotting.
%
%   polys = optimizePolygons(x, y)
%   polys = optimizePolygons(x, y, tolerance)
%
% Converts coordinate vectors containing NaN-separated polygons into an
% optimized structure array suitable for fast plotting with MAPSHOW and
% similar MATLAB mapping functions.
%
% The function reorganizes polygon vertices and optionally simplifies the
% geometry to significantly reduce rendering time when plotting large or
% complex polygon datasets (e.g., GSHHG coastlines).
%
% INPUTS
%   x, y
%       Coordinate vectors containing polygon vertices. Individual
%       polygons must be separated by NaN values.
%
%   tolerance
%       Simplification tolerance passed to REDUCEPOLY (optional).
%
%       tolerance = 0 (default) → no simplification
%       tolerance > 0           → polygon simplification applied
%
% OUTPUT
%   polys
%       Structure array containing optimized polygons with fields:
%
%           .Geometry
%               Geometry type ('Polygon')
%
%           .X
%               X-coordinates of the polygon vertices
%
%           .Y
%               Y-coordinates of the polygon vertices
%
%           .BoundingBox
%               Bounding box of the polygon:
%               [minX minY; maxX maxY]
%
% DESCRIPTION
%   Large polygon datasets (such as high-resolution coastlines) can be slow
%   to render in MAPSHOW when stored as long NaN-separated vectors. This
%   function:
%
%       • splits NaN-separated polygons into individual elements
%       • optionally simplifies polygon geometry using REDUCEPOLY
%       • returns a struct array optimized for fast map visualization
%
%   These steps can significantly improve rendering performance when
%   plotting large geographic datasets.
%
% EXAMPLE
%   polys = optimizePolygons(x, y, 0.01);
%   mapshow(polys)
%
% SEE ALSO
%   MAPSHOW, REDUCEPOLY
%
% EGR

if nargin < 3
    tolerance = 0;  % No simplification by default
end

% Validate input sizes
if numel(x) ~= numel(y)
    error('Input vectors x and y must be the same length.');
end

% Find the start and end indices of each polygon (vectorized)
x = x(:);
y = y(:);
nanMask = isnan(x) | isnan(y);
notNan = ~nanMask;
transitions = diff([false; notNan; false]);
ini = find(transitions == 1);   % Starts of polygons
fin = find(transitions == -1) - 1;  % Ends of polygons
n = numel(ini);

% Preallocate polygon struct array
polys(n,1).Geometry = '';
polys(n,1).X = [];
polys(n,1).Y = [];
polys(n,1).BoundingBox = [];

% Fill in the struct array
for P = 1:n
    lons = x(ini(P):fin(P));
    lats = y(ini(P):fin(P));

    % Apply simplification if tolerance > 0
    if tolerance > 0
        [lons, lats] = reducepoly(lons, lats, tolerance);
    end

    polys(P).X = lons(:)';  % Ensure row vectors
    polys(P).Y = lats(:)';
    polys(P).Geometry = 'Polygon';
    polys(P).BoundingBox = [min(lons), min(lats); max(lons), max(lats)];
end
end
