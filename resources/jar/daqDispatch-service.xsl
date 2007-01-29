<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the
daqDispatch-?-service.xml files.  This stylesheet is also used for
inclusion in the cluster-services.xsl file to pick up the template for
modules named "daqDispatch". -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD MBean Service 3.2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-service_3_2.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]/location/module[name='daqDispatch']" />
  </xsl:template>

  <!-- Match daqDispatch modules, for use as an imported stylesheet -->
  <xsl:template match="module[name='daqDispatch']">
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/daqDispatch-', id, '-service.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/daqDispatch_', id, '-service.xml')">
      <server>
        <xsl:text disable-output-escaping="yes">&lt;!-- This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated. --&gt;</xsl:text>
        <classpath codebase="tools/lib" archives="commons-logging-api.jar"/>
      
        <mbean code="icecube.daq.dispatch.service.DevNullController"
               name="IceCubeDAQ.dispatch:acme-aspect=configuration,component=dd,dd=dispatch,dispatch=physics,type=devnull"
               xmbean-dd="XMBEAN-INF/icecube.daq.dispatch.service.DevNullController.xml">
          <attribute name="dispatchJndiName">PhysicsDispatcher</attribute>
        </mbean>

        <mbean code="icecube.daq.dispatch.service.DevNullController"
               name="IceCubeDAQ.dispatch:acme-aspect=configuration,component=dd,dd=dispatch,dispatch=moni,type=devnull"
               xmbean-dd="XMBEAN-INF/icecube.daq.dispatch.service.DevNullController.xml">
          <attribute name="dispatchJndiName">MoniDispatcher</attribute>
        </mbean>

        <mbean code="icecube.daq.dispatch.service.DevNullController"
               name="IceCubeDAQ.dispatch:acme-aspect=configuration,component=dd,dd=dispatch,dispatch=tcal,type=devnull"
               xmbean-dd="XMBEAN-INF/icecube.daq.dispatch.service.DevNullController.xml">
          <attribute name="dispatchJndiName">TCalDispatcher</attribute>
        </mbean>

        <mbean code="icecube.daq.dispatch.service.DevNullController"
               name="IceCubeDAQ.dispatch:acme-aspect=configuration,component=dd,dd=dispatch,dispatch=sn,type=devnull"
               xmbean-dd="XMBEAN-INF/icecube.daq.dispatch.service.DevNullController.xml">
          <attribute name="dispatchJndiName">SNDispatcher</attribute>
        </mbean>

      </server>
    </redirect:write>
  </xsl:template>

</xsl:stylesheet>
