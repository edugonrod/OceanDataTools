function varargout = rotateCoords(x,y,varargin)
%rotateCoords Rotate 2D or 3D vector components.
%
% SYNTAX
%   [xp,yp]       = rotateCoords(x,y,theta)
%   [u2,v2,w2]    = rotateCoords(u,v,w,heading,pitch,roll)
%
% DESCRIPTION
%   rotateCoords rotates vector components into a rotated coordinate system.
%   Inputs may be scalars, vectors, or matrices of equal size.
%
% -------- 2D ROTATION --------
%   [xp,yp] = rotateCoords(x,y,theta)
%
%   Rotates the coordinate axes counterclockwise by THETA degrees.
%   Equivalent to rotating the vector clockwise by THETA.
%
%   xp =  x cosθ + y sinθ
%   yp = -x sinθ + y cosθ
%
%   Common uses:
%       • alongshore / cross-shore currents
%       • wind parallel/perpendicular to coast
%       • transect-aligned velocities
%
% -------- 3D ROTATION --------
%   [u2,v2,w2] = rotateCoords(u,v,w,heading,pitch,roll)
%
%   Rotates vector components using Euler angles (degrees).
%
%   ROTATION ORDER (applied in sequence):
%       1) Roll    → rotation about X axis
%       2) Pitch   → rotation about Y axis
%       3) Heading → rotation about Z axis
%
%   ANGLE DEFINITIONS
%       heading : rotation around vertical axis (yaw)
%                 positive rotates X toward Y
%
%       pitch   : rotation around Y axis
%                 positive tilts X toward Z
%
%       roll    : rotation around X axis
%                 positive tilts Y toward Z
%
%   TYPICAL RANGES
%       heading :   0 – 360°   instrument or frame orientation
%       pitch   :  ±0 – 10°    typical tilt (up to ±30° possible)
%       roll    :  ±0 – 10°    typical tilt (up to ±30° possible)
%
%   This convention is widely used in:
%       • oceanography (ADCP transformations)
%       • navigation and vehicle dynamics
%       • slope-aligned velocity analysis
%
%   Typical applications:
%       • transform instrument velocities to Earth coordinates
%       • rotate velocities relative to bathymetric slope
%       • convert to local along-track / cross-track frames
%
% NOTES
%   • Angles are in degrees.
%   • Positive rotations follow right-hand rule.
%   • To reverse a rotation, use negative angles.
%
% EXAMPLES
%   % 2D: alongshore current (coast orientation 42°)
%   [ualong,ucross] = rotateCoords(u,v,42);
%
%   % 3D: rotate velocities using heading, pitch, roll
%   [u2,v2,w2] = rotateCoords(u,v,w,heading,pitch,roll);
%
% Author: MDM toolbox
%

if nargin==3          % ----- 2D -----
    theta = deg2rad(varargin{1});
    xp = x.*cos(theta) + y.*sin(theta);
    yp = -x.*sin(theta) + y.*cos(theta);
    varargout = {xp,yp};
else                  % ----- 3D -----
    z = varargin{1};
    h = deg2rad(varargin{2});
    p = deg2rad(varargin{3});
    r = deg2rad(varargin{4});

    Rx = [1 0 0;0 cos(r) sin(r);0 -sin(r) cos(r)];
    Ry = [cos(p) 0 -sin(p);0 1 0;sin(p) 0 cos(p)];
    Rz = [cos(h) sin(h) 0;-sin(h) cos(h) 0;0 0 1];
    R = Rz*Ry*Rx;

    s = size(x);
    v = R*[x(:) y(:) z(:)]';
    varargout = {reshape(v(1,:),s),reshape(v(2,:),s),reshape(v(3,:),s)};
end
