% Given the set of printer parameters used for a set of measurements on
% the bed surface, and optionally some measurements of a calibration print,
% re-construct probe positions when probe was triggered,
% and at measured points of the calibration print, 
% and add this data to the complete parameter set ready for
% calibration analysis.
%
% We try to cache this computation so that it does not need
% to be repeated many times in parameter optimization.
%
% PP         -- is the parameters (from printer.cfg) when the probe test was done.
% probe(n,3) -- is the commanded X,Y,Z position when bed probe triggered
% measXYda   -- struct of standard measurement names holding length measured
% measCmd    -- ideal/designed XY measurement positions
%
% Return an appended full probe parameter strucure with readings
% and associated tower stepper positions
function tp = getTowerPositions(PP,probe, measXYdat, measCmd)
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

    if nargin < 4  % no calibration print measurements
        return
    end

    %measCmd = loadAsStruct(measDefFileName);  % info on commanded measurements
    fn = fieldnames(measXYdat);
    fnDef = fieldnames(measCmd);

    m = length(fn);
    n = 0;
    id = fn;  % -- pre-allocate computed arrays
    cmd = zeros(m,6);  % commanded measurement locations
    ideal = zeros(m,1); % ideal measurement
    dist = ideal;
    twr = cmd;  % stepper position at each commanded point
    
    for j=1:m
        nam = fn{j};
        if length(nam) != 3
            continue;  % not a recognized measureemnt id
        end
        pid = ['p', nam];
        if !ismember(pid, fnDef)
            contuinue;  % no defn for measurement ID
        end
        p = measCmd.(pid);
        p1 = cart2tetra(tp.k,[p(1,:),0]);
        if !isreal(p1)
            continue;  % bad measurement point
        end
        p2 = cart2tetra(tp.k,[p(2,:),0]);
        if !isreal(p2)
            continue;  % bad measurement point
        end
        n=n+1;
        id{n} = nam;  % measurement ID code
        cmd(n,:) = [p(1,:), 0, p(2,:), 0]; % commanded measurement locations
        ideal(n) = norm(p(1,:) - p(2,:)); % expected measurement
        twr(n,:) = [p1, p2]; % commanded tower positions at measurement
        dist(n) = measXYdat.(nam); % printed distance measurement
    end
    % truncate to only "good" data in output struct
    tp.measXY = struct('cmd'  ,   cmd(1:n,:),...
                       'twr'  ,   twr(1:n,:),...
                       'ideal', ideal(1:n)  ,...
                       'dist' ,  dist(1:n)  ,...
                       'id'  ,char(id{1:n}));
end
