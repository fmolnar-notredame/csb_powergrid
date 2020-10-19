function [beta_tilde, lmax_tilde] = GetLmaxLattice1D(J, lattice)
% Calculate the lmax_tilde on the given beta lattice
% J: matrix template, it should have the correct betas for nodes that do
%    not change,
% nodes: the node indices that will be varied on the lattice,
% lattice: lattice parameters, see below

%% extract lattice parameters

a = lattice.a; % node a
b = lattice.b; % node b
res = lattice.size;
ctr = lattice.center;
xt = lattice.extent / 2;

%% run

% P matrix size
n = size(J,1)/2;

% define the beta space lattice
betas = linspace(ctr - xt, ctr + xt, res);

% Lmax lattice
Lmax = zeros(res, 1);

for i = 1:res
    J(n+a, n+a) = -betas(i);
    J(n+b, n+b) = -betas(i);
    Lmax(i) = GetLmaxJ(J);
end

% find the minimum point
[~,i] = min(Lmax);
lmax_tilde = Lmax(i);

% formulate the optimal beta
d = diag(J);
beta_tilde = -d(n+1 : 2*n);
beta_tilde(a) = betas(i);
beta_tilde(b) = betas(i);

end
