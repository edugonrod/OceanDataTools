function e = entire(x)
%ENTIRE  Return the integer part of a number (truncation toward zero)
%   E = ENTIRE(X) returns the integer part of X by truncating the fractional part.
%   For positive numbers, this is equivalent to FLOOR(X).
%   For negative numbers, this is equivalent to CEIL(X) but toward zero.
%
%   INPUT:
%       x : Numeric array (real numbers)
%
%   OUTPUT:
%       e : Integer part of each element (same size as x)
%
%   EXAMPLES:
%       entire(3.14)    % Returns 3
%       entire(-2.7)    % Returns -2
%       entire([1.5, -2.3, 4.8])  % Returns [1, -2, 4]
%
%   NOTE:
%       This function truncates toward zero, which is the same behavior as:
%           - FIX(X) in MATLAB
%           - INT(X) in some programming languages
%           - Truncation when converting float to int
%
%   SEE ALSO: FIX, FLOOR, CEIL, ROUND, REM

% EGR 200903 (original)
% Updated: 20260311 - Input validation, better documentation

% Validate input
validateattributes(x, {'numeric'}, {}, 'entire', 'x');

% Truncate toward zero
% Using REM(X,1) removes the fractional part
% X - REM(X,1) keeps only the integer part
e = x - rem(x, 1);

% Alternative implementation (same result):
% e = fix(x);
% e = sign(x) .* floor(abs(x));

