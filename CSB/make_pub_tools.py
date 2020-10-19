
import numpy as np
from scipy.linalg import eigvals


panel_label_args = dict(fontweight='bold', fontsize=11)
X = np.ones((4,4)) * (-0.3)
Y = np.ones((4,4)) * 1.03

Y[0,:] = 1.08

X[2,:] = -0.10
Y[2,:] = 0.92

Y[3,:] = 1.03

def add_panel_label(ax, label, row, col):
    ax.text(X[row,col], Y[row,col], label, transform=ax.transAxes, **panel_label_args)
    
def get_lmax(J):
    """get the max of the real part of eigenvalues, excluding zero"""
    e = eigvals(J, check_finite=False)
    i = np.argmin(np.abs(e))
    e[i] = np.nan
    return np.nanmax(np.real(e))
