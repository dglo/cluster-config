<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the
daq-<location>-jboss.xml files. -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD J2EE Application 1.3V2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-app_3_2.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]" />
  </xsl:template>

  <xsl:template match="cluster[@name=$cluster-name]">
   <xsl:for-each select="location">
     <xsl:call-template name="daq-location-jboss">
        <xsl:with-param name="build-dir" select="$build-dir" />
        <xsl:with-param name="cluster-name" select="$cluster-name" />
     </xsl:call-template>
   </xsl:for-each>
  </xsl:template>

  <!-- generate a daq-<host>-jboss.xml file -->
  <xsl:template name="daq-location-jboss">
    <xsl:param name="build-dir">.</xsl:param>
    <xsl:param name="cluster-name" />
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/daq-', address/host, '-jboss.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/daq-', address/host, '-jboss.xml')">
      <jboss-app>
        <xsl:text disable-output-escaping="yes">&lt;!-- This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated. --&gt;</xsl:text>
        <xsl:apply-templates select="module" />
        <xsl:apply-templates select="/icecube/cluster[@name=$cluster-name]/every-location/module" />
      </jboss-app>
    </redirect:write>
  </xsl:template>

  <!-- Template for all the service modules. -->
  <xsl:template match="module">
    <!-- set a var because I can't figure out the following xpath query without using a var -->
    <xsl:variable name="module-name"><xsl:value-of select="name" /></xsl:variable>
    <xsl:if test="/icecube/module-properties-list/module-properties/name[text()=$module-name]/../type='service'" >
      <module>
        <service>
          <xsl:value-of select="name" />
          <xsl:if test="id">
            <xsl:text>_</xsl:text>
            <xsl:value-of select="id" />
          </xsl:if>
          <xsl:text>.sar</xsl:text>
        </service>
      </module>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
