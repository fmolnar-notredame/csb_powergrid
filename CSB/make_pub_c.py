# publication row 3: similarity graphs

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatch
import matplotlib.path as mpath
import matplotlib.cm as cm

from make_pub_tools import add_panel_label

# plot similarity graphs
def plot_similarity(fig, ax, data, idx, **kwargs):
    
    ax.axis('off')
    
    sysname = data.sysname
    a = data.a - 1
    b = data.b - 1
    
    q = 6 # how many common nodes to show in the tripartite plot
    circ = dict(markersize=14, mec='k', mfc='w', mew=0.5) # node style
    labels = dict(ha='center', va='center', fontsize=9)

    P = np.loadtxt("%s_P_orig.dat" % sysname, delimiter=',')
    n = P.shape[0]
    
    # in the P matrix, out of the n-2 neighbors of a and b, 
    # find q nodes with the strongest links (in absolute edge weight)
    neighbors = np.hstack((range(0,a), range(a+1,b), range(b+1,n))).astype(np.int)
    
    links = np.abs(P[a,neighbors])
    order = np.argsort(links)[::-1] # decreasing order
    neigh = neighbors[order[:q]]
    link_a_to_neigh = links[order[:q]]
    link_b_to_neigh = np.abs(P[b, neighbors])[order[:q]]
    
    link_a_to_b = np.abs(P[a,b])
    link_b_to_a = np.abs(P[b,a])
    
    # get max value for color scaling
    cmax = np.max((link_a_to_neigh[0], link_b_to_neigh[0], link_a_to_b, link_b_to_a)) 
    cmap = plt.get_cmap('winter')
    
    cy = np.flip(np.arange(q) - (q-1)/2, 0) # reversed: strongest link on top (largest y value)
    cx = np.zeros(cy.shape)
    
    # pull a gap so we can plot the a--b links
    cy[cy<0] -= 1
    cy[cy>0] += 1
    
    # add similarity value
    label = r'$s=%4.3f$' % data.similarity
    ax.text(-2.1, q*0.6, label, fontsize=9)

    # links a to center
    for i in range(q):
        ratio = link_a_to_neigh[i]/cmax
        ax.plot([-2, 0], [0, cy[i]], '-', color=cmap(ratio), linewidth=1)
        
    # links b to center
    for i in range(q):
        ratio = link_b_to_neigh[i]/cmax
        ax.plot([2, 0], [0, cy[i]], '-', color=cmap(ratio), linewidth=1)
        
    ax.set_xlim(-2.3, 2.3)
    ax.set_ylim(-q*0.7, q*0.7)
        
    # link a->b
    ratio = link_a_to_b / cmax    
    lw = 1
    style = "simple,tail_width=%f,head_width=%f,head_length=%f" % (lw, lw*4, lw*6)
    path = mpath.Path([(-1.2,0.1), (0,1), (1.2,0.1)],
                      [mpath.Path.MOVETO,mpath.Path.CURVE3,mpath.Path.CURVE3])
    arrow = mpatch.FancyArrowPatch(path=path, arrowstyle=style, color=cmap(ratio), zorder=1000)    
    ax.add_patch(arrow)    

    # link b->a
    ratio = link_b_to_a / cmax    
    lw = 1
    style = "simple,tail_width=%f,head_width=%f,head_length=%f" % (lw, lw*4, lw*6)
    path = mpath.Path([(1.2,-0.1), (0,-1), (-1.2,-0.1)],
                      [mpath.Path.MOVETO,mpath.Path.CURVE3,mpath.Path.CURVE3])
    arrow = mpatch.FancyArrowPatch(path=path, arrowstyle=style, color=cmap(ratio), zorder=1000)
    ax.add_patch(arrow)

    
    # center nodes
    ax.plot(cx, cy, 'o', **circ)
    for i in range(q):
        ax.annotate('%d'%(neigh[i]+1), xy=(0,cy[i]), **labels)
    
    # node a
    ax.plot([-2], [0], 'o', **circ)
    ax.annotate('%d'%(a+1), xy=(-2,0), **labels)
    
    # node b
    ax.plot([2], [0], 'o', **circ)
    ax.annotate('%d'%(b+1), xy=(2,0), **labels)
    
#    # lines to show scale legend
#    for ratio in [0, 0.5, 1-1e-9]:
#        value = ratio * cmax
#        ax.plot([0, 0], [0, 0], '-', color=cmap(ratio), linewidth=1, 
#                 label='%2.1f' % value, solid_capstyle='projecting', dash_capstyle='projecting')
    
    if idx==3:
        sm = cm.ScalarMappable(cmap=cmap)
        
        cbar = fig.colorbar(sm, cax=kwargs['cax'], format='%2.1f')
        cbar.set_label(r'$z$')
        cbar.ax.tick_params(labelsize=8) 
        
        ticks = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        labels = [str(tik) for tik in ticks]        
        cbar.set_ticks(ticks)
        cbar.set_ticklabels(labels)
        

    add_panel_label(ax, kwargs['label'], 2, idx)
    
    plt.pause(0.1)