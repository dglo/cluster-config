#!/usr/bin/env python

from os import listdir
from re import search
from os.path import exists
from xml.dom import minidom

class ConfigNotFoundException(Exception): pass
class MalformedDeployConfigException(Exception): pass

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
    def __init__(self, compName, compID): self.compName = compName; self.compID = compID
    def compName(self): return self.compName
    def compID(self):   return self.compID
    
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
        logDirForSpade = cluster[0].getElementsByTagName("logDirForSpade")
        if len(logDirForSpade) != 1: raise MalformedDeployConfigException(self.configFile+" (logDirForSpade)")
        self.logDirForSpade = logDirForSpade[0].childNodes[0].data
        
        locations = cluster[0].getElementsByTagName("location")
        for nodeXML in locations:
            
            name = nodeXML.attributes["name"].value
            # Get address
            address = nodeXML.getElementsByTagName("address")
            if len(address) != 1: raise MalformedDeployConfigException(self.configFile)
            hostXML = address[0].getElementsByTagName("host")
            if len(hostXML) != 1: raise MalformedDeployConfigException(self.configFile)
            if len(hostXML[0].childNodes) != 1: raise MalformedDeployConfigException(self.configFile)
            hostname = hostXML[0].childNodes[0].data

            thisNode = deployNode(name, hostname)
            self.nodes.append(thisNode)

            # Get modules: name and ID
            components = []
            modules = nodeXML.getElementsByTagName("module")
            for compXML in modules:
                nameXML = compXML.getElementsByTagName("name")
                if len(nameXML) != 1: raise MalformedDeployConfigException(self.configFile)
                if len(nameXML[0].childNodes) != 1: raise MalformedDeployConfigException(self.configFile)
                compName = nameXML[0].childNodes[0].data
                idXML = compXML.getElementsByTagName("id")
                if len(idXML) != 1: raise MalformedDeployConfigException(self.configFile)
                if len(idXML[0].childNodes) != 1: raise MalformedDeployConfigException(self.configFile)
                compID = int(idXML[0].childNodes[0].data)
                
                thisNode.addComp(deployComponent(compName, compID))
