% Making a demo power system that features cluster CSB

[P, ps] = make_demo();
n = size(P,1);

% extract generator steady state
gen = ps.bus(:,2)>1;
Vm = ps.bus(gen, 8);
Va = ps.bus(gen, 9);

fprintf('Steady-state generator angles:\n');
fprintf('  %f\n', Va);
fprintf('Pg, Qg:\n');
PgQg = ps.gen(:,[2,3]);
disp(PgQg);

% find the global optimum
beta_range = 30;
repeats = 50;
fprintf('finding global optimum...\n');
[beta_SA, lmax_SA, beta_runs] = GetBetaSA(P, beta_range, repeats);
fprintf('global optimum Lmax: %f\n', lmax_SA);

%% use cluster (2,3)
a = 2; b = 3;

%% plot uniform landscape

% get beta tilde (within the cluster)
J = [zeros(n,n), eye(n,n); -P, -diag(beta_SA)]; % outside of the cluster: use beta_SA
%diags = 2*n*n+n+1 : 2*n+1 : 4*n*n; % linear index of betas in the J matrix for global btilde optimization
betas = linspace(0, 50, 5000);
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

figure(1);
clf();
plot(betas, ll);
xlim([3.5,5.5])
xlabel('uniform beta');
ylabel('lmax');

%% 2D landscape for the most similar node pair

lattice = [];
lattice.a = a;
lattice.b = b;
lattice.size = 200;
lattice.center_a = btilde * 0.8;
lattice.center_b = btilde * 0.8;
lattice.extent_a = 8;
lattice.extent_b = 8;


[beta_opt, lmax_opt, L] = GetLmaxLattice2D(J, lattice, false);

ca = lattice.center_a;
cb = lattice.center_b;
xa = lattice.extent_a / 2;
xb = lattice.extent_b / 2;
beta_a = linspace(ca - xa, ca + xa, lattice.size);
beta_b = linspace(cb - xb, cb + xb, lattice.size);

figure(2);
clf();
imagesc(beta_a, beta_b, L);

% marker for SA optimum
hold on;
plot(beta_SA(a), beta_SA(b), 'ro');

% marker for landscape optimum
plot(beta_opt(a), beta_opt(b), 'wo');

fprintf('lmax_tilde: %f\tlmax_opt: %f\n', lmax_tilde, lmax_opt);

% save data
save('run_test.mat')
