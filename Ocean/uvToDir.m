function [dir,speed] = uvToDir(u,v)
%uvToDir Convert vector components to compass direction and speed.
%
%   [DIR,SPEED] = uvToDir(U,V) converts the vector components U (eastward)
%   and V (northward) into direction DIR (degrees North) and magnitude
%   SPEED.
%
%   Direction convention:
%       0°   = North
%       90°  = East
%       180° = South
%       270° = West
%
%   Inputs
%       U   Eastward component
%       V   Northward component
%
%   Outputs
%       DIR     Direction in degrees (degN)
%       SPEED   Vector magnitude
%
%   Notes
%       If U = 0 and V = 0, DIR is set to NaN.
%
%   Example
%       u = [1 0 -1 0];
%       v = [0 1 0 -1];
%       [dir,s] = uvToDir(u,v)
% EGR 2026 + IA

speed = hypot(u,v);
dir = mod(90 - atan2d(v,u),360);
dir(dir==360) = 0;
dir(speed==0) = NaN;
