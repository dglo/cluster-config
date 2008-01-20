#!/usr/bin/env python

# makeconfig
# John Jacobsen, NPX Designs, Inc., john@mail.npxdesigns.com
# Started: Wed Jan 16 23:54:00 2008

import optparse


def doconfig(string):

    configtxt = """
<icecube remarks="Standalone config + one remote stringHub">

  <cluster name="single-string-%s">

    <!-- Non-fully-qualified paths are relative to pdaq metaproject on expcont -->
    <logDirForSpade>/mnt/data/pdaq/log</logDirForSpade>
    <defaultLogLevel>WARN</defaultLogLevel>

    <location name="sps-ichub%s">
      <address>
        <host>sps-ichub%s</host>
      </address>

      <module>
        <name>SecondaryBuilders</name>
        <id>0</id>
      </module>

      <module>
        <name>eventBuilder</name>
        <id>0</id>
      </module>

      <module>
        <name>globalTrigger</name>
        <id>0</id>
      </module>

      <module>
        <name>inIceTrigger</name>
        <id>0</id>
      </module>

      <module>
        <name>StringHub</name>
        <id>%s</id>
      </module>
    </location>

  </cluster>

</icecube>
"""
    filename = "single-string-%s.xml"
    filename  = filename % string
    configtxt = configtxt % (string, string, string, string)
    out = file(filename, "w")
    print >>out, configtxt
    out.close()

def main():
    p = optparse.OptionParser()
    opt, args = p.parse_args()
    for string in args:
        doconfig(string)
    
if __name__ == "__main__": main()

