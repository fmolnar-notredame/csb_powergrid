function make_stressed_systems(casename, convert, stress, rangename)

%configure
precision = '%.16f';

%load system
mpc = load_system(casename, convert);

%compute capacity of the system (the multiplier c where the system becomes
%unstable)
%results = capacity(mpc, 0, 10, 1e-4);
%cap = results.capacity;
cap = 1.0;

mkdir(casename);
outdir = [casename '/' rangename];
mkdir(outdir);

%export stress levels
filename = sprintf('%s/levels.txt', outdir);
dlmwrite(filename, stress', 'precision', precision, 'newline', 'pc');

for k = 1 : length(stress)
    s = stress(k);
    [success, ~, results] = compute_stability(mpc, cap * s);

    if (~success) 
        continue
    end    
    
    %export the P matrix
    filename = sprintf('%s/level%04d_P.txt', outdir, k);
    dlmwrite(filename, results.P, 'precision', precision, 'newline', 'pc');
    
    %export betas
    n = size(results.P,1);
    b = diag(-results.J(n+1 : 2*n, n+1 : 2*n));
    filename = sprintf('%s/level%04d_b.txt', outdir, k);
    dlmwrite(filename, b, 'precision', precision, 'newline', 'pc');
    
end
