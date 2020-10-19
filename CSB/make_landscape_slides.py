# version 2: interpolation plots added

import numpy as np
import os

sysnames = ['10gen', '48gen', 'uk', 'germany']
w = open('Landscape_choices.tex', 'w')
w.write('\\documentclass{beamer}\n')
w.write('\\usepackage{beamerposter}\n')

w.write('\\setlength{\\paperwidth}{11in}\n')
w.write('\\setlength{\\paperheight}{8.5in}\n')
w.write('\\setlength{\\textwidth}{10in}\n')
w.write('\\setlength{\\textheight}{8in} \n')

w.write('\\usepackage{graphicx}\n')

w.write('\\begin{document}\n')

for sysname in sysnames:

    # clusters    
    cluster_file = 'cluster_choice_%s.dat' % sysname
    clusters = np.loadtxt(cluster_file, delimiter=',').astype(np.int) - 1 # 0-based

    if clusters.ndim == 1:
        clusters = clusters[None,:]
        
    # similarity data
    fname = 'similarity_%s.csv' % sysname
    with open(fname, 'r') as f:
        f.readline() # header
        raw = [ [float(item) for item in line.split(',')] for line in f]
        
    data = np.array(raw)    
    nodes = data[:,[0,1]].astype(np.int) - 1 # 0-based indexing
        
        
    for j in range(clusters.shape[0]):
    
        # get nodes
        a, b = clusters[j,:]
        
        # similarity data
        where = np.nonzero(np.logical_and(nodes[:,0]==a, nodes[:,1]==b))[0]
        similarity = data[where, 3] # inlink similarity
        avg_del = data[where, 5] # distance to equitable
    
        # load landscape args
        fname = 'Results_%s/landscape_args_%s_%d_%d.dat' % (sysname, sysname, a+1, b+1)
        with open(fname, 'r') as f:
            bmin_a, bmax_a, bmin_b, bmax_b = [ float(item) for item in f.readline().split(',')]
            bopt_a, bopt_b, lmax_opt = [ float(item) for item in f.readline().split(',')]
            btilde, lmax_tilde = [ float(item) for item in f.readline().split(',')]
            
        # grab the landscape plot
        plotfile = 'Results_%s/landscape_zoom_%s_%d_%d.png' % (sysname, sysname, a+1, b+1)
        if not os.path.exists(plotfile):
            continue
        
        # grab the interpolation plot
        interpfile = 'Results_%s/interp_plot_%s_%d_%d.png' % (sysname, sysname, a+1, b+1)
        if not os.path.exists(interpfile):
            interpfile = None
        
        # find the simfile (because stupid number in fname)       
        for i in range(1,30):
            simfile = 'Results_%s/graph_%s_sim_%d_[%d,%d].png' % (sysname, sysname, i, a+1, b+1)
            if os.path.exists(simfile):
                break
            simfile = None
        
        if simfile is None:
            continue
        
        # make page
        w.write('\\begin{frame}\n')
        w.write('\\frametitle{{\\bf %s} - cluster (%d, %d)} \n' % (sysname, a+1, b+1))
        
        w.write('\\begin{columns}[T]\n')
        w.write('\\begin{column}{0.48\\textwidth}\n')
        
        w.write('\\includegraphics[width=4in]{%s}\n' % simfile)
        if interpfile is not None:
            w.write('\\\\ \n')
            w.write('\\includegraphics[width=4in]{%s} \\\\ \n' % interpfile)
        else:
            w.write('\n')
            
        w.write('\\end{column}\n')
        w.write('\\begin{column}{0.48\\textwidth}\n')
        
        w.write('\\includegraphics[width=5in]{%s} \\\\ \n' % plotfile)
        #w.write('\\\\ \n')        
        
        w.write('\\texttt{Lmax\\_tilde~= %f} \\\\ \n' % lmax_tilde)
        w.write('\\texttt{Lmax\\_opt~~~= %f} \\\\ \n' % lmax_opt)        
        w.write('\\texttt{similarity~= %f} \\\\ \n' % similarity)
        w.write('\\texttt{avg\\_del~~~~= %f} \n' % avg_del)
        
        w.write('\\end{column}\n')
        w.write('\\end{columns}\n')
        
        w.write('\\end{frame}\n')
        
w.write('\\end{document}\n')
w.close()


#\begin{document}
#\begin{frame}
#\frametitle{{\bf 10gen}, cluster (6, 7)}
#\begin{columns}
#\begin{column}{0.48\textwidth}
#\includegraphics[width=4in]{Results_10gen/graph_10gen_sim_2_[6,7].png} \\
#\includegraphics[width=4in]{Results_10gen/interp_plot_10gen_6_7.png} 
#\end{column}
#\begin{column}{0.48\textwidth}
#\includegraphics[width=5in]{Results_10gen/landscape_zoom_10gen_6_7.png}\\
#\texttt{Lmax\_tilde~= -4.044656} \\ 
#\texttt{Lmax\_opt~~~= -4.692162} \\ 
#\texttt{similarity~= 0.231043} \\ 
#\texttt{avg\_del~~~~= 8.213610}
#\end{column}
#\end{columns} 
#\end{frame}
#\end{document}
