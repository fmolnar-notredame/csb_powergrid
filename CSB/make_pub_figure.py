# Figure for publication
import numpy as np
import matplotlib.pyplot as plt

from make_pub_a import plot_over_landscape
from make_pub_b import plot_landscape
from make_pub_c import plot_similarity
from make_pub_d import plot_interp

class Object:
    pass

#%% Input data

# define systems
sysnames = ['10gen', '48gen', 'uk', 'germany']
clusterChoices = [[6,7], [37,38], [8,10], [59,65]]
sizes = [10, 48, 66, 69]

def load_data(sysIndex):

    result = Object()
    
    sysname = sysnames[sysIndex]
    result.sysname = sysname
    
    # chosen clusters to show
    a = clusterChoices[sysIndex][0]
    b = clusterChoices[sysIndex][1]
    result.a = a
    result.b = b
    
    # similarity data
    fname = 'similarity_%s.csv' % sysname
    with open(fname, 'r') as f:
        f.readline() # header
        raw = [ [float(item) for item in line.split(',')] for line in f]
        
    data = np.array(raw)    
    nodes = data[:,[0,1]].astype(np.int)
    where = np.nonzero(np.logical_and(nodes[:,0]==a, nodes[:,1]==b))[0]
    result.similarity = data[where, 3] # inlink similarity
    result.avg_del = data[where, 5] # distance to equitable
    
    # load landscape args
    fname = 'Results_%s/landscape_args_%s_%d_%d.dat' % (sysname, sysname, a, b)
    with open(fname, 'r') as f:
        result.bmin_a, result.bmax_a, result.bmin_b, result.bmax_b = [ float(item) for item in f.readline().split(',')]
        result.bopt_a, result.bopt_b, result.lmax_opt = [ float(item) for item in f.readline().split(',')]
        result.btilde, result.lmax_tilde = [ float(item) for item in f.readline().split(',')]
        
    # load landscape matrix
    fname = 'Results_%s/landscape_%s_%d_%d.dat' % (sysname, sysname, a, b)
    result.L = np.loadtxt(fname, delimiter=',')
    
    # load interpolation plot data    
    fname = 'Results_%s/interp2_lmax_%s_%d_%d.dat' % (sysname, sysname, a, b)
    try:
        with open(fname, 'r') as f:
            raw = [ [float(item) for item in line.split(',')] for line in f]        
        data = np.array(raw)    
        levels = data.shape[1] // 2 # zoom levels
        l = levels-1  # desired level to use
        
        # extract
        result.interp_lmax_opt = data[:,l]
        result.interp_lmax_tilde = data[:,levels+l]
        result.interp_x = np.linspace(0, 1, data.shape[0])
    except:
        
        # fake data
        result.interp_lmax_opt = -2 * np.ones(101)
        result.interp_lmax_tilde = -1 * np.ones(101)
        result.interp_x = np.linspace(0, 1, 101)
        
    # the interpolation zoomin optimal betas should override the landscape args,
    # because they are more accurate.
    # load interpolation betas
    if sysIndex < 3:
        fname = 'Results_%s/interp2_beta_opt_%s_%d_%d.dat' % (sysname, sysname, a, b)
        with open(fname, 'r') as f:
            raw = [ [float(item) for item in line.split(',')] for line in f]        
        data = np.array(raw)
        n = sizes[sysIndex]
        levels = data.shape[1] // sizes[sysIndex] # zoom levels
        l = levels-1  # desired level to use
        
        beta_opt = data[-1, l*n : l*n+n] # last interp step (PEQ)
        result.bopt_a = beta_opt[a-1]
        result.bopt_b = beta_opt[b-1]
    
    return result
    

#%% exec
plt.rcParams.update({'font.size': 10})

if plt.fignum_exists(1): # clear old fig if present
    plt.figure(1)
    plt.clf()
fig, ax = plt.subplots(4,4, figsize=(10,8), num=1)

# manually adjust panels

tilew = np.ones((4,4)) * 0.16 
tilew[2,:] = 0.20 # IF this goes +X

hgap = np.ones((4,4)) * 0.06
hgap[2,:] = 0.02 # THEN THIS GOES -X

hgap[:,2] += 0.01  # uh

tileh = np.array([0.1, 0.2, 0.23, 0.18])
vgap = np.array([0.05, 0.06, 0.01, 0.07, 0])

bottom_margin = (1.0 - np.sum(tileh) - np.sum(vgap[:3])) / 2

top = 1.0 - bottom_margin
for j in range(4):    
    left = (1.0 - np.sum(tilew[j,:]) - np.sum(hgap[j,:3])) * 0.4 # multiplier gives offset    
    for i in range(4):        
        ax[j,i].set_position([left, top-tileh[j], tilew[j,i], tileh[j]]) # left, bottom, width, height        
        left += tilew[j,i] + hgap[j,i]
    top -= tileh[j] + vgap[j]

## move the second row panels, add/split for cax | COLORBAR LOC
#cax = []
#for i in range(4):
#    rect = list(ax[1,i].get_position().bounds)
#    crect = [rect[0]+rect[2]*0.85, rect[1]+0.02, rect[2]*0.05, rect[3]-0.04]
#    cax.append(fig.add_axes(crect))
#    rect[2] *= 0.8
#    ax[1,i].set_position(rect)

# one colorbar only, no moving, just add to the right
rect = list(ax[1,3].get_position().bounds)
crect = [0.93, rect[1], rect[2]*0.06, rect[3]]
cax = fig.add_axes(crect)


# Similarity graphs: one colorbar only, no moving, just add to the right
rect = list(ax[2,3].get_position().bounds)
crect = [0.93, rect[1], rect[2]*0.06, rect[3]]
cax2 = fig.add_axes(crect)

labels = [ [ chr(ord('a')+j*4+i) + ')' for i in range(4)] for j in range(4)]
#labels = [['a)', 'b)', 'c)', 'd)'],['e)','f','g','h'],['i','j','k','l'],['m','n','o','p']]

# draw
for i in range(4):
    data = load_data(i)
    
    plot_over_landscape(fig, ax[0,i], data, i, label=labels[0][i])
    
    plot_landscape(fig, ax[1,i], data, i, cax=cax, label=labels[1][i])
    
    plot_similarity(fig, ax[2,i], data, i, cax=cax2, label=labels[2][i])
    
    plot_interp(fig, ax[3,i], data, i, label=labels[3][i])
    
    
# adjust the top row panel width to the active width of the second row
for i in range(4):
    rect = list(ax[1,i].get_position().bounds)
    pos = list(ax[0,i].get_position().bounds)
    pos[0] = rect[0]
    pos[2] = rect[2]
    ax[0,i].set_position(pos)

plt.savefig('landscape_c1.pdf')