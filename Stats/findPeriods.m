function [p,model,stats] = findPeriods(x,varargin)
% FINDPERIODS  Detect periodicities in a time series using cyclic descent.
%
%   p = FINDPERIODS(x)
%   p = FINDPERIODS(x,'t',t)
%   p = FINDPERIODS(x,'time',t)
%   [p,model,stats] = FINDPERIODS(x, Name, Value)
%
%   Estimates dominant periods in a time series using an iterative harmonic
%   regression (cyclic descent). At each step the period that maximizes the
%   reciprocal residual sum of squares (RRSS) is selected, removed from the
%   residual series, and the process continues until the improvement of the
%   model is not statistically significant (F-test) or a maximum number of
%   harmonics is reached.
%
% INPUT
%   x           Time series (vector). Must be numeric, finite, and contain
%               no NaN values.
%
% NAME-VALUE PARAMETERS (all optional)
%
%   TIME VECTOR
%       't' or 'time'
%                   Time vector. If not provided, indices (1:N) are used.
%                   Supported types:
%                       - numeric: interpreted as time values
%                       - datetime: automatically converted to days since first
%                       - duration: automatically converted to days
%                   Default: 1:length(x)
%
%   PERIOD SEARCH RANGE
%       'ip' or 'minperiod'
%                   Initial/minimum period tested. Must be positive.
%                   Units are the same as the sampling interval of t.
%                   Default: 3 (samples)
%
%       'lp' or 'maxperiod'
%                   Maximum period tested. Must be positive and greater than ip.
%                   Units are the same as the sampling interval of t.
%                   Default: N/2 (Nyquist limit)
%
%       'step'      Period search resolution. Must be positive.
%                   Smaller values give finer resolution but increase computation.
%                   Units are the same as the sampling interval of t.
%                   Default: mean(diff(t)) (sampling interval)
%
%   HARMONIC SELECTION
%       'hn' or 'harmonics'
%                   Maximum number of harmonics (periods) to extract.
%                   If provided, the algorithm will extract exactly this many
%                   periods (or until no periods remain to test).
%                   If omitted, the model stops automatically using an F-test.
%                   Default: [] (automatic selection)
%
%       'neig', 'neigh', or 'neighbors'
%                   Number of neighboring periods removed after a period is found.
%                   Helps avoid detecting the same spectral peak repeatedly.
%                   Options:
%                       -1 : remove only the detected period (default)
%                        0 : keep all periods (may detect harmonics)
%                      n>0: remove n periods on each side (total 2n+1 periods)
%                   Default: -1
%
%   MODEL OPTIONS
%       'trend'     Logical flag to remove linear trend before analysis.
%                   If true, a linear trend is fitted and removed before
%                   period detection, then added back in final model.
%                   Default: false
%
%       'robust'    Logical flag to use robust regression for final model.
%                   If true, uses bisquare weights to reduce influence of outliers.
%                   Default: false
%
%       'alpha'     Significance level for F-test in automatic mode.
%                   Must be between 0 and 1. A new harmonic is added only if
%                   its p-value is less than alpha.
%                   Default: 0.05
%
%   PERIOD LISTS
%       'known'     Vector of periods to test exclusively (bypasses search).
%                   When provided, the algorithm tests only these periods
%                   in the given order, instead of searching through ip:step:lp.
%                   Default: []
%
%       'include'   Periods forced into the final model.
%                   These periods are added after the automatic selection,
%                   regardless of their statistical significance.
%                   Can include named periods (see NOTES below).
%                   Default: []
%
%       'exclude'   Periods removed from the final model.
%                   These periods are excluded from both the search and
%                   the final model, even if they would otherwise be selected.
%                   Can include named periods (see NOTES below).
%                   Default: []
%
%   PREDICTION
%       'predict'   Time vector or number of steps for prediction.
%                   If numeric scalar, generates that many equally spaced
%                   points after the last time value.
%                   If vector, uses these time values for prediction.
%                   Default: [] (no prediction)
%
%   VISUALIZATION
%       'plots', 'plot', or 'plt'
%                   Plot control:
%                       'none'  – no plots (default)
%                       'all'   – show cyclic descent steps
%                       'final' – show final model only
%                   Default: 'none'
%
% OUTPUT
%   p           Structure with harmonic parameters:
%                   p.period       Dominant periods detected
%                   p.amplitude    Amplitude of each harmonic
%                   p.phase        Phase (radians) of each harmonic
%                   p.lag          Lag (time units) of each harmonic
%
%   model       Structure with reconstructed series:
%                   model.xfit      fitted model (same length as x)
%                   model.xpred     fitted + prediction (if requested)
%                   model.period    same as p.period
%                   model.amplitude same as p.amplitude
%                   model.phase     same as p.phase
%
%   stats       Model statistics:
%                   stats.R2        R-squared of final model
%                   stats.AdjR2     Adjusted R-squared
%                   stats.R2step    R-squared at each step
%                   stats.F         F-statistic for each added harmonic
%                   stats.pval      p-value for each added harmonic
%                   stats.AIC       Akaike Information Criterion
%                   stats.BIC       Bayesian Information Criterion
%
% NAMED PERIODS
%   The following named periods can be used in 'include' and 'exclude':
%       Annual/seasonal:
%           'annual'      = 365.2422 days
%           'semiannual'  = 182.6211 days
%           'seasonal'    = 91.3106 days (quarterly)
%       
%       Tidal (in days):
%           'm2'          = 12.4206/24 days (principal lunar)
%           's2'          = 12/24 days (principal solar)
%           'k1'          = 23.9345/24 days (luni-solar diurnal)
%           'o1'          = 25.8193/24 days (principal lunar diurnal)
%       
%       Climate indices:
%           'qbo'         = 840 days (Quasi-Biennial Oscillation)
%           'enso'        = [1095, 1826] days (El Niño ~3-5 years)
%           'decadal'     = 3652 days (~10 years)
%           'pdo'         = [7305, 9131] days (Pacific Decadal Oscillation ~20-25 years)
%           'solar'       = 4017 days (~11 years solar cycle)
%           'amo'         = 21915 days (~60 years Atlantic Multidecadal Oscillation)
%
% METHOD
%   The algorithm implements the cyclic descent method described in:
%
%   González-Rodríguez et al. (2015)
%   Computational Method for Extracting and Modeling Periodicities
%   in Time Series. Open Journal of Statistics.
%   This approach has several practical advantages:
%       • Works directly with the time series (no spectral transform)
%       • Provides amplitudes and phases from the regression model
%       • Allows irregular time vectors
%       • Handles strong non-sinusoidal signals through harmonic expansion
%       • Model selection can be controlled statistically (F-test)
%
%   As a result, the method can be particularly useful in geophysical and
%   climate time series where periodic signals are embedded in noise and
%   may deviate from perfect sinusoidal behavior.
%
% EXAMPLES
%
%   % Basic usage with default parameters
%   load sunspot.dat
%   t = sunspot(:,1);
%   x = sunspot(:,2);
%   [p, model] = findPeriods(x, 't', t);
%
%   % With custom search range and neighbor removal
%   [p, model] = findPeriods(x, 't', t, 'step', 0.1, 'neig', 3);
%
%   % Using named periods
%   [p, model] = findPeriods(x, 't', t, 'include', {'annual', 'solar'});
%
%   % With trend removal and robust regression
%   [p, model, stats] = findPeriods(x, 't', t, 'trend', true, 'robust', true);
%
%   % With prediction
%   [p, model] = findPeriods(x, 't', t, 'predict', 10); % predict 10 steps ahead
%
%   % With visualization
%   [p, model] = findPeriods(x, 't', t, 'plots', 'final');
%
% Expected dominant periods in sunspot data:
%       ~11 years  (Schwabe solar cycle)
%       ~22 years  (Hale cycle)
%
% See also FFT, PERIODOGRAM
% EGR with help from IA 20260306

% Validación de entrada principal
validateattributes(x, {'numeric'}, {'finite', 'vector'}, 'findPeriods', 'x');
x = x(:);
n = numel(x);
if any(isnan(x))
    error('NaNs not allowed')
end

% Inicialización de parámetros
t = [];
ip = 3;
lp = [];
step = 1;
hn = [];
neig = -1;
trend = false;
robust = false;
alpha = 0.05;
known = [];
exclude = [];
include = [];
predict = [];
plots = 'none';

% Parseo de parámetros nombre-valor
for k = 1:2:numel(varargin)
    switch lower(varargin{k})
        case {'t','time'}
            t = varargin{k+1};
        case {'ip','minperiod'}
            ip = varargin{k+1};
            validateattributes(ip, {'numeric'}, {'positive', 'scalar'}, 'findPeriods', 'ip');
        case {'lp','maxperiod'}
            lp = varargin{k+1};
            validateattributes(lp, {'numeric'}, {'positive', 'scalar'}, 'findPeriods', 'lp');
        case 'step'
            step = varargin{k+1};
            validateattributes(step, {'numeric'}, {'positive', 'scalar'}, 'findPeriods', 'step');
        case {'hn','harmonics'}
            hn = varargin{k+1};
            validateattributes(hn, {'numeric'}, {'positive', 'integer', 'scalar'}, 'findPeriods', 'hn');
        case {'neig','neigh','neighbors'}
            neig = varargin{k+1};
            validateattributes(neig, {'numeric'}, {'integer', 'scalar'}, 'findPeriods', 'neig');
        case 'trend'
            trend = varargin{k+1};
            validateattributes(trend, {'logical'}, {'scalar'}, 'findPeriods', 'trend');
        case 'robust'
            robust = varargin{k+1};
            validateattributes(robust, {'logical'}, {'scalar'}, 'findPeriods', 'robust');
        case 'alpha'
            alpha = varargin{k+1};
            validateattributes(alpha, {'numeric'}, {'positive', 'scalar', '<=', 1}, 'findPeriods', 'alpha');
        case 'known'
            known = varargin{k+1};
        case 'include'
            include = varargin{k+1};
        case 'exclude'
            exclude = varargin{k+1};
        case 'predict'
            predict = varargin{k+1};
        case {'plots', 'plot', 'plt'}
            plots = varargin{k+1};
        otherwise
            error('Unknown option: %s', varargin{k})
    end
end

% Diccionario de períodos conocidos
dict = struct;
dict.annual     = 365.2422;
dict.semiannual = 365.2422/2;
dict.seasonal   = 365.2422/4;

dict.m2 = 12.4206/24;
dict.s2 = 12/24;
dict.k1 = 23.9345/24;
dict.o1 = 25.8193/24;

dict.qbo  = 840;
dict.enso = [1095 1826];
dict.decadal = 3652;
dict.pdo  = [7305 9131];
dict.solar = 4017;
dict.amo  = 21915;

% Expandir períodos nombrados
include = expandPeriods(include, dict);
exclude = expandPeriods(exclude, dict);

% Preparación del vector de tiempo
if isempty(t)
    t = (1:n)';
elseif isa(t, 'datetime') || isa(t, 'duration')
    t = days(t - t(1));
else
    t = t(:);
end
if numel(t) ~= n
    error('t length mismatch')
end

[t, ix] = sort(t);
x = x(ix);
tunit = mean(diff(t));

if isempty(lp)
    lp = ceil(n/2);
end
if step > tunit
    step = tunit;
end

% Eliminación de tendencia lineal
if trend
    p_trend = polyfit(t, x, 1);
    trend_line = polyval(p_trend, t);
    y = x - trend_line;
else
    y = x - mean(x);
end

% Definición de períodos a probar
if ~isempty(known)
    perds = known(:);
else
    perds = (tunit * ip):step:(tunit * lp);
    if ~isempty(exclude)
        perds = setdiff(perds, exclude);
    end
end

auto = isempty(hn);
if auto
    hn = 1;
end

% Inicialización de variables
Per = [];
Amp = [];
Pha = [];
z = y;
TSS = sum((y - mean(y)).^2);
RSS = [];
R2 = [];
np = 2;
nH = 0;
Fval = [];
Pval = [];

% Bucle principal de cyclic descent
while nH < hn
    nH = nH + 1;
    A = zeros(numel(perds), 1);
    F = A;
    RRSS = A;
    
    if isempty(known)
        for k = 1:numel(perds)
            [A(k), F(k), RRSS(k)] = fitHarmonic(z, t, perds(k));
        end
        [~, ixm] = max(RRSS);
        OP = perds(ixm);
        Per = [Per; OP];
        Amp = [Amp; A(ixm)];
        Pha = [Pha; F(ixm)];
    else
        OP = perds(nH);
        [Amp(end+1), Pha(end+1), ~] = fitHarmonic(z, t, OP);
        Per = [Per; OP];
    end
    
    w = 2 * pi / Per(end);
    hc = Amp(end) * cos(w * t - Pha(end));
    z = z - hc;
    
    if nH == 1
        hcum = hc;
    else
        hcum = hcum + hc;
    end
    
    RSS(nH) = sum((y - hcum).^2);
    R2(nH) = 1 - RSS(nH) / TSS;
    
    % Eliminación de períodos vecinos
    if neig ~= 0 && isempty(known)
        if neig == -1
            perds = setdiff(perds, OP);
        else
            permin = OP - neig * tunit;
            permax = OP + neig * tunit;
            ix = perds >= permin & perds <= permax;
            perds = perds(~ix);
        end
    end
    
    % Prueba F para selección automática
    if nH > 1 && auto
        dfn = np;
        dfd = n - nH * np - 1;
        Fs = ((RSS(nH - 1) - RSS(nH)) / dfn) / (RSS(nH) / dfd);
        pval = 1 - fcdf(Fs, dfn, dfd);
        Fval(nH - 1) = Fs;
        Pval(nH - 1) = pval;
        
        if pval > alpha
            Per(end) = [];
            Amp(end) = [];
            Pha(end) = [];
            hcum = hcum - hc;
            break
        end
    end
    
    % Visualización paso a paso
    if strcmpi(plots, 'all')
        figure
        set(gcf, 'Position', [100 100 1120 450])
        if isempty(known)
            subplot(2, 1, 1)
            plot(perds, RRSS, 'k')
            title(['OP = ' num2str(OP / tunit)], 'fontsize', 12)
        end
        subplot(2, 1, 2)
        hold on
        plot(t, x, 'o-', 'color', [.5 .5 .5], 'markersize', 2)
        plot(t, hcum + mean(x), 'b', 'linewidth', 2)
        hold off
        title(['R^2 = ' num2str(R2(end), '%.3f')])
    end
    
    if auto
        hn = hn + 1;
    end
end

% Inclusión forzada de períodos
if ~isempty(include) && isempty(known)
    for k = 1:numel(include)
        [A_inc, P_inc, ~] = fitHarmonic(y, t, include(k));  % Usar y original, no z residual
        Per = [Per; include(k)];
        Amp = [Amp; A_inc];
        Pha = [Pha; P_inc];
    end
end

% Eliminación de períodos duplicados
[Per, ia, ~] = unique(Per, 'stable');
Amp = Amp(ia);
Pha = Pha(ia);
if numel(ia) < numel(Per)
    warning('Períodos duplicados fueron eliminados');
end

% Construcción de la matriz de diseño
Y = zeros(n, 2 * numel(Per));
for k = 1:numel(Per)
    Y(:, 2 * k - 1) = cos(2 * pi / Per(k) * t);
    Y(:, 2 * k) = sin(2 * pi / Per(k) * t);
end

% Inclusión de tendencia en el modelo final
if trend
    X = [ones(n, 1) t Y];
else
    X = Y;
end

% Regresión final (robusta o estándar)
if robust
    b = robustfit(X(:, 2:end), x, 'bisquare', [], 'off');  % Sin intercepto
    if trend
        b = [robustfit(X(:, 2:end), x); 0];  % Ajuste para consistencia
    end
else
    b = X \ x;
end

% Extracción de coeficientes
if trend
    alpha0 = b(1);
    beta = b(2);
    coef = b(3:end);
else
    alpha0 = 0;
    beta = 0;
    coef = b;
end

% Parámetros armónicos finales
ai = coef(1:2:end);
bi = coef(2:2:end);
AmpN = hypot(ai, bi);
PhaN = atan2(bi, ai);
LagN = (Per .* PhaN) / (2 * pi);
Params = [Per, AmpN, PhaN, LagN];

% Eliminación de períodos excluidos
if ~isempty(exclude)
    tol = step;
    keep = true(size(Params, 1), 1);
    for k = 1:numel(exclude)
        keep = keep & abs(Params(:, 1) - exclude(k)) > tol;
    end
    Params = Params(keep, :);
end

% Reconstrucción del modelo
xe = zeros(n, 1);
for k = 1:size(Params, 1)
    w = 2 * pi / Params(k, 1);
    xe = xe + Params(k, 2) * cos(w * t - Params(k, 3));
end
xe = alpha0 + beta * t + xe + mean(x);

% Predicción
if isempty(predict)
    xef = [];
else
    pt = [t; predict(:)];
    xef = zeros(numel(pt), 1);
    for k = 1:size(Params, 1)
        w = 2 * pi / Params(k, 1);
        xef = xef + Params(k, 2) * cos(w * pt - Params(k, 3));
    end
    xef = alpha0 + beta * pt + xef + mean(x);
end

% Estadísticas del modelo
SSE = sum((x - xe).^2);
SST = sum((x - mean(x)).^2);
R2f = 1 - SSE / SST;
AdjR2 = 1 - (1 - R2f) * (n - 1) / (n - size(X, 2) - 1);

% Criterios de información
AIC = n * log(SSE / n) + 2 * size(X, 2);
BIC = n * log(SSE / n) + log(n) * size(X, 2);

% Estructuras de salida
p.period = Params(:, 1) / tunit;
p.amplitude = Params(:, 2);
p.phase = Params(:, 3);
p.lag = Params(:, 4);

model.xfit = xe;
model.xpred = xef;
model.period = p.period;
model.amplitude = p.amplitude;
model.phase = p.phase;

stats.R2 = R2f;
stats.AdjR2 = AdjR2;
stats.R2step = R2(:);
stats.F = Fval(:);
stats.pval = Pval(:);
stats.AIC = AIC;
stats.BIC = BIC;

% Visualización final
perstr = 'Periods = ';
for k = 1:numel(p.period)
    perstr = [perstr num2str(p.period(k), '%.2f') ', '];
end
perstr(end-1:end) = [];

if strcmpi(plots, 'final') || strcmpi(plots, 'all')
    figure
    hold on
    if ~isempty(xef)
        plot(pt, xef, 'g', 'LineWidth', 1.5)
    end
    plot(t, xe, 'k', 'LineWidth', 1.2)
    plot(t, x, 'o-', 'Color', [0.1 0.2 0.6], 'MarkerFaceColor', 'k', 'MarkerSize', 2)
    grid on
    xlabel('Time')
    ylabel('Signal')
    title({perstr; ...
        ['R^2 = ' num2str(stats.R2, '%.3f') ...
        ', AdjR^2 = ' num2str(stats.AdjR2, '%.3f') ...
        ', Harmonics = ' num2str(numel(stats.R2step))]})
    hold off
end

end % Fin de función principal

% -------------------------------------------------------------------------
function [A, phi, RRSS] = fitHarmonic(z, t, period)
% Subfunción para ajustar un armónico simple
    w = 2 * pi / period;
    cs = [cos(w * t) sin(w * t)];
    c = cs \ z;
    A = hypot(c(1), c(2));
    phi = atan2(c(2), c(1));
    hc = A * cos(w * t - phi);
    RRSS = 1 / sum((z - hc).^2);
end

% -------------------------------------------------------------------------
function out = expandPeriods(val, dict)
% Subfunción para expandir nombres de períodos
    if isempty(val)
        out = [];
        return
    end
    if isnumeric(val)
        out = val(:);
        return
    end
    if ischar(val) || isstring(val)
        val = {val};
    end
    
    % Inicializar como cell array y luego convertir
    out_temp = {};
    for i = 1:numel(val)
        key = lower(val{i});
        if isfield(dict, key)
            out_temp{end+1} = dict.(key)(:);
        else
            error('Unknown cycle: %s', key)
        end
    end
    out = vertcat(out_temp{:});
    out = out(:);
end