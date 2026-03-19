function [gstats, ix] = groupstats(grps, dats, stat)
%GROUPSTATS Compute statistics for grouped data.
%
%   GSTATS = GROUPSTATS(GRPS) returns the number of elements in each group
%   defined by GRPS.
%
%   GSTATS = GROUPSTATS(GRPS,DATS) computes the mean of DATS for each group.
%
%   GSTATS = GROUPSTATS(GRPS,DATS,STAT) computes the statistic specified by
%   STAT for each group.
%
%   [GSTATS,IX] = GROUPSTATS(...) also returns indices associated with the
%   computed statistic. For 'max' and 'min', IX contains the index of the
%   element where the extreme value occurs within each group.
%
%   INPUTS
%
%   GRPS    Vector or matrix defining group membership. Rows with identical
%           values belong to the same group.
%
%   DATS    Data vector used to compute statistics. Must have the same
%           number of elements as GRPS. If empty ([]), counts are computed.
%
%   STAT    Statistic to compute. Options include:
%
%           'sum'      Sum of values
%           'count'    Number of elements in each group
%           'mean'     Mean value (default)
%           'max'      Maximum value
%           'min'      Minimum value
%           'std'      Standard deviation
%           'median'   Median value
%
%
%   OUTPUTS
%
%   GSTATS  Table containing group statistics.
%        The table includes the grouping variables and one column
%        containing the requested statistic.
%
%   IX      Index information for each group.
%           For 'max' and 'min', IX gives the index of the element where the
%           extreme value occurs in the original data.
%
%   EXAMPLES
%       grps = [1 1 2 2 2 3];
%       dats = [5 7 3 4 6 2];
%       % Mean per group
%       groupstats(grps,dats,'mean')
%
%       % Maximum value and index per group
%       [g,ix] = groupstats(grps,dats,'max')
%
%       % Count elements per group
%       groupstats(grps)
%
%   SEE ALSO
%       UNIQUE, ACCUMARRAY, GROUPCOUNTS
%  RGR 20241017

% Handle input cases
if nargin == 1
    % groupstats(grps) -> count
    dats = ones(size(grps));
    stat = 'sum';
elseif nargin == 2
    if ischar(dats)
        % groupstats(grps, 'mean') -> stats on grps itself
        stat = dats;
        dats = grps;
    elseif isempty(dats)
        % groupstats(grps, []) -> count with ones
        dats = ones(size(grps));
        stat = 'sum';
    else
        % groupstats(grps, dats) -> default to mean
        stat = 'mean';
    end
elseif nargin == 3 && isempty(dats)
    % groupstats(grps, [], 'sum') -> count with ones
    dats = ones(size(grps));
end

[unique_grps, ~, id] = unique(grps, 'rows', 'stable');

switch lower(stat)
    case 'sum'
        stats = accumarray(id, dats);
        ix = accumarray(id, 1);
    case 'count'
        stats = accumarray(id, 1);
        ix = stats;
    case 'mean'
        stats = accumarray(id, dats, [], @nanmean);
        ix = accumarray(id, 1);
    case 'max'
        stats = accumarray(id, dats, [], @nanmax);
        ix = accumarray(id, (1:numel(dats))', [], ...
            @(indices) indices(find(dats(indices) == max(dats(indices)), 1)));
    case 'min'
        stats = accumarray(id, dats, [], @nanmin);
        ix = accumarray(id, (1:numel(dats))', [], ...
            @(indices) indices(find(dats(indices) == min(dats(indices)), 1)));
    case 'std'
        stats = accumarray(id, dats, [], @nanstd);
        ix = accumarray(id, 1);
    case 'median'
        stats = accumarray(id, dats, [], @nanmedian);
        ix = accumarray(id, 1);
    otherwise
        error('Statistic not supported: %s', stat);
end

% Table output
if size(unique_grps,2) == 1
    gstats = table(unique_grps, stats);
    gstats.Properties.VariableNames = {'grps', stat};
else
    gstats = array2table(unique_grps);
    gstats.(stat) = stats;
end
