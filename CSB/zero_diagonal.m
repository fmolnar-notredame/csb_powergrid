function P = zero_diagonal(P)
% replace the diagonal elements of P with zeros
% (write directly, do not compute --> supports nan, etc)

n = size(P,1);
for i = 1 : n
    P(i,i) = 0;
end

end

