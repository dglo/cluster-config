<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

<!-- This stylesheet is used for generating the NODES environment var
to be sourced by the deploy-daq.sh script.  This is the list of
machine names in use within the cluster. -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="text"/>

  <xsl:template match="/icecube">
    <!-- Put a warning in for those who like to hack -->
    <xsl:text># This is an automatically generated file.  Do not edit this file.</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text># Rather, edit the cluster-config.xml file from which this file was generated.</xsl:text>
    <xsl:value-of select="$newline"/>

    <xsl:text>CLUSTER=&quot;</xsl:text>
    <xsl:value-of select="$cluster-name"/>
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="$newline"/>

    <xsl:text>NODES=&quot;</xsl:text>
    <xsl:apply-templates select="cluster[@name=$cluster-name]" />
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="$newline"/>
  </xsl:template>

  <xsl:template match="cluster[@name=$cluster-name]">
    <xsl:for-each select="location/address">
      <xsl:value-of select="host"/>
      <xsl:if test = "not(position()=last())" >
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
