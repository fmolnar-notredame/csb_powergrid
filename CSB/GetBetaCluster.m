function beta = GetBetaCluster(mask, betaCluster, betaOther)
% create a beta vector based on the given index mask, and betas

beta = zeros(size(mask));
beta(mask) = betaCluster;
beta(~mask) = betaOther;

end

