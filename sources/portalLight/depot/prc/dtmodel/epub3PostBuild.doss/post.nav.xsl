<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml ncx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="xhtml:li[@class='pagenum']/xhtml:a">
		<a>
			<xsl:apply-templates select="@*"/>
			<xsl:text>Page </xsl:text><xsl:value-of select="count(preceding::xhtml:li[@class='pagenum'])+1"/>
		</a>
	</xsl:template>


	<xsl:template match="xhtml:html">
		<html>
			<xsl:apply-templates select="@*|node()"/>
		</html>
	</xsl:template>

	<xsl:template match="xhtml:@*">
		<xsl:attribute name="{local-name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="xhtml:*">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@*|node()"/>
		</xsl:element>
	</xsl:template>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>