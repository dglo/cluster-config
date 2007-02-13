#!/usr/bin/env python

# DeployPDAQ.py
# Jacobsen Feb. 2007
#
# Deploy valid pDAQ cluster configurations to any cluster

import optparse
from ClusterConfig import *
from ParallelShell import *
from os import environ, getcwd, listdir
from os.path import abspath, isdir, join, split
from re import search

from locate_pdaq import find_pdaq_trunk

def main():
    "Main program"
    usage = "%prog [options]"
    p = optparse.OptionParser()
    p.add_option("-c", "--config-name",  action="store", type="string", dest="configName",
                 help="REQUIRED: Configuration name")
    p.add_option("-l", "--list-configs", action="store_true",           dest="doList",
                 help="List available configs")
    p.add_option("-n", "--dry-run",      action="store_true",           dest="dryRun",
                 help="Don't actually do anything - just print steps")
    p.add_option("-p", "--parallel",     action="store_true",           dest="doParallel",
                 help="Run rsyncs in parallel")
    p.set_defaults(configName = None,
                   doParallel = False,
                   dryRun     = False)
    opt, args = p.parse_args()

    top = find_pdaq_trunk()

    configXMLDir = abspath(join(top, 'cluster-config', 'src', 'main', 'xml'))

    if opt.doList: showConfigs(configXMLDir); raise SystemExit
    
    if opt.configName == None: p.print_help(); raise SystemExit    

    config = deployConfig(configXMLDir, opt.configName)
    print "NODES:"
    for node in config.nodes:
        print "  %s(%s)" % (node.hostName, node.locName),
        for comp in node.comps:
            print "%s:%d" % (comp.compName, comp.compID),
            if comp.compName == "StringHub":
                if comp.isIcetop: print "[icetop]",
                else: print "[in-ice]",
            print " ",
        print

    # Remember this config
    hereFile = abspath(join(top, 'cluster-config', '.config'))
    if not opt.dryRun:
        fd = open(hereFile, 'w')
        print >>fd, opt.configName
        fd.close()

    m2  = join(environ["HOME"], '.m2')

    parallel = ParallelShell(opt.doParallel, opt.dryRun)

    done = False
    for node in config.nodes:

        # Ignore localhost - already "deployed"
        if node.hostName == "localhost": continue
        if not done: print "COMMANDS:"; done = True
        
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
