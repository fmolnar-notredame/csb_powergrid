# make landscape plots for selected clusters
# using the exact equitable matrix
# using precomputed landscapes from matlab

import numpy as np
import matplotlib.pyplot as plt

#%% Input
    
# define systems
sysnames = ['10gen', '48gen', 'uk', 'germany']
sysname = sysnames[0]

# load the clusters
cluster_file = 'cluster_choice_%s.dat' % sysname
clusters = np.loadtxt(cluster_file, delimiter=',').astype(np.int) - 1 # 0-based

if clusters.ndim == 1:
    clusters = clusters[None,:]

#%% process each cluster

for j in range(clusters.shape[0]):

    # get nodes
    a, b = clusters[j,:]

    # load landscape args
    fname = 'Results_%s/landscape_args_%s_%d_%d.dat' % (sysname, sysname, a+1, b+1)
    with open(fname, 'r') as f:
        bmin_a, bmax_a, bmin_b, bmax_b = [ float(item) for item in f.readline().split(',')]
        bopt_a, bopt_b, lmax_opt = [ float(item) for item in f.readline().split(',')]
        btilde, lmax_tilde = [ float(item) for item in f.readline().split(',')]
        
    # load landscape matrix
    fname = 'Results_%s/landscape_%s_%d_%d.dat' % (sysname, sysname, a+1, b+1)
    L = np.loadtxt(fname, delimiter=',')

    res = L.shape[0]    
    beta_a = np.linspace(bmin_a, bmax_a, res)
    beta_b = np.linspace(bmin_b, bmax_b, res)
    
    ba_range = bmax_a - bmin_a
    bb_range = bmax_b - bmin_b
    
    #%%
    plt.figure(2)
    plt.clf()
    try:
        im = plt.imshow(L, cmap=plt.get_cmap('jet'), extent=(bmin_a, bmax_a, bmin_b, bmax_b), origin='lower')
        
        ax = plt.gca()
        ax.set_aspect(ba_range / bb_range)
        
        plt.plot(bopt_a, bopt_b, 'o', markersize=8, mec='k', mfc='w')
        plt.plot(btilde, btilde, 'o', markersize=8, mec='k', mfc='r')
        
        cbar = plt.colorbar(im, ax=ax)
        cbar.set_label(r'$\lambda^\mathrm{max}$')
        
        plt.xlabel(r'$\beta_{%d}$' % (a+1))
        plt.ylabel(r'$\beta_{%d}$' % (b+1))
        plt.tight_layout()
    
    except: # some nonsense landscape
        continue

    plt.savefig('Results_%s/landscape_zoom_%s_%d_%d.png' % (sysname, sysname, a+1, b+1))
