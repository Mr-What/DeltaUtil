% Given a set of measurements on the bed surface, guess
% the delta_radius which is most likely to have 
% caused this distortion.
%
% probe data is (n,3) where columns are:
%     commanded X,  commanded Y,  probed Z
%
% RETURN:  revised parameter set
function pp = guessTetraRadius(tp,probe)

% initial data plot
figure(2);
hold off;
[c,ax,pFit] = plotParabolicFit(probe);
grid on;hold on;
plot3(probe(:,1),probe(:,2),probe(:,3),'+');
title('Parabolic fit to measurements, + is measurements, . are fit points');
pause(0.1);

GuessParams = tp;
GuessParams.probe = probe;
GuessParams.verbose = 0;
[fit,nEval,status,err] = SimplexMinimize(...
              @(p) tetraRadiusErr(p,GuessParams),...
   	      tp.p.delta_radius(1), 1, 0.004, 300)
pp = tp.p;
pp.delta_radius = [0,0,0] + fit;
pp = getTetraParams(pp);  % re-compute kinematic params

% plot delta parameter fit
%errZ = deltaEndstopErrZ(dErr,GuessParams);
%plot3(meas(:,1),meas(:,2),errZ+meas(:,3),'r.');
%#legend('Parabolic Fit to measurements','Measured','Delta Fit Points');
%xlabel('X');ylabel('Y');
%hold off

%figure(3);
%hold off;
%fm = meas; fm(:,3) = fm(:,3)+errZ;
%c = plotParabolicFit(fm);
%grid on;hold on;
%plot3(fm(:,1),fm(:,2),fm(:,3),'+');
%hold off;
%title('Parabolic Fit to simulated points');
%xlabel('X');ylabel('Y');

%figure(1);
%hold off
%plot3(meas(:,1),meas(:,2),meas(:,3),'+');
%grid on;hold on;
%plot3(meas(:,1),meas(:,2),errZ+meas(:,3),'rx');
%legend('Measured','Fitted Points');
%xlabel('X');ylabel('Y');
%hold off

end

%-- ============================================ Error metric for minimization
function err = tetraRadiusErr(p,DP)
    err = tetraRadiusErrZ(p,DP);
    err = mean(err .* err);
    disp([sqrt(err),p]);
end

% retrieve whole error vector
function errZ = tetraRadiusErrZ(p,DP)
    err = 0;
    tp = DP.p;
    tp.delta_radius = [0,0,0] + p;
    tp = getTetraParams(tp);  % re-compute kinematic parameters
    n = size(DP.probe,1);
    errZ = zeros(n,1);
    for i=1:n
        d0 = cart2tetra(DP.k,DP.probe(i,:)); % commanded servo pos
        dz = tetra2cart(tp.k,d0); % cart from guess parameters
        errZ(i) = dz(3);
    end
end
