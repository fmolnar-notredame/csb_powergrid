# make tri-partite graph plots for the most similar 2-node clusters
# also creates cluster_choice files for the same clusters

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatch
import matplotlib.path as mpath
import os

#%% Load system

sysnames = ['10gen', '48gen', 'uk', 'germany']
sysname = sysnames[3] # <------------------------select current system here
fname = 'similarity_%s.csv' % sysname

with open(fname, 'r') as f:
    f.readline() # header
    raw = [ [float(item) for item in line.split(',')] for line in f]
    
data = np.array(raw)

nodes = data[:,[0,1]].astype(np.int) - 1 # 0-based indexing

# sort by similarity (out, in, both) i.e., 2-norm, so smaller is closer
idx_out = np.argsort(data[:,2])
idx_in =  np.argsort(data[:,3])
idx_both = np.argsort(data[:,4])
idx_eq = np.argsort(data[:,5])

# load the P matrix
P = np.loadtxt("%s_P_orig.dat" % sysname, delimiter=',')

# zero the diagonal
P = P - np.diag(np.diag(P))

count = 20 # how many to plot
n = P.shape[0]

#%% outfolder

result_folder = "Results_" + sysname
try:
    os.mkdir(result_folder)
    
except Exception as e:
    print("Did not make folder %s because: %s" % (result_folder, str(e)))

#%% make plots

q = 8 # how many common nodes to show in the tripartite plot

circ = dict(markersize=25, mec='k', mfc='w') # node style
labels = dict(ha='center', va='center', fontsize=12)

def plot_similarity(a, b):
    """make a plot showing how similar the neighborhoods of a and b are"""
    
    neighbors = np.hstack((range(0,a), range(a+1,b), range(b+1,n))).astype(np.int)
    a_links = np.abs(P[a,neighbors])
    b_links = np.abs(P[b,neighbors])
    
    plt.plot(a_links, b_links, 'ko', markersize=3)
    plt.xlabel('link strength from node %d' % (a+1))
    plt.ylabel('link strength from node %d' % (b+1))
    

def plot_links(a, b):
    """make the tripartite graph plot"""
    
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
    cmap = plt.get_cmap('cool')
    
    cy = np.flip(np.arange(q) - (q-1)/2, 0) # reversed: strongest link on top (largest y value)
    cx = np.zeros(cy.shape)
    
    # pull a gap so we can plot the a--b links
    cy[cy<0] -= 1
    cy[cy>0] += 1

    # links a to center
    for i in range(q):
        ratio = link_a_to_neigh[i]/cmax
        plt.plot([-2, 0], [0, cy[i]], '-', color=cmap(ratio), linewidth=ratio*8+1)
        
    # links b to center
    for i in range(q):
        ratio = link_b_to_neigh[i]/cmax
        plt.plot([2, 0], [0, cy[i]], '-', color=cmap(ratio), linewidth=ratio*8+1)
        
    # link a->b
    ratio = link_a_to_b / cmax    
    lw = ratio*8+1
    style = "simple,tail_width=%f,head_width=%f,head_length=%f" % (lw, lw*2, lw*3)
    path = mpath.Path([(-1.2,0.1), (0,1), (1.2,0.1)],
                      [mpath.Path.MOVETO,mpath.Path.CURVE3,mpath.Path.CURVE3])
    arrow = mpatch.FancyArrowPatch(path=path, arrowstyle=style, color=cmap(ratio), zorder=1000)    
    plt.gca().add_patch(arrow)    

    # link b->a
    ratio = link_b_to_a / cmax    
    lw = ratio*8+1
    style = "simple,tail_width=%f,head_width=%f,head_length=%f" % (lw, lw*2, lw*3)
    path = mpath.Path([(1.2,-0.1), (0,-1), (-1.2,-0.1)],
                      [mpath.Path.MOVETO,mpath.Path.CURVE3,mpath.Path.CURVE3])
    arrow = mpatch.FancyArrowPatch(path=path, arrowstyle=style, color=cmap(ratio), zorder=1000)
    plt.gca().add_patch(arrow)

    
    # center nodes
    plt.plot(cx, cy, 'o', **circ)
    for i in range(q):
        plt.annotate('%d'%(neigh[i]+1), xy=(0,cy[i]), **labels)
    
    # node a
    plt.plot([-2], [0], 'o', **circ)
    plt.annotate('%d'%(a+1), xy=(-2,0), **labels)
    
    # node b
    plt.plot([2], [0], 'o', **circ)
    plt.annotate('%d'%(b+1), xy=(2,0), **labels)
    
    # lines to show scale legend
    for ratio in [0, 0.5, 1-1e-9]:
        value = ratio * cmax
        plt.plot([0, 0], [0, 0], '-', color=cmap(ratio), linewidth=ratio*10+1, 
                 label='%2.1f' % value, solid_capstyle='projecting', dash_capstyle='projecting')
    
    # override solid capstyle in the legend lines
    leg = plt.legend()
    artists = leg.legendHandles
    for artist in artists:
        artist.set_solid_capstyle('projecting')
        artist.set_dash_capstyle('projecting')
        

# plot and save list of clusters
with open('cluster_choice_%s.dat' % sysname, 'w') as f:
    for i in range(count):
        plt.figure(1, figsize=(7,6))
        plt.clf()
        idx = idx_in[i] # select here which ordering to use |fname: in->"sim", eq->"eq"
        a, b = nodes[idx,:]
        f.write('%d,%d\n' % (a+1,b+1))
        
        print("nodes: %d, %d; similarity: %f, avg_del: %f" % (a+1, b+1, data[idx,3], data[idx,5]))
        
        plot_links(a, b)    
        plt.ylim(-q/2-0.8, q/2+0.8)
        plt.axis('off')
        
        #plot_similarity(a, b)
        
        plt.tight_layout()
        plt.savefig(os.path.join(result_folder, 'graph_%s_sim_%d_[%d,%d].png' % (sysname, i+1, a+1, b+1)))
