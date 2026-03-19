function gifWriter(filename, varargin)
% GIFWRITER Modern and robust utility for creating animated GIFs.
%
% BASIC USAGE
%   gifWriter('anim.gif')    % Initialize GIF file
%   gifWriter()              % Append current frame
%   gifWriter('close')       % Finalize and clear writer
%
% ADVANCED USAGE
%   gifWriter('anim.gif','DelayTime',0.05,'Quality',128)
%   for k = 1:10
%       plot(...);
%       gifWriter();
%   end
%   gifWriter('close')
%
% DESCRIPTION
%   GIFWRITER simplifies the creation of animated GIFs directly from MATLAB
%   figures. The function initializes a persistent writer, captures frames
%   from the current figure (or a specified figure handle), and appends them
%   to the GIF file.
%
% INPUTS
%   filename
%       Name of the GIF file to create. If the string 'close' is provided,
%       the current GIF writer is cleared.
%
% NAME–VALUE OPTIONS
%   'DelayTime'
%       Time between frames in seconds (default: 0.1).
%
%   'LoopCount'
%       Number of animation loops. Use Inf for infinite looping (default).
%
%   'Quality'
%       Number of colors used in the GIF colormap (default: 256).
%
%   'Frame'
%       Figure handle used to capture frames (default: gcf).
%
%   'Dither'
%       Logical flag controlling dithering during color quantization
%       (default: true).
%
%   'Stabilize'
%       Captures an initial frame to stabilize rendering before recording
%       the first frame (default: true).
%
% NOTES
%   • Frames are captured using GETFRAME.
%   • Existing GIF files with the same name are overwritten at initialization.
%   • The function uses a persistent writer to efficiently append frames.
%
% EGR 20250306

persistent writer

% Cerrar writer
if nargin > 0 && strcmpi(filename, 'close')
    clear writer;
    return;
end

% Inicializar
if nargin > 0 && contains(filename, '.gif')
    % Defaults optimizados para animaciones largas
    opts = struct('DelayTime', 1/10, ...      
        'LoopCount', Inf, ...
        'Quality', 256, ...
        'Frame', gcf, ...
        'Dither', true, ...
        'Stabilize', true);
    
    % Parsear inputs
    for i = 1:2:length(varargin)
        if isfield(opts, varargin{i})
            opts.(varargin{i}) = varargin{i+1};
        end
    end
    
    % Crear writer
    writer = struct('filename', filename, 'opts', opts, 'firstFrame', true);
    
    % Sobrescribir si existe
    if exist(filename, 'file')
        delete(filename);
    end
    return;
end

% Verificar inicialización
if isempty(writer)
    error('First initialize: gifWriter(''filename.gif'')');
end

% Capturar frame
if writer.firstFrame && writer.opts.Stabilize
    getframe(writer.opts.Frame);
end

f = getframe(writer.opts.Frame);

if writer.opts.Dither
    [imind, cmap] = rgb2ind(f.cdata, writer.opts.Quality, 'dither');
else
    [imind, cmap] = rgb2ind(f.cdata, writer.opts.Quality, 'nodither');
end

% Escribir
if writer.firstFrame
    imwrite(imind, cmap, writer.filename, 'gif', ...
        'LoopCount', writer.opts.LoopCount, ...
        'DelayTime', writer.opts.DelayTime);
    writer.firstFrame = false;
else
    imwrite(imind, cmap, writer.filename, 'gif', ...
        'WriteMode', 'append', ...
        'DelayTime', writer.opts.DelayTime);
end
end
