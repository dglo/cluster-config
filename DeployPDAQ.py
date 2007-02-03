#!/usr/bin/env python

import optparse
from ClusterConfig import *
from ParallelShell import *
from os import environ, getcwd
from os.path import abspath, isdir, join, split

def find_top():
    curDir = getcwd()
    [parentDir, baseName] = split(curDir)
    for dir in [curDir, parentDir]:
        if isdir(join(dir, 'config')) and \
                isdir(join(dir, 'cluster-config')) and \
                isdir(join(dir, 'dash')):
                    return dir

    raise Exception, 'Couldn''t find pDAQ trunk'

def main():
    "Main program"
    p = optparse.OptionParser()
    p.add_option("-c", "--config-name",  action="store", type="string", dest="configName")
    p.add_option("-p", "--parallel",     action="store_true",           dest="doParallel")
    p.add_option("-n", "--dry-run",      action="store_true",           dest="dryRun")
    p.set_defaults(configName = "sps-sim-config-reduced",
                   doParallel = False,
                   dryRun     = False)
    opt, args = p.parse_args()

    top = find_top()

    configDir = abspath(join(top, 'cluster-config', 'src', 'main', 'xml'))
    config = deployConfig(configDir, opt.configName)
    print "NODES:"
    for node in config.nodes:
        print "  %s(%s)" % (node.hostName, node.locName),
        for comp in node.comps:
            print "%s:%d " % (comp.compName, comp.compID),
        print

    m2  = join(environ["HOME"], '.m2')

    parallel = ParallelShell(opt.doParallel, opt.dryRun)

    print "COMMANDS:"
    for node in config.nodes:
        rsynccmd = "rsync -az %s %s:" % (top, node.hostName)
        print "  "+rsynccmd
        parallel.add(rsynccmd)
        rsynccmd = "rsync -az %s %s:" % (m2, node.hostName)
        print "  "+rsynccmd
        parallel.add(rsynccmd)

    parallel.start()
    parallel.wait()
    parallel.showAll()
    
if __name__ == "__main__": main()
