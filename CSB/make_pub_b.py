# publication row 2: landscape 2D plots

import numpy as np
import matplotlib.pyplot as plt
from make_pub_tools import get_lmax, add_panel_label
from matplotlib import cm
from matplotlib.colors import ListedColormap


def plot_landscape(fig, ax, data, idx, **kwargs):

    # extract data
    sysname = data.sysname
    a = data.a
    b = data.b
    
    btilde = data.btilde
    bopt_a = data.bopt_a
    bopt_b = data.bopt_b    

    # recompute the landscape on the fly.
    # btilde must be on the diagonal -> need the bounding box of btilde, the bopt point, and its mirror image
    
    bmin_a = min((bopt_a, btilde, bopt_b))
    bmin_b = bmin_a
    bmax_a = max((bopt_a, btilde, bopt_b))
    bmax_b = bmax_a
    
    # expand range a bit
    ratio = 0.1
    extent = bmax_a - bmin_a
    bmin_a -= extent * ratio
    bmin_b -= extent * ratio
    bmax_a += extent * ratio
    bmax_b += extent * ratio
    
    # lattice
    res = 200
    beta_a = np.linspace(bmin_a, bmax_a, res)
    beta_b = np.linspace(bmin_b, bmax_b, res)
    
    ba_range = bmax_a - bmin_a
    bb_range = bmax_b - bmin_b
    
    # if the landscape with the given parameters exists, load it. 
    # else, compute it and save it
    descriptor = (res, bmin_a, bmin_b, bmax_a, bmax_b)
    fname = "pub_landscape_%s_%d.npz" % (sysname, hash(descriptor))
    try:
        with np.load(fname) as f:
            L = f['L']
    except:
        # data
        P = np.loadtxt("EQ_%s/P_%d_%d.dat" % (sysname, a, b), delimiter=',') # PEQ matrix
        beta = np.loadtxt("%s_beta_SA.dat" % sysname)[-1,:] # optimal betas   
        
        # make J template
        n = beta.shape[0]
        J1 = np.hstack((np.zeros((n,n)), np.eye(n)))
        J2 = np.hstack((-P, -np.diag(beta)))
        J = np.vstack((J1, J2))
    
        # compute    
        L = np.zeros((res,res))
        for j in range(res):
            for i in range(res):
                J[a+n-1, a+n-1] = -beta_a[i]
                J[b+n-1, b+n-1] = -beta_b[j]
                L[j,i] = get_lmax(J)
        
        np.savez_compressed(fname, L=L)
    
    # colors relative to lmax_opt (locally)
    lopt = np.min(L)
    L = np.log10(L - lopt)
    
    # set the colorbar limits 
    
    #cmap = plt.get_cmap('jet')
    
#    c5 = np.array([124,132,174,255]) / 255
#    c4 = np.array([82, 92,145,255]) / 255
#    c3 = np.array([49, 59,116,255]) / 255
#    c2 = np.array([24, 34, 87,255]) / 255
#    c1 = np.array([7, 15, 58,255]) / 255
#    
#    inter =  np.linspace(0, 1, 20, endpoint=False)[:,None]
#    colors = [c1 * (1-inter) + c2 * inter]
#    colors.append(c2 * (1-inter) + c3 * inter)
#    colors.append(c3 * (1-inter) + c4 * inter)
#    colors.append(c4 * (1-inter) + c5 * inter)
#    cc = np.vstack(colors)
    
    c1 = np.array([255, 255, 204, 255]) / 255
    c2 = np.array([0, 0, 102, 255]) / 255
    inter =  np.linspace(0, 1, 100)[:,None]
    cc = c1 * (1-inter) + c2 * inter
    
    cmap = ListedColormap(cc)
    cmap.set_over(cmap(0.999))
    cmap.set_under(cmap(0))
    
    #lmax_range = lmax_tilde - lmax_opt    
#    im = ax.imshow(L, cmap=cmap, extent=(bmin_a, bmax_a, bmin_b, bmax_b), origin='lower',
#                   vmin=lmax_opt-lmax_range*0.1, vmax=lmax_tilde+lmax_range*0.8)
    im = ax.imshow(L, cmap=cmap, extent=(bmin_a, bmax_a, bmin_b, bmax_b), origin='lower',
                   vmin=-1.5, vmax=0.5)
    #im = ax.imshow(L, cmap=cmap, extent=(bmin_a, bmax_a, bmin_b, bmax_b), origin='lower')
    
    ax.set_aspect(ba_range / bb_range)
   
    # diagonal
    ax.plot(beta_a, beta_a, 'w--', linewidth=1)    
    
    # get the eqn for the line going through the beta points
    x1, y1 = btilde, btilde
    x2, y2 = bopt_a, bopt_b
    dx = x2 - x1
    dy = y2 - y1
    
    # find out what beta_b correspond to the beta_a along that line
    bmin_b2 = (bmin_a - x1) * (dy/dx) + y1 # vertical axis values must be on the line
    bmax_b2 = (bmax_a - x1) * (dy/dx) + y1
    bb = np.linspace(bmin_b2, bmax_b2, beta_a.shape[0])
    
    ax.plot(beta_a, bb, 'k--', linewidth=1)

    # point markers
    ax.plot(bopt_a, bopt_b, 'o', markersize=6, mec='k', mfc='w')
    ax.plot(btilde, btilde, 'o', markersize=6, mec='k', mfc='r')

    ax.set_xlim(bmin_a, bmax_a)
    ax.set_ylim(bmin_b, bmax_b)
    
    if idx==3:
        cbar = fig.colorbar(im, cax=kwargs['cax'], extend='both', format='%2.1f')
        cbar.set_label(r'$\lambda^\mathrm{max} - \lambda^\mathrm{max}_\mathrm{opt}$')
        cbar.ax.tick_params(labelsize=8) 
        
        ticks = [0.05, 0.1, 0.2, 0.5, 1, 2]
        labels = [str(tik) for tik in ticks]
        logticks = np.log10(ticks)
        cbar.set_ticks(logticks)
        cbar.set_ticklabels(labels)
        
    
    ax.set_xlabel(r'$\beta_{%d}$' % a, fontsize=12, labelpad=0)
    ax.set_ylabel(r'$\beta_{%d}$' % b, fontsize=12, labelpad=0)
    
    step=1
    yticks = np.arange(np.ceil(bmin_b), np.floor(bmax_b)+1, step)
    while len(yticks)>4:
        step += 1
        yticks = np.arange(np.ceil(bmin_b), np.floor(bmax_b)+1, step)
    ax.set_yticks(yticks)
    
    step=1
    xticks = np.arange(np.ceil(bmin_a), np.floor(bmax_a)+1, step)
    while len(xticks)>4:
        step += 1
        xticks = np.arange(np.ceil(bmin_a), np.floor(bmax_a)+1, step)
    ax.set_xticks(xticks)
    
    add_panel_label(ax, kwargs['label'], 1, idx)
    
    plt.pause(0.1)
