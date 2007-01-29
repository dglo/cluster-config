<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- Generate all the -service.xml files as described in
cluster-config.xml -->

  <!-- Bring in the templates for writing out to the various service
descriptor files.  I'm using imports here only because I get an error
when using includes. Can't have multiply defined doctype-system values
within the same "import level".  I actually want different
doctype-system values in the different files but I'm not sure how to
achieve that. -->
  <xsl:import href="domHub-service.xsl" />
  <xsl:import href="stringProcessor-service.xsl" />
  <xsl:import href="iceTopDataHandler-service.xsl" />
  <xsl:import href="inIceTrigger-service.xsl" />
  <xsl:import href="iceTopTrigger-service.xsl" />
  <xsl:import href="globalTrigger-service.xsl" />
  <xsl:import href="snBuilder-service.xsl" />
  <xsl:import href="tcalBuilder-service.xsl" />
  <xsl:import href="monitorBuilder-service.xsl" />
  <xsl:import href="eventBuilder-service.xsl" />
  <xsl:import href="daqToOffline-service.xsl" />
  <xsl:import href="daqControl-service.xsl" />
  <xsl:import href="daqDispatch-service.xsl" />
  <xsl:import href="daq-jndi-service.xsl" />
  <xsl:import href="channelLocator-service.xsl" />

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD MBean Service 3.2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-service_3_2.dtd" />

  <!-- Match the root, so I can select only the named cluster -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]" />
  </xsl:template>

  <!-- Matching only that named cluster... -->
  <xsl:template match="cluster[@name=$cluster-name]">
    <xsl:for-each select="location/module">
      <!-- set a var because I can't figure out the following xpath query without using a var -->
      <xsl:variable name="module-name"><xsl:value-of select="name" /></xsl:variable>
      <xsl:if test="/icecube/module-properties-list/module-properties/name[text()=$module-name]/../type='service'" >
        <!-- xsl:message>module: <xsl:value-of select="$module-name" /></xsl:message -->
        <xsl:apply-templates select="." />
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="every-location/module">
      <!-- set a var because I can't figure out the following xpath query without using a var -->
      <xsl:variable name="module-name"><xsl:value-of select="name" /></xsl:variable>
      <xsl:if test="/icecube/module-properties-list/module-properties/name[text()=$module-name]/../type='service'" >
        <!-- xsl:message>module: <xsl:value-of select="$module-name" /></xsl:message -->
        <xsl:apply-templates select="." />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
