function ok = CheckSize(count)
% user interactive function to check for the size of the array/cell
% proposed to be allocated

ok = false;
if count > 1e9 %assuming 4byte integers
    fprintf('WARNING: output array size will exceed 4 GB\n')
    re = input('Proceed? (y/n)', 's');
    if strcmp(re, 'y'); ok=true; end
else
    ok = true;
end

end

