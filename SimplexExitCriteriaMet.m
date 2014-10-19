% Return true if exit criteria met

function a = SimplexExitCriteriaMet(simplex,smallBox,nEvalSinceNewLow)

% exit when simplex can be bound within a smallBox, and
% it has been several evaluations since we found a better low
n = length(simplex);
a = 0;
if (nEvalSinceNewLow < 2*n)
    return;
end

% find err range
hiErr = simplex(1).y;
loErr = hiErr;
for (i=2:n)
    if (simplex(i).y < loErr), loErr = simplex(i).y; end
    if (simplex(i).y > hiErr), hiErr = simplex(i).y; end
end
if (loErr <= 0)
   a=1;
   disp('zero error');
simplex(:).p
simplex(:).y
   return
end
if ((hiErr-loErr)/loErr < 0.001)
    a=1;
    disp('error pretty flat across simplex');
    return;
end

% find boinding box of simplex
lo = simplex(1).p;
hi = simplex(1).p;
for i=2:n;
    j = find(simplex(i).p > hi);
    hi(j) = simplex(i).p(j);
    
    j = find(simplex(i).p < lo);
    lo(j) = simplex(i).p(j);
end
box = hi - lo;
a = (length(find(hi - lo > smallBox)) <=  0);
%if (a), disp('smallbox'); end
