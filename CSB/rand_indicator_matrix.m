function Q = rand_indicator_matrix(n,c)

Q = zeros(n,c);
i = randperm(n);
for k = 1:c
    Q(i(k),k) = 1;
end
for k = 1:n
    if sum(Q(k,:)) == 0
        Q(k,randi(c)) = 1;
    end
end