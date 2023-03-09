<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="xhtml1-transitional.dtd"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d'"/>
  <xsl:variable name="durations" select="java:getVar($vDialog, 'durations')"/>

	<xsl:template match="xhtml:meta[@name='ncc:totalTime']">
		<xsl:copy>
				<xsl:apply-templates select="@name|@scheme"/>
				<xsl:attribute name="content"><xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $format-audio-duration)"/></xsl:attribute>
			</xsl:copy>
	</xsl:template>


  <xsl:template match="xhtml:meta[@name='ncc:tocItems']">
		<xsl:variable name="anchors" select="count(//xhtml:a)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="content"><xsl:value-of select="$anchors"/></xsl:attribute>
		</xsl:copy><xsl:text>
		</xsl:text><meta name="ncc:pageNormal" content="{count(//xhtml:span[containWord(@class,'page-normal')])}"/><xsl:text>
		</xsl:text><meta name="ncc:maxPageNormal" content="{count(//xhtml:span[containWord(@class,'page-normal')])}"/>
	</xsl:template>

	<xsl:template match="xhtml:span/xhtml:a">
  		<xsl:copy>
  			<xsl:apply-templates select="@*|node()"/>
  			<xsl:value-of select="count(preceding::xhtml:span)+1"/>
  		</xsl:copy>
  	</xsl:template>

	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>

</xsl:stylesheet>