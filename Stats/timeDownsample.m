function [dataout,timevecnew] = timeDownsample(datain,timevec,tdwn,fun)
%TIMEDOWNSAMPLE  Temporal reduction of vectors, matrices or tensors by time grouping.
%
%   [dataout,timevecnew] = timeDownsample(datain,timevec,tdwn)
%   [dataout,timevecnew] = timeDownsample(datain,timevec,tdwn,fun)
%
%   This function computes statistics of data grouped by time units such as
%   day, month, quarter or year. It can handle one or more time series and
%   also multidimensional arrays where one dimension corresponds to time.
%
%   Unlike climatological grouping functions, this routine performs only
%   temporal frequency reduction (downsampling), for example:
%
%       daily   -> monthly
%       monthly -> yearly
%       daily   -> yearly
%       quarterly -> yearly
%
%   INPUTS:
%     datain   - array containing a temporal dimension (vector, matrix or ND)
%
%     timevec  - vector of datetimes or datenums corresponding to the
%                temporal dimension of datain
%
%     tdwn     - string specifying grouping method:
%                  'dd' - day of each year (year + day)
%                  'mm' - monthly (year + month)
%                  'qq' - quarterly (year + quarter)
%                  'yy' - yearly
%
%     fun      - optional statistic to apply within each time group:
%                  string: 'mean','median','sum','std', etc.
%                  handle: @nanmean, @median, @(x) prctile(x,90), etc.
%
%                default: 'mean' (ignoring NaNs)
%
%   OUTPUTS:
%     dataout     - aggregated array with reduced temporal dimension
%
%     timevecnew  - vector of grouped timestamps (datetime)
%
%   NOTES:
%     - If input time is numeric (datenum), it is internally converted.
%     - The temporal dimension is detected automatically from timevec length.
%     - NaN values are ignored when computing statistics.
%     - For matrices, each column is treated as an independent time series.
%     - For tensors, aggregation is applied along the detected time dimension.
%
%  When using custom function handles, the function must reduce the last
%  dimension of the grouped data (time). For example:
%
%   p90 = @(x) prctile(x,90,ndims(x))
%
%   Functions that do not reduce a dimension (e.g. @(x) max(x,90)) will
%   produce size mismatch errors.
%
%   EXAMPLES:
%     Annual mean from monthly series:
%        [y,ty] = timeDownsample(x,t,'yy');
%
%     Monthly median from daily 3D field:
%        [xm,tm] = timeDownsample(X,t,'mm','median');
%
%     Custom statistic (90th percentile):
%        xp = timeDownsample(x,t,'yy', p90);
%
%   EGR 20170601 egonzale@cicese.mx
%   Unified version 20260325

t = timevec(:);

if isnumeric(t)
    t = datetime(t,'ConvertFrom','datenum');
end

nt = numel(t);
sz = size(datain);
timedim = find(sz==nt,1);

if isempty(timedim)
    error('No dimension matches length(timevec).')
end

if nargin<4 || isempty(fun)
    fun = @nanmean;
end

switch lower(tdwn)
    case 'dd'
        g = dateshift(t,'start','day');
    case 'mm'
        g = dateshift(t,'start','month');
    case 'qq'
        g = dateshift(t,'start','quarter');
    case 'yy'
        g = dateshift(t,'start','year');
    otherwise
        error('Unknown tdwn option: %s',tdwn)
end

[G, timevecnew] = findgroups(g);
ntnew = numel(timevecnew);
perm = 1:ndims(datain);
perm([timedim end]) = perm([end timedim]);
datain = permute(datain,perm);
sz = size(datain);
dataout = nan([sz(1:end-1) ntnew]);

dimt = ndims(datain);
subs = repmat({':'},1,dimt);
for k = 1:ntnew
    ix = (G==k);
    subs{dimt} = ix;
    x = datain(subs{:});
    if ischar(fun) || isstring(fun)
        switch lower(fun)
            case 'mean'
                tmp = mean(x,dimt,'omitnan');
            case 'median'
                tmp = median(x,dimt,'omitnan');
            case 'sum'
                tmp = sum(x,dimt,'omitnan');
            case 'std'
                tmp = std(x,0,dimt,'omitnan');
            case 'min'
                tmp = min(x,[],dimt);
            case 'max'
                tmp = max(x,[],dimt);
            case 'var'
                tmp = var(x,0,dimt,'omitnan');
            otherwise
                error('Unknown statistic: %s',fun)
        end
    else
        tmp = fun(x);
    end    
    subs{dimt} = k;
    dataout(subs{:}) = tmp;
end

dataout = ipermute(dataout,perm);
