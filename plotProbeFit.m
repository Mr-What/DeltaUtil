function plotProbeFit(probe,errZ)
    hold off
    plot3(probe(:,1),probe(:,2),probe(:,3),'+');
    grid on;hold on;
    plot3(probe(:,1),probe(:,2),probe(:,3)+errZ,'rx');
    plot3(probe(:,1),probe(:,2),errZ,'mo');
    legend('Measured','Fitted Points','Bed Error');
    xlabel('X');ylabel('Y');
    [s,m] = std(errZ(:));
    mse = mean(errZ(:) .* errZ(:));
    title(sprintf('Error: Median=%.6f Mean=%.6f MSE=%.6f SD=%.6f',...
                  median(errZ(:)), m, mse, s));
end
