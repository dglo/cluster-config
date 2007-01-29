<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- This stylesheet is used for defining common variables and
parameters to be imported in the other cluster config stylesheets. -->

  <!-- The build dir into which to place generated files.  Defaults to pwd -->
  <xsl:param name="build-dir">.</xsl:param>

  <!-- a newline var -->
  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <!-- The cluster-name, defaults to merc -->
  <xsl:param name="cluster-name">merc</xsl:param>
  <xsl:param name="ws-name">DAQ-PROD</xsl:param>
  <xsl:param name="build-number">0</xsl:param>
  <xsl:param name="build-host">localhost</xsl:param>

  <!-- Cluster's name in lower case
  <xsl:variable name="cluster-name">
    <xsl:value-of select="translate(/cluster/name,
                                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                    'abcdefghijklmnopqrstuvwxyz')" />
  </xsl:variable>  -->

  <!-- If cluster-name is "merc" then make this empty otherwise use
  the cluster-name as the hostname-prefix -->
  <xsl:variable name="hostname-prefix">
    <xsl:choose>
      <xsl:when test="$cluster-name = 'merc'"/>
      <xsl:otherwise>
        <xsl:value-of select="$cluster-name"/>
        <xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

</xsl:stylesheet>
