function [dFdx, dFdy] = geogradient(F, lonvec, latvec)
% GEOGRADIENT Spatial gradient on a latitude–longitude grid
%
%   [dFdx, dFdy] = geogradient(F, lonvec, latvec)
%
% Computes horizontal gradients of a field defined on a regular
% latitude–longitude grid, returning derivatives in physical units.
%
% INPUT
%   F
%       Field of size [ny nx] or [ny nx nt]
%
%   lonvec
%       Longitude vector (nx)
%
%   latvec
%       Latitude vector (ny)
%
% OUTPUT
%   dFdx
%       Zonal gradient ∂F/∂x (per meter)
%
%   dFdy
%       Meridional gradient ∂F/∂y (per meter)
%
% DESCRIPTION
%   MATLAB's gradient function assumes Cartesian coordinates. When working
%   with latitude–longitude grids, grid spacing varies with latitude.
%
%   Distances are computed as:
%
%       dx = R cos(lat) dlon
%       dy = R dlat
%
%   where
%
%       R = Earth radius = 6371000 m
%
% EXAMPLE
%
%   [dTdx,dTdy] = geogradient(sst,lon,lat);
%
% SEE ALSO
%   gradient
%
% OceanDataTools
% 20160306 EGR + IA help

R = 6371000;
dlon = deg2rad(mean(diff(lonvec)));
dlat = deg2rad(mean(diff(latvec)));
lat0 = mean(latvec);
dx = R * cosd(lat0) * dlon;
dy = R * dlat;
[dFdy, dFdx] = gradient(F, dy, dx);

