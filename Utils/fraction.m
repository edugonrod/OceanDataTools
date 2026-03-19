function f = fraction(x)
%FRACTION  Return the fractional part of a number
%   F = FRACTION(X) returns the fractional part of X.
%
%   EXAMPLES:
%       fraction(3.14)    % Returns 0.14
%       fraction(-2.7)    % Returns -0.7
%
%   SEE ALSO: ENTIRE, REM

f = rem(x, 1);
