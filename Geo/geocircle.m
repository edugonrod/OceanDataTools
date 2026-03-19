function [xpts, ypts] = geocircle(x, y, radius, varargin)
%GEOCIRCLE Generate coordinates of a geographic circle.
%
%   [XPTS, YPTS] = GEOCIRCLE(X, Y, RADIUS) returns the longitude (XPTS) and
%   latitude (YPTS) coordinates of a circle centered at (X,Y). The circle
%   is approximated by a polygon defined by equally spaced points.
%
%   [XPTS, YPTS] = GEOCIRCLE(..., Name, Value) specifies optional
%   parameters using name-value pairs.
%
%   Inputs
%       X        Longitude of the circle center (scalar, degrees).
%       Y        Latitude of the circle center (scalar, degrees).
%       RADIUS   Radius of the circle. Units depend on the 'units'
%                parameter.
%
%   Name-Value Parameters
%
%       'npoints'         Number of points used to approximate the circle.
%                         Must be >= 3. Default: 50.
%
%       'units'           Units for RADIUS:
%                           'km'  kilometers (default)
%                           'm'   meters
%                           'nm'  nautical miles
%                           'deg' degrees
%
%       'correctLatitude' Logical flag indicating whether longitude
%                         distances are corrected by cos(latitude) to
%                         account for meridian convergence. Default: true.
%
%       'closeCircle'     Logical flag indicating whether the first point
%                         is repeated at the end to close the circle.
%                         Default: true.
%
%   Outputs
%       XPTS     Longitudes of the generated circle (column vector).
%       YPTS     Latitudes of the generated circle (column vector).
%
%   Notes
%       Longitudes are wrapped to the interval [-180, 180]. If the circle
%       extends beyond ±90° latitude, the latitude values are clipped and
%       a warning is issued.
%
%   Example
%       [x,y] = geocircle(-110.3, 24.1, 100);
%       plot(x,y)
%
%   See also KM2DEG
% Parse inputs

p = inputParser;
addRequired(p, 'x', @(x) isnumeric(x) && isscalar(x));
addRequired(p, 'y', @(x) isnumeric(x) && isscalar(x));
addRequired(p, 'radius', @(x) isnumeric(x) && isscalar(x) && x>0);
addParameter(p, 'npoints', 50, @(x) isnumeric(x) && isscalar(x) && x>=3);
addParameter(p, 'units', 'km', @(x) ismember(x, {'km', 'm', 'nm', 'deg'}));
addParameter(p, 'correctLatitude', true, @islogical);
addParameter(p, 'closeCircle', true, @islogical);
parse(p, x, y, radius, varargin{:});

% Convert radius to degrees
switch p.Results.units
    case 'km'
        radius_deg = km2deg(radius);
    case 'm'
        radius_deg = km2deg(radius/1000);
    case 'nm'  % nautical miles
        radius_deg = km2deg(radius * 1.852);
    case 'deg'
        radius_deg = radius;
end

% Generate angles
th = linspace(0, 2*pi, p.Results.npoints+1)';
if ~p.Results.closeCircle
    th(end) = [];
end

% Latitude correction
if p.Results.correctLatitude && abs(y) > 1
    lat_correction = 1 / cosd(y);
else
    lat_correction = 1;
end

% Calculate points
xpts = x + (radius_deg * cos(th) * lat_correction);
ypts = y + (radius_deg * sin(th));

% Handle antimeridian
xpts = mod(xpts + 180, 360) - 180;

% Handle poles
if any(abs(ypts) > 90)
    warning('GEOCIRCLE:poleCrossing', 'Circle extends beyond 90° latitude');
    ypts = max(min(ypts, 90), -90);
end

