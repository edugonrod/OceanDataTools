function tracks = trackEddies(eddies,varargin)
% trackEddies Track eddies through time using nearest-neighbor matching.
%
% tracks = trackEddies(eddies)
% tracks = trackEddies(...,'maxdist',D)
%
% INPUT
%   eddies  cell array where eddies{t} is the output of eddydetect at time t.
%
% OPTIONS
%   maxdist maximum distance between eddy centers in consecutive timesteps
%           used to associate eddies (km). Default = 150 km.
%
% OUTPUT
%   tracks structure array with fields:
%       id          track identifier
%       lon         longitude positions
%       lat         latitude positions
%       time        time indices
%       radius      eddy radius (km)
%       amplitude   eddy amplitude
%       polarity    cyclonic or anticyclonic
%
% DESCRIPTION
%   Eddies are associated between consecutive timesteps using a nearest
%   neighbor search constrained by maximum distance and equal polarity.
%   If no match is found, a new track is initialized.
%
% REQUIREMENTS
%   geodistance
%
% OceanDataTools

maxdist = 150;
k = 1;
while k <= numel(varargin)
    switch lower(varargin{k})
        case 'maxdist'
            maxdist = varargin{k+1};
    end
    k = k + 2;
end

nt = numel(eddies);
tracks = struct([]);
tid = 0;

for i = 1:numel(eddies{1})
    tid = tid + 1;
    tracks(tid).id = tid;
    tracks(tid).lon = eddies{1}(i).center_lon;
    tracks(tid).lat = eddies{1}(i).center_lat;
    tracks(tid).time = 1;
    tracks(tid).radius = eddies{1}(i).radius_km;
    tracks(tid).amplitude = eddies{1}(i).amplitude;
    tracks(tid).polarity = eddies{1}(i).polarity;
end

for t = 2:nt
    cur = eddies{t};
    for i = 1:numel(cur)
        lon = cur(i).center_lon;
        lat = cur(i).center_lat;
        best = NaN;
        bestdist = inf;
        for j = 1:numel(tracks)
            if tracks(j).time(end) ~= t-1
                continue
            end
            if ~strcmp(tracks(j).polarity,cur(i).polarity)
                continue
            end
            d = geodistance([tracks(j).lat(end) lat], [tracks(j).lon(end) lon]);
            d = d(1);
            if d < bestdist && d <= maxdist
                best = j;
                bestdist = d;
            end
        end
        if ~isnan(best)
            tracks(best).lon(end+1) = lon;
            tracks(best).lat(end+1) = lat;
            tracks(best).time(end+1) = t;
            tracks(best).radius(end+1) = cur(i).radius_km;
            tracks(best).amplitude(end+1) = cur(i).amplitude;
        else
            tid = tid + 1;
            tracks(tid).id = tid;
            tracks(tid).lon = lon;
            tracks(tid).lat = lat;
            tracks(tid).time = t;
            tracks(tid).radius = cur(i).radius_km;
            tracks(tid).amplitude = cur(i).amplitude;
            tracks(tid).polarity = cur(i).polarity;
        end
    end
end
tracks = tracks(:);
