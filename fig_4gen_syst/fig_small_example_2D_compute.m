function fig_small_example_2D_compute

tic

load('run_test.mat')

lattice = [];
lattice.a = 2;
lattice.b = 3;
lattice.size = 400;
lattice.center_a = 4.5; %btilde * 0.95;
lattice.center_b = 4.5; %btilde * 0.95;
lattice.extent_a = 2;
lattice.extent_b = 2;

[beta_opt, lmax_opt, L] = GetLmaxLattice2D(J, lattice, false);

ca = lattice.center_a;
cb = lattice.center_b;
xa = lattice.extent_a / 2;
xb = lattice.extent_b / 2;
beta_a = linspace(ca - xa, ca + xa, lattice.size);
beta_b = linspace(cb - xb, cb + xb, lattice.size);

toc

figure;
imagesc(beta_a, beta_b, L);
axis xy square

save(mfilename)
