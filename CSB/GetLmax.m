function lmax = GetLmax(P, betas, noskip)

J = [ zeros(size(P)), eye(size(P)); 
    -P, -diag(betas)];

eval = eig(J);

if nargin>2 && noskip
    lmax = max(real(eval));
else
    [~,ix] = min(abs(eval));
    eval(ix) = [];
    lmax = max(real(eval));
end
    
end
