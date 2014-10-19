% Return the indices of the low, hi, and next-to-higest values in a
% vector.
%
function [lo,hi,nhi] = getExtremaIndices(y)

n = length(y);
[x,hi] = max(y);
[x,lo] = min(y);
t = y;
t(hi) = x-abs(x);
[x,nhi] = max(t);
end
