function windir = uvToWindDir(u, v)
% uvToWindDir Convert wind vector components (u,v) to meteorological wind direction.
%
%   windir = uvToWindDir(u, v)
%
% Computes the wind direction in meteorological convention from the zonal
% and meridional wind components.
%
% INPUT
%   u
%       Zonal wind component (positive toward the east).
%
%   v
%       Meridional wind component (positive toward the north).
%
%       u and v must have the same dimensions and can be scalars,
%       vectors, or matrices.
%
% OUTPUT
%   windir
%       Wind direction in degrees indicating the direction FROM which
%       the wind blows.
%
%       Convention:
%
%           0°   → North
%           90°  → East
%           180° → South
%           270° → West
%
%       Range: [0, 360)
%
% DESCRIPTION
%   The wind direction is computed using the meteorological convention
%   (direction from which the wind originates). The formula used is:
%
%       windir = mod(180 + rad2deg(atan2(u, v)), 360)
%
%   which converts vector components into a compass direction referenced
%   clockwise from geographic north.
%
% EXAMPLE
%   windir = uvToWindDir(u, v);
%
% SEE ALSO
%   ATAN2, RAD2DEG
%
% EGR 2016


windir = mod(180+rad2deg(atan2(u, v)),360);

