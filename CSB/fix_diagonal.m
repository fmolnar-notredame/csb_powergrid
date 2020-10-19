function P = fix_diagonal(P)
% replace the diagonal of the matrix with the negative rowsum of the
% offdiagonal elements in each row

n = size(P, 1);
for i = 1 : n
    P(i,i) = -sum(P(i,[1:i-1,i+1:n]));
end

end

