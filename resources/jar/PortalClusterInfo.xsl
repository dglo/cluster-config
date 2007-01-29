<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- Pick up the cluster vars, etc. -->
    <!--  defines the cluster-name global param -->
    <xsl:import href="cluster-vars.xsl"/>
    <xsl:output indent="yes" method="xml"/>

    <!--    <xsl:template match="/">
        <xsl:apply-templates select="merge"/>
    </xsl:template> -->

    <xsl:template match="merge">
        <xsl:variable name="static_xml" select="string(staticxml)"/>
        <xsl:variable name="config_xml" select="string(configxml)"/>
        <xsl:call-template name="domerge">
            <xsl:with-param name="static_nodes"
                select="document($static_xml)/icecube/cluster[@name=$cluster-name]"/>
            <xsl:with-param name="config_nodes"
                select="document($config_xml)/icecube/cluster[@name=$cluster-name]"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="domerge">
        <xsl:param name="static_nodes"/>
        <xsl:param name="config_nodes"/>
        <icecube>
            <cluster>
                <xsl:attribute name="name">
                    <xsl:value-of select="$cluster-name"/>
                </xsl:attribute>
                <xsl:for-each select="$static_nodes//node">
                    <node>
                        <xsl:attribute name="usage">
                            <xsl:choose>
                                <xsl:when test=".=$config_nodes//location/address/host">true</xsl:when>
                                <xsl:otherwise>false</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </node>
                </xsl:for-each>
            </cluster>
            <workspace>
                <xsl:value-of select="$ws-name"/>
            </workspace>
            <build>
                <xsl:value-of select="$build-number"/>
            </build>
            <host>
                <xsl:value-of select="$build-host"/>
            </host>
        </icecube>
    </xsl:template>
</xsl:stylesheet>
