function zeta = relativevorticity(u, v, lonvec, latvec)
% RELATIVEVORTICITY Relative vorticity on a latitude–longitude grid
%
%   zeta = relativevorticity(u, v, lonvec, latvec)
%
% Computes the vertical component of relative vorticity from horizontal
% velocity components on a regular latitude–longitude grid.
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
%   zeta
%       Relative vorticity (s⁻¹)
%
% DESCRIPTION
%   Relative vorticity is defined as:
%
%       ζ = ∂v/∂x − ∂u/∂y
%
%   where
%
%       u = zonal velocity
%       v = meridional velocity
%
%   Spatial derivatives are computed using GEOGRADIENT, which accounts for
%   the variable grid spacing of latitude–longitude coordinates.
%
% EXAMPLE
%
%   zeta = relativevorticity(u, v, lon, lat);
%
% SEE ALSO
%   geogradient, geostrophicvelocity
%
% OceanDataTools
% 20160306 EGR + IA help


% dimensiones
sz = size(u);
if numel(sz) == 2
    % ---- caso 2D ----
    dvdx = geogradient(v, lonvec, latvec);
    [~, dudy] = geogradient(u, lonvec, latvec);
    zeta = dvdx - dudy;

else
    % ---- caso 3D ----
    nt = sz(3);
    zeta = nan(sz);
    for it = 1:nt
        dvdx = geogradient(v(:,:,it), lonvec, latvec);
        [~, dudy] = geogradient(u(:,:,it), lonvec, latvec);
        zeta(:,:,it) = dvdx - dudy;
    end
end

% máscara NaN
zeta(~isfinite(u) | ~isfinite(v)) = NaN;