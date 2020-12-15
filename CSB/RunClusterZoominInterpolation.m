% For 2-node clusters, plot the lmax_tilde and lmax_opt as a function of
% interpolation between original and exact-equitable P matrices.
% Note: making P exaxt-equitable only affects the 2 rows corresponding to
% the selected 2 nodes.

% v2: interpolation is sequential, zoomin is parallel,
% interpolation starts from the previous point to track the same optimum
% and prevent jumping around in the landscape

sysnames = {'10gen', '48gen', 'uk', 'germany'};
sysIndex = 2; % <--------------------- select the system using this index
parallel = false;  % parfor freezes. bad matlab.

sysname = sysnames{sysIndex};

% selected clusters - hand picked from cluster_choices files
CC = [6, 7; 19, 44; 6, 10; 17, 25];
C = CC(sysIndex,:);

fname = sprintf('%s_P_orig.dat', sysname);
P = dlmread(fname);
n = size(P,1);

fname = sprintf('%s_beta_SA.dat', sysname);
betas = dlmread(fname);
beta_SA = betas(end,:);

fprintf('--------------------------------------\n');
fprintf('System: %s\nLmax_SA: %f\n', ...
    sysname, GetLmax(P, beta_SA));


%% interpolation - configure

interp_steps = 101;     % how many steps of interpolation
lattice_size = 20;      % size of grid at each zoom level
initial_extent = 20;    % initial range of betas (both dimensions, initial beta range: [0, initial_extent])
zoom_levels = 20;        % how many times to compute lattices
zoom_factor = (1+sqrt(5))/2;   % how much the zoom reduces the extent at each step

continue_zoom = 7; % what zoom level to start from when continuing interpolation

% final resolution in beta space
beta_res = (initial_extent / lattice_size) * (1/zoom_factor)^(zoom_levels-1);
fprintf('Final beta resolution will be: %e\n', beta_res);
fprintf('Number of eig calculations per interp step: %d\n', lattice_size^2 * zoom_levels);

%% run interpolation

a = C(1);
b = C(2);
fprintf('Cluster: %d,%d\n', a, b);

% Make exact equitable P matrix
indices = [1:a-1, a, b, a+1:b-1, b+1:n];
clusters = [1:a-1, a, a, a+1:n-1];
Q = full(sparse(indices, clusters, ones(1,n)));
PEQ = make_exact_EP(P,Q);

% Prepare interpolation plan (linspace for matrix P)
Pstep = (PEQ - P) / (interp_steps-1);

% record results here
beta_tilde = zeros(interp_steps, n * zoom_levels);
beta_opt = zeros(interp_steps, n * zoom_levels);
lmax_tilde = zeros(interp_steps, zoom_levels);
lmax_opt = zeros(interp_steps, zoom_levels);

% initial zoom into the original P matrix ---------------------------------

Pmatrix = P;

% Make J matrix template
J = [zeros(n,n), eye(n,n); -Pmatrix, -diag(beta_SA)];

% Make initial lattice specs for 2D
lattice = [];
lattice.a = a;
lattice.b = b;
lattice.size = lattice_size;
lattice.center_a = initial_extent / 2;
lattice.center_b = initial_extent / 2;
lattice.extent_a = initial_extent;
lattice.extent_b = initial_extent;

% zoom!
betas = zeros(1, n*zoom_levels);
lambdas = zeros(1, zoom_levels);
for z = 1 : zoom_levels

    % run lattice
    [beta, lmax] = GetLmaxLattice2D(J, lattice, parallel);
    betas((z-1)*n+1 : z*n) = beta;
    lambdas(z) = lmax;

    % zoom in to the next level: centered at the previous optimum
    lattice.center_a = beta(a);
    lattice.center_b = beta(b);
    lattice.extent_a = lattice.extent_a / zoom_factor;
    lattice.extent_b = lattice.extent_b / zoom_factor;
end

% record final result
beta_opt(1,:) = betas;
lmax_opt(1,:) = lambdas;

% do the first 1D case separately as well -------------------------------
% make initial lattice specs for 1D  
% (a, b, and lattice_size are unchanged)
lattice.center = initial_extent / 2;        
lattice.extent = initial_extent;        

% zoom!
betas = zeros(1, n*zoom_levels);
lambdas = zeros(1, zoom_levels);
for z = 1 : zoom_levels

    % run lattice
    [beta1, lmax1] = GetLmaxLattice1D(J, lattice);
    betas((z-1)*n+1 : z*n) = beta1;
    lambdas(z) = lmax1;

    % zoom in to the next level: centered at the previous optimum
    lattice.center = beta1(a);  % or beta(b), they are the same
    lattice.extent = lattice.extent / zoom_factor;

end

% record final result
beta_tilde(1,:) = betas;
lmax_tilde(1,:) = lambdas;


% continuation-based zoomin
for k = 2 : interp_steps  % no parfor this time

    fprintf('  k = %d / %d\n', k, interp_steps);
    Pmatrix = P + Pstep * (k-1); % interpolate

    % Make J matrix template
    J = [zeros(n,n), eye(n,n); -Pmatrix, -diag(beta_SA)];

    % Make initial lattice specs for 2D
    lattice = [];
    lattice.a = a;
    lattice.b = b;
    lattice.size = lattice_size;
    lattice.center_a = beta(a); % last zoomlevel of last interpolation step!!!
    lattice.center_b = beta(b);
    lattice.extent_a = initial_extent * (1/zoom_factor)^(continue_zoom-1);
    lattice.extent_b = initial_extent * (1/zoom_factor)^(continue_zoom-1);

    % zoom!
    betas = zeros(1, n*zoom_levels);
    lambdas = zeros(1, zoom_levels);
    for z = continue_zoom : zoom_levels

        % run lattice
        [beta, lmax] = GetLmaxLattice2D(J, lattice, parallel);
        betas((z-1)*n+1 : z*n) = beta;
        lambdas(z) = lmax;

        % zoom in to the next level: centered at the previous optimum
        lattice.center_a = beta(a);
        lattice.center_b = beta(b);
        lattice.extent_a = lattice.extent_a / zoom_factor;
        lattice.extent_b = lattice.extent_b / zoom_factor;
    end

    % record final result
    beta_opt(k,:) = betas;
    lmax_opt(k,:) = lambdas;

    % Make initial lattice specs for 1D  
    % (a, b, and lattice_size are unchanged)
    lattice.center = initial_extent / 2;        
    lattice.extent = initial_extent;        

    % zoom!
    betas = zeros(1, n*zoom_levels);
    lambdas = zeros(1, zoom_levels);
    for z = 1 : zoom_levels

        % run lattice
        [beta1, lmax1] = GetLmaxLattice1D(J, lattice);
        betas((z-1)*n+1 : z*n) = beta1;
        lambdas(z) = lmax1;

        % zoom in to the next level: centered at the previous optimum
        lattice.center = beta1(a);  % or beta(b), they are the same
        lattice.extent = lattice.extent / zoom_factor;

    end

    % record final result
    beta_tilde(k,:) = betas;
    lmax_tilde(k,:) = lambdas;

end

% save results
fname = sprintf('Results_%s/interp2_lmax_%s_%d_%d.dat', sysname, sysname, a, b);
dlmwrite(fname, [lmax_opt, lmax_tilde]);

fname = sprintf('Results_%s/interp2_beta_tilde_%s_%d_%d.dat', sysname, sysname, a, b);
dlmwrite(fname, beta_tilde);

fname = sprintf('Results_%s/interp2_beta_opt_%s_%d_%d.dat', sysname, sysname, a, b);
dlmwrite(fname, beta_opt);

