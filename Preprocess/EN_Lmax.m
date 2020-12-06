function [lmax, eigvals, lmax_tilde] = EN_Lmax( ps )
% calculates Lmax from EN model

% calculate the extended bus admittance matrix, split to parts for
% Kron-reduction
[Ynn, Ynr, Yrn, Yrr] = MakeExtendedYbus(ps);

% Do Kron-reduction
%YEN = full(Ynn - Ynr * (Yrr \ Yrn));
YEN = full(Ynn) - full(Ynr) * (full(Yrr) \ full(Yrn));

% Calculate linearization
P = pg_eff_net_lin_P(ps, YEN);

% Calculate J matrix
n = size(ps.gen, 1);
beta = ps.gen_dyn(:,3) ./ (2.0 * ps.gen_dyn(:,2));
J = [ zeros(n,n), eye(n); -P, -diag(beta) ];

ev_P = eig(P);
[~,ix] = min(abs(ev_P));
ev_P(ix) = [];
beta_tilde = 2*sqrt(min(abs(ev_P)));
J2 = [ zeros(n,n), eye(n); -P, -diag(beta_tilde * ones(n,1)) ];

% Calculate smallest nonzero eigenvalue
ev_J = eig(J);
eigvals = ev_J;
[~,ix] = min(abs(ev_J));
ev_J(ix) = [];
lmax = max(real(ev_J));

ev_J = eig(J2);
[~,ix] = min(abs(ev_J));
ev_J(ix) = [];
lmax_tilde = max(real(ev_J));


end

