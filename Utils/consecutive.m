function idx = consecutive(vector)
%CONSECUTIVE  Find consecutive sequences in a vector
%   IDX = CONSECUTIVE(VECTOR) finds runs of consecutive values in a vector
%   and returns their start and end indices.
%
%   INPUT:
%       vector : Numeric vector or categorical/group vector
%
%   OUTPUT:
%       idx : Nx3 matrix where each row corresponds to a consecutive sequence:
%             Column 1: Start index of the sequence
%             Column 2: End index of the sequence
%             Column 3: Length of the sequence (number of consecutive elements)
%
%   EXAMPLES:
%       % Example 1: Simple numeric sequence
%       v = [1 1 1 2 2 3 3 3 3 5 5];
%       idx = consecutive(v)
%       % Returns:
%       %   1   3   3   (three 1's)
%       %   4   5   2   (two 2's)
%       %   6   9   4   (four 3's)
%       %   10  11  2   (two 5's)
%
%       % Example 2: With gaps (non-consecutive but same value)
%       v = [1 1 2 2 1 1 3 3];
%       idx = consecutive(v)
%       % Treats separated values as different sequences
%       % [1 2 2; 3 4 2; 5 6 2; 7 8 2]
%
%       % Example 3: With categorical data
%       v = categorical({'A','A','B','B','B','A','A','C'});
%       idx = consecutive(v)
%       % Works with any data type convertible by findgroups
%
%       % Example 4: Single value
%       idx = consecutive([5 5 5])
%       % Returns [1 3 3]
%
%       % Example 5: All different values
%       idx = consecutive([1 2 3 4 5])
%       % Returns 5 rows: [1 1 1; 2 2 1; 3 3 1; 4 4 1; 5 5 1]
%
%   NOTES:
%       - "Consecutive" means the same value appears in adjacent positions
%       - For numeric vectors, uses exact equality (floating point caution)
%       - For non-numeric inputs, uses findgroups to convert to group indices
%       - Useful for run-length encoding, data compression, sequence analysis
%
%   ALGORITHM:
%       1. Convert non-numeric inputs to group indices
%       2. Find where values change using diff
%       3. Locate change points and compute sequence boundaries
%       4. Calculate start, end, and length of each sequence
%
%   SEE ALSO:
%       diff, findgroups, ismember, runlength, seqle
%
%   EGR 20200603 (original)
%   Updated: 20260311 - Input validation, better documentation

% Validate input
validateattributes(vector, {'numeric', 'categorical', 'string', 'cell'}, ...
    {'vector'}, 'consecutive', 'vector');

% Convert non-numeric to group indices
if ~isnumeric(vector)
    vector = findgroups(vector);  % Converts text/categorical to numbers
end

% Ensure column vector
vector = vector(:);

% Find where values change
% diff(vector) gives 0 where consecutive values are the same
% We want to mark the boundaries where changes occur
dd = diff(vector);

% Find indices where sequence changes
% Changes occur when diff is not 0 (values differ)
% Add inf at the end to ensure last sequence is captured
change_points = find([dd; inf] ~= 0);

% Calculate start indices of each sequence
% First sequence starts at 1
% Subsequent sequences start right after previous change point
start_idx = [1; change_points(1:end-1) + 1];

% Calculate end indices of each sequence
end_idx = change_points;

% Calculate lengths
len = end_idx - start_idx + 1;

% Combine into output matrix
idx = [start_idx, end_idx, len];

end
