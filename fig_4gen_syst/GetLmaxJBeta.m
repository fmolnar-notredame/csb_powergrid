function lmax = GetLmaxJBeta(J, indices, beta)
    J(indices) = -beta;
    lmax = GetLmaxJ(J);
end
