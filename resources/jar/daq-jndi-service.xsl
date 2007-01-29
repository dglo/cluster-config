<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the daq-jndi-service.xml
  file.  This stylesheet is also used for inclusion in the
  cluster-services.xsl file to pick up the template for modules named
  "daq-jndi". -->

  <!-- There is only one daq-jndi service so it is assumed there is no
  id for it and it is in the every-location element rather than the
  location element in cluster-config.xml.  Further there really isn't
  anything that this stylesheet needs from the cluster-config.xml
  file.  This is here only for consistency with how all the other
  -service.xml files are generated. -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD MBean Service 3.2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-service_3_2.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]/every-location/module[name='daq-jndi']" />
  </xsl:template>

  <!-- Match daq-jndi modules, for use as an imported stylesheet -->
  <xsl:template match="module[name='daq-jndi']">
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/daq-jndi-service.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/daq-jndi-service.xml')">
      <server>
        <xsl:text disable-output-escaping="yes">&lt;!-- This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated. --&gt;</xsl:text>
        <classpath codebase="tools/lib" archives="commons-logging-api.jar"/>
        <classpath codebase="tools/lib" archives="jaxb-api.jar,jaxb-impl.jar,jaxb-libs.jar,jax-qname.jar,relaxngDatatype.jar,namespace.jar"/>

        <mbean code="org.jboss.naming.ExternalContext"
               name="iceboss:service=ExternalContext,jndiName=external/daq-ejb-context">
          <attribute name="JndiName">external/daq-ejb-context</attribute>
          <attribute name="PropertiesURL">file:///${jboss.server.base.dir}/iceboss-cluster/jndi.properties</attribute>
          <attribute name="InitialContext">javax.naming.InitialContext</attribute>
          <depends>jboss:service=Naming</depends>
        </mbean>

        <mbean code="icecube.iceboss.jndi.ExternalToJVMPrivateMapper"
               name="iceboss:service=ExternalToJVMPrivateMapper,context=external/daq-ejb-context"
               xmbean-dd="XMBEAN-INF/icecube.iceboss.jndi.ExternalToJVMPrivateMapper.xml">
          <attribute name="mappings">
            <mappings>
              <base>
                <from>daq/ejb</from>
                <to>daq/ejb</to>
              </base>
              <mapping>
                <from-name>DataCacheMgrAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQToOfflineMBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQcontrolAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQcontrolAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQconfigurationBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQcontrolConfigurationBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQcontrolSignalListBean</from-name>
              </mapping>
              <mapping>
                <from-name>IcetopTrigAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>IcetopTrigAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>IcetopDataHandlerAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>IcetopDataHandlerAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>EventBuilderAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>EventBuilderAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>EventBuilderConfigurationBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomHubAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomHubAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQvalidStatesListBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQcontrolSignalsListBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQstringProcConfigurationBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQdomHubConfigurationBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomHubDomSetBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>IniceTrigAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>IniceTrigAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>TriggerConfigurationBean</from-name>
              </mapping>
              <mapping>
                <from-name>TriggerIdBean</from-name>
              </mapping>
              <mapping>
                <from-name>TriggerConfigBean</from-name>
              </mapping>
              <mapping>
                <from-name>TriggerNameBean</from-name>
              </mapping>
              <mapping>
                <from-name>ParamConfigBean</from-name>
              </mapping>
              <mapping>
                <from-name>ParamBean</from-name>
              </mapping>
              <mapping>
                <from-name>ParamValueBean</from-name>
              </mapping>
              <mapping>
                <from-name>ReadoutConfigBean</from-name>
              </mapping>
              <mapping>
                <from-name>ReadoutParametersBean</from-name>
              </mapping>
              <mapping>
                <from-name>GlobalTrigAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>GlobalTrigAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>GTriggerConfigurationBean</from-name>
              </mapping>
              <mapping>
                <from-name>ExpandedTimewindowBean</from-name>
              </mapping>
              <mapping>
                <from-name>DaqInterconnectionsBean</from-name>
              </mapping>
              <mapping>
                <from-name>DaqComponentsInConfigBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomHubSimulationBean</from-name>
              </mapping>
              <mapping>
                <from-name>StringProcAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>StringProcAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>StringProcConnectionBean</from-name>
              </mapping>
              <mapping>
                <from-name>MonitorBuilderAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>MonitorBuilderAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>TcalBuilderAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>TcalBuilderAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>SNBuilderAttributeBean</from-name>
              </mapping>
              <mapping>
                <from-name>SNBuilderAttributeMapBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQprimaryKeyListBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQConfigurationDescriptionBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQConfigurationDataBean</from-name>
              </mapping>
              <mapping>
                <from-name>DAQConfigurationHistoryBean</from-name>
              </mapping>
              <mapping>
                <from-name>ConfigToHubBean</from-name>
              </mapping>
              <mapping>
                <from-name>SimConfigBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomHubSimBean</from-name>
              </mapping>
              <mapping>
                <from-name>HubToDomBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomSimBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomConfigBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomSetBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomSetNameBean</from-name>
              </mapping>
              <mapping>
                <from-name>DomIdBean</from-name>
              </mapping>
            </mappings>
          </attribute>
          <depends optional-attribute-name="externalContextService">iceboss:service=ExternalContext,jndiName=external/daq-ejb-context</depends>
        </mbean>
      </server>
    </redirect:write>   
  </xsl:template>

</xsl:stylesheet>
