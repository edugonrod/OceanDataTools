function p = isentire(x)
%ISENTIRE True for integer-valued elements.
%
%   P = ISENTIRE(X) returns a logical array indicating whether the
%   elements of X are integer values.
%
%   The output P has the same size as X. Elements of P are true (1) when
%   the corresponding value in X is an integer and false (0) otherwise.
%
%   X can be a scalar, vector, or matrix.
%
%   Example
%       x = [3 4.5 7 -2 1.2];
%       p = isentire(x)
%
%   See also FLOOR, MOD, REM
%
%   EGR-200808
%   CICESE La Paz
%   egonzale@cicese.mx

p = ~(rem(x,1));



