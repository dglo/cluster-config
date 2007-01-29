<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the
daqToOffline-?-service.xml files.  This stylesheet is also used for
inclusion in the cluster-services.xsl file to pick up the template for
modules named "daqToOffline". -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD MBean Service 3.2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-service_3_2.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]/location/module[name='daqToOffline']" />
  </xsl:template>

  <!-- Match daqToOffline modules, for use as an imported stylesheet -->
  <xsl:template match="module[name='daqToOffline']">
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/daqToOffline-', id, '-service.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/daqToOffline_', id, '-service.xml')">
      <server>
        <xsl:text disable-output-escaping="yes">&lt;!-- This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated. --&gt;</xsl:text>
        <classpath codebase="tools/lib" archives="Smc.jar,commons-logging-api.jar,jaxb-api.jar,jaxb-impl.jar,jaxb-libs.jar,jax-qname.jar,relaxngDatatype.jar,namespace.jar,xsdlib.jar"/>
        <mbean code="icecube.daq.config.util.dto.DAQToOfflineMBean"
               name="iceCube.daq:type=daqToOffline,id={id},acme-aspect=control,name=daqToOffline"
               xmbean-dd="XMBEAN-INF/icecube.daq.config.util.dto.DAQToOfflineMBean.xml">
          <attribute name="DAQCompID"><xsl:value-of select="id"/></attribute>
          <attribute name="DAQCompName">daqToOffline</attribute>
          <attribute name="LocatorJNDIAttribute">jndiName</attribute>
          <xsl:if test="$cluster-name!='merc'">
            <attribute name="DataSourceName">java:/PostgresDS</attribute>
          </xsl:if>
          <depends>iceboss:service=ExternalToJVMPrivateMapper,context=external/daq-ejb-context</depends>
        </mbean>
      </server>
    </redirect:write>
  </xsl:template>

</xsl:stylesheet>
