function [dist, cumdist, bearing] = geodistance(lat, lon, mode, units)
% GEODISTANCE Great-circle distance on Earth using the Haversine formula
%
%   dist = geodistance(lat, lon)
%   [dist, cumdist] = geodistance(lat, lon)
%   [dist, cumdist, bearing] = geodistance(lat, lon, 'alongtrack')
%
%   dist = geodistance(lat, lon, mode)
%   dist = geodistance(lat, lon, mode, units)
%
% INPUT
%   lat, lon
%       Latitude and longitude in degrees.
%       Vectors must have the same length and represent a geographic track.
%
% OPTIONAL
%   mode
%       'track'      distance between consecutive points (default)
%       'alongtrack' distance + cumulative distance + bearing
%       'matrix'     distance matrix between all points
%
%   units
%       'km'  kilometers (default)
%       'm'   meters
%       'nm'  nautical miles
%
% OUTPUT
%   dist
%       Distance between consecutive points (track modes) or distance matrix.
%
%   cumdist
%       Cumulative distance along track.
%       Returned only for 'track' and 'alongtrack'.
%
%   bearing
%       Initial bearing (azimuth) between consecutive points in degrees.
%       Returned only for 'alongtrack'.
%
% DESCRIPTION
%   Computes great-circle distances using the Haversine formula. The function
%   supports three modes:
%
%   'track'
%       Returns distances between consecutive points.
%
%   'alongtrack'
%       Returns segment distance, cumulative distance, and bearing.
%       Useful for transects and ship tracks.
%
%   'matrix'
%       Computes the full pairwise distance matrix.
%
%   The longitude difference is internally normalized to avoid dateline
%   crossing errors.
%
% EXAMPLES
%
%   % Distance between stations
%   d = geodistance(lat, lon);
%
%   % Cumulative distance along track
%   [d, cd] = geodistance(lat, lon);
%
%   % Distance and bearing along a transect
%   [d, cd, az] = geodistance(lat, lon, 'alongtrack');
%
%   % Distance matrix
%   D = geodistance(lat, lon, 'matrix');
%
%   % Distances in nautical miles
%   d = geodistance(lat, lon, 'track', 'nm');
%
% NOTES
%   Earth radius used:
%       6371 km
%
%   Longitude differences are normalized to [-π, π] to correctly handle
%   dateline crossings.
%
% SEE ALSO
%   deg2rad
%
% EGR 2026 + AI

if nargin < 3 || isempty(mode)
    mode = 'track';
end
if nargin < 4 || isempty(units)
    units = 'km';
end
% Earth radius according to units
switch lower(units)
    case 'km'
        R = 6371;
    case 'm'
        R = 6371000;
    case 'nm'
        R = 3440.065;
    otherwise
        error('Units must be ''km'', ''m'', or ''nm''.')
end
% ensure column vectors
lat = lat(:);
lon = lon(:);
if numel(lat) ~= numel(lon)
    error('lat and lon must have the same length.')
end
% convert to radians
lat = deg2rad(lat);
lon = deg2rad(lon);
switch lower(mode)
    case {'track','alongtrack'}
        lat1 = lat(1:end-1);
        lat2 = lat(2:end);
        lon1 = lon(1:end-1);
        lon2 = lon(2:end);
        dlat = lat2 - lat1;
        % safe longitude difference (dateline-safe)
        dlon = lon2 - lon1;
        dlon = mod(dlon + pi, 2*pi) - pi;
        % haversine
        a = sin(dlat/2).^2 + cos(lat1).*cos(lat2).*sin(dlon/2).^2;
        c = 2 .* atan2(sqrt(a), sqrt(1-a));
        dist = R * c;
        if nargout >= 2
            cumdist = [0; cumsum(dist)];
        else
            cumdist = [];
        end
        if strcmpi(mode,'alongtrack')
            % bearing calculation
            y = sin(dlon).*cos(lat2);
            x = cos(lat1).*sin(lat2) - sin(lat1).*cos(lat2).*cos(dlon);
            bearing = mod(rad2deg(atan2(y,x)),360);
        else
            bearing = [];
        end
    case 'matrix'
        n = numel(lat);
        dist = zeros(n);
        for i = 1:n
            lat1 = lat(i);
            lon1 = lon(i);
            dlat = lat - lat1;
            dlon = lon - lon1;
            dlon = mod(dlon + pi, 2*pi) - pi;
            a = sin(dlat/2).^2 + cos(lat1).*cos(lat).*sin(dlon/2).^2;
            c = 2 .* atan2(sqrt(a), sqrt(1-a));
            dist(i,:) = R * c;
        end
        cumdist = [];
        bearing = [];
        % -------------------------------------------------------------
    otherwise
        error('Mode must be ''track'', ''alongtrack'', or ''matrix''.')
end
