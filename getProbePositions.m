% Given a set of measurements on the bed surface, and
% the parameter settings for the printer when they were
% taken, re-construct probe positions when probe was triggered,
% and add this data to the complete parameter set ready for
% calibration analysis.
%
% We try to cache this computation so that it does not need
% to be repeated many times in parameter optimization.
%
% PP         -- is the parameters (from printer.cfg) when the probe test was done.
% probe(n,3) -- is the commanded X,Y,Z position when probe triggered
%
% Return an appended full probe parameter strucure with readings
% and associated tower stepper positions
function tp = getProbePositions(PP,probe)
    tp = getTetraParams(PP);  % re-construct kinematic parameters
    m = size(probe,1);
    pos = zeros(m,3);
    n=1;
    for j=1:m
        p = cart2tetra(tp.k,probe(j,:));
        if isreal(p)
            probe(n,:) = probe(j,:);
            pos(n,:) = p;
            n=n+1;
        else
            fprintf(2,'probe(%d,:)=[%.3f,%.3f,%.3f] non-physical.  ignored.\n',...
                    j,probe(j,:));
        end
    end
    tp.probe = probe(1:n-1,:);
    tp.pos   = pos(1:n-1,:);
end
