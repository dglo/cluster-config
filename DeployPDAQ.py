#!/usr/bin/env python

# DeployPDAQ.py
# Jacobsen Feb. 2007
#
# Deploy valid pDAQ cluster configurations to any cluster

import optparse
from ClusterConfig import *
from ParallelShell import *
from os import environ, getcwd, listdir, system
from os.path import abspath, isdir, join, split
from re import search

# Find install location via $PDAQ_HOME, otherwise use locate_pdaq.py
if environ.has_key("PDAQ_HOME"):
    metaDir = environ["PDAQ_HOME"]
else:
    from locate_pdaq import find_pdaq_trunk
    metaDir = find_pdaq_trunk()

def getDeployedClusterConfig(clusterFile):
        "Get cluster configuration name persisted in clusterFile"
        # FIXME - this is duplicated in DAQLaunch.py
        try:
            f = open(clusterFile, "r")
            ret = f.readline()
            f.close()
            return ret.rstrip('\r\n')
        except:
            return None
                                                
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
    p.add_option("-q", "--quiet",        action="store_true",           dest="quiet",
                 help="Run quietly")
    p.add_option("-s", "--serial",       action="store_true",           dest="doSerial",
                 help="Run rsyncs serially")
    p.add_option("-v", "--verbose",      action="store_true",           dest="verbose",
                 help="Be chatty")
    p.set_defaults(configName = None,
                   doParallel = True,
                   doSerial   = False,
                   verbose    = True,
                   quiet      = False,
                   dryRun     = False)
    opt, args = p.parse_args()

    if opt.doSerial: opt.doParallel = False
    if opt.quiet:    opt.verbose    = False
    if opt.dryRun:   opt.verbose    = True
    
    # Find install location via $PDAQ_HOME, otherwise use locate_pdaq.py
    if environ.has_key("PDAQ_HOME"):
        top = environ["PDAQ_HOME"]
    else:
        from locate_pdaq import find_pdaq_trunk
        top = find_pdaq_trunk()

    configXMLDir = abspath(join(top, 'cluster-config', 'src', 'main', 'xml'))

    if opt.configName == None:
        opt.configName = getDeployedClusterConfig(join(metaDir, 'cluster-config', '.config'))

    if opt.doList: showConfigs(configXMLDir, opt.configName); raise SystemExit
    
    if opt.configName == None: p.print_help(); raise SystemExit    

    config = deployConfig(configXMLDir, opt.configName)

    if opt.verbose:
        print "CONFIG: %s" % opt.configName
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

    if opt.doParallel:
        parallel = ParallelShell(opt.doParallel, opt.dryRun)

    done = False
    for node in config.nodes:

        # Ignore localhost - already "deployed"
        if node.hostName == "localhost": continue
        if not done and opt.verbose:
            print "COMMANDS:"
            done = True
        
        rsynccmd = "rsync -az %s %s:" % (top, node.hostName)
        if opt.verbose: print "  "+rsynccmd
        if opt.doParallel:
            parallel.add(rsynccmd)
        else:
            if not opt.dryRun: system(rsynccmd)
            
        rsynccmd = "rsync -az %s %s:" % (m2, node.hostName)
        if opt.verbose: print "  "+rsynccmd
        if opt.doParallel:
            parallel.add(rsynccmd)
        else:
            if not opt.dryRun: system(rsynccmd)

    if opt.doParallel:
        parallel.start()
        parallel.wait()
        parallel.showAll()
    
if __name__ == "__main__": main()
