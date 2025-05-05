data = simulate_cmap_scan();
figure;
plot(data(1).stim, data(1).curve);
xlabel('Stimulation Intensity (mA)');
ylabel('CMAP Amplitude (μV)');
title(sprintf('CMAP Curve (M=%d, σ=%d μV)', data(1).M, data(1).sigma));
