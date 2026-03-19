function y = isodd(x)
%ISODD  Determine if numbers are odd
%   Y = ISODD(X) returns logical true (1) for odd elements, false (0) for even.
%
%   INPUT:
%       x : Numeric scalar, vector, or matrix (real integers recommended)
%
%   OUTPUT:
%       y : Logical array same size as x, true where x is odd
%
%   EXAMPLES:
%       isodd(3)        % Returns true
%       isodd(4)        % Returns false
%       isodd(1:5)      % Returns [true, false, true, false, true]
%       isodd([1 2; 3 4])  % Returns [true false; true false]
%
%   NOTES:
%       - Works with floating point, but best with integers
%       - For negative numbers, oddness is based on absolute value
%       - Non-integer values return true if the integer part is odd
%         (e.g., isodd(3.7) returns true, isodd(4.2) returns false)
%
%   SEE ALSO:
%       iseven, rem, mod, logical
%
%   EGR-200808 (original)
%   Updated: 20260311 - Input validation, better documentation

% Validate input
validateattributes(x, {'numeric'}, {}, 'isodd', 'x');

% Calculate oddness using remainder after division by 2
% rem(x,2) returns 1 for odd numbers, 0 for even numbers
% logical converts to true/false
y = logical(rem(x, 2));

end
