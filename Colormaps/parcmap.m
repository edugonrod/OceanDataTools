function cmap = parcmap(n_colors)
% Paleta personalizada para PAR (Radiación Fotosintéticamente Activa)
% Genera una paleta de 256 colores interpolados
if nargin < 1
    % Número de puntos deseados (256 colores)
    n_colors = 256;
end

% Colores base (10 puntos de control)
base_colors = [
    0.00, 0.00, 0.20;  % Azul marino oscuro (muy bajo PAR)
    0.20, 0.00, 0.40;  % Púrpura oscuro
    0.40, 0.00, 0.60;  % Púrpura
    0.60, 0.00, 0.80;  % Violeta
    0.80, 0.00, 1.00;  % Magenta
    1.00, 0.20, 0.80;  % Rosa
    1.00, 0.40, 0.40;  % Rojo claro
    1.00, 0.60, 0.20;  % Naranja
    1.00, 0.80, 0.00;  % Amarillo dorado
    1.00, 1.00, 0.00;  % Amarillo brillante (muy alto PAR)
];

% Crear puntos de interpolación
x_base = linspace(1, n_colors, size(base_colors, 1));
x_new = 1:n_colors;

% Interpolar cada canal de color (R, G, B) por separado
cmap(:,1) = interp1(x_base, base_colors(:,1), x_new, 'linear');
cmap(:,2) = interp1(x_base, base_colors(:,2), x_new, 'linear');
cmap(:,3) = interp1(x_base, base_colors(:,3), x_new, 'linear');

% Asegurar que los valores estén en el rango [0,1]
cmap = max(0, min(1, cmap));

end