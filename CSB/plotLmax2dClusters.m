function plotLmax2dClusters(P,btilde,cluster,n,bmin,bmax,cmin,cmax)

tic

bb1 = linspace(bmin,bmax,n);
bb2 = linspace(bmin,bmax,n);
[b1,b2] = meshgrid(bb1,bb2);
lmax = zeros(size(b1));
for i = 1:size(b1,1)
    for k = 1:size(b1,2)
        b = zeros(size(P,1),1);
        ix = false(size(P,1),1);
        ix(cluster) = true;
        b(ix) = b1(i,k);
        b(~ix) = b2(i,k);
        lmax(i,k) = GetLmax(P, b, false);
    end
end

clf

% surf(b1,b2,lmax), shading interp

if ~exist('cmin','var')
    imagesc(bb1,bb2,lmax)
else
    imagesc(bb1,bb2,lmax,[cmin,cmax])
end
hold on
plot(xlim,xlim,'r-')
hold off
colormap(parula(400))
colorbar
axis square xy
grid on
set(gca, 'FontSize', 14)
title('Lmax')
xlabel('\beta_i')
ylabel('\beta_j')

b = zeros(size(P,1),1);
ix = false(size(P,1),1);
ix(cluster) = true;
b(ix) = btilde(1);
b(~ix) = btilde(2);
fprintf('Green: Lmax(b) = %8.6f\n', GetLmax(P, b, false));
hold on
plot(btilde(1),btilde(2),'g.','MarkerSize',16)
hold off

[~,i] = min(lmax(:));
fprintf('White: Lmax(bopt) = %8.6f\n', lmax(i));
fprintf('       at (%8.6f, %8.6f)\n', b1(i), b2(i));
hold on
plot(b1(i),b2(i),'w.','MarkerSize',16)
hold off

toc