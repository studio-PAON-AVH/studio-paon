<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java dtb">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="dPfx"/>
	<xsl:param name="pPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="contentTags" select="'p h1 h2 h3 h4 h5 h6 line doctitle docauthor'"/>

	<xsl:template match="dtb:frontmatter/@id|dtb:level1/@id|dtb:level2/@id|dtb:level3/@id|dtb:level4/@id|dtb:level5/@id|dtb:level6/@id"><xsl:attribute name="id"><xsl:value-of select="$dPfx"/><xsl:value-of select="."/></xsl:attribute></xsl:template>

	<xsl:template match="dtb:p|dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6|dtb:line|dtb:doctitle|dtb:docauthor">
		<xsl:copy>
			<xsl:variable name="divBlock" select="ancestor::*[contains(local-name(), 'level')][@id][1]|ancestor::dtb:frontmatter"/>
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

	<xsl:template match="dtb:span">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="@class='sentence'">
				<xsl:variable name="divBlock" select="ancestor::*[contains(local-name(), 'level')][@id][1]|ancestor::dtb:frontmatter"/>
				<xsl:variable name="contentBlock" select="ancestor::*[@id][1]"/>
				<xsl:variable name="contentPosition" select="count($contentBlock/preceding::*[contains($contentTags,local-name())])"/>
				<xsl:variable name="position" select="count(preceding::dtb:span[@class='sentence'])"/>
				<!--xsl:attribute name="position"><xsl:value-of select="$position"/></xsl:attribute-->
				<xsl:attribute name="id">
					<xsl:value-of select="$sPfx"/>
					<xsl:value-of select="$divBlock/@id"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="count($divBlock/descendant::*[contains($contentTags,local-name())][count(preceding::*[contains($contentTags,local-name())]) &lt; $contentPosition])"/>
					<xsl:text>_</xsl:text>
					<xsl:value-of select="count($contentBlock/descendant::dtb:span[@class='sentence'][count(preceding::dtb:span[@class='sentence']) &lt; $position])"/></xsl:attribute>
			</xsl:if>
			<xsl:choose>
					<xsl:when test="parent::dtb:noteref"><xsl:apply-templates select="parent::dtb:noteref" mode="copyNoteRef"/></xsl:when>
					<xsl:otherwise><xsl:apply-templates select="node()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<!-- Cas particulier d'un span@sentence mis à l'intérieur d'un noteref. On réinverse les balises -->
	<xsl:template match="dtb:noteref">
		<xsl:choose>
			<xsl:when test="dtb:span"><xsl:apply-templates select="node()"/></xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <xsl:template match="dtb:noteref" mode="copyNoteRef">
		<xsl:copy><xsl:apply-templates select="@*"/><xsl:value-of select="normalize-space()"/></xsl:copy>
	</xsl:template>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
