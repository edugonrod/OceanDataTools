function ymd = dateToYMD(date, opt)
%dateToYMD  Convert MATLAB dates to compact YYYYMMDD numeric format
%   YMD = dateToYMD(DATE) returns date as numeric YYYYMMDD
%   YMD = dateToYMD(DATE, OPT) returns specified component
%
%   INPUTS:
%       date : MATLAB datetime array or datenum array
%       opt  : Output format (string):
%              'ymd' - YYYYMMDD (default)
%              'ym'  - YYYYMM
%              'y'   - YYYY
%              'm'   - MM
%              'd'   - DD
%
%   OUTPUT:
%       ymd : Numeric array in compact format
%
%   EXAMPLES:
%       % Single date
%       d = datetime(2020,3,6);
%       dateToYMD(d)           % Returns 20200306
%       dateToYMD(d, 'ym')     % Returns 202003
%       dateToYMD(d, 'y')      % Returns 2020
%
%       % Array of dates
%       dates = datetime(2020,1:12,1);
%       ymd_vec = dateToYMD(dates)  % [20200101; 20200201; ...]
%
%       % From datenum
%       dn = datenum(2020,3,6);
%       date2ymd(dn)           % Returns 20200306
%
%       % Useful for grouping
%       [~, idx] = sort(date2ymd(t, 'ym'));  % Sort by year-month
%
%   SEE ALSO: YMD2DT, DATETIME, DATENUM, DATESTR

% EGR 20220301 (original)
% Updated: 20260311 - Vectorization, input validation, better docs

% Convert to datetime if needed
if isnumeric(date)
    date = datetime(date, 'ConvertFrom', 'datenum');
end

% Default option
if nargin < 2 || isempty(opt)
    opt = 'ymd';
end

% Extract components using datetime methods
switch opt
    case 'ymd'
        ymd = year(date)*10000 + month(date)*100 + day(date);
    case 'ym'
        ymd = year(date)*100 + month(date);
    case 'y'
        ymd = year(date);
    case 'm'
        ymd = month(date);
    case 'd'
        ymd = day(date);
    otherwise
        error('Invalid option: %s', opt);
end

end
