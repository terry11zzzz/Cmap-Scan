clear all
close all
data = simulate_cmap_scan();
idx=20;
figure;
plot(data(idx).stim, data(idx).curve);
xlabel('Stimulation Intensity (mA)');
ylabel('CMAP Amplitude (μV)');
title(sprintf('CMAP Curve (M=%d, σ=%d μV)', data(idx).M, data(idx).sigma));

[M_opt, lambda_opt, tau_opt] = fit_cmap_staircase(data(idx).stim, data(idx).curve, 20:2:60, 5);
%%
plot_stairfit_result(data(idx).stim, data(idx).curve, lambda_opt, tau_opt);