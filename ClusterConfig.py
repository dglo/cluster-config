#!/usr/bin/env python

from os.path import exists
from xml.dom import minidom

class ConfigNotFoundException(Exception): pass
class MalformedDeployConfigException(Exception): pass

class deployComponent:
    def __init__(self, compName, compID): self.compName = compName; self.compID = compID
    def compName(self): return self.compName
    def compID(self):   return self.compID
    
class deployNode:
    def __init__(self, locName, hostName): self.locName = locName; self.hostName = hostName; self.comps = []
    def addComp(self, comp): self.comps.append(comp)
    
class deployConfig:
    CONFIGDIR = "./src/main/xml"
    def __init__(self, configName):
        self.nodes = []
        
        self.configFile = deployConfig.CONFIGDIR + "/" + configName + ".xml"
        if not exists(self.configFile): raise ConfigNotFoundException(self.configFile)
        parsed = minidom.parse(self.configFile)
        icecube = parsed.getElementsByTagName("icecube")
        if len(icecube) != 1: raise MalformedDeployConfigException(self.configFile)
        cluster = icecube[0].getElementsByTagName("cluster")
        if len(cluster) != 1: raise MalformedDeployConfigException(self.configFile)
        self.clusterName = cluster[0].attributes[ "name" ].value

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
