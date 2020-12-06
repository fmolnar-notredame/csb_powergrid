function mpc = load_system( casename, convert )
%load_system Loads the specified powergrid sample by case name and
%conversion

if (convert == 0)       % matpower func
    mpc = eval(casename);
elseif (convert == 1)   %matpower from .mat file
    load(casename);
elseif (convert == 2)   %pst func
    [bus, line, mac_con] = eval(casename);
    %fprintf('Using OLD pst conversion (adding fictitious generators)\n');
    %mpc = pst2matpower_old(bus, line, mac_con);
    fprintf('Using NEW pst conversion (no fictitious generators)\n');
    mpc = pst2matpower(bus, line, mac_con);
elseif (convert == 3)   %US power grid sample
    fname = [casename '.mat'];
    if exist(fname, 'file')
        load(fname);
    else
        %load nametable
        names = readtable('nametable.txt', 'Delimiter', '\t', 'ReadVariableNames', false);
        [rows, ~] = size(names);
        for i = 1 : rows
            id = cell2mat(table2array(names(i,1)));
            fname = cell2mat(table2array(names(i,2)));

            if (id == casename)
                load(fname); %contains mpc
                return
            end
        end
    end
end

end

