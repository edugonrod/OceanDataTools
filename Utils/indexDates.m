function [ixd, ixdDates] = indexDates(timevector, dates, type, mode)
%indexDates  Logical indexing of dates in a time vector.
%
%   IXD = indexDates(TIMEVECTOR, DATES, TYPE) returns a logical vector IXD
%   the same size as TIMEVECTOR, indicating which elements match the
%   criteria specified by TYPE.
%
%   [IXD, IXD_DATES] = indexDates(...) also returns a logical vector
%   IXD_DATES indicating which elements of DATES found matches in
%   TIMEVECTOR. This avoids calling IXDATES twice in reverse order.
%
%   IXD = indexDates(TIMEVECTOR, DATES, TYPE, MODE) controls how matches are
%   resolved when no exact matches are found.
%
%   TIMEVECTOR must be a datetime array or a datenum vector. Internally,
%   TIMEVECTOR is always converted to datetime.
%
%   DATES may be either:
%     - datetime : interpreted as absolute dates
%     - numeric  : interpreted ONLY as calendar components (year, month,
%                  quarter, etc.), depending on TYPE, NOT datenum allowed
%
%   IMPORTANT:
%     Numeric DATES are NEVER interpreted as datenums.
%     To specify absolute dates, DATES must be datetime.
%
%   TYPE specifies how DATES is interpreted:
%
%   Component-based selection
%   -------------------------
%   'yyyy'   Match by year.
%            DATES = yyyy or vector of years, or datetime.
%
%   'mm'     Match by month (independent of year).
%            DATES = mm (1–12) or datetime.
%
%   'qq'     Match by quarter (independent of year).
%            DATES = qq (1–4) or datetime.
%
%   'ym'     Match by year and month.
%            DATES = [yyyy mm] or datetime.
%
%   'yq'     Match by year and quarter.
%            DATES = [yyyy qq] or datetime.
%
%   Absolute-date selection
%   -----------------------
%   'ymd'    Match exact dates (day resolution).
%            DATES must be datetime.
%
%  Absolute dates must be datetime..
%
%   MODE
%   ----
%   'exact'    (default) Only exact matches are returned.
%   'nearest'  If no exact matches are found, the nearest date(s) in
%              TIMEVECTOR are selected.
%
%   Output
%   ------
%   IXD         logical vector same size as TIMEVECTOR
%   IXDDATES   logical vector same size as DATES indicating which
%               requested dates were matched
%
%   Examples
%   --------
%     indexDates(t, 2021, 'yyyy')
%     indexDates(t, 6:8, 'mm')
%     indexDates(t, [2021 6], 'ym')
%     indexDates(t, datetime(2021,6,15), 'ym')
%     indexDates(t, datetime(2021,6,15), 'ymd','nearest')
%     indexDates(t, [1999 2024], 'range')                     % full years
%     indexDates(t, [1999 6; 2024 8], 'range')                % year-month limits
%     indexDates(t, [datetime(2000,1,1) datetime(2010,12,31)], 'range')%
%   Notes
%   -----
%   - Numeric DATES are interpreted strictly as calendar components.
%   - Ambiguous numeric inputs are resolved by TYPE, not by value.
%
%   EGR 2016–2025
%   Updated 2026: second output for matched DATES.

% Convert TIMEVECTOR to datetime
if isnumeric(timevector)
    timevector = datetime(timevector,'ConvertFrom','datenum');
elseif ~isa(timevector,'datetime')
    error('TIMEVECTOR must be datetime or datenum.');
end
timevector = timevector(:);

% Defaults
if nargin < 3 || isempty(type)
    type = 'ymd';
end
type = lower(type);

if nargin < 4 || isempty(mode)
    mode = 'exact';
end
mode = lower(mode);

if ~ismember(mode,{'exact','nearest'})
    error('MODE must be ''exact'' or ''nearest''.');
end

% Validate DATES based on TYPE
if isa(dates,'datetime')
    if strcmp(type,'range')
        if numel(dates) ~= 2
            error('For ''range'', DATES must be a 2-element datetime array.');
        end
        if iscolumn(dates)
            dates = dates';
        end
    else
        dates = dates(:);
    end
elseif isnumeric(dates)
    dates = dates(:);
else
    error('DATES must be numeric or datetime.');
end

% Precompute components
Y = year(timevector);
M = month(timevector);
Q = ceil(M/3);
D = dateshift(timevector,'start','day');

% Validate numeric dimensions by TYPE
switch type
    case {'ym','yq'}
        if isnumeric(dates) && size(dates,2) ~= 2
            error('For ''%s'', numeric DATES must be Nx2.', type);
        end
    case 'ymd'
        if ~isa(dates,'datetime')
            error('For ''ymd'', DATES must be datetime.');
        end
end

% Exact matching
switch type
    case {'yyyy', 'year'}
        if isa(dates,'datetime')
            yy = year(dates);
        else
            yy = dates;
        end
        ixd = ismember(Y, yy);
        ixdDates = ismember(yy, Y);        
    case {'mm', 'month'}
        if isa(dates,'datetime')
            mm = month(dates);
        else
            mm = dates;
        end
        if any(mm < 1 | mm > 12), error('Months must be 1–12.'); end
        ixd = ismember(M, mm);
        ixdDates = ismember(mm, M);        
    case {'qq', 'quarter'}
        if isa(dates,'datetime')
            qq = quarter(dates);
        else
            qq = dates;
        end
        if any(qq < 1 | qq > 4), error('Quarters must be 1–4.'); end
        ixd = ismember(Q, qq);
        ixdDates = ismember(qq, Q);        
    case 'ym'
        if isa(dates,'datetime')
            ym = [year(dates), month(dates)];
        else
            ym = dates;
        end
        ixd = ismember([Y M], ym, 'rows');
        ixdDates = ismember(ym, [Y M], 'rows');        
    case 'yq'
        if isa(dates,'datetime')
            yq = [year(dates), quarter(dates)];
        else
            yq = dates;
        end
        ixd = ismember([Y Q], yq, 'rows');
        ixdDates = ismember(yq, [Y Q], 'rows');        
    case 'ymd'
        d2 = dateshift(dates,'start','day');
        ixd = ismember(D, d2);
        ixdDates = ismember(d2, D);
    case 'range'
        % must define two limits
        if size(dates,1) ~= 2 && numel(dates) ~= 2
            error('For ''range'', provide two limits.');
        end
        if isa(dates,'datetime')
            t0 = dates(1);
            t1 = dates(2);
        elseif isnumeric(dates)
            % -------- YEAR RANGE --------
            if isvector(dates) && all(dates >= 0 & dates < 10000)
                t0 = datetime(dates(1),1,1);
                t1 = dateshift(datetime(dates(2),1,1),'end','year');
                % -------- YEAR-MONTH --------
            elseif size(dates,2) == 2
                t0 = datetime(dates(1,1),dates(1,2),1);
                t1 = dateshift(datetime(dates(2,1),dates(2,2),1),'end','month');
                % -------- YEAR-MONTH-DAY --------
            elseif size(dates,2) == 3
                t0 = datetime(dates(1,1),dates(1,2),dates(1,3));
                t1 = datetime(dates(2,1),dates(2,2),dates(2,3));
            else
                error(['Numeric ranges must be calendar components:' ...
                    ' [yyyy yyyy], [yyyy mm; yyyy mm], or [yyyy mm dd; ...]']);
            end
        else
            error('DATES must be datetime or numeric calendar components.');
        end
        % ensure chronological order
        if t1 < t0
            [t0,t1] = deal(t1,t0);
        end

        ixd = timevector >= t0 & timevector <= t1;
        ixdDates = any(ixd);
end

% Nearest fallback
if strcmp(mode,'nearest') && ~any(ixd) && ~strcmp(type,'range')
    if isa(dates,'datetime')
        ref = dates;
    else
        switch type
            case 'yyyy'
                ref = datetime(dates,1,1);
            case 'mm'
                ref = datetime(year(timevector(1)),dates,1);
            case 'qq'
                ref = datetime(year(timevector(1)),(dates-1)*3+1,1);
            case 'ym'
                ref = datetime(dates(:,1),dates(:,2),1);
            case 'yq'
                ref = datetime(dates(:,1),(dates(:,2)-1)*3+1,1);
            case 'ymd'
                ref = dates;
        end
    end

    diffMat = abs(timevector - ref');
    [~,idx] = min(diffMat,[],1);
    ixd = false(size(timevector));
    ixd(unique(idx)) = true;
    ixdDates = true(numel(ref),1);
end