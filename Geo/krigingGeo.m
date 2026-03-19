function [Zi, VarZ] = krigingGeo(X, Y, Z, Xi, Yi, options)
% krigingGeo Gaussian Process kriging interpolation for geographic data.
%
%   Zi = krigingGeo(X, Y, Z, Xi, Yi)
%   [Zi, VarZ] = krigingGeo(X, Y, Z, Xi, Yi, options)
%
% Performs spatial interpolation using Gaussian Process Regression (GPR),
% equivalent to kriging with a specified covariance kernel. The method
% predicts values at new geographic locations and optionally returns the
% prediction variance.
%
% INPUTS
%   X, Y, Z
%       Column vectors containing the coordinates and observed values.
%
%   Xi, Yi
%       Coordinates where the interpolation is evaluated. These can be
%       vectors or matrices (e.g., meshgrid outputs).
%
%   options
%       Structure containing optional parameters:
%
%       .Kernel
%           Covariance kernel used by the GPR model:
%
%               'squaredexponential' (default)
%               'exponential'
%               'matern32'
%               'matern52'
%               'rationalquadratic'
%
%       .Standardize
%           Logical flag indicating whether predictors are standardized
%           before training (default true).
%
%       .Noise
%           Standard deviation of observation noise. If empty, it is
%           estimated as 0.1 * std(Z).
%
%       .BlockSize
%           Number of prediction points processed per block during
%           evaluation (default 1000). Useful for large grids.
%
%       .UseParallel
%           Logical flag enabling parallel block prediction (default false).
%
%       .Verbose
%           Logical flag controlling progress messages (default false).
%
% OUTPUTS
%   Zi
%       Interpolated values at locations (Xi, Yi). The output has the same
%       shape as Xi.
%
%   VarZ
%       Prediction variance estimated by the Gaussian process model.
%
% DESCRIPTION
%   The function fits a Gaussian Process Regression model using the
%   Statistics and Machine Learning Toolbox and then predicts values at
%   new locations. Predictions are performed in blocks to reduce memory
%   usage and optionally support parallel execution.
%
% NOTES
%   • Requires the Statistics and Machine Learning Toolbox.
%   • NaN values in the input observations are automatically removed.
%   • Block processing improves performance when interpolating large grids.
%
% EXAMPLE
%   [Xi,Yi] = meshgrid(linspace(-120,-100,200),linspace(20,35,200));
%   Zi = krigingGeo(X,Y,Z,Xi,Yi);
%
% EGR

arguments
    X (:,1) double
    Y (:,1) double
    Z (:,1) double
    Xi (:,:) double
    Yi (:,:) double
    options.Kernel char = 'squaredexponential'
    options.Standardize (1,1) logical = true
    options.Noise (1,1) double = []
    options.BlockSize (1,1) double {mustBePositive} = 1000
    options.UseParallel (1,1) logical = false
    options.Verbose (1,1) logical = false
end

% Validar toolbox
if ~license('test', 'Statistics_Toolbox')
    error('Se requiere Statistics and Machine Learning Toolbox');
end

% Preparar datos
valid = ~isnan(X) & ~isnan(Y) & ~isnan(Z);
X = X(valid); Y = Y(valid); Z = Z(valid);

% Estimar ruido si no se proporciona
if isempty(options.Noise)
    sigma0 = std(Z) * 0.1;
else
    sigma0 = options.Noise;
end

% Crear modelo GPR
if options.Verbose
    fprintf('Entrenando modelo...\n');
end

gprMdl = fitrgp([X, Y], Z, ...
    'KernelFunction', options.Kernel, ...
    'Standardize', options.Standardize, ...
    'Sigma', sigma0);

% Preparar puntos de predicción
Xi_vec = Xi(:);
Yi_vec = Yi(:);
nPred = length(Xi_vec);
X_pred_new = [Xi_vec, Yi_vec];

% Predicción por bloques
nBlocks = ceil(nPred / options.BlockSize);
Zi = zeros(nPred, 1);
VarZ = zeros(nPred, 1);

if options.Verbose
    fprintf('Prediciendo %d puntos en %d bloques...\n', nPred, nBlocks);
end

if options.UseParallel && nBlocks > 1
    % Para paralelo, necesitamos una celda de resultados
    Zi_cell = cell(nBlocks, 1);
    VarZ_cell = cell(nBlocks, 1);

    parfor iBlock = 1:nBlocks
        idx = (iBlock-1)*options.BlockSize + 1 : ...
            min(iBlock*options.BlockSize, nPred);
        [Zi_cell{iBlock}, VarZ_cell{iBlock}] = predict(gprMdl, X_pred_new(idx, :));
    end

    % Combinar resultados
    Zi = vertcat(Zi_cell{:});
    VarZ = vertcat(VarZ_cell{:});
else
    for iBlock = 1:nBlocks
        idx = (iBlock-1)*options.BlockSize + 1 : ...
            min(iBlock*options.BlockSize, nPred);
        [Zi(idx), VarZ(idx)] = predict(gprMdl, X_pred_new(idx, :));
    end
end

% Reconstruir forma original
Zi = reshape(Zi, size(Xi));
VarZ = reshape(VarZ, size(Xi));
