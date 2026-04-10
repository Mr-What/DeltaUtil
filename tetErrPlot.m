% plot errs for given human parameters
%  P0 -- Ideal parameters, with optional probe(m,3) grid
%  pp -- perturbed tetrahedral (tilted) delta parameters
%  [dScale=10] - scale on displacement error plot
%
% returns actual position when each probe touched plate
function pos0 = tetErrPlot(P0,pp, dScale=10)
    if nargin < 1
        load P0.mat % ideal parameters and probe
    end
    if nargin < 2
        pp = P0.p;
        pp.delta_radius = P0.p.delta_radius+1; % default perturbation
    end

    tp = getTetraParams(pp)  % add internal parameters


%tp.arm_lengths = tp.arm_lengths - 1;  % perturbation
%tp.delta_radius = tp.delta_radius + 1;
%tp.tilt_radial = tp.tilt_radial + 1;

    % tProbe is the COMMANDED position at probe trigger (using tp)
    % pos0 should have all zero col(:,3) since it is true bed probe position
    % tetCmd is servo pos commanded using tp,
    % tet0 is actual servo pos, after endstop and rotation_distance errors applied
    [tProbe, pos0, tetCmd, tet0] = simulateBedProbe(P0.probe, P0.k, tp.k);

    figure(1); hold off
    plot3(pos0(:,1), pos0(:,2), pos0(:,3), 'b.');
    grid on; hold on;
    plot3(tProbe(:,1), tProbe(:,2), tProbe(:,3), 'r+');
    legend('Commanded location at probe trigger','actual location');

    err = tProbe - pos0;
    e2=err .* err;
    m2 = mean(e2);
    sxy2 = sum(e2(:,1:2),2);
    exy = sqrt(sxy2);
    errZ = sqrt(mean(e2(:,3)));
    title(sprintf('RMSE_z=%.3f   Med_x_y=%.3f mu_x_y=%.3f   std_x_y=%.3f',errZ, ...
              median(exy), mean(exy), std(exy)));
    hold off;

    figure(2);hold off % plot (magnified) XY displacement
    xy0 = tProbe(:,1:2);
    plot(xy0(:,1), xy0(:,2), 'bo');  % cmd probe locations
    grid on; axis equal; hold on;
    dxy = pos0(:,1:2) - xy0;
    xy = xy0 + dxy * dScale;  % add magnified err
    plot(xy(:,1), xy(:,2), 'rd');
    xlabel('X');ylabel('Y');
    title(sprintf('Displacement Error * %g',dScale));
    plot([xy0(:,1),xy(:,1)]',[xy0(:,2),xy(:,2)]','k');
    hold off
end

% probe -- commanded points to probe
% kp    -- kinetic parameters simulated
% k0    -- kinetic parameters, truth
%
% tProbe is the COMMANDED position at probe trigger (using tp)
% pos0 should have all zero col(:,3) since it is true bed probe position
% tetCmd is servo pos commanded using tp,
% tet0 is actual servo pos, after endstop and rotation_distance errors applie
function [tProbe, pos0, tetCmd, tet0, nBad] = simulateBedProbe(probe, kp, k0)

    m = size(probe,1);
    pos0 = zeros(m,3);
    tProbe = pos0;
    tetCmd = pos0;  % carriage positions at probe trigger, tp
    tet0 = pos0;    % truth carriage positions at probe trigger
    bad = int32(pos0(:,1));
    for j=1:m
        x = probe(j,1);
        y = probe(j,2);
        z = simulatedBedProbe(x, y, 5, kp, k0);
        if !isreal(z)
            bad(j) = 1;
            fprintf(2,'Non-reachable position at %d [%g,%g] ignored\n',...
                    j,x,y);
            disp(z);
            continue;
        end
        tet  = cart2tetra(kp,[x,y,z]);  % pos commanded for perturbed params
        if !isreal(tet)
            bad(j) = 1;
            fprintf(2,'Non-reachable carriage position at %d [%g,%g,%g] ignored\n',...
                    j,x,y,z);
            continue;
        end

        % adjust tower positions for stepper parameter differences, if any
        tetTrue = commandedTowerPositions(kp,tet,k0);
      
        tPos = tetra2cart(k0,tetTrue); % truth pos from true tetra positions
        if !isreal(tPos)
            bad(j)=1;
            fprintf(2,'Non-physical carriage position for %d [%g,%g,%g]\n',...
                    j,tetTrue);
            continue;
        end

        tProbe(j,:) = [x,y,z];  % bed probe reported position
        tetCmd(j,:) = tet;  % commanded carriage locations
        tet0(j,:) = tetTrue;  % actual commanded carriage locations
        pos0(j,:) = tPos;  % truth position at bed probe trigger
    end

    nBad = sum(bad);
    if nBad > 0
        j = find(bad != 0);
        disp('Bad samples at :');
        disp(j);
        disp(probe(j,1:2));
        disp('ignored.');
        j = find(bad == 0);
        tProbe = tProbe(j,:);
        tetCmd = tetCmd(j,:);
        tet0 = tet0(j,:);
        pos0 = pos0(j,:);
    end
end
