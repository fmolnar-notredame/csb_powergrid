function fig_small_example
% Creates a preliminary version of Fig 5.

fig_visible = 'off';

load('run_test.mat')
load('fig_small_example_2D_compute')
fprintf('cluster: [%d,%d]\n', a, b);
bmin = ca - xa; bmax = ca + xa;

% Font size:
fs = 10;

% Compute lambda_max along the diagonal beta_2 = beta_3. Outside of the
% cluster: use beta_SA)
J = [zeros(n,n), eye(n,n); -P, -diag(beta_SA)];
betas = linspace(bmin, bmax, 300);
btilde = 0;
lmax_tilde = 0;
ll = zeros(size(betas));
for i = 1 : length(betas)
    beta = betas(i);
    %J(diags) = -beta; % global btilde
    J(a+n, a+n) = -beta;
    J(b+n, b+n) = -beta;
    lmax = GetLmaxJ(J);
    ll(i) = lmax;
    if lmax < lmax_tilde
       lmax_tilde = lmax;
       btilde = beta;
    end
end
fprintf('btilde ~= %g, lmax_tilde ~= %g\n', btilde, lmax_tilde);

% Compute lambda_max along the line connecting btilde and beta_opt. Outside of the
% cluster: use beta_SA)
J = [zeros(n,n), eye(n,n); -P, -diag(beta_SA)];
betas_a = linspace(bmin, bmax+1, 1000);
s = (beta_opt(a) - btilde)/(beta_opt(b) - btilde);
betas_b = s*(betas_a - btilde) + btilde;
ll2 = zeros(size(betas));
for i = 1 : length(betas_a)
    J(a+n, a+n) = -betas_a(i);
    J(b+n, b+n) = -betas_b(i);
    lmax = GetLmaxJ(J);
    ll2(i) = lmax;
end

% Set up figure.
w = 4; h = 6;
fh = figure('Visible', fig_visible, ...
    'PaperUnit', 'inches', 'PaperSize', [w,h], ...
    'PaperPosition', [0,0,w,h], ...
    'Units', 'inches', 'Position', [0,0,w,h]);

% Height of the middle axes in inches:
h2 = 3;

% Height of the other two panels:
h3 = 1.1736; 

% Vertical gap between middle and the other two panels:
h4 = 0.1;

% The height and bottom position of all panels:
w2 = 3.0417; w3 = 0.3194;

% Plot lambda_max along the diagonal beta_2 = beta_3 in the 2D landscape.
ah = axes(fh, 'Units', 'inches');
plot(ah, betas, ll, 'k-');
hold(ah,'on');
plot(ah, btilde, lmax_tilde, 'r.', 'MarkerSize', 10)
hold(ah,'off');
xlabel('\beta_2 = \beta_3');
ylabel('lmax');
set(ah, 'FontSize', fs, ...
    'Position', [w3, h/2+h2/2+h4, w2, h3], ...
    'XLim', [bmin,bmax], 'XTick', 1:0.5:6, 'XTickLabel', {}, ...
    'YLim', [-2.6,-1.4], 'YTick', -2.5:0.5:-1.5, ...
    'YTickLabel', {'-2.5','-2.0','-1.5'}, ...
    'YAxisLocation', 'left');

% 2D landscape plot
ah2 = axes(fh, 'Units', 'inches');
imagesc(ah2, beta_a, beta_b, L);
axis(ah2, 'xy');
box(ah2, 'on');
hold(ah2, 'on');
plot(ah2, [bmin,bmax], [bmin,bmax], 'w--');
plot(ah2, betas_a, betas_b, 'k--');
plot(ah2, btilde, btilde, 'r.', 'MarkerSize', 10)
plot(ah2, beta_opt(a), beta_opt(b), 'b.', 'MarkerSize', 10)
plot(ah2, beta_opt(b), beta_opt(a), 'b.', 'MarkerSize', 10)
hold(ah2, 'off');
xlabel('\beta_2')
ylabel('\beta_3')
cmin = [254,253,193]/255; cmax = [8,14,82]/255; nc = 100;
s = linspace(0,1,nc)';
colormap((1-s)*cmin + s*cmax);
hp = colorbar;
hp.Label.String = '\lambda^{max}';
hp.Location = 'eastoutside';
hp.Ticks = -2.5:0.5:1.5;
hp.TickLabels = {'-2.5','-2.0','-1.5'};
set(ah2, 'Position', [w3, h/2-h2/2, w2, h2], 'FontSize', fs, ...
    'XLim', [bmin,bmax], 'XTick', 1:0.5:6, 'XTickLabel', {}, ...
    'YLim', [bmin,bmax], 'YTick', 3.5:0.5:5.5, ...
    'YTickLabel', {'3.5','4.0','4.5','5.0','5.5'});
hp.Position(3) = 0.04;

% Plot lambda_max along the line connecting btilde to bg.
ah3 = axes(fh, 'Units', 'inches');
box(ah3,'on');
plot(ah3, betas_a, ll2, 'k-');
hold(ah3,'on');
plot(ah3, btilde, lmax_tilde, 'r.', 'MarkerSize', 10)
plot(ah3, beta_opt(b), lmax_opt, 'b.', 'MarkerSize', 10)
hold(ah3,'off');
set(ah3, 'Position', [w3, h/2-h2/2-h3-h4, w2, h3], ...
    'FontSize', fs, 'YAxisLocation', 'left', ...
    'YLim', [-3.1,-1.9], 'YTick', -3:0.5:-2, ...
    'YTickLabel', {'-3.0','-2.5','-2.0'}, ...
    'XLim', [bmin,bmax], 'XTick', 3.5:0.5:5.5, ...
    'XTickLabel', {'3.5','4.0','4.5','5.0','5.5'});
    
% Export to PNG
print(fh, '-dpng', '-r300', [mfilename,'_export']);
close(fh);
