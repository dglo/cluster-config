<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- This stylesheet is used for defining common variables and
parameters to be imported in the other cluster config stylesheets. -->

  <!-- a newline var -->
  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>

  <!-- Cluster's name in lower case -->
  <xsl:variable name="cluster-name">
    <xsl:value-of select="/icecube/cluster/@name" />
  </xsl:variable>

</xsl:stylesheet>
