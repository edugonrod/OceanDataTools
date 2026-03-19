function land = (shpfile, lonlims, latlims)
%CROPSHAPEFILE Crop shapefile polygons to a geographic bounding box.
%
%   land = cropShapefile(shpfile, lonlims, latlims)
%
% Extracts the portion of a shapefile contained within the geographic
% limits defined by longitude and latitude ranges.
%
% INPUT
%   shpfile
%       Structure obtained from SHAPEREAD containing polygon geometry.
%
%   lonlims
%       Two-element vector defining longitude limits:
%
%           [lonmin lonmax]
%
%   latlims
%       Two-element vector defining latitude limits:
%
%           [latmin latmax]
%
% OUTPUT
%   land
%       Structure containing cropped polygons that can be directly
%       plotted using MAPSHOW.
%
% DESCRIPTION
%   The function concatenates the polygon coordinates stored in the
%   shapefile structure, trims them using MAPTRIMP, and returns a
%   simplified polygon structure compatible with MAPSHOW.
%
% EXAMPLE
%   S = shaperead('coast.shp');
%
%   land = cropShapefile(S, [-120 -105], [20 35]);
%
%   mapshow(land,'DisplayType','polygon','FaceColor',[0.8 0.8 0.8])
%
% SEE ALSO
%   SHAPEREAD, MAPSHOW, MAPTRIMP
%
% EGR
% 20151020

X = {shpfile.X};
Y = {shpfile.Y};
Longs = cell2mat(X)';
Latgs = cell2mat(Y)';

[Latgs, Longs] = maptrimp(Latgs, Longs, latlims, lonlims);
land = struct('Geometry','Polygon', 'X', Longs, 'Y', Latgs, ...
    'BoundingBox', [min(Longs), min(Latgs); max(Longs), max(Latgs)]);


