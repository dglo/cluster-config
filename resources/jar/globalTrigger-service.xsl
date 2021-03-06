<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the
globalTrigger-?-service.xml files.  This stylesheet is also used for
inclusion in the cluster-services.xsl file to pick up the template for
modules named "globalTrigger". -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD MBean Service 3.2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-service_3_2.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]/location/module[name='globalTrigger']" />
  </xsl:template>

  <!-- Match globalTrigger modules, for use as an imported stylesheet -->
  <xsl:template match="module[name='globalTrigger']">
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/globalTrigger-', id, '-service.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/globalTrigger_', id, '-service.xml')">
      <server>
        <xsl:text disable-output-escaping="yes">&lt;!-- This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated. --&gt;</xsl:text>
        <classpath codebase="tools/lib" archives="Smc.jar,commons-logging-api.jar,jaxb-api.jar,jaxb-impl.jar,jaxb-libs.jar,jax-qname.jar,relaxngDatatype.jar,namespace.jar,xsdlib.jar"/>
        <mbean code="icecube.daq.globalTrigger.GlobalTriggerManager"
               name="iceCube.daq:type=globalTrigger,id={id},acme-aspect=control,name=globalTriggerCommands"
               xmbean-dd="XMBEAN-INF/icecube.daq.globalTrigger.GlobalTriggerManager.xml">
          <attribute name="DAQCompID"><xsl:value-of select="id"/></attribute>
          <attribute name="DAQCompName">globalTrigger</attribute>
          <attribute name="LocatorJNDIAttribute">jndiName</attribute>
          <depends>iceboss:service=ExternalToJVMPrivateMapper,context=external/daq-ejb-context</depends>
          <depends optional-attribute-name="LocatorJNDIService">iceboss.locator:service=SocketChannelLocatorFactory</depends>
          <xsl:if test="$cluster-name='merc'">
            <depends-list>
              <depends-list-element>jboss.j2ee:module=daq-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=daqcontrol-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=stringProc-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=iniceTrig-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=icetopTrig-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=globalTrig-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=eventBuilder-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=domhub-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=monitorBuilder-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
              <depends-list-element>jboss.j2ee:module=tcalBuilder-prod-conf-ejb.jar,service=EjbModule</depends-list-element>
            </depends-list>
          </xsl:if>
        </mbean>
      </server>
    </redirect:write>
  </xsl:template>

</xsl:stylesheet>
