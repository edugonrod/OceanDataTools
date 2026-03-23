function [climat, anomaly, stats] = getClimatology(data, timevec, climatology, varargin)
% GETCLIMATOLOGY Compute climatologies and anomalies from time-series data.
%
%   climat = getClimatology(data, timevec, climatology)
%
%   [climat, anomaly] = getClimatology(data, timevec, climatology)
%
%   [climat, anomaly, stats] = getClimatology(data, timevec, climatology)
%
%   [...] = getClimatology(...,'Name',Value)
%
% Calculates climatologies by grouping data according to temporal units
% (monthly, seasonal, daily, annual, etc.). Optionally returns anomalies
% and additional statistics associated with the climatological calculation.
%
% INPUTS
%   data
%       Data to process. Can be a vector, matrix, or N-dimensional array.
%       The temporal dimension must match TIMEVEC.
%
%       The function automatically detects whether time is located in:
%           - the last dimension   (X,Y,T)
%           - the first dimension  (T,X,Y)
%
%   timevec
%       Time vector corresponding to DATA. It can be:
%           - datetime
%           - datenum
%
%   climatology
%       Type of climatology to compute:
%
%       'monthly','month','my'     monthly climatology (1–12)
%       'seasonal','season','qy'   seasonal climatology (1–4)
%       'daily','doy','dy'         daily climatology (1–366)
%       'annual','year','yy'       annual climatology
%
%       'month_year','mm'          month-year series (e.g., Jan-1993, Feb-1993...)
%       'season_year','qq'         season-year series
%
% NAME–VALUE OPTIONS
%   'statistic' | 'stat'
%       Statistic used to compute the climatology:
%
%           'mean'    mean (default)
%           'median'  median
%           'std'     standard deviation
%           'max'     maximum
%           'min'     minimum
%
%   'minsamples' | 'min'
%       Minimum number of samples required to compute the climatology
%       for each temporal group (default = 1).
%
% OUTPUTS
%   climat
%       Computed climatology. Its temporal dimension corresponds to the
%       number of groups defined by CLIMATOLOGY.
%
%   anomaly
%       Anomalies computed as:
%
%           anomaly = data − climatology
%
%       Has the same size as DATA.
%
%   stats
%       Structure containing additional information about the calculation:
%
%           .timeunit
%               Temporal units of the climatology
%
%           .climatology
%               Type of climatology used
%
%           .statistic
%               Statistic applied
%
%           .nsamples
%               Number of valid samples per group
%
%           .count
%               Counts used for mean calculation
%
%           .M2
%               Sum of squares used for variance calculation
%
%           .std
%               Standard deviation per group
%
%           .min
%               Minimum value per group
%
%           .max
%               Maximum value per group
%
%           .mean
%               Computed climatology
%
%           .n_groups
%               Number of temporal groups
%
%           .total_points
%               Number of spatial series processed
%
% DIMENSION HANDLING
%   DATA may have any number of spatial dimensions. Internally the function
%   reorganizes the data into a 2-D array (space × time) for computation,
%   and later reconstructs the original shape in the outputs.
%
% TIME-ONLY MODE
%   If DATA and TIMEVEC are identical, the function returns only the
%   temporal units corresponding to the requested climatology type,
%   without computing climatologies or anomalies.
%
% EXAMPLES
%   Monthly climatology:
%
%       clim = getClimatology(sst,time,'monthly');
%
%   Climatology and anomalies:
%
%       [clim,anom] = getClimatology(chl,time,'monthly');
%
%   Climatology using median:
%
%       clim = getClimatology(sst,time,'monthly','stat','median');
%
%   Require at least 5 observations per month:
%
%       clim = getClimatology(sst,time,'monthly','minsamples',5);
%
%   Obtain statistics as well:
%
%       [clim,anom,stats] = getClimatology(sst,time,'monthly');
%
% NOTES
%   The function is designed for large oceanographic or climate time-series
%   datasets and is optimized for multidimensional arrays.
%
% Keywords: climatology, anomaly, time series, oceanography, climate
%
% Based on EGR climatology routines, optimized with AI, 20260306


% DETECCIÓN DE OUTPUTS SOLICITADOS
compute_anom = (nargout > 1);  % anomaly es 2do output
compute_stats = (nargout > 2); % stats es 3er output

% CONFIGURACIÓN INICIAL
statistic = 'mean';
min_samples = 1;
if nargin > 3
    for i = 1:2:length(varargin)
        switch lower(varargin{i})
            case {'statistic','stat'}
                statistic = varargin{i+1};
            case {'minsamples','min'}
                min_samples = varargin{i+1};
        end
    end
end

% Convertir timevec a datetime
if ~isdatetime(timevec)
    t = datetime(timevec(:), 'ConvertFrom', 'datenum');
else
    t = timevec(:);
end

time_only_mode = isequal(data(:), timevec(:));

original_size = size(data);
original_ndims = ndims(data);
n_time = length(t);

% Reorganizar datos a 2D
if original_ndims == 1
    data = data(:);
    original_size = size(data);
    original_ndims = ndims(data);
    was_vector = true;
else
    was_vector = false;
end

if original_size(end) == n_time
    spatial_size = original_size(1:end-1);
    n_spatial = prod(spatial_size);
    data_2d = reshape(data, n_spatial, n_time);
elseif original_size(1) == n_time
    spatial_size = original_size(2:end);
    n_spatial = prod(spatial_size);
    data_2d = reshape(data, n_time, n_spatial)';
else
    error('No se encontró dimensión temporal compatible');
end

% CÁLCULO DE GRUPOS CLIMATOLÓGICOS (ORDEN CRONOLÓGICO)
switch lower(climatology)
    case {'monthly','month','my'}
        timeunit = (1:12)';
        [~, ~, ic] = unique(month(t));  % Sin cliuni
    case {'seasonal','season','qy'}
        timeunit = (1:4)';
        [~, ~, ic] = unique(quarter(t));
    case {'daily','doy','dy'}
        timeunit = (1:366)';
        [~, ~, ic] = unique(day(t, 'dayofyear'));
    case {'annual','year', 'yearly', 'yy'}
        [timeunit, ~, ic] = unique(year(t));  % timeunit ya viene ordenado
    case {'month_year','mm'}
        tu = [year(t), month(t)];
        [tunit_idx, ~, ic] = unique(tu, 'rows', 'stable');
        timeunit = datetime(tunit_idx(:,1), tunit_idx(:,2), 1);
        [timeunit, sort_idx] = sort(timeunit);  % Ordenar cronológicamente
        ic_old = ic;
        for i = 1:length(sort_idx)
            ic(ic_old == sort_idx(i)) = i;
        end
    case {'season_year','qq'}
        tu = [year(t), quarter(t)];
        [tunit_idx, ~, ic] = unique(tu, 'rows', 'stable');
        timeunit = datetime(tunit_idx(:,1), 1, 1) + calmonths(3*(tunit_idx(:,2)-1));
        [timeunit, sort_idx] = sort(timeunit);
        ic_old = ic;
        for i = 1:length(sort_idx)
            ic(ic_old == sort_idx(i)) = i;
        end
    otherwise
        error('Climatología no reconocida: %s', climatology);
end

% MODO SOLO TIEMPO
if time_only_mode
    switch lower(climatology)
        case {'daily','doy','dy'}
            climat = unique(dateshift(t,'start','day'),'stable');
        case {'monthly','month','my'}
            climat = unique(dateshift(t,'start','month'),'stable');
        case {'seasonal','season','qy'}
            climat = unique(dateshift(t,'start','quarter'),'stable');
        otherwise
            climat = timeunit;
    end

    if nargout > 1
        anomaly = [];
    end
    if nargout > 2
        stats = [];
    end
    return
end

nunits = numel(timeunit);

% CÁLCULO DE CLIMATOLOGÍA (SIEMPRE SE CALCULA)
climat_2d = nan(n_spatial, nunits, 'like', data_2d);
n_samples_per_series = zeros(n_spatial, nunits);

% Variables para estadísticas (solo si se van a calcular)
if compute_stats && strcmpi(statistic, 'mean')
    count_2d = zeros(n_spatial, nunits);
    M2_2d = zeros(n_spatial, nunits, 'like', data_2d);
    min_2d = nan(n_spatial, nunits, 'like', data_2d);
    max_2d = nan(n_spatial, nunits, 'like', data_2d);
end

% Cálculo vectorizado por grupos
for C = 1:nunits
    group_idx = (ic == C);
    if any(group_idx)
        group_data = data_2d(:, group_idx);
        valid_mask = ~isnan(group_data);
        n_samples_per_series(:, C) = sum(valid_mask, 2);
        valid_idx = n_samples_per_series(:, C) >= min_samples;
        if any(valid_idx)
            valid_data = group_data(valid_idx, :);
            valid_mask_sub = valid_mask(valid_idx, :);
            switch lower(statistic)
                case 'mean'
                    sum_valid = sum(valid_data .* valid_mask_sub, 2, 'omitnan');
                    climat_2d(valid_idx, C) = sum_valid ./ n_samples_per_series(valid_idx, C);
                    if compute_stats
                        count_2d(valid_idx, C) = sum(valid_mask_sub, 2);
                        M2_2d(valid_idx, C) = sum(valid_data.^2 .* valid_mask_sub, 2, 'omitnan');
                        min_2d(valid_idx, C) = min(valid_data, [], 2, 'omitnan');
                        max_2d(valid_idx, C) = max(valid_data, [], 2, 'omitnan');
                    end
                case 'median'
                    for i = 1:sum(valid_idx)
                        idx_linear = find(valid_idx, i, 'first');
                        row_data = valid_data(i, valid_mask_sub(i, :));
                        if ~isempty(row_data)
                            climat_2d(idx_linear, C) = median(row_data, 'omitnan');
                        end
                    end
                case 'std'
                    climat_2d(valid_idx, C) = std(valid_data, 0, 2, 'omitnan');
                    
                case 'max'
                    climat_2d(valid_idx, C) = max(valid_data, [], 2, 'omitnan');
                    
                case 'min'
                    climat_2d(valid_idx, C) = min(valid_data, [], 2, 'omitnan');
            end
        end
    end
end

% CÁLCULO DE ANOMALÍAS (SOLO SI SE PIDEN)
if compute_anom
    % Calcular anomalías
    anomaly_2d = nan(size(data_2d), 'like', data_2d);
    for t_idx = 1:n_time
        g = ic(t_idx);
        if g >= 1 && g <= size(climat_2d, 2)
            anomaly_2d(:, t_idx) = data_2d(:, t_idx) - climat_2d(:, g);
        end
    end
else
    anomaly_2d = [];
end

% ORGANIZAR SALIDAS
% 1. CLIMATOLOGÍA (siempre)
if was_vector
    climat = climat_2d(:);
elseif original_ndims <= 2
    climat = climat_2d';
else
    climat = reshape(climat_2d, [spatial_size nunits]);
end

% 2. ANOMALÍAS (solo si se calcularon)
if compute_anom
    if was_vector
        anomaly = anomaly_2d(:);
    elseif original_ndims <= 2
        if original_size(1) == n_time
            anomaly = anomaly_2d';
        else
            anomaly = anomaly_2d;
        end
    else
        anomaly = reshape(anomaly_2d, original_size);
    end
else
    anomaly = [];
end

% 3. ESTADÍSTICAS (solo si se calcularon)
if compute_stats
    stats = struct();
    stats.timeunit = timeunit;
    stats.climatology = climatology;
    stats.statistic = statistic;
    stats.nsamples = n_samples_per_series;
    if strcmpi(statistic, 'mean') && exist('count_2d', 'var')
        stats.count = count_2d;
        stats.M2 = M2_2d;
        stats.std = sqrt(M2_2d ./ max(count_2d - 1, 1));
        stats.min = min_2d;
        stats.max = max_2d;
    end
    stats.mean = climat_2d;
    stats.n_groups = nunits;
    stats.total_points = n_spatial;
else
    stats = [];
end
