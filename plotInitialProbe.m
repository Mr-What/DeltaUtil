function [c,ax,pFit] = plotInitialProbe(probe)
    hold off;
    [c,ax,pFit] = plotParabolicFit(probe);
    grid on;hold on;
    %plot3(probe(:,1), probe(:,2), probe(:,3),'+');
    title('Parabolic fit to measurements, + is measurements, . are fit points');
    xlabel('X');ylabel('Y');
    pause(0.1);
end
