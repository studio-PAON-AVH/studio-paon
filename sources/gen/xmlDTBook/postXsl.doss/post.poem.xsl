<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="dtb">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="dtb:poem">
		<xsl:copy>
			<xsl:apply-templates select="*[1]" mode="poem"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dtb:line|dtb:blockquote" mode="poem">
		<linegroup>
			<xsl:apply-templates select="current()"/>
			<xsl:apply-templates select="following-sibling::*[1]" mode="linegroup"/>
		</linegroup>
		<xsl:apply-templates select="following-sibling::dtb:sidebar[1]" mode="poem"/>
	</xsl:template>

	<xsl:template match="dtb:sidebar|dtb:epigraph" mode="poem">
		<xsl:apply-templates select="current()"/>
		<xsl:apply-templates select="following-sibling::*[1]" mode="poem"/>
	</xsl:template>

	<xsl:template match="dtb:line|dtb:blockquote|dtb:epigraph" mode="linegroup">
		<xsl:apply-templates select="current()"/>
		<xsl:apply-templates select="following-sibling::*[1]" mode="linegroup"/>
	</xsl:template>

	<xsl:template match="dtb:sidebar" mode="linegroup"/>


	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
