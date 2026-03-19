function SI = stratification(temp, sal, mdl, depth, lat, lon, temptype, saltype)
%STRATIFICATION  Bulk water column stratification index
%
%   SI = STRATIFICATION(temp, sal, mdl, depth, lat, lon, temptype, saltype)
%
%   Computes a bulk stratification index defined as:
%
%       SI = sigma0(MLD) - sigma0(surface)
%
%   where sigma0 is the potential density anomaly referenced to 0 dbar.
%
%   Positive SI values indicate stratified conditions (lighter surface 
%   waters overlying denser subsurface waters), while values near zero 
%   represent well-mixed conditions. 
% -------------------------------------------------------------------------
% INPUTS:
%   temp : [lon × lat × depth]
%       Temperature field.
%       Interpretation depends on temptype:
%           'T'  → in situ temperature (°C)
%           'PT' → potential temperature (°C)
%           'CT' → Conservative Temperature (°C)
%
%   sal : [lon × lat × depth]
%       Salinity field.
%       - 'SP' → Practical Salinity (PSU)
%       - 'SA' → Absolute Salinity (g kg⁻¹)
%
%   mdl : [lon × lat]
%       Mixed layer thickness / depth (m, positive).
%
%   depth : [depth × 1]
%       Depth levels (m, positive downward).
%
%   lat : [lat × 1]
%       Latitude (degrees_north).
%
%   lon : [lon × 1]
%       Longitude (degrees_east).
%
%   temptype : (optional)
%       'T'  (default), 'PT', or 'CT'
%
%   saltype : (optional)
%       'SP' (default) or 'SA'
%
% -------------------------------------------------------------------------
% OUTPUT:
%   SI : [lon × lat]
%       Stratification index (kg m⁻³)
%
% -------------------------------------------------------------------------
% REQUIREMENTS:
%   Gibbs SeaWater (GSW) Oceanographic Toolbox (TEOS-10)
%
% Eduardo Gonzalez Rodriguez + IA
% 2025-12-14
% -------------------------------------------------------------------------

% Defaults
if nargin < 7 || isempty(temptype)
    temptype = 'T';
end
if nargin < 8 || isempty(saltype)
    saltype = 'SP';
end

% Dimensions
[nlon, nlat, nz] = size(temp);

% 1. Build 3D grids (TEOS-10 safe)
[LAT, LON, Z] = ndgrid(lat, lon, -depth);   % Z negative
P = gsw_p_from_z(Z, LAT);                   % Pressure [dbar]

% 2. Salinity handling
switch upper(saltype)
    case 'SP'
        SA = gsw_SA_from_SP(sal, P, LON, LAT);
    case 'SA'
        SA = sal;
    otherwise
        error('saltype must be ''SP'' or ''SA''.');
end

% 3. Temperature → Conservative Temperature
switch upper(temptype)
    case 'T'    % in situ temperature
        CT = gsw_CT_from_t(SA, temp, P);

    case 'PT'   % potential temperature
        CT = gsw_CT_from_pt(SA, temp);

    case 'CT'   % already Conservative Temperature
        CT = temp;

    otherwise
        error('temptype must be ''T'', ''PT'' or ''CT''.');
end

% 4. Potential density anomaly
sigma0 = gsw_sigma0(SA, CT);

% 5. Surface density
sigma0_surf = sigma0(:,:,1);

% 6. Density at MLD
dist = abs(depth(:)' - mdl(:));
[~, lev] = min(dist, [], 2);

[I, J] = ndgrid(1:nlon, 1:nlat);
ind_mld = sub2ind([nlon, nlat, nz], I(:), J(:), lev);

sigma0_mld = reshape(sigma0(ind_mld), nlon, nlat);

% 7. Stratification index
SI = sigma0_mld - sigma0_surf;

SI(isnan(mdl)) = NaN;


