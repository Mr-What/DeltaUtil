% Implementation of the Simplex minimization technique.
% Based off of Wikipedia article, circa 2015

function [fit,nEval,status,err] = SimplexMinimize(fcn,...
      initialGuess,initialStep,smallBox,maxIter,errEps)
if (nargin < 5), maxIter = 1000; end
if (nargin < 6), errEps  = .001; end

status = 0;  % Normal completion
nDim = prod(size(initialGuess));

% initialize simplex
simplex.p = initialGuess;
simplex.y = 0;
x = simplex;
for i=2:nDim+1;
    %simplex = [simplex x]; % expand simplex vector
    simplex(i).p = initialGuess;
end
for i=1:nDim;
    % radndomize starting point
    stp = initialStep(i);
    if (rand() < 0.5), stp = -stp; end

    simplex(i).p(i) = simplex(i).p(i) + stp;
end

% get value of errFunc at each simplex point
for i=1:nDim+1;
    simplex(i).y = feval(fcn,simplex(i).p);
end
nEval = nDim+1;  % initialize function evaluation counter

% initialize variable to store sum of simplex point values
%psum = simplex(nDim+1).p;
%for i=1:nDim;
%    psum=psum+simplex(i).p;
%end

% evaluation counter when last new low found
lastNewLow = nEval;
while(1)
    simplex = sortSimplex(simplex);
    
    % check exit condition(s)
    if (SimplexExitCriteriaMet(simplex,smallBox,nEval-lastNewLow,errEps) || (nEval > maxIter))
	    fit = simplex(1).p;
        err = simplex(1).y;
        if (nEval > maxIter)
           status = -1;  % did not converge
	    end
	    return;
    end

    [simplex,nEval] = simplexUpdate(simplex,fcn,nEval);
end
end


% ----------------------------- main routine

% update sorted simplex
function [simplex,ne] = simplexUpdate(simplex,fcn,ne)
nDim = length(simplex)-1;
if (nargin < 3), ne=nDim+1; end
expansionFactor = 1.66;  % normally 2.0
contractionFactor = -0.5;  % normally -0.5.  0.66 moves 1/3 way towards center
reductionFactor = 0.66;  % normally .5.  .33 reduces entire simplex 2/3 of the way towards low point

  % assume that simplex was already sorted
  ylo = simplex(1).y;
  yhi = simplex(nDim+1).y;
  yhi1 = simplex(nDim).y;  % second worst
  
  % reflect worst vertex about centroid of remaining vertices
  pr = simplexReflect(simplex,1.0);
  yr = feval(fcn,pr);    ne=ne+1;

  if (yr < ylo)
      % reflected point was best so far.  try expanding
      pe = simplexReflect(simplex,expansionFactor);
      ye = feval(fcn,pe);    ne=ne+1;
      if (ye < yr)  % if expansion was even better than default reflection, use it
          yr=ye;
          pr=pe;
      end
      simplex(nDim+1).y = yr;
      simplex(nDim+1).p = pr;
      return
  end
  
  % reflected point was not a new best.
  
  if (yr < yhi1)
      % reflected was better than second worst, replace worst with reflected 
      simplex(nDim+1).y = yr;
      simplex(nDim+1).p = pr;
      return
  end
  
  % reflected was worse than second worst.
  % see if moving worst point in a bit improves it (contraction)
  pc = simplexReflect(simplex,contractionFactor);
  yc = feval(fcn,pc);   ne=ne+1;
  if (yc < yhi)
      % better than previous worst, use it instead
      simplex(nDim+1).y = yc;
      simplex(nDim+1).p = pc;
      return
  end
  
  % contraction of worst vertex didn't help.
  
  % shrink entire simplex toward best point (reduction)
  p1 = simplex(1).p * (1.0-reductionFactor);
  for k=2:nDim+1
     simplex(k).p = p1 + (reductionFactor * simplex(k).p);
     simplex(k).y = feval(fcn,simplex(k).p);   ne=ne+1;
  end
end

%% -----------------------------------------------

function simplex = sortSimplex(simplex0);
  n = length(simplex0);
  y = zeros(1,n);
  for k=1:n, y(k) = simplex0(k).y; end
  [yo,yIdx] = sort(y);
  simplex = simplex0;
  for k=1:n, simplex(k) = simplex0(yIdx(k)); end
end

% reflect the worst point about the centroid of the others, with the
% given gain ( can be negative, for contraction, instead of reflection)
% assumes simplex is sorted
function pr = simplexReflect(simplex,a)
   nDim = length(simplex)-1;
   p0 = simplex(1).p;
   for k=2:nDim
       p0 = p0 + simplex(k).p;
   end
   p0 = p0 / nDim;
   pr = p0 + a * (p0 - simplex(nDim+1).p);
end
