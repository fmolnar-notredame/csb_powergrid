import numpy as np
import matplotlib.pyplot as plt
from make_pub_tools import add_panel_label

ylim = [[-4.95, -3.9], [-2.32, -2.02], [-6.35, -5.95], [-3.35, -2.6]]

#%% plot interpolation
def plot_interp(fig, ax, data, idx, **kwargs):
    
    x = data.interp_x
    lmax_opt = data.interp_lmax_opt
    lmax_tilde = data.interp_lmax_tilde
    
    a = data.a
    b = data.b
    
    ax.plot(x, lmax_tilde, 'r-', label=r'$\beta_{%d} = \beta_{%d}$'%(a,b))
    ax.plot(x, lmax_opt, 'b-', label=r'$\beta_{%d} \neq \beta_{%d}$'%(a,b))

    ax.set_ylim(ylim[idx])
    
    ax.set_xlabel(r'$\alpha$')

    if idx==0:
        ax.set_ylabel(r'$\lambda^\mathrm{max}$', fontsize=12)
        
    #ax.legend(loc='center right')
   
    add_panel_label(ax, kwargs['label'], 3, idx)
    
    plt.pause(0.1)