function [u,v] = dirToUV(dir,speed)
%dirToUV Convert compass direction and speed to vector components.
%
%   [U,V] = dirToUV(DIR,SPEED) converts direction DIR (degrees North)
%   and magnitude SPEED into vector components U (eastward) and
%   V (northward).
%
%   Direction convention:
%       0°   = North
%       90°  = East
%       180° = South
%       270° = West
%
%   Inputs
%       DIR     Direction in degrees (degN)
%       SPEED   Vector magnitude
%
%   Outputs
%       U       Eastward component
%       V       Northward component
%
%   Example
%       dir = [0 90 180 270];
%       speed = 1;
%       [u,v] = dirToUV(dir,speed)

u = speed .* sind(dir);
v = speed .* cosd(dir);

