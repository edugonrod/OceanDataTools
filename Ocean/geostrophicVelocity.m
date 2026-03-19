function [ug, vg] = geostrophicVelocity(ssh, lonvec, latvec)
% geostrophicVelocity Geostrophic velocity from sea surface height
%
%   [ug, vg] = geostrophicVelocity(ssh, lonvec, latvec)
%
% Computes geostrophic velocities from sea surface height (SSH) gradients
% on a regular latitude–longitude grid.
%
% INPUT
%   ssh
%       Sea surface height field [ny nx] or [ny nx nt] (meters)
%
%   lonvec
%       Longitude vector (nx)
%
%   latvec
%       Latitude vector (ny)
%
% OUTPUT
%   ug
%       Zonal geostrophic velocity (m s⁻¹)
%
%   vg
%       Meridional geostrophic velocity (m s⁻¹)
%
% DESCRIPTION
%   Geostrophic velocities are computed as:
%
%       ug = -(g/f) ∂η/∂y
%       vg =  (g/f) ∂η/∂x
%
%   where
%
%       η = sea surface height
%       g = gravitational acceleration (9.81 m s⁻²)
%       f = Coriolis parameter
%
%   Horizontal gradients are computed using GEOGRADIENT.
%
% NOTES
%   Velocities are undefined near the equator where f → 0.
%
% EXAMPLE
%
%   [ug,vg] = geostrophicVelocity(adt,lon,lat);
%
% SEE ALSO
%   geogradient
%
% OceanDataTools
% 20160306 EGR + IA help

g = 9.81;

% gradients
[dssh_dx, dssh_dy] = geogradient(ssh, lonvec, latvec);

% Coriolis parameter
Omega = 7.2921e-5;
f = 2 * Omega .* sind(latvec(:));

% expand f to grid
f = f .* ones(1,length(lonvec));
f(abs(f) < 1e-10) = NaN;

% geostrophic velocities
ug = -(g ./ f) .* dssh_dy;
vg =  (g ./ f) .* dssh_dx;

