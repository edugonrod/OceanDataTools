function ixg = indexGroups(grp)
% indexGroups Return start and end indices of consecutive groups.
%
%   ixg = indexGroups(grp)
%
% Identifies groups in a vector and returns the start and end indices
% corresponding to each group. The groups must appear consecutively in
% the input vector.
%
% INPUT
%   grp
%       Vector containing group identifiers. Elements belonging to the
%       same group must appear consecutively.
%
% OUTPUT
%   ixg
%       Matrix with three columns:
%
%           [groupID  startIndex  endIndex]
%
%       where startIndex and endIndex correspond to the first and last
%       position of each group in the input vector.
%
% NOTES
%   - The function assumes groups are ordered consecutively.
%   - If the group labels are not sorted, a warning is issued.
%
% EXAMPLE
%   grp = [1 1 1 2 2 3 3 3 3];
%
%   ixg = indexGroups(grp)
%
%   % Result:
%   % [1 1 3
%   %  2 4 5
%   %  3 6 9]
%
% SEE ALSO
%   FINDGROUPS, ACCUMARRAY
%
% EGR
% 20190430

% Asegurar que sea vector fila
grp = grp(:)';

% Verificar que los grupos sean consecutivos
if any(diff(grp) < 0)
    warning('Los grupos no están ordenados consecutivamente');
end

[g, id] = findgroups(grp(:));
inicios = accumarray(g, (1:length(grp))', [], @min);
finales = accumarray(g, (1:length(grp))', [], @max);
ixg = [id, inicios, finales];
