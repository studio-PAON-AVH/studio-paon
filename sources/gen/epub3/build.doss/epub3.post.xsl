<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:epub="http://www.idpf.org/2007/ops"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<!-- Complete metas and acapela tag cleanup -->

	<xsl:template match="xhtml:html">
		<xsl:variable name="lang" select="xhtml:head/xhtml:meta[@name='dc:language']/@content"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="lang"><xsl:value-of select="$lang"/></xsl:attribute>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

		<!-- clean up des balises scripts -->
  	<xsl:template match="xhtml:script"/>

  	<xsl:template match="xhtml:link">
  	<xsl:copy>
	  	<xsl:attribute name="href"><xsl:value-of select="substring(@href, 9)"/></xsl:attribute>
	  	<xsl:apply-templates select="@*[name() != 'href']"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@epubtype">
		<xsl:attribute name="epub:type"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
