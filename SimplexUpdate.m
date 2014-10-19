% Update a simplex for SimplesMinimize

function [simplex,ytry,psum] =  SimplexUpdate(simplex,fcn,ihi,fac)

nDim = length(simplex)-1;

psum = simplex(nDim+1).p;
for i=1:nDim;
    psum = psum + simplex(i).p;
end

fac1 = (1.0-fac)/nDim;
fac2 = fac1 - fac;

ptry = psum*fac1 - (simplex(ihi).p * fac2);
ytry = feval(fcn,ptry);

if (ytry < simplex(ihi).y)
    % this is better than current highest, so replace it.
    psum = psum + ptry - simplex(ihi).p;
    simplex(ihi).y = ytry;
    simplex(ihi).p = ptry;
    %ptry % debug output
    %ytry
end
