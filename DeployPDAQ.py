#!/usr/bin/env python

import optparse
from ClusterConfig import *
from ParallelShell import *
from os import environ, getcwd, listdir
from os.path import abspath, isdir, join, split
from re import search

def find_top():
    curDir = getcwd()
    [parentDir, baseName] = split(curDir)
    for dir in [curDir, parentDir]:
        if isdir(join(dir, 'config')) and \
                isdir(join(dir, 'cluster-config')) and \
                isdir(join(dir, 'dash')):
                    return dir

    raise Exception, 'Couldn''t find pDAQ trunk'

def showConfigs(configDir):
    l = listdir(configDir)
    cfgs = []
    for f in l:
        match = search(r'^(.+?)\.xml$', f)
        if not match: continue
        cfgs.append(match.group(1))

    ok = []
    remarks = {}
    for cname in cfgs:
        try:
            config = deployConfig(configDir, cname)
            ok.append(cname)
            remarks[cname] = config.remarks
        except Exception, e: pass # print cname+ `e`

    ok.sort()
    for cname in ok:
        print "%40s === " % cname,
        if remarks[cname]: print remarks[cname]
        else: print
    
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

    top = find_top()

    configDir = abspath(join(top, 'cluster-config', 'src', 'main', 'xml'))

    if opt.doList: showConfigs(configDir); raise SystemExit
    
    if opt.configName == None: p.print_help(); raise SystemExit    

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
