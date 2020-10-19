function [lmax_orig, lmax_opt, lmax_tilde] = plotLmax2d(P,b,cluster,n,bmin,bmax,cmin,cmax)
% Plot the lambda_max landscape, return the marked points' values

tic

% calculate non-uniform landscape (including uniform diagonal)
b0 = b;
bb = linspace(bmin,bmax,n);
lmax = zeros(n, n);
for i = 1:n % y axis: second node
    for k = 1:n % x axis: first node
        b(cluster) = [bb(k), bb(i)]; % ORDER!!
        lmax(i,k) = GetLmax(P, b, false);
    end
end

clf

if ~exist('cmin','var')
    imagesc(bb,bb,lmax)
else
    imagesc(bb,bb,lmax,[cmin,cmax])
end

hold on
plot(xlim,xlim,'r-') % red diagonal
plot(b0(cluster(1)),b0(cluster(2)),'g.','MarkerSize',16) % green dot: given input
hold off

colormap(parula(400));
colorbar
axis square xy
grid on
set(gca, 'FontSize', 14);
title('Lmax');
xlabel(sprintf('\\beta_{%d}', cluster(1)));
ylabel(sprintf('\\beta_{%d}', cluster(2)));

lmax_orig = GetLmax(P, b0, false);
fprintf('Green (given betas): Lmax = %8.6f\n', lmax_orig);

[~,i] = min(lmax(:));
[i,k] = ind2sub(size(lmax), i);
lmax_opt = lmax(i,k);
fprintf('White (opt within plot): Lmax = %8.6f\n', lmax_opt);
hold on
plot(bb(k),bb(i),'w.','MarkerSize',16);

% opt along diagonal
lmax2 = diag(lmax);
[~,i] = min(lmax2);
lmax_tilde = lmax2(i);
fprintf('Red (opt along diagonal): Lmax = %8.6f\n', lmax_tilde);
plot(bb(i), bb(i), 'r.', 'MarkerSize', 16);

toc