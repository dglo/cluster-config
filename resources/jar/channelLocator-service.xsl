<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:redirect="http://xml.apache.org/xalan/redirect"
     extension-element-prefixes="redirect">

  <!-- This is the stylesheet for generating the
  channelLocator-service.xml file.  This stylesheet is also used for
  inclusion in the cluster-services.xsl file to pick up the template
  for modules named "channelLocator". -->

  <!-- There is only one channel-locator service so it is assumed there is no
  id for it and it is in the every-location element rather than the
  location element in cluster-config.xml.  -->

  <!-- Pick up the cluster vars, etc. -->
  <xsl:import href="cluster-vars.xsl" />

  <!-- This is the port used for each locations.  In the future this
    may vary by host, but for now it doesn't so a variable is used
    here for all hosts in the cluster -->
  <xsl:variable name="locator-port">
    <xsl:value-of select="/icecube/cluster[@name=$cluster-name]/iceboss/locator-port" />
  </xsl:variable>

  <xsl:output method="xml"
              doctype-public="-//JBoss//DTD MBean Service 3.2//EN"
              doctype-system="http://www.jboss.org/j2ee/dtd/jboss-service_3_2.dtd" />

  <!-- Match the root, for use as a stand-alone stylesheet -->
  <xsl:template match="/">
    <xsl:apply-templates select="icecube/cluster[@name=$cluster-name]/every-location/module[name='channelLocator']" />
  </xsl:template>

  <!-- Match channelLocator modules, for use as an imported stylesheet -->
  <xsl:template match="module[name='channelLocator']">
    <!-- xsl:message>Generating for <xsl:value-of select="$cluster-name" />: <xsl:value-of select="concat($build-dir, '/channelLocator-service.xml')" /></xsl:message -->
    <redirect:write select="concat($build-dir, '/channelLocator-service.xml')">

      <server>
        <xsl:comment>This is a generated file.  Do not edit.  Rather, edit the cluster-config.xml file from which this was generated.</xsl:comment>
        <classpath codebase="tools/lib" archives="Smc.jar"/>
        <classpath codebase="tools/lib" archives="commons-logging-api.jar,jaxb-api.jar,jaxb-impl.jar,jaxb-libs.jar,jax-qname.jar,relaxngDatatype.jar,namespace.jar,xsdlib.jar"/>
        <mbean code="icecube.iceboss.jndi.JVMPrivateBoundObject"
               name="iceboss.locator:service=PipeChannelLocatorFactory"
               xmbean-dd="XMBEAN-INF/icecube.iceboss.jndi.JVMPrivateBoundObject.xml">
          <attribute name="className">icecube.daq.common.channels.PipeChannelLocatorFactory</attribute>
          <attribute name="jndiName">ChannelLocatorType1</attribute>
        </mbean>
      
        <mbean code="icecube.daq.common.channels.services.DelayedChannelLocators"
               name="iceboss.locator:service=DelayedChannelLocatorFactory"
               xmbean-dd="XMBEAN-INF/icecube.daq.common.channels.services.DelayedChannelLocators.xml">
          <attribute name="factoryClass">icecube.daq.common.channels.PipeChannelLocatorFactory</attribute>
          <attribute name="jndiName">ChannelLocatorType2</attribute>
          <depends>jboss:service=Naming</depends>
        </mbean>
      
        <mbean code="icecube.daq.common.channels.services.SocketChannelLocators"
               name="iceboss.locator:service=SocketChannelLocatorFactory"
               xmbean-dd="XMBEAN-INF/icecube.daq.common.channels.services.SocketChannelLocators.xml">
          <attribute name="jndiName">ChannelLocatorType3</attribute>
          <attribute name="port">
              <xsl:value-of select="$locator-port" />
          </attribute>
          <attribute name="xmlConfig">
            <locations>
      
              <!-- For each location drop in all the services -->
              <xsl:for-each select="/icecube/cluster[@name=$cluster-name]/location[@rank > 1]">
                <!-- Don't even start a location element unless we have channelLocator using modules -->
                <xsl:variable name="location-modules" select="module/name"/>
                <xsl:if test="count(/icecube/module-properties-list/module-properties/name[text()=$location-modules]/../channelLocator) > 0">
                  <location>
                    <address>
                      <host>
                        <xsl:value-of select="address/host" />
                      </host>
                      <port>
                        <xsl:value-of select="$locator-port" />
                      </port>
                      </address>

                  <!-- Select the modules which use the channelLocator per location -->
                  <xsl:for-each select="module">
                    <!-- set a var because I can't figure out the following xpath query without using a var -->
                    <xsl:variable name="module-name" select="name"/>
                    <xsl:if test="/icecube/module-properties-list/module-properties/name[text()=$module-name]/../channelLocator" >
                      <end>
                        <type>
                          <xsl:value-of select="name" />
                        </type>
                        <id>
                          <xsl:value-of select="id" />
                        </id>
                      </end>
                    </xsl:if>
                  </xsl:for-each>
                  </location>
                </xsl:if>      
              </xsl:for-each>

            </locations>

          </attribute>
          <depends>jboss:service=Naming</depends>
        </mbean>
      
      </server>
    </redirect:write>
  </xsl:template>

</xsl:stylesheet>
