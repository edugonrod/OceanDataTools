function land = gshhgland(lonlims, latlims, res)
% GSHHGLAND Extract land polygons from the GSHHG shoreline database.
%
%   land = gshhgland(lonlims, latlims)
%   land = gshhgland(lonlims, latlims, res)
%
% Returns land polygons from the GSHHG (Global Self-consistent Hierarchical
% High-resolution Geography) shoreline database within the specified
% longitude and latitude limits.
%
% INPUTS
%   lonlims
%       Two-element vector with longitude limits [min max].
%
%   latlims
%       Two-element vector with latitude limits [min max].
%
%   res
%       Resolution of the GSHHG dataset to use:
%
%           'c'  crude
%           'l'  low
%           'i'  intermediate
%           'h'  high
%           'f'  full (default)
%
% OUTPUT
%   land
%       Structure array containing land polygons compatible with
%       MAPSHOW. Each element contains:
%
%           .Geometry     'Polygon'
%           .X            longitude coordinates
%           .Y            latitude coordinates
%           .BoundingBox  polygon bounding box
%
% DESCRIPTION
%   The function reads shoreline polygons from the GSHHG database using
%   the selected resolution and extracts only Level 1 features (land).
%   Polygons are trimmed to the requested geographic limits using
%   MAPTRIMP and returned in a format suitable for plotting with MAPSHOW.
%
% REQUIREMENTS
%   • The GSHHG shoreline database must be available in the MATLAB path.
%   • Requires the function GSHHS for reading binary shoreline files.
%
% EXAMPLE
%   lonlims = [-120 -100];
%   latlims = [15 35];
%
%   land = gshhgland(lonlims,latlims,'i');
%
%   figure
%   mapshow(land)
%
% NOTES
%   The function extracts only Level 1 polygons (land masses). Lakes and
%   other hierarchical shoreline levels are ignored.
%
% EGR 201206
% egonzale@cicese.mx

if nargin == 2
    res = 'f'; %default
end

resfile = ['gshhs_', res, '.b'];
S = gshhs(resfile, latlims, lonlims);
nvs = [S.Level];
Sn = S(nvs==1); % 1 = land
Longs = cell2mat({Sn.Lon})';
Latgs = cell2mat({Sn.Lat})';
[Latgs, Longs] = maptrimp(Latgs, Longs, latlims, lonlims);

valid = find(~isnan(Latgs));
ini = valid(logical([1; diff(valid) > 1]));
fin = valid(logical([diff(valid)>1; 1]));
n = numel(ini);
land(n,1).Geometry = ''; % Preallocate struct array
land(n,1).X = [];
land(n,1).Y = [];
land(n,1).BoundingBox = [];
for P = 1:n
    lons = Longs(ini(P):fin(P));
    lats = Latgs(ini(P):fin(P));
    land(P).X = [lons(:); nan]'; %separa poligonos con nans
    land(P).Y = [lats(:); nan]';
    land(P).Geometry = 'Polygon';
    land(P).BoundingBox = [min(lons), min(lats); max(lons), max(lats)];
end

