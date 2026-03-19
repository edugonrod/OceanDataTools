function stats = initStats(data)
% INITSTATS Initialize a CumStats accumulator for incremental statistics.
%
%   stats = initStats(data)
%
% Initializes and accumulates incremental statistics using the CumStats
% class. This function is designed as a statistical core independent of
% the physical meaning of the accumulation dimension (time, ensembles,
% simulations, realizations, etc.).
%
% INPUT
%   data
%       Vector [N] or 3-D array [nx ny N].
%
%       • If a vector, each element is interpreted as an observation.
%       • If a 3-D array, the third dimension represents the accumulation
%         dimension.
%
% OUTPUT
%   stats
%       CumStats object ready for incremental accumulation.
%
% BEHAVIOR
%   • Initializes an empty CumStats object if no valid data are present.
%   • Accumulates only blocks containing non-NaN values.
%   • Ignores blocks that are entirely NaN.
%   • Does not interpret any temporal information.
%
% NOTES
%   • DATA must be either a vector or a 3-D array.
%   • 2-D matrices are not allowed to avoid structural ambiguity.
%   • The third dimension represents the accumulation dimension.
%
% EXAMPLES
%   stats = initStats(series);
%   stats = initStats(field3D);
%
%   % incremental update
%   stats = stats.update(new_data);
%
% Eduardo Gonzalez & AI, 20260222

if nargin < 1
    error('initStats requiere data')
end
if isvector(data)
    n = numel(data);
    data = reshape(data,1,1,n);
elseif ndims(data) == 3
else
    error('data debe ser un vector o un tensor 3D')
end
n = size(data,3);
if n == 0
    stats = [];
    return
end
valid = any(~isnan(data),[1 2]);
if ~any(valid)
    stats = [];
    return
end
stats = CumStats;
stats = stats.init(data(:,:,valid));
end