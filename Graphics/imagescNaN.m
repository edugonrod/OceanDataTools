function h = imagescNaN(x, y, data, varargin)
%imagescNaN  Display image with NaN values rendered as transparent.
%
%   imagescNaN(DATA) displays DATA using imagesc, making NaN values
%   transparent so the background is visible.
%
%   imagescNaN(X, Y, DATA) specifies coordinate vectors X and Y,
%   similar to imagesc(X,Y,DATA).
%
%   H = imagescNaN(...) returns the image handle.

% Parsear argumentos de entrada
p = inputParser;
addOptional(p, 'Alpha', 1, @(x) x>=0 && x<=1);
parse(p, varargin{:});
global_alpha = p.Results.Alpha;

% Determinar si tenemos x,y o solo data
if nargin >= 3 && isnumeric(x) && isnumeric(y) && isnumeric(data)
    % Caso: imagescNaN(x, y, data, ...)
    if ~isvector(x)
        x = x(1,:);
    end
    if ~isvector(y)
        y = y(:,1);
    end
    h = imagesc(x, y, real(data));
elseif nargin >= 1 && isnumeric(x)
    % Caso: imagescNaN(data, ...)
    data = x;
    if nargin >= 2 && isnumeric(y)
        global_alpha = y;
    end
    h = imagesc(data);
end

axis xy tight

% Aplicar transparencia donde hay NaNs
alphaData = ~isnan(data);

% Aplicar transparencia global
if global_alpha < 1
    alphaData = alphaData * global_alpha;
end

if sum(~alphaData(:)) ~= 0
    ax = gca;
    set(h, 'AlphaData', alphaData);
    ax.Color = [1 1 1];    % Fondo blanco
end

if nargout == 0
    clear h
end
