function y = iseven(x)
%ISEVEN  Determine if numbers are even
%   Y = ISEVEN(X) returns logical true (1) for even elements, false (0) for odd.
%
%   EXAMPLES:
%       iseven(3)        % Returns false
%       iseven(4)        % Returns true
%
%   SEE ALSO: isodd, rem, mod

y = ~isodd(x);
