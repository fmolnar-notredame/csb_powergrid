function plotLmax3d(P,b,cluster,n,bmin,bmax)
% Plot the lambda_max landscape in 3D

tic

b0 = b;
bb1 = linspace(bmin,bmax,n);
bb2 = linspace(bmin,bmax,n);
[b1,b2] = meshgrid(bb1,bb2);
lmax = zeros(size(b1));
for i = 1:size(b1,1)
    for k = 1:size(b1,2)
        b(cluster) = [b1(i,k) b2(i,k)];
        lmax(i,k) = GetLmax(P, b, false);
    end
end

clf

surf(b1,b2,lmax), shading interp
hold on
xl = xlim;
xx = linspace(xl(1),xl(2),1000);
yy = xx;
zz = zeros(size(xx));
for k = 1:length(xx)
    b = b0;
    b(cluster(1)) = xx(k);
    b(cluster(2)) = yy(k);
    zz(k) = GetLmax(P, b, false);
end
plot3(xx, yy, zz, 'r-')
lmax0 = GetLmax(P, b0, false);
plot3(b0(cluster(1)), b0(cluster(2)), lmax0, 'g.', 'MarkerSize', 16)
hold off
colormap(parula(400))
colorbar
axis vis3d
grid on
set(gca, 'FontSize', 14)
xlabel('\beta_i')
ylabel('\beta_j')
zlabel('Lmax')

fprintf('Green (given betas): Lmax = %8.6f\n', lmax0);

[~,i] = min(lmax(:));
fprintf('White (opt within plot): Lmax = %8.6f\n', lmax(i));
hold on
plot3(b1(i), b2(i), lmax(i), 'w.', 'MarkerSize', 16)
toc