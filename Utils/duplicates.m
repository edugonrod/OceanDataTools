function [dup, counts, ix] = duplicates(x, direction)
%DUPLICATES  Find duplicate elements in an array
%   [DUP, COUNTS, IX] = DUPLICATES(X) finds all duplicate elements in X.
%   [DUP, COUNTS, IX] = DUPLICATES(X, DIRECTION) controls which occurrences
%   are marked in the output index.
%
%   INPUTS:
%       x         : Numeric array, cell array, or string array
%       direction : Specifies which duplicates to return in IX:
%                   'all'   - Mark all occurrences of duplicate values (default)
%                   'first' - Mark only first occurrence of each duplicate
%                   'last'  - Mark only last occurrence of each duplicate
%
%   OUTPUTS:
%       dup     : Unique duplicate values (each repeated value appears once)
%       counts  : Number of occurrences for each duplicate value
%       ix      : Logical index marking the selected occurrences
%
%   EXAMPLES:
%       % Example 1: Basic usage
%       x = [1 2 3 2 4 3 3 5];
%       [dup, counts, ix] = duplicates(x)
%       % dup    = [2; 3]
%       % counts = [2; 3]
%       % ix     = [0 1 1 1 0 1 1 0]'  (all duplicates)
%
%       % Example 2: First occurrences only
%       [dup, counts, ix] = duplicates(x, 'first')
%       % ix = [0 1 1 0 0 0 0 0]'  (first 2 and first 3)
%
%       % Example 3: Last occurrences only
%       [dup, counts, ix] = duplicates(x, 'last')
%       % ix = [0 0 0 1 0 0 1 0]'  (last 2 and last 3)
%
%       % Example 4: Cell array of strings
%       names = {'John', 'Mary', 'John', 'Peter', 'Mary', 'John'};
%       [dup, counts, ix] = duplicates(names)
%       % dup    = {'John'; 'Mary'}
%       % counts = [3; 2]
%       % ix     = [1 1 1 0 1 1]'  (all Johns and Marys)
%
%       % Example 5: Matrix with rows (using 'rows' option)
%       X = [1 1; 2 2; 1 1; 3 3; 2 2];
%       [dup, counts, ix] = duplicates(X, 'all')
%       % dup    = [1 1; 2 2]
%       % counts = [2; 2]
%       % ix     = [1 1 1 0 1]'  (all duplicate rows)
%
%       % Example 6: Practical use - find and remove duplicates
%       data = [10 20 10 30 20 40];
%       [~, ~, ix_dups] = duplicates(data, 'first');
%       clean_data = data(~ix_dups);  % Keep only first occurrences
%       % clean_data = [10 20 30 40]
%
%       % Example 7: Statistics on duplicates
%       x = [1 1 2 2 2 3 4 4 4 4];
%       [dup, counts] = duplicates(x);
%       fprintf('Value %d appears %d times\n', [dup, counts]');
%
%   NOTES:
%       - Works with any data type supported by unique
%       - For matrices, uses 'rows' option to find duplicate rows
%       - The 'first' and 'last' options are useful for:
%           * Removing duplicates while keeping first/last occurrence
%           * Identifying boundaries of repeated sequences
%           * Data cleaning and preprocessing
%
%   ALGORITHM:
%       1. Find unique elements and their indices using unique(...,'stable')
%       2. Count occurrences using accumarray
%       3. Filter to keep only values with count > 1
%       4. Generate logical index based on direction
%
%   SEE ALSO:
%       unique, accumarray, ismember, find, duplicate (inverse)
%
%   EGR (original)
%   Updated: 20260311 - Optimized 'last' option, better documentation

% Set default direction
if nargin < 2 || isempty(direction)
    direction = 'all';
end

% Ensure column vector for consistent behavior
if isvector(x)
    x = x(:);
end

% Find unique elements and their indices
% 'stable' preserves original order
[x_unique, ia, ic] = unique(x, 'rows', 'stable');

% Count occurrences of each unique element
counts = accumarray(ic, 1);

% Identify duplicate values (count > 1)
dup_mask = counts > 1;

% Extract duplicate values and their counts
dup = x_unique(dup_mask, :);
counts = counts(dup_mask);

% Generate logical index based on direction
switch lower(direction)
    case 'all'
        % Mark all occurrences of duplicate values
        ix = ismember(x, dup, 'rows');
        
    case 'first'
        % Mark only first occurrence of each duplicate
        ix = false(size(x, 1), 1);
        ix(ia(dup_mask)) = true;
        
    case 'last'
        % Mark only last occurrence of each duplicate
        ix = false(size(x, 1), 1);
        
        % For each duplicate value, find its last occurrence
        % This is more efficient than looping with ismember
        unique_dup_idx = find(dup_mask);
        for i = 1:length(unique_dup_idx)
            % Find all indices where this value occurs
            val_idx = find(ic == unique_dup_idx(i));
            % Mark the last one
            ix(val_idx(end)) = true;
        end
        
    otherwise
        error('Direction must be ''all'', ''first'', or ''last''. Got: %s', direction);
end

end
