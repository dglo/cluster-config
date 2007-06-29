#!/usr/bin/env python

#
# ClusterConfig.py
#
# J. Jacobsen, NPX Designs, Inc. for UW-IceCube
#
# February, 2007

from os import listdir
from re import search
from os.path import exists, join
from xml.dom import minidom

class ConfigNotFoundException(Exception): pass
class MalformedDeployConfigException(Exception): pass

GLOBAL_DEFAULT_LOG_LEVEL = "INFO"

def getDeployedClusterConfig(clusterFile):
    "Get cluster configuration name persisted in clusterFile"
    try:
        f = open(clusterFile, "r")
        ret = f.readline()
        f.close()
        return ret.rstrip('\r\n')
    except:
        return None
    
def xmlOf(name):
    if not search(r'^(.+?)\.xml$', name): return name+".xml"
    return name

def showConfigs(configDir, configToUse=None):
    "Utility to show all available cluster configurations in configDir"
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
        sep = "==="
        if configToUse and cname == configToUse:
            sep = "<=>"
        print "%40s %3s " % (cname, sep),
        if remarks[cname]: print remarks[cname]
        else: print
    

class deployComponent:
    "Record-keeping class for deployed components"
    def __init__(self, compName, compID, logLevel, iceTop = False):
        self.compName = compName;
        self.compID   = compID;
        self.logLevel = logLevel
        self.isIcetop = iceTop
        
class deployNode:
    "Record-keeping class for host targets"
    def __init__(self, locName, hostName):
        self.locName  = locName;
        self.hostName = hostName;
        self.comps    = []
        
    def addComp(self, comp): self.comps.append(comp)

def getElementSingleTagName(root, name):
    "Fetch a single element tag name of form <tagName>yowsa!</tagName>"
    elems = root.getElementsByTagName(name)
    if len(elems) != 1:
        raise MalformedDeployConfigException("Expected exactly one %s" % name)
    if len(elems[0].childNodes) != 1:
        raise MalformedDeployConfigException("Expected exactly one child node of %s" %name)
    return elems[0].childNodes[0].data

class deployConfig:
    "Class for parsing and storing pDAQ cluster configurations stored in XML files"
    def __init__(self, configDir, configName):
        self.nodes = []
        
        self.configFile = xmlOf(join(configDir,configName))
        if not exists(self.configFile): raise ConfigNotFoundException(self.configFile)
        parsed = minidom.parse(self.configFile)
        icecube = parsed.getElementsByTagName("icecube")
        if len(icecube) != 1: raise MalformedDeployConfigException(self.configFile)

        # Get "remarks" string if available
        try:
            self.remarks = icecube[0].attributes["remarks"].value
        except Exception, e: self.remarks = None
        
        cluster = icecube[0].getElementsByTagName("cluster")
        if len(cluster) != 1: raise MalformedDeployConfigException(self.configFile)
        self.clusterName = cluster[0].attributes[ "name" ].value

        # Get location of SPADE output
        self.logDirForSpade = getElementSingleTagName(cluster[0], "logDirForSpade")

        # Get location of SPADE/logs copies
        try:
            self.logDirCopies = getElementSingleTagName(cluster[0], "logDirCopies")
        except:
            self.logDirCopies = None
            
        # Get default log level
        try:
            self.defaultLogLevel = getElementSingleTagName(cluster[0], "defaultLogLevel")
        except:
            self.defaultLogLevel = GLOBAL_DEFAULT_LOG_LEVEL
        
        locations = cluster[0].getElementsByTagName("location")
        for nodeXML in locations:
            name = nodeXML.attributes["name"].value
            # Get address
            address = nodeXML.getElementsByTagName("address")
            hostname = getElementSingleTagName(address[0], "host")

            thisNode = deployNode(name, hostname)
            self.nodes.append(thisNode)

            # Get modules: name and ID
            components = []
            modules = nodeXML.getElementsByTagName("module")
            for compXML in modules:
                compName = getElementSingleTagName(compXML, "name")
                compID   = int(getElementSingleTagName(compXML, "id"))
                try:
                    logLevel = getElementSingleTagName(compXML, "logLevel")
                except:
                    logLevel = self.defaultLogLevel
                iceTop = False
                try:
                    itElems = compXML.getElementsByTagName("isIcetop")
                    if len(itElems) > 0: iceTop = True
                except: pass
                thisNode.addComp(deployComponent(compName, compID, logLevel, iceTop))

    def getHubNodes(self):
        hublist = []
        for node in self.nodes:
            for comp in node.comps:
                if comp.compName == "StringHub":
                    try:
                        hublist.index(node.hostName)
                    except ValueError:
                        hublist.append(node.hostName)
        return hublist
