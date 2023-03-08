<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
	xmlns="http://www.daisy.org/z3986/2005/ncx/"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml ncx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" doctype-public="-//NISO//DTD ncx 2005-1//EN" doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="ncx:navMap">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<pageList>
			<xsl:apply-templates select="*" mode="pageList"/>
		</pageList>
	</xsl:template>

	<xsl:template match="ncx:navPoint[@class='page']"/>

	<xsl:template match="ncx:navPoint">
		<xsl:copy>
		<xsl:apply-templates select="@*"/>
			<xsl:attribute name="playOrder"><xsl:value-of select="count(preceding::ncx:navPoint)+1"/></xsl:attribute>
			<xsl:apply-templates select="*"/>
		</xsl:copy>
		<xsl:apply-templates select="ncx:pages/*"/>
	</xsl:template>

	<xsl:template match="ncx:pages"/>

	<xsl:template match="ncx:navPoint[@class='page']" mode="pageList">
		<pageTarget class="pagenum" id="{@id}" playOrder="{count(preceding::ncx:navPoint)+1}" type="front">
			<navLabel>
				<text>Page <xsl:value-of select="count(preceding::ncx:navPoint[@class='page'])+1"/></text>
				<audio clipBegin="{ncx:navLabel/ncx:audio/@clipBegin}" clipEnd="{ncx:navLabel/ncx:audio/@clipEnd}" src="{ncx:navLabel/ncx:audio/@src}"/>
			</navLabel>
			<content src="{ncx:content/@src}"/>
		</pageTarget>
	</xsl:template>

	<xsl:template match="@*|node()" mode="pageList">
		<xsl:apply-templates select="@*|node()" mode="pageList"/>
	</xsl:template>


	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>

</xsl:stylesheet>