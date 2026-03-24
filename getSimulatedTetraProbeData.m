%  generate simulated bed probe data for a tilted_delta (tetra) printer

function z = getSimulatedTetraProbeData(x, y, zStart, tp, p0, file='probeSim.mat')
    z = zeros(size(x));
    m = numel(x);
    for k = 1:m
        % probe starts at [x,y,zStart] and calls
        % inverse kinematics to get a path down
        %    for tetra, don't assume march all Z down
        z(k) = simulatedBedProbe(x(k), y(k), 5, tp.k, p0.k);

        % print out results in CSV
        fprintf(1,"%g, %g, %.3f\n",x(k),y(k),z(k));
    end
    % x, y, z now available for plotting

    % generate truth data for comparison
    ds = tp.k.endstop - p0.k.endstop;  % endstop err
    x0=zeros(size(x));y0=x0;z0=x0;a0=x0;b0=x0;c0=x0;
    fprintf(1,"%% actual positions at probe trigger:\n");
    for k = 1:m
        tet0 = cart2tetra(tp.k, [x(k), y(k), z(k)]);
        if isreal(tet0)
            a0(k) = tet0(1); b0(k) = tet0(2); c0(k)=tet0(3);
            tet = tet0 + ds;  % apply endstop error
            xyz = tetra2cart(p0.k,tet);
            if isreal(xyz)
                x0(k) = xyz(1); y0(k) = xyz(2); z0(k)=xyz(3);
                % print out results in CSV
                fprintf(1,"%g, %g, %.3f,\t%.3f, %.3f, %.3f\n",xyz,tet0);
            end
        end
    end
    % truth, x0,y0,z0 now available for plotting.

    save('-text',file,'tp','p0','x','y','z','x0','y0','z0','a0','b0','c0');
end
