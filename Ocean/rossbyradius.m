function Rd = rossbyradius(N, H, lat)
% ROSSBYRADIUS First baroclinic Rossby deformation radius
%
%   Rd = rossbyradius(N, H, lat)
%
% Computes the first baroclinic Rossby deformation radius using the
% approximation:
%
%       Rd = N H / (pi f)
% where
%
%       N   Brunt–Väisälä frequency (s⁻¹)
%       H   vertical scale depth (m)
%       f   Coriolis parameter
%
% INPUT
%   N
%       Brunt–Väisälä frequency (s⁻¹)
%   H
%       Vertical scale depth (m)
%   lat
%       Latitude in degrees
%
% OUTPUT
%   Rd
%       Rossby deformation radius (meters)
%
% DESCRIPTION
%   The Rossby deformation radius represents the horizontal length scale
%   where rotational and buoyancy effects balance. It sets the typical
%   size of mesoscale eddies and baroclinic instabilities.
%
%   Coriolis parameter:
%       f = 2 Ω sin(lat)
%
%   with
%       Ω = 7.2921×10⁻⁵ s⁻¹
%
% EXAMPLES
%
%   % typical mid-latitude values
%   Rd = rossbyradius(1e-3,1000,30)
%
%   % vector latitude
%   lat = -60:60;
%   Rd = rossbyradius(1e-3,1000,lat);
%
% SEE ALSO
%   bruntVaisala
%
% OceanDataTools
% 20160306 EGR + IA help

Omega = 7.2921e-5;
f = 2 * Omega .* sind(lat);
Rd = (N .* H) ./ (pi .* abs(f));

