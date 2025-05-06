clear all
close all
data = simulate_cmap_scan();
idx=30;
figure;
plot(data(idx).stim, data(idx).curve);
xlabel('Stimulation Intensity (mA)');
ylabel('CMAP Amplitude (μV)');
title(sprintf('CMAP Curve (M=%d, σ=%d μV)', data(idx).M, data(idx).sigma));

%[M_opt, lambda_opt, tau_opt] = fit_cmap_staircase(data(idx).stim, data(idx).curve, 20:2:60, 5);
CDIX = compute_cdix(data(idx).curve)
[D50_integral, D50_diffcount] = compute_D50(data(idx).stim, data(idx).curve)