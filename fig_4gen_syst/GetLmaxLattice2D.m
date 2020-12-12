function [beta_opt, lmax_opt, Lmax] = GetLmaxLattice2D(J, lattice, parallel)
% Calculate the lmax on the given beta lattice
% J: matrix template, it should have the correct betas for nodes that do
%    not change,
% lattice: lattice parameters, see below
% parallel: if true, it uses parfor (default: false)

if nargin <= 2
    parallel=false;
end

%% extract lattice parameters

a = lattice.a; % node a
b = lattice.b; % node b
res = lattice.size;
ca = lattice.center_a;
cb = lattice.center_b;
xa = lattice.extent_a / 2;
xb = lattice.extent_b / 2;

%% run

% P matrix size
n = size(J,1)/2;

% define the beta space lattice
beta_a = linspace(ca - xa, ca + xa, res);
beta_b = linspace(cb - xb, cb + xb, res);

% Lmax lattice
Lmax = zeros(res, res);

if parallel
    parfor j = 1:res % parfor compatible
        JJ = J; % local copy
        Lj = zeros(res,1); % j-th column of L1

        for i = 1:res
            JJ(n+a, n+a) = -beta_a(j); % a varies horizontally
            JJ(n+b, n+b) = -beta_b(i); % b varies vertically
            Lj(i) = GetLmaxJ(JJ);
        end

        % store
        Lmax(:,j) = Lj;
    end

else
    for j = 1:res % parfor compatible
        JJ = J; % local copy
        Lj = zeros(res,1); % j-th column of L1

        for i = 1:res
            JJ(n+a, n+a) = -beta_a(j); % a varies horizontally
            JJ(n+b, n+b) = -beta_b(i); % b varies vertically
            Lj(i) = GetLmaxJ(JJ);
        end

        % store
        Lmax(:,j) = Lj;
    end
end

% find the minimum point
[~,i] = min(Lmax(:));
[i,j] = ind2sub(size(Lmax), i); % row index i, col index j
lmax_opt = Lmax(i,j);

% formulate the optimal beta
d = diag(J);
beta_opt = -d(n+1 : 2*n);
beta_opt(a) = beta_a(j);
beta_opt(b) = beta_b(i);

end

