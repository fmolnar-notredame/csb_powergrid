function P = make_exact_EP(P,Q)
% Make the partitiation equitable by setting the matrix element P_{ij} to
% the average of P(ii,jj) over all nodes ii in  the same cluster as node i,
% and all nodes jj \neq ii in the same cluster as node j.

P = zero_diagonal(P);

% Generate a matrix that would be the Laplacian matrix of the quotient
% graph if Q was an equitable partition.  Pq(c1,c2) = the average of
% P(i1,i2) over all nodes i1 in cluster c1 and all nodes i2 \neq i1 in
% cluster c2.
Pq = P_quotient(P,Q);

for i = 1:size(Pq,1)
    for j = 1:size(Pq,2)
        if i == j && sum(Q(:,i)) == 1, continue, end
        ii = logical(Q(:,i));
        jj = logical(Q(:,j));
        input_sums = P(ii,:)*Q(:,j);
        P(ii,jj) = P(ii,jj) ./ (input_sums*ones(1,sum(Q(:,j)))) * Pq(i,j);
    end
end

P = fix_diagonal(P);
