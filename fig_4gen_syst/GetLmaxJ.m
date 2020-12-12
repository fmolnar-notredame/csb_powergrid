function lmax = GetLmaxJ(J)
% get Lmax from a J matrix

eval = eig(J);

[~,ix] = min(abs(eval));
eval(ix) = [];
lmax = max(real(eval));

end