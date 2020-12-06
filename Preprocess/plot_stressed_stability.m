function plot_stressed_stability(casename, convert, stress)
%plots the given system against stress (load multiplier)
% convert: 0 for matpower func, 1 for matpower .mat data, 2 for pst func

%load system
if (convert == 0) % matpower func
    mpc = eval(casename);
elseif (convert == 1) %matpower from .mat file
    load(casename);
else        %pst func
    [bus, line, mac_con] = eval(casename);
    mpc = pst2matpower(bus, line, mac_con);    
end

%compute capacity of the system (the multiplier c where the system becomes
%unstable)
%results = capacity(mpc, 0, 10, 1e-4);
%cap = results.capacity;
%if isnan(cap)
%    cap = 1.0;
%end

cap = 1.0;


%make up some stress levels for plotting
%stress = 0 : 0.05 : 1.8;

lmax = nan(size(stress));
lmax2 = nan(size(stress));
for k = 1 : length(stress)
    s = stress(k);
    fprintf('Computing stress = %f\n', s);
    [success, ~, results] = compute_stability(mpc, cap * s);
    
    if success
        lmax(k) = results.max_lyap;
        lmax2(k) = results.max_lyap2;
        
        if isnan(lmax2(k))
            if ~results.is_alpha_real
                fprintf('  some alpha are complex\n');
                fprintf('  max imaginary part: %f\n', results.max_abs_imag_ev_P);
            end
            fprintf('  alpha_2 = %f + %fi\n', real(results.alpha2), imag(results.alpha2));
        end
    else
        fprintf('  no powerflow\n');
    end
    
end

%plot it
plot(stress, lmax, '*-')
xlabel('power demand multiplier','interpreter', 'none')
ylabel('lmax','interpreter', 'none')
hold on
plot(stress, lmax2, 'x-')
grid

end
