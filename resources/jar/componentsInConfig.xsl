<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="1.0">

<!-- This stylesheet is used for generating the componentsInConfig.sql
file which is used by the componentInConfig.sh script.  This is the
subset of components which are actually being deployed, so daqcontrol
doesn't waste time tring to discover a bunch of components which are
going to be there. -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <!-- SQL, actually -->
  <xsl:output method="text"/>

  <xsl:template match="/icecube">
    <!-- Put a warning in for those who like to hack -->
    <xsl:text>-- This is an automatically generated file.  Do not edit this file.</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>-- Rather, edit the cluster-config.xml file from which this file was generated.</xsl:text>
    <xsl:value-of select="$newline"/>

    <xsl:text>
-- Set all component as FALSE, meaning they are not deployed.
UPDATE DAQCOMPONENTSINCONFIGBEAN SET COMPONENTDEPLOYED='FALSE';
UPDATE DAQCOMPONENTSINCONFIGBEAN SET COMPONENTINCONFIG='FALSE';

-- Now set set the components which are being deployed to TRUE:
</xsl:text>

    <xsl:apply-templates select="cluster[@name=$cluster-name]" />

  </xsl:template>

  <xsl:template match="cluster[@name=$cluster-name]">

    <xsl:for-each select="location">
      <xsl:call-template name="get-services"/>
    </xsl:for-each>

    <xsl:for-each select="every-location">
      <xsl:call-template name="get-services"/>
    </xsl:for-each>

  </xsl:template>

  <xsl:template name="get-services">
    <xsl:for-each select="module">
      <xsl:variable name="module-name"><xsl:value-of select="name" /></xsl:variable>
      <xsl:if test="id and /icecube/module-properties-list/module-properties/name[text()=$module-name]/../daqControl">
        <xsl:text>UPDATE DAQCOMPONENTSINCONFIGBEAN 
  SET COMPONENTDEPLOYED='TRUE'
  WHERE DAQCOMPONENTSINCONFIGBEAN.COMPONENTTYPE='</xsl:text><xsl:value-of select="name" /><xsl:text>'
  AND DAQCOMPONENTSINCONFIGBEAN.COMPONENTID='</xsl:text><xsl:value-of select="id" /><xsl:text>';
</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>