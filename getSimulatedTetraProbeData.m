%  generate simulated bed probe data for a tilted_delta (tetra) printer

function z = getSimulatedTetraProbeData(x, y, zStart, tp, p0, file='probeSim.mat')
    z = zeros(size(x));
    m = numel(x);
    for k = 1:m
        % probe starts at [x,y,zStart] and calls
        % inverse kinematics to get a path down
        %    for tetra, don't assume march all Z down
        z(k) = simulatedBedProbe(x(k), y(k), zStart, tp.k, p0.k);

        % print out results in CSV
        if isfield(tp,'verbose')
            fprintf(1,"%g, %g, %.3f\n",x(k),y(k),z(k));
        end
    end
    %fprintf(2,'Simulated bed probe range : [%.3f,%.3f]\n',min(z(:)),max(z(:)));
    % x, y, z now available for plotting
    hold off; plot3(x,y,z,'rx');
    grid on; hold on;

    % generate truth data for comparison
    sz = size(x);
    x0=zeros(sz);y0=x0;z0=x0;
    abc = zeros(m,3);
    fprintf(1,"%% actual positions at probe trigger:\n");
    for k = 1:m
        tet0 = cart2tetra(tp.k, [x(k), y(k), z(k)]);
        if isreal(tet0)
            abc(k,:) = tet0;
        end
    end
    a0 = reshape(abc(:,1),sz);
    b0 = reshape(abc(:,1),sz);
    c0 = reshape(abc(:,1),sz);

    % adjust commanded tower position for any stepper calibration differences
    abc = commandedTowerPositions(tp.k, abc, p0.k);

    % use truth parameters to find where this probe actually was
    for k = 1:m
        xyz = tetra2cart(p0.k, abc(k,:));
        if isreal(xyz)
            x0(k) = xyz(1); y0(k) = xyz(2); z0(k)=xyz(3);
            % print out results in CSV
            if isfield(tp, 'verbose')
                fprintf(1,"%g, %g, %.3f,\t%.3f, %.3f, %.3f\n",xyz,abc(k,:));
            end
        end
    end
    % truth, x0,y0,z0 now available for plotting.

    whos
    plot3(x0,y0,z0,'o');
    zMid = median(abs(z(:)));  zlim(2*[-zMid,zMid]);
    hold off; pause(0.1);
    
    save('-text',file,'tp','p0','x','y','z','x0','y0','z0','a0','b0','c0');
    disp(['Simulated Bed Probe Data saved in "', file, '"']);
end
