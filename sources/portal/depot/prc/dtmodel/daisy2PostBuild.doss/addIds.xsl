<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="dPfx"/>
	<xsl:param name="pPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="contentTags" select="'p h1 h2 h3 h4 h5 h6'"/>

	<xsl:template match="xhtml:div/@id"><xsl:attribute name="id"><xsl:value-of select="$dPfx"/><xsl:value-of select="."/></xsl:attribute></xsl:template>

	<xsl:template match="xhtml:p|xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6">
		<xsl:copy>
			<xsl:variable name="divBlock" select="ancestor::xhtml:div[not(@class='note')][@id][1]"/>
			<xsl:variable name="contentPosition" select="count(preceding::*[contains($contentTags,local-name())])"/>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="id">
				<xsl:value-of select="$pPfx"/>
				<xsl:value-of select="$divBlock/@id"/>
				<xsl:text>_</xsl:text>
				<xsl:value-of select="count($divBlock/descendant::*[contains($contentTags,local-name())][count(preceding::*[contains($contentTags,local-name())]) &lt; $contentPosition])"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:span">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="@class='sentence'">
				<xsl:variable name="divBlock" select="ancestor::xhtml:div[not(@class='note')][@id][1]"/>
				<xsl:variable name="contentBlock" select="ancestor::*[contains($contentTags,local-name())][1]"/>
				<xsl:variable name="contentPosition" select="count($contentBlock/preceding::*[contains($contentTags,local-name())])"/>
				<xsl:variable name="position" select="count(preceding::xhtml:span[@class='sentence'])"/>
				<!--xsl:attribute name="position"><xsl:value-of select="$position"/></xsl:attribute-->
				<xsl:attribute name="id">
					<xsl:value-of select="$sPfx"/>
					<xsl:value-of select="$divBlock/@id"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="count($divBlock/descendant::*[contains($contentTags,local-name())][count(preceding::*[contains($contentTags,local-name())]) &lt; $contentPosition])"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="count($contentBlock/descendant::xhtml:span[@class='sentence'][count(preceding::xhtml:span[@class='sentence']) &lt; $position])"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
	</xsl:template>

</xsl:stylesheet>
