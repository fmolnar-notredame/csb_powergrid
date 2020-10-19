# make interpolation plots 
# v2: continued interpolation mode, only for select systems

import numpy as np
import matplotlib.pyplot as plt

#%% Input
    
# define systems
sysnames = ['10gen', '48gen', 'uk', 'germany']
sizes = [10, 48, 66, 69]
clusterChoices = [[6,7], [37,38], [8,10], [59,65]]

sysindex = 3

sysname = sysnames[sysindex]
n = sizes[sysindex]

# get nodes
a, b = clusterChoices[sysindex]

# load lmax data
fname = 'Results_%s/interp2_lmax_%s_%d_%d.dat' % (sysname, sysname, a, b)
with open(fname, 'r') as f:        
    raw = [ [float(item) for item in line.split(',')] for line in f]        
data = np.array(raw)

levels = data.shape[1] // 2 # zoom levels

# extract lmax results    
lmax_opt = data[:,0:levels]
lmax_tilde = data[:,levels:2*levels]
interp = np.linspace(0, 1, lmax_opt.shape[0])

colorscale = np.linspace(0.1, 0.7, levels)
c1 = plt.get_cmap('Reds')
c2 = plt.get_cmap('Blues')

# make figure
plt.figure(1, figsize = (6,4))
plt.clf()

for i in range(7,levels):
    if i==levels-1:
        plt.plot(interp, lmax_tilde[:,i], '-', linewidth=2, color=c1(colorscale[i]), label='uniform')
        plt.plot(interp, lmax_opt[:,i], '-', linewidth=2, color=c2(colorscale[i]), label='non-uniform')
    else:
        plt.plot(interp, lmax_tilde[:,i], '-', linewidth=2, color=c1(colorscale[i]))
        plt.plot(interp, lmax_opt[:,i], '-', linewidth=2, color=c2(colorscale[i]))
        #plt.fill_between(interp, lmax_tilde[:,i], lmax_tilde[:,-1], color=c1(colorscale[i]))
        #plt.fill_between(interp, lmax_opt[:,i], lmax_opt[:,-1], color=c2(colorscale[i]))
            
plt.xlabel('interpolation from original to equitable')
plt.ylabel(r'$\lambda^\mathrm{max}$')

plt.legend()
plt.tight_layout()

fname = 'Results_%s/interp2_plot_%s_%d_%d.png' % (sysname, sysname, a+1, b+1)
plt.savefig(fname)
    