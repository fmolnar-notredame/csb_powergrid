function [ alpha2 ] = EN_Alpha2( ps )
% calculates Alpha2 from EN model

% calculate the extended bus admittance matrix, split to parts for
% Kron-reduction
[Ynn, Ynr, Yrn, Yrr] = MakeExtendedYbus(ps);

% Do Kron-reduction
YEN = full(Ynn - Ynr * (Yrr \ Yrn));

% Calculate linearization
P = pg_eff_net_lin_P(ps, YEN);

eigvals = eig(P);

% find the row/col index of alpha2
[~, alphaIndex] = sort(abs(eigvals));
alpha2Index = alphaIndex(2);
alpha2 = eigvals(alpha2Index);

end

