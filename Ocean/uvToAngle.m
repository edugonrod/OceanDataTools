function [direction, speed] = uvToAngle(u, v)
% uvToAngle Convert vector components (u,v) to direction and speed.
%
%   [direction, speed] = uvToAngle(u, v)
%
% Computes the direction and magnitude of vectors defined by their
% zonal (u) and meridional (v) components.
%
% INPUT
%   u
%       Zonal component of the vector field.
%
%   v
%       Meridional component of the vector field.
%
%       u and v must have the same size and can be scalars, vectors,
%       or matrices.
%
% OUTPUT
%   direction
%       Direction of the vector in degrees measured clockwise from
%       geographic north.
%
%       Range: [0, 360)
%
%   speed
%       Magnitude of the vector:
%
%           speed = hypot(u, v)
%
% DESCRIPTION
%   The direction is computed using:
%
%       direction = atan2(u, v)
%
%   which returns the angle relative to north, increasing clockwise,
%   consistent with common meteorological and oceanographic conventions.
%
% EXAMPLE
%   [dir,spd] = uv2angle(u,v);
%
%   quiver(x,y,u,v)
%
% SEE ALSO
%   ATAN2, HYPOT
%
% EGR


% Calculate wind direction in degrees (from north, clockwise)
direction = atan2(u, v) * (180/pi);
% Adjust the angle to ensure it's in the range [0, 360]
direction(direction < 0) = direction(direction < 0) + 360;
%speed
speed = hypot(u, v);
