function W = okuboweiss(u, v, lonvec, latvec)
% OKUBOWEISS Okubo–Weiss parameter on a latitude–longitude grid
%
%   W = okuboweiss(u, v, lonvec, latvec)
%
% Computes the Okubo–Weiss parameter used to distinguish vorticity-
% dominated regions (eddies) from strain-dominated regions.
%
% INPUT
%   u
%       Zonal velocity component (m s⁻¹) [ny nx] or [ny nx nt]
%
%   v
%       Meridional velocity component (m s⁻¹) [ny nx] or [ny nx nt]
%
%   lonvec
%       Longitude vector (nx)
%
%   latvec
%       Latitude vector (ny)
%
% OUTPUT
%   W
%       Okubo–Weiss parameter (s⁻²)
%
% DESCRIPTION
%   The Okubo–Weiss parameter is defined as:
%
%       W = s_n² + s_s² − ζ²
%
%   where
%
%       ζ   = relative vorticity
%       s_n = normal strain
%       s_s = shear strain
%
%   with
%
%       ζ  = ∂v/∂x − ∂u/∂y
%       s_n = ∂u/∂x − ∂v/∂y
%       s_s = ∂v/∂x + ∂u/∂y
%
%   Regions where W is negative are typically associated with coherent
%   vortices (eddies), while positive values indicate strain-dominated flow.
%
% EXAMPLE
%
%   [ug,vg] = geostrophicvelocity(ssh,lon,lat);
%   W = okuboweiss(ug,vg,lon,lat);
%
% SEE ALSO
%   relativevorticity, geogradient
%
% OceanDataTools
% 20160306 EGR + IA help

% velocity gradients
[dudx, dudy] = geogradient(u, lonvec, latvec);
[dvdx, dvdy] = geogradient(v, lonvec, latvec);

% relative vorticity
zeta = dvdx - dudy;

% strain components
sn = dudx - dvdy;
ss = dvdx + dudy;

% Okubo–Weiss parameter
W = sn.^2 + ss.^2 - zeta.^2;
W(~isfinite(u) | ~isfinite(v)) = NaN;
