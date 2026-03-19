function I = areaIntegral(field, lonvec, latvec, mask)
% AREAINTEGRAL Area integral on a regular latitude–longitude grid
%
%   I = areaIntegral(field, lonvec, latvec)
%   I = areaIntegral(field, lonvec, latvec, mask)
%
% Computes the spatial integral of a field defined on a regular
% latitude–longitude grid. Each grid cell is weighted by its physical
% surface area on the Earth.
%
% INPUT
%   field
%       Data array of size:
%           [ny nx]
%           [ny nx nt]
%
%   lonvec
%       Longitude vector (nx)
%
%   latvec
%       Latitude vector (ny)
%
%   mask
%       Optional logical mask (ny × nx)
%
% OUTPUT
%   I
%       Area integral of the field.
%
% DESCRIPTION
%   The area of each grid cell is computed as:
%
%       A = R² cos(lat) dlat dlon
%
%   where
%
%       R    Earth radius (6371 km)
%       lat  latitude
%       dlat latitude spacing
%       dlon longitude spacing
%
%   The result corresponds to the spatial integral:
%
%       I = Σ field × cell_area
%
% EXAMPLES
%
%   % Total heat content proxy
%   H = areaintegral(sst, lon, lat);
%
%   % Time series of integrated chlorophyll
%   H = areaintegral(chl, lon, lat);
%
%   % Masked region
%   H = areaintegral(sst, lon, lat, mask);
%
% SEE ALSO
%   areamean
%
% OceanDataTools
% 20160306 EGR + IA help

if nargin < 4
    mask = [];
end

R = 6371000; % meters
lonvec = lonvec(:);
latvec = latvec(:);
dlon = abs(mean(diff(lonvec)));
dlat = abs(mean(diff(latvec)));
dlon = deg2rad(dlon);
dlat = deg2rad(dlat);
latrad = deg2rad(latvec);

% area weight
A = (R^2) .* cos(latrad) .* dlat .* dlon;

% expand to grid
A = A .* ones(1,length(lonvec));

if ~isempty(mask)
    field(~mask) = NaN;
end

if ndims(field) == 2
    I = nansum(field .* A,'all');
else
    A = repmat(A,1,1,size(field,3));
    I = squeeze(nansum(field .* A,[1 2]));
end
