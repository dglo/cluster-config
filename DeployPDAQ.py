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

def getUniqueHostNames(config):
    # There's probably a much better way to do this
    retHash = {}
    for node in config.nodes:
        retHash[str(node.hostName)] = 1
    return retHash.keys()

def main():
    "Main program"
    usage = "%prog [options]"
    version = "%prog:\n  $Id: DeployPDAQ.py 2103 2007-10-11 17:51:34Z dglo $\n  $URL: http://code.icecube.wisc.edu/daq/projects/cluster-config/trunk/DeployPDAQ.py $"
    p = optparse.OptionParser(usage=usage, version=version)
    p.add_option("-c", "--config-name",  action="store", type="string", dest="configName",
                 help="REQUIRED: Configuration name")
    p.add_option("", "--delete",       action="store_true",           dest="delete",
                 help="Run rsync's with --delete")
    p.add_option("-l", "--list-configs", action="store_true",           dest="doList",
                 help="List available configs")
    p.add_option("-n", "--dry-run",      action="store_true",           dest="dryRun",
                 help="Don't run rsyncs, just print as they would be run (disables quiet)")
    p.add_option("", "--deep-dry-run",   action="store_true",           dest="deepDryRun",
                 help="Run rsync's with --dry-run (implies verbose and serial)")
    p.add_option("-p", "--parallel",     action="store_true",           dest="doParallel",
                 help="Run rsyncs in parallel (default)")
    p.add_option("-q", "--quiet",        action="store_true",           dest="quiet",
                 help="Run quietly")
    p.add_option("-s", "--serial",       action="store_true",           dest="doSerial",
                 help="Run rsyncs serially (overrides parallel)")
    p.add_option("-v", "--verbose",      action="store_true",           dest="verbose",
                 help="Be chatty")
    p.add_option("", "--undeploy",       action="store_true",           dest="undeploy",
                 help="Remove entire ~pdaq/.m2 and ~pdaq/pDAQ_current dirs on remote nodes - use with caution!")
    p.set_defaults(configName = None,
                   doParallel = True,
                   doSerial   = False,
                   verbose    = False,
                   quiet      = False,
                   delete     = False,
                   dryRun     = False,
                   undeploy   = False,
                   deepDryRun = False)
    opt, args = p.parse_args()

    ## Work through options implications ##
    # A deep-dry-run implies verbose and serial
    if opt.deepDryRun:
        opt.doSerial = True
        opt.verbose = True
        opt.quiet = False

    # Serial overrides parallel
    if opt.doSerial: opt.doParallel = False

    # dry-run implies we want to see what is happening
    if opt.dryRun:   opt.quiet = False

    # Map quiet/verbose to a 3-value tracelevel
    traceLevel = 0
    if opt.quiet:                 traceLevel = -1
    if opt.verbose:               traceLevel = 1
    if opt.quiet and opt.verbose: traceLevel = 0

    rsyncCmdStub = "nice rsync -azLC%s%s" % (opt.delete and ' --delete' or '',
                                       opt.deepDryRun and ' --dry-run' or '')

    targetDir        = abspath(join(metaDir, 'target'))
    clusterConfigDir = abspath(join(metaDir, 'cluster-config'))
    runConfigDir     = abspath(join(metaDir, 'config'))
    dashDir          = abspath(join(metaDir, 'dash'))

    try:
        config = ClusterConfig(metaDir, opt.configName, opt.doList, False)
    except ConfigNotSpecifiedException:
        print >>sys.stderr, 'No configuration specified'
        p.print_help()
        raise SystemExit

    if traceLevel >= 0:
        print "CONFIG: %s" % config.configName
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

    if not opt.dryRun:
        config.writeCacheFile()

    m2  = join(environ["HOME"], '.m2')

    parallel = ParallelShell(parallel=opt.doParallel, dryRun=opt.dryRun,
                             verbose=(traceLevel > 0 or opt.dryRun),
                             trace=(traceLevel > 0))

    done = False

    rsyncNodes = getUniqueHostNames(config)

    for nodeName in rsyncNodes:

        # Check if targetDir (the result of a build) is present
        if not isdir(targetDir):
            print >>sys.stderr, "ERROR: Target dir (%s) does not exist." % (targetDir)
            print >>sys.stderr, "ERROR: Did you run 'mvn clean install assembly:assembly'?"
            raise SystemExit
        
        # Ignore localhost - already "deployed"
        if nodeName == "localhost": continue
        if not done and traceLevel >= 0:
            print "COMMANDS:"
            done = True

        if opt.undeploy:
            cmd = 'ssh %s "\\rm -rf %s %s"' % (nodeName, m2, metaDir)
            parallel.add(cmd)
            continue

        rsynccmd = "%s %s %s:%s" % (rsyncCmdStub, targetDir, nodeName, metaDir)
        if traceLevel >= 0: print "  "+rsynccmd
        parallel.add(rsynccmd)

        rsynccmd = "%s %s %s:%s" % (rsyncCmdStub, clusterConfigDir, nodeName, metaDir)
        if traceLevel >= 0: print "  "+rsynccmd
        parallel.add(rsynccmd)

        rsynccmd = "%s %s %s:%s" % (rsyncCmdStub, runConfigDir, nodeName, metaDir)
        if traceLevel >= 0: print "  "+rsynccmd
        parallel.add(rsynccmd)

        rsynccmd = "%s %s %s:%s" % (rsyncCmdStub, dashDir, nodeName, metaDir)
        if traceLevel >= 0: print "  "+rsynccmd
        parallel.add(rsynccmd)

    parallel.start()
    if opt.doParallel:
        parallel.wait()

if __name__ == "__main__": main()
