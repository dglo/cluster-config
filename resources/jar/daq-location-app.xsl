<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the daq-<location>-app.xml files.
This stylesheet is also used for inclusion in the cluster-config.xsl
file to pick up the daq-location-app named template. -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//Sun Microsystems, Inc.//DTD J2EE Application 1.3//EN"
              doctype-system="http://java.sun.com/dtd/application_1_3.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]" />
  </xsl:template>

  <xsl:template match="cluster[@name=$cluster-name]" >
    <xsl:for-each select="location">
      <xsl:call-template name="daq-location-app">
        <xsl:with-param name="build-dir" select="$build-dir" />
        <xsl:with-param name="cluster-name" select="$cluster-name" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- Generate a daq-<host>-app.xml file -->
  <xsl:template name="daq-location-app">
    <xsl:param name="build-dir">.</xsl:param>
    <xsl:param name="cluster-name" />
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/daq-', address/host, '-app.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/daq-', address/host, '-app.xml')">
      <application>
        <xsl:text disable-output-escaping="yes">&lt;!-- This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated. --&gt;</xsl:text>
        <display-name>DAQ for <xsl:value-of select="$cluster-name" /></display-name>
        <description>EAR deployment descriptor for <xsl:value-of select="$cluster-name" /> version of DAQ.</description>

        <xsl:apply-templates select="module" />

      </application>
    </redirect:write>
  </xsl:template>

  <!-- We're looking for EJBs which don't use the channel locator -->
  <xsl:template match="module" >
    <xsl:for-each select=".">
      <!-- set a var because I can't figure out the following xpath query without using a var -->
      <xsl:variable name="module-name"><xsl:value-of select="name" /></xsl:variable>
      <xsl:if test="not(/icecube/module-properties-list/module-properties/name[text()=$module-name]/../channelLocator) and
                    /icecube/module-properties-list/module-properties/name[text()=$module-name]/../type='ejb'" >
        <module>
          <ejb>
            <xsl:value-of select="name" /><xsl:text>-ejb.jar</xsl:text>
          </ejb>
        </module>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
