import numpy as np
import matplotlib.pyplot as plt
from make_pub_tools import get_lmax, add_panel_label

# tick marks on the top panels
lmax_ticks = [[-2, -3, -4], [-2.1, -2.2, -2.3], [-5.0, -5.5, -6.0], [-3.1, -3.2, -3.3]]

#%%
def plot_over_landscape(fig, ax, data, idx, **kwargs):
    
    sysname = data.sysname
    a = data.a
    b = data.b
    
#    bmin_a = data.bmin_a
#    bmin_b = data.bmin_b
#    bmax_a = data.bmax_a
#    bmax_b = data.bmax_b

    # use the same landscape extent as in the landscape plot
    btilde = data.btilde
    bopt_a = data.bopt_a
    bopt_b = data.bopt_b    
    
    bmin_a = min((bopt_a, btilde, bopt_b))
    bmax_a = max((bopt_a, btilde, bopt_b))
    
    # expand range a bit
    ratio = 0.1
    extent = bmax_a - bmin_a
    bmin_a -= extent * ratio
    bmax_a += extent * ratio

    # actually do eig locally
    P = np.loadtxt("EQ_%s/P_%d_%d.dat" % (sysname, a, b), delimiter=',') # PEQ matrix
    beta = np.loadtxt("%s_beta_SA.dat" % sysname)[-1,:] # optimal betas   
    
    # make J template
    n = beta.shape[0]
    J1 = np.hstack((np.zeros((n,n)), np.eye(n)))
    J2 = np.hstack((-P, -np.diag(beta)))
    J = np.vstack((J1, J2))
    
    # get the eqn for the line going through the beta points
    x1, y1 = data.btilde, data.btilde
    x2, y2 = data.bopt_a, data.bopt_b
    dx = x2 - x1
    dy = y2 - y1
    
    # find out what betas correspond to the landscape bounds
    bmin_b = (bmin_a - x1) * (dy/dx) + y1 # vertical axis values must be on the line
    bmax_b = (bmax_a - x1) * (dy/dx) + y1
    
    N = 100
    bb_a = np.linspace(bmin_a, bmax_a, N)
    bb_b = np.linspace(bmin_b, bmax_b, N)
    lmax = np.zeros(N)
    
    for i in range(N):
        J[a+n-1, a+n-1] = -bb_a[i]
        J[b+n-1, b+n-1] = -bb_b[i]
        lmax[i] = get_lmax(J)
        
    ax.plot(bb_a, lmax, 'k-', linewidth=0.5)
    ax.set_xlim(bmin_a, bmax_a)
    
    step=1
    xticks = np.arange(np.ceil(bmin_a), np.floor(bmax_a)+1, step)
    while len(xticks)>4:
        step += 1
        xticks = np.arange(np.ceil(bmin_a), np.floor(bmax_a)+1, step)
    ax.set_xticks(xticks)
    
    ax.set_yticks(lmax_ticks[idx])
    
    if idx==0:
        ax.set_ylabel(r'$\lambda^\mathrm{max}$', fontsize=12)
        
    add_panel_label(ax, kwargs['label'], 0, idx)
    
    plt.pause(0.1)
