function plot_stressed_stability_ps(casename, stress)
%plots the given system against stress (load multiplier)
% this version is for ps format

if ischar(casename)
    load(casename); %loads as ps2
else 
    ps2 = casename;
end

%make up some stress levels for plotting
%stress = 0 : 0.05 : 1.8;

lmax = nan(size(stress));
lmax2 = nan(size(stress));
for k = 1 : length(stress)
    s = stress(k);
    fprintf('Computing stress = %f\n', s);
    
    % Scale each load and generator by c.
    ps = ps2;
    ps.bus(:,3) = s * ps.bus(:,3); %scale up active power load
    ps.bus(:,4) = s * ps.bus(:,4); %scale up reactive power load
    ps.gen(:,2) = s * ps.gen(:,2); %scale up active power generated
    % note, some will be overwritten by powerflow

    [ps3, success] = runpf_ps(ps);
       
    if success
        [l1,~,l2] = EN_Lmax(ps3);
        lmax(k) = l1;
        lmax2(k) = l2;
        
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
