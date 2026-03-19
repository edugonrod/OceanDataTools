function [curlTau, ekmanPump, lonC, latC] = windStressCurl(xi, yi, u, v)
% windStressCurl Wind stress curl and Ekman pumping from wind vectors
%
%   [curlTau, ekmanPump, lonC, latC] = windStressCurl(xi, yi, u, v)
%
% Computes wind stress from wind velocity and derives the wind stress curl
% and Ekman pumping velocity on a geographic grid.
%
% INPUT
%   xi, yi
%       Longitude and latitude coordinates. Can be vectors or matrices.
%
%   u, v
%       Zonal and meridional wind velocity components (m/s).
%       Must have the same dimensions as xi and yi.
%
% OUTPUT
%   curlTau
%       Curl of wind stress (N m^-3)
%
%   ekmanPump
%       Ekman pumping velocity (m s^-1)
%       Positive values indicate upwelling.
%       Negative values indicate downwelling.
%
%   lonC, latC
%       Coordinates of the centered grid where curl is evaluated.
%
% DESCRIPTION
%   The function performs the following steps:
%
%       1. Computes wind speed magnitude.
%       2. Estimates drag coefficient using Large & Pond (1981).
%       3. Computes wind stress components.
%       4. Calculates wind stress curl on a spherical Earth.
%       5. Computes Ekman pumping velocity.
%
%   The curl is computed using geographic derivatives:
%
%       curl(tau) = d(tau_y)/dx - d(tau_x)/dy
%
%   where distances are converted from degrees to meters.
%
% REFERENCES
%   Gill, A. E. (1982), Atmosphere-Ocean Dynamics.
%   Large, W. G. & Pond, S. (1981), J. Phys. Oceanogr.
%   Trenberth, K. E. et al. (1990), J. Phys. Oceanogr.
%
% EGR

% Grid handling
if isvector(xi) && isvector(yi)
    [xi, yi] = meshgrid(xi, yi);
end
validateattributes(xi, {'numeric'}, {'2d'})
validateattributes(yi, {'numeric'}, {'size', size(xi)})
validateattributes(u,  {'numeric'}, {'size', size(xi)})
validateattributes(v,  {'numeric'}, {'size', size(xi)})

% Constants
rho_air = 1.2;          % kg m^-3
rho_w   = 1025;         % kg m^-3
omega   = 7.292115e-5;  % Earth rotation (s^-1)
R       = 6371000;      % Earth radius (m)

% Wind stress (Large & Pond 1981)
wmag = hypot(u,v);
cd = zeros(size(wmag));
cd(wmag < 1) = 0.00218;
idx = wmag > 1 & wmag <= 3;
cd(idx) = (0.62 + 1.56 ./ wmag(idx)) * 0.001;
idx = wmag > 3 & wmag < 10;
cd(idx) = 0.00114;
idx = wmag >= 10;
cd(idx) = (0.49 + 0.065 .* wmag(idx)) * 0.001;
tau_x = rho_air .* cd .* wmag .* u;
tau_y = rho_air .* cd .* wmag .* v;

% Convert grid spacing to meters
lon = xi;
lat = yi;
dlat = diff(lat,1,1);
dlon = diff(lon,1,2);
dy = deg2rad(dlat) * R;
dx = deg2rad(dlon) .* R .* cosd(lat(:,1:end-1));

% Derivatives
dtauy_dx = diff(tau_y,1,2) ./ dx;
dtaux_dy = diff(tau_x,1,1) ./ dy;
% Center grid
dtauy_dx = dtauy_dx(1:end-1,:);
dtaux_dy = dtaux_dy(:,1:end-1);
curlTau = dtauy_dx - dtaux_dy;
% Center coordinates
lonC = lon(1:end-1,1:end-1);
latC = lat(1:end-1,1:end-1);

% Ekman pumping
f = 2 * omega .* sind(latC);
ekmanPump = curlTau ./ (rho_w .* f);
% Avoid equatorial singularity
ekmanPump(abs(f) < 1e-10) = NaN;
