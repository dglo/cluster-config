<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the domHub-?-service.xml
files. This stylesheet is also used for inclusion in the
cluster-services.xsl file to pick up the template for modules named
"domHub". -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD MBean Service 3.2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-service_3_2.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]/location/module[name='domHub']" />
  </xsl:template>

  <!-- Match domHub modules, for use as an imported stylesheet -->
  <xsl:template match="module[name='domHub']">
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/domHub-', id, '-service.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/domHub_', id, '-service.xml')">
      <server>
        <xsl:text disable-output-escaping="yes">&lt;!-- This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated. --&gt;</xsl:text>
        <classpath codebase="tools/lib" archives="log4j.jar,Smc.jar,commons-logging-api.jar,jboss-common.jar,jboss-jmx.jar,jmxtools.jar,concurrent.jar,jboss-system.jar,jdom.jar,j2ee.jar,jmxri.jar"/>
        <mbean code="icecube.daq.domHub.DomHubManager"
               name="iceCube.daq:type=domHub,id={id},acme-aspect=control,name=domHubCommands"
               xmbean-dd="XMBEAN-INF/icecube.daq.domHub.DomHubManager.xml">
          <attribute name="DAQCompID"><xsl:value-of select="id"/></attribute>
          <attribute name="DAQCompName">domHub</attribute>
          <attribute name="LocatorJNDIAttribute">jndiName</attribute>
          <depends>iceboss:service=ExternalToJVMPrivateMapper,context=external/daq-ejb-context</depends>
          <depends optional-attribute-name="LocatorJNDIService">iceboss.locator:service=SocketChannelLocatorFactory</depends>
          <xsl:if test="$cluster-name='merc'">
            <depends-list>
              <depends-list-element>jboss.j2ee:module=daq-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=daqcontrol-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=domhub-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
            </depends-list>
          </xsl:if>
        </mbean>
      </server>
    </redirect:write>
  </xsl:template>

</xsl:stylesheet>
