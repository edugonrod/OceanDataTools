function xtickLab = xticklabel2rows(varargin)
% XTICKLABEL2ROWS  Create multi-line x-tick labels (optimized for numbers below)
%
%   xtickLab = XTICKLABEL2ROWS(row1, row2)
%   xtickLab = XTICKLABEL2ROWS(row1, row2, row3)
%
%   Perfect for putting numeric values (years, depths, etc.) below text labels.
%   Scalars are automatically expanded to match vector lengths.
%
%   Examples:
%       % Same year for all ticks
%       xtickLab = xticklabel2rows({'Ene','Feb','Mar'}, 2020);
%
%       % Different years
%       xtickLab = xticklabel2rows({'Ene','Feb','Mar'}, [2020, 2020, 2021]);
%
%       % With three rows
%       xtickLab = xticklabel2rows({'Ene','Feb'}, 2020, {'15°C','18°C'});

% Convert all inputs to cell arrays of strings
nRows = nargin;
labelArray = cell(nRows, 1);

for k = 1:nRows
    row = varargin{k};
    
    % Convert to cellstr based on type
    if isnumeric(row)
        if isscalar(row)
            % Expand scalar to match others later
            row = {num2str(row)};
        else
            row = arrayfun(@num2str, row, 'UniformOutput', false);
        end
    elseif isstring(row)
        row = cellstr(row);
    elseif ischar(row)
        row = cellstr(row);
    elseif ~iscellstr(row)
        error('Input %d must be string, cellstr, or numeric', k);
    end
    
    labelArray{k} = row(:)';  % Ensure row vector
end

% Find maximum length among non-scalar cells
lengths = cellfun(@length, labelArray);
nonScalarIdx = lengths > 1;
if any(nonScalarIdx)
    targetLen = max(lengths(nonScalarIdx));
else
    targetLen = 1;
end

% Expand scalars to match target length
for k = 1:nRows
    if length(labelArray{k}) == 1
        labelArray{k} = repmat(labelArray{k}, 1, targetLen);
    elseif length(labelArray{k}) ~= targetLen
        error('All inputs must have same length or be scalars');
    end
end

% Create combined labels
if nRows == 2
    formatStr = '%s\\newline%s\n';
elseif nRows == 3
    formatStr = '%s\\newline%s\\newline%s\n';
else
    error('Function supports 2 or 3 input rows only');
end

% Combine and return
labelMatrix = vertcat(labelArray{:});
xtickLab = strtrim(sprintf(formatStr, labelMatrix{:}));
xtickLab = splitlines(xtickLab);
xtickLab(cellfun(@isempty, xtickLab)) = [];
end
