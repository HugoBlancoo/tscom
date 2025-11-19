% minimal empirical check (replace your loop with this)
P = 150; gtx = srrc(0, P, OF); Lg = length(gtx); delay = floor((Lg-1)/2);
Fs = OF * N * delta_c;

k_list = [0, 10, 20, 30, 40, 50, 100];
figure; hold on; colors = lines(length(k_list)); % for overplot option

for ii = 1:length(k_list)
    k = k_list(ii);
    nullpos = [];
    if k>0
        nullpos = [1:k, N-k+1:N];
    end
    [x, u, w] = OFDMmod(data, N, Lc, OF, nullpos);

    % trim SRRC delay (important) to avoid transients in PSD
    if length(x) > 2*delay
        x_trim = x(delay+1:end-delay);
    else
        x_trim = x;
    end

    % PSD centered
    [Px, f] = pwelch(x_trim, 512, [], 512, Fs, 'centered');

    % numeric attenuation at +/-7 MHz (relative to peak)
    peak = max(Px);
    % find closest frequency bins
    [~, idx_p7] = min(abs(f -  7e6));
    [~, idx_m7] = min(abs(f - -7e6));
    lvl_p7 = Px(idx_p7); lvl_m7 = Px(idx_m7);
    att_p7 = 10*log10(peak / lvl_p7);
    att_m7 = 10*log10(peak / lvl_m7);
    att_min = min(att_p7, att_m7);
    fprintf('k=%3d  active=%3d  att(+7MHz)=%6.2f dB  att(-7MHz)=%6.2f dB  min= %6.2f dB\n', ...
        k, N-2*k, att_p7, att_m7, att_min);

    % plot (all on same figure). If prefieres figuras separadas, usa figure inside loop
    plot(f/1e6, 10*log10(Px), 'Color', colors(ii,:), 'DisplayName', sprintf('k=%d (act=%d)', k, N-2*k));
end

% decorate plot
xline( 7, '--k', '+7 MHz'); xline(-7, '--k', '-7 MHz');
xlabel('Frequency (MHz)'); ylabel('PSD (dB/Hz)');
title('PSD of x(t) for different nulling (edge nulling)');
legend('show','Location','best');
xlim([-Fs/2, Fs/2]/1e6);
grid on;
hold off;
