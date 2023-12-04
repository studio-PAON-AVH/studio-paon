<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//NISO//DTD ncx 2005-1//EN" doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<!-- Nombre de phrases par page -->
  <xsl:variable name="sPerPage" select="17"/>
	
	<xsl:template match="xhtml:li[@class='pagenum']">
		<xsl:variable name="prec" select="count(preceding-sibling::xhtml:li[@class='pagenum'])"/>
		<xsl:if test="($prec mod $sPerPage = 0 and $prec != 0)">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="xhtml:li[@class='pagetitle']">
			<xsl:copy>
				<xsl:attribute name="class">pagenum</xsl:attribute>
				<xsl:apply-templates select="@id|node()"/>
			</xsl:copy>
			<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>

</xsl:stylesheet>