function stats = eddyStats(tracks)
% eddyStats Compute basic statistics for eddy tracks.
%
% stats = eddyStats(tracks)
%
% INPUT
%   tracks  structure array returned by eddytrack
%
% OUTPUT
%   stats structure array with fields:
%       id
%       lifetime
%       distance
%       speed
%       mean_radius
%       max_amplitude
%       polarity
%
% DESCRIPTION
%   Computes lifetime, propagation distance, mean speed, mean radius,
%   and maximum amplitude for each eddy track.
%
% REQUIREMENTS
%   geodistance
%
% OceanDataTools

n = numel(tracks);
stats = struct([]);

for k = 1:n
    lon = tracks(k).lon;
    lat = tracks(k).lat;
    t   = tracks(k).time;
    lifetime = numel(t);
    dist = 0;
    for i = 2:lifetime
        d = geodistance([lat(i-1) lat(i)], [lon(i-1) lon(i)]);
        dist = dist + d(1);
    end

    speed = dist / max(lifetime-1,1);
    stats(k).id = tracks(k).id;
    stats(k).lifetime = lifetime;
    stats(k).distance = dist;
    stats(k).speed = speed;
    stats(k).mean_radius = mean(tracks(k).radius);
    stats(k).max_amplitude = max(tracks(k).amplitude);
    stats(k).polarity = tracks(k).polarity;
end
