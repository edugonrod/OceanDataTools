classdef CumStats
% CUMSTATS Incremental accumulator for basic statistics using Welford's method.
%
% This class maintains cumulative statistics for multidimensional data
% and allows incremental updates as new data blocks become available.
% The algorithm is based on Welford's method, which provides numerically
% stable estimates of the mean and variance.
%
% USAGE
%   stats = CumStats(x)
%       Initialize the accumulator using data x.
%
%   stats = stats.update(x)
%       Update the cumulative statistics with new data.
%
%   m  = stats.cmean
%       Access the cumulative mean.
%
%   sd = stats.cstd
%       Access the cumulative standard deviation.
%
% PROPERTIES
%   cmean
%       Cumulative mean.
%
%   M2
%       Sum of squared deviations used to compute variance.
%
%   count
%       Number of valid (non-NaN) samples accumulated per element.
%
%   cmax
%       Cumulative maximum value per element.
%
%   cmin
%       Cumulative minimum value per element.
%
%   total
%       Total number of matrices accumulated.
%
% DEPENDENT PROPERTIES
%   cstd
%       Cumulative standard deviation derived from M2 and count.
%
% NOTES
%   This class is designed for incremental statistical processing of
%   large multidimensional datasets, avoiding the need to recompute
%   statistics from the full dataset each time new data are added.
%
% EGR

properties (SetAccess = private)
    cmean
    M2
    count
    cmax
    cmin
    total
end

properties (Dependent)
    cstd
end

methods
    % Constructor
    function obj = CumStats(x)
        if nargin == 0
            return
        end
        obj = obj.init(x);
    end

    % Inicialización
    function obj = init(obj, x)
        obj.count = sum(~isnan(x), 3);
        obj.cmean  = nanmean(x, 3);

        % Inicialización de M2
        dx   = x - obj.cmean;
        obj.M2 = nansum(dx.^2, 3);

        obj.cmax  = nanmax(x, [], 3);
        obj.cmin  = nanmin(x, [], 3);
        obj.total = size(x, 3);
    end

    % Actualización incremental (Welford)
    function obj = update(obj, x)
        n_new = sum(~isnan(x), 3);
        mean_new = nanmean(x, 3);
        delta = mean_new - obj.cmean;
        tot_count = obj.count + n_new;
        % Actualizar media
        obj.cmean = obj.cmean + delta .* (n_new ./ tot_count);
        % Actualizar M2 (Welford combinado)
        dx = x - mean_new;
        M2_new = nansum(dx.^2, 3);
        obj.M2 = obj.M2 + M2_new + delta.^2 .* (obj.count .* n_new ./ tot_count);
        % Actualizar conteo
        obj.count = tot_count;
        % Max / Min
        obj.cmax = max(obj.cmax, nanmax(x, [], 3));
        obj.cmin = min(obj.cmin, nanmin(x, [], 3));
        % Total de bloques
        obj.total = obj.total + size(x, 3);
    end

    % Desviación estándar (derivada)
    function s = get.cstd(obj)
        s = nan(size(obj.M2));
        valid = obj.count > 1;
        s(valid) = sqrt(obj.M2(valid) ./ (obj.count(valid) - 1));
    end    end
end
