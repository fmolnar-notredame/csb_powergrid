function make_stressed_systems_ps(casename, stress, rangename)

%configure
precision = '%.16f';

%load system
load(casename); %loads as ps2

mkdir(casename);
outdir = [casename '/' rangename];
mkdir(outdir);

%export stress levels
filename = sprintf('%s/levels.txt', outdir);
dlmwrite(filename, stress', 'precision', precision, 'newline', 'pc');

for k = 1 : length(stress)
    s = stress(k);    
    
    % Scale each load and generator by c.
    ps = ps2;
    ps.bus(:,3) = s * ps.bus(:,3); %scale up active power load
    ps.bus(:,4) = s * ps.bus(:,4); %scale up reactive power load
    ps.gen(:,2) = s * ps.gen(:,2); %scale up active power generated
    % note, some will be overwritten by powerflow

    [ps3, success] = runpf_ps(ps);
       
    if (~success) 
        continue
    end    
    
    % make the P matrix
    [Ynn, Ynr, Yrn, Yrr] = MakeExtendedYbus(ps3);

    % Do Kron-reduction
    %YEN = full(Ynn - Ynr * (Yrr \ Yrn));
    YEN = full(Ynn) - full(Ynr) * (full(Yrr) \ full(Yrn));

    % Calculate linearization
    P = pg_eff_net_lin_P(ps3, YEN);
    
    %export the P matrix
    filename = sprintf('%s/level%04d_P.txt', outdir, k);
    dlmwrite(filename, P, 'precision', precision, 'newline', 'pc');
    
    %export original betas    
    b = ps3.gen_dyn(:,3) ./ (2.0 * ps3.gen_dyn(:,2));    
    filename = sprintf('%s/level%04d_b.txt', outdir, k);
    dlmwrite(filename, b, 'precision', precision, 'newline', 'pc');
    
end
