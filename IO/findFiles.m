function files = findFiles(rootPath)
% findFiles Recursively search files and return full paths.
%
%   files = findFiles()
%   files = findFiles('*.m')
%   files = findFiles('/path/data/*.nc')
%
% Performs a recursive file search starting from a specified directory and
% returns a structure array containing file information with full paths.
%
% INPUT
%   rootPath
%       Search path and optional filename pattern.
%
%       Examples:
%           findFiles()                search all files from current folder
%           findFiles('*.m')           search MATLAB files recursively
%           findFiles('/data/*.nc')    search NetCDF files in /data
%
% OUTPUT
%   files
%       Structure array with fields:
%
%           .name
%               Full path to the file or directory.
%
%           .date
%               File modification date.
%
%           .bytes
%               File size in bytes.
%
%           .isdir
%               Logical flag indicating whether the entry is a directory.
%
% DESCRIPTION
%   The function performs a recursive directory search using DIR and the
%   '**' wildcard. It returns a structure similar to the output of DIR but
%   replaces the NAME field with the full file path for convenience.
%
%   The entries '.' and '..' are automatically removed from the output.
%
% EXAMPLES
%   files = findFiles('*.m');
%
%   files = findFiles('/data/*.nc');
%
%   % Extract file paths
%   paths = {files.name};
%
% SEE ALSO
%   DIR, FULLFILE
%
% EGR


arguments
    rootPath {mustBeText} = pwd
end

rootPath = string(rootPath);

% Separar ruta y patrón
if ~contains(rootPath, filesep) && contains(rootPath, ['*', '?'])
    basePath = string(pwd);
    pattern = rootPath;
else
    [folder, name, ext] = fileparts(rootPath);
    basePath = folder;
    if basePath == "", basePath = pwd; end
    pattern = name + ext;
    if pattern == "", pattern = "*"; end
end

% Búsqueda recursiva
allFiles = dir(fullfile(basePath, "**", pattern));

% Construir struct con ruta completa en .name
if ~isempty(allFiles)
    % Pre-asignar struct
    files = struct('name', {}, 'date', {}, 'bytes', {}, 'isdir', {});
    files = repmat(files, size(allFiles));

    for i = 1:numel(allFiles)
        files(i).name = char(fullfile(allFiles(i).folder, allFiles(i).name));
        files(i).date = allFiles(i).date;
        files(i).bytes = allFiles(i).bytes;
        files(i).isdir = allFiles(i).isdir;
    end

    % Filtrar . y ..
    names = {files.name};
    [~, fname] = cellfun(@fileparts, names, 'UniformOutput', false);
    isDotDir = false(size(files));
    for i = 1:numel(files)
        if files(i).isdir && (strcmp(fname{i}, '.') || strcmp(fname{i}, '..'))
            isDotDir(i) = true;
        end
    end
    files(isDotDir) = [];
else
    files = struct('name', {}, 'date', {}, 'bytes', {}, 'isdir', {});
end
