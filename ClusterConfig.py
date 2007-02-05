#!/usr/bin/env python

from os import listdir
from re import search
from os.path import exists
from xml.dom import minidom

class ConfigNotFoundException(Exception): pass
class MalformedDeployConfigException(Exception): pass

GLOBAL_DEFAULT_LOG_LEVEL = "INFO"

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
    

class deployComponent:
    def __init__(self, compName, compID, logLevel):
        self.compName = compName; self.compID = compID; self.logLevel = logLevel

    def compName(self): return self.compName
    def compID(self):   return self.compID
    def logLevel(self): return self.logLevel

class deployNode:
    def __init__(self, locName, hostName): self.locName = locName; self.hostName = hostName; self.comps = []
    def addComp(self, comp): self.comps.append(comp)

class deployConfig:
    def __init__(self, configDir, configName):
        self.nodes = []
        
        self.configFile = configDir + "/" + configName + ".xml"
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
                thisNode.addComp(deployComponent(compName, compID, logLevel))

def getElementSingleTagName(root, name):
    elems = root.getElementsByTagName(name)
    if len(elems) != 1: raise MalformedDeployConfigException("Expected exactly one %s" % name)
    if len(elems[0].childNodes) != 1:
        MalformedDeployConfigException("Expected exactly one child node of %s" %name)
    return elems[0].childNodes[0].data
