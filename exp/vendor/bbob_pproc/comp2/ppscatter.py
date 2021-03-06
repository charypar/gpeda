#! /usr/bin/env python
# -*- coding: utf-8 -*-

"""Scatter Plot.

For two algorithms, this generates the scatter plot of log(ERT1(df)) vs.
log(ERT0(df)), where ERT0(df) is the ERT of the reference algorithm,
ERT1(df) is the ERT of the algorithm of concern, both for target
precision df.

Different symbols are used for different dimension (see
:py:data:`markers` for the order of the markers, :py:data:`colors` for
the corresponding colors).
The target precisions considered are in :py:data:`targets`: there are
:py:data:`nbmarkers` targets regularly distributed on the log-scale in
10**[-8:1].

Boxes correspond to the maximum numbers of function evaluations for
each algorithm in each dimension.

"""

"""For two algorithms, ERTs(given target function value) can also be
plotted in a scatter plot (log(ERT0) vs. log(ERT1)), which results in a
very attractive presentation, see the slides of Frank Hutter at
http://www.msr-inria.inria.fr/events-news/first-search-biology-day. The
advantage is that the absolute values do not get lost. The disadvantage
(in our case minor) is that there is an upper limit of data that can be
displayed.
"""

import os
import numpy
from pdb import set_trace
from matplotlib import pyplot as plt
try:
    from matplotlib.transforms import blended_transform_factory as blend
except ImportError:
    # compatibility matplotlib 0.8
    from matplotlib.transforms import blend_xy_sep_transform as blend
from bbob_pproc import readalign
from bbob_pproc.ppfig import saveFigure

dimensions = (2, 3, 5, 10, 20, 40)
figure_legend = (r"Expected running time (\ERT\ in $\log_{10}$ of number of function evaluations) " + 
 r" of \algorithmA\ ($x$-axis) versus \algorithmB\ ($y$-axis) for 46 target values $\Df \in [10^{-8}, 10]$ in each dimension " +
 r" on functions #1. Markers on the upper or right edge indicate that the target " +
 r" value was never reached. Markers represent dimension: " + 
 r" 2:{\color{cyan}+}, " +
 r" 3:{\color{green!45!black}$\triangledown$}, " +
 r" 5:{\color{blue}$\star$},  " +
 r"10:$\circ$,  " +
 r"20:{\color{red}$\Box$},  " +
 r"40:{\color{magenta}$\Diamond$}. ")
 
colors = ('c', 'g', 'b', 'k', 'r', 'm', 'k', 'y', 'k', 'c', 'r', 'm')
markers = ('+', 'v', '*', 'o', 's', 'D', 'x')
offset = 0. #0.02
markersize = 10.  # modified in config.py
# offset provides a way to move away the box boundaries to display the outer markers fully 
nbmarkers = 46
_inc = 45./(nbmarkers-1)
targets = numpy.power(10, numpy.arange(-40, 5 + _inc, _inc)/5.)

#Get benchmark short infos.
funInfos = {}
isBenchmarkinfosFound = True
infofile = os.path.join(os.path.split(__file__)[0], '..', 'benchmarkshortinfos.txt')

try:
    f = open(infofile,'r')
    for line in f:
        if len(line) == 0 or line.startswith('%') or line.isspace() :
            continue
        funcId, funcInfo = line[0:-1].split(None,1)
        funInfos[int(funcId)] = funcId + ' ' + funcInfo
    f.close()
except IOError, (errno, strerror):
    print "I/O error(%s): %s" % (errno, strerror)
    isBenchmarkinfosFound = False
    print 'Could not find file', infofile, \
          'Titles in figures will not be displayed.'

def beautify():
    a = plt.gca()
    a.set_xscale('log')
    a.set_yscale('log')
    #a.set_xlabel('ERT0')
    #a.set_ylabel('ERT1')
    xmin, xmax = plt.xlim()
    ymin, ymax = plt.ylim()
    minbnd = min(xmin, ymin)
    maxbnd = max(xmax, ymax)
    maxbnd = maxbnd ** (1 + 11.*offset/(numpy.log10(float(maxbnd)/minbnd)))
    plt.plot([minbnd, maxbnd], [minbnd, maxbnd], ls='-', color='k')
    plt.plot([10*minbnd, 10*maxbnd], [minbnd, maxbnd], ls=':', color='k')
    plt.plot([100*minbnd, 100*maxbnd], [minbnd, maxbnd], ls=':', color='k')
    plt.plot([minbnd, maxbnd], [10*minbnd, 10*maxbnd], ls=':', color='k')
    plt.plot([minbnd, maxbnd], [100*minbnd, 100*maxbnd], ls=':', color='k')

    plt.xlim(minbnd, maxbnd)
    plt.ylim(minbnd, maxbnd)
    #a.set_aspect(1./a.get_data_ratio())
    a.set_aspect('equal')
    plt.grid(True)
    tmp = a.get_yticks()
    tmp2 = []
    for i in tmp:
        tmp2.append('%d' % round(numpy.log10(i)))
    a.set_yticklabels(tmp2)
    a.set_xticklabels(tmp2)
    #for line in a.get_xticklines():# + a.get_yticklines():
    #    plt.setp(line, color='b', marker='o', markersize=10)
    #set_trace()

def main(dsList0, dsList1, outputdir, verbose=True):
    """Generate a scatter plot figure."""

    #plt.rc("axes", labelsize=24, titlesize=24)
    #plt.rc("xtick", labelsize=20)
    #plt.rc("ytick", labelsize=20)
    #plt.rc("font", size=20)
    #plt.rc("legend", fontsize=20)

    dictFunc0 = dsList0.dictByFunc()
    dictFunc1 = dsList1.dictByFunc()
    funcs = set(dictFunc0.keys()) & set(dictFunc1.keys())

    for f in funcs:
        dictDim0 = dictFunc0[f].dictByDim()
        dictDim1 = dictFunc1[f].dictByDim()
        dims = set(dictDim0.keys()) & set(dictDim1.keys())
        #set_trace()

        for i, d in enumerate(dimensions):
            try:
                entry0 = dictDim0[d][0] # should be only one element
                entry1 = dictDim1[d][0] # should be only one element
            except (IndexError, KeyError):
                continue

            xdata = numpy.array(entry0.detERT(targets))
            ydata = numpy.array(entry1.detERT(targets))

            tmp = (numpy.isinf(xdata)==False) * (numpy.isinf(ydata)==False)
            if tmp.any():
                try:
                    plt.plot(xdata[tmp], ydata[tmp], ls='', markersize=markersize,
                             marker=markers[i], markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3)
                except KeyError:
                    plt.plot(xdata[tmp], ydata[tmp], ls='', markersize=markersize,
                             marker='x', markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3)
                #try:
                #    plt.scatter(xdata[tmp], ydata[tmp], s=10, marker=markers[i],
                #            facecolor='None', edgecolor=colors[i], linewidth=3)
                #except ValueError:
                #    set_trace()

            #ax = plt.gca()
            ax = plt.axes()

            tmp = numpy.isinf(xdata) * (numpy.isinf(ydata)==False)
            if tmp.any():
                trans = blend(ax.transAxes, ax.transData)
                #plt.scatter([1.]*numpy.sum(tmp), ydata[tmp], s=10, marker=markers[i],
                #            facecolor='None', edgecolor=colors[i], linewidth=3,
                #            transform=trans)
                try:
                    plt.plot([1.]*numpy.sum(tmp), ydata[tmp], markersize=markersize, ls='',
                             marker=markers[i], markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3,
                             transform=trans, clip_on=False)
                except KeyError:
                    plt.plot([1.]*numpy.sum(tmp), ydata[tmp], markersize=markersize, ls='',
                             marker='x', markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3,
                             transform=trans, clip_on=False)
                #set_trace()

            tmp = (numpy.isinf(xdata)==False) * numpy.isinf(ydata)
            if tmp.any():
                trans = blend(ax.transData, ax.transAxes)
                #    plt.scatter(xdata[tmp], [1.-offset]*numpy.sum(tmp), s=10, marker=markers[i],
                #                facecolor='None', edgecolor=colors[i], linewidth=3,
                #                transform=trans)
                try:
                    plt.plot(xdata[tmp], [1.-offset]*numpy.sum(tmp), markersize=markersize, ls='',
                             marker=markers[i], markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3,
                             transform=trans, clip_on=False)
                except KeyError:
                    plt.plot(xdata[tmp], [1.-offset]*numpy.sum(tmp), markersize=markersize, ls='',
                             marker='x', markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3,
                             transform=trans, clip_on=False)

            tmp = numpy.isinf(xdata) * numpy.isinf(ydata)
            if tmp.any():
                #    plt.scatter(xdata[tmp], [1.-offset]*numpy.sum(tmp), s=10, marker=markers[i],
                #                facecolor='None', edgecolor=colors[i], linewidth=3,
                #                transform=trans)
                try:
                    plt.plot([1.-offset]*numpy.sum(tmp), [1.-offset]*numpy.sum(tmp), markersize=markersize, ls='',
                             marker=markers[i], markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3,
                             transform=ax.transAxes, clip_on=False)
                except KeyError:
                    plt.plot([1.-offset]*numpy.sum(tmp), [1.-offset]*numpy.sum(tmp), markersize=markersize, ls='',
                             marker='x', markerfacecolor='None',
                             markeredgecolor=colors[i], markeredgewidth=3,
                             transform=ax.transAxes, clip_on=False)

                #set_trace()

        beautify()

        for i, d in enumerate(dimensions):
            try:
                entry0 = dictDim0[d][0] # should be only one element
                entry1 = dictDim1[d][0] # should be only one element
            except (IndexError, KeyError):
                continue

            minbnd, maxbnd = plt.xlim()
            plt.plot((entry0.mMaxEvals(), entry0.mMaxEvals()),
                     # (minbnd, entry1.mMaxEvals()), ls='-', color=colors[i],
                     (max([minbnd, entry1.mMaxEvals()/10.]), entry1.mMaxEvals()), ls='-', color=colors[i],
                     zorder=-1)
            plt.plot(# (minbnd, entry0.mMaxEvals()),
                     (max([minbnd, entry0.mMaxEvals()/10.]), entry0.mMaxEvals()),
                     (entry1.mMaxEvals(), entry1.mMaxEvals()), ls='-',
                     color=colors[i], zorder=-1)
            plt.xlim(minbnd, maxbnd)
            plt.ylim(minbnd, maxbnd)
            #Set the boundaries again: they changed due to new plots.

            #plt.axvline(entry0.mMaxEvals(), ls='--', color=colors[i])
            #plt.axhline(entry1.mMaxEvals(), ls='--', color=colors[i])

        if isBenchmarkinfosFound:
            try:
                plt.ylabel(funInfos[f])
            except IndexError:
                pass

        filename = os.path.join(outputdir, 'ppscatter_f%03d' % f)
        saveFigure(filename, verbose=verbose)
        plt.close()

    #plt.rcdefaults()
