<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xalan="http://xml.apache.org/xalan" xmlns:java="http://xml.apache.org/xslt/java" exclude-result-prefixes="xalan java html">
	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>

	<xsl:template match="head">
		<esFieldsMaker>
      <xsl:apply-templates/>
    </esFieldsMaker>
  </xsl:template>

 	<xsl:template match="meta[@name='ncc:timeInThisSmil']">
		<addArrayEntryField key="duration" value="{@content}"/>
	</xsl:template>
  
</xsl:stylesheet>