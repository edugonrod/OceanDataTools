function unpackstruct(S,replace,exclude)
%UNPACKSTRUCT Copy struct fields to caller workspace
% unpackstruct(S)
% unpackstruct(S,replace)
% unpackstruct(S,replace,exclude)
%
% Inputs
%   S        struct
%   replace  logical, overwrite existing variables (default false)
%   exclude  cell array with field names to skip
%
% Example
%   out = readncocean(files,cfg,lonlims,latlims);
%   unpackstruct(out)
%   unpackstruct(out,true)
%   unpackstruct(out,false,{'units','longname','palette'})

if nargin < 2 || isempty(replace)
    replace = false;
end

if nargin < 3
    exclude = {};
end

f = fieldnames(S);
for k = 1:numel(f)
    name = f{k};
    if any(strcmp(name,exclude))
        continue
    end

    if ~replace
        if evalin('caller',sprintf('exist(''%s'',''var'')',name))
            continue
        end
    end
    assignin('caller',name,S.(name));
end
