function W = areaWeights(lonvec, latvec)
% areaWeights Area weights for regular latitude–longitude grids
%
%   W = areaWeights(lonvec, latvec)
%
% Computes the physical area of each grid cell on a regular latitude–
% longitude grid. The weights correspond to the surface area of each
% cell on a spherical Earth.
%
% INPUT
%   lonvec
%       Longitude vector (nx)
%
%   latvec
%       Latitude vector (ny)
%
% OUTPUT
%   W
%       Matrix of size [ny nx] containing the area of each grid cell.
%       Units: square meters.
%
% DESCRIPTION
%   The area of each grid cell is approximated as
%
%       A = R² cos(lat) dlat dlon
%
%   where
%
%       R    Earth radius (6371000 m)
%       lat  latitude
%       dlat latitude spacing (radians)
%       dlon longitude spacing (radians)
%
%   This approximation is accurate for regular latitude–longitude grids.
%
%   The resulting matrix can be used to compute:
%
%       • area-weighted means
%       • spatial integrals
%       • weighted statistics
%
% EXAMPLES
%
%   % compute weights
%   W = areaWeights(lon,lat);
%
%   % weighted mean
%   m = sum(field .* W,'all') ./ sum(W,'all');
%
%   % spatial integral
%   I = sum(field .* W,'all');
%
% SEE ALSO
%   areamean, areaintegral
%
% OceanDataTools
% 20160306 EGR + IA help

R = 6371000; % Earth radius (m)
lonvec = lonvec(:);
latvec = latvec(:);
% grid spacing
dlon = deg2rad(mean(diff(lonvec)));
dlat = deg2rad(mean(diff(latvec)));
latrad = deg2rad(latvec);

% area per latitude band
A = (R^2) .* cos(latrad) .* dlat .* dlon;

% expand to full grid
W = A .* ones(1,length(lonvec));

