<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="dtb">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<!-- post processing générique DTB -->

	<!-- Ajout de la CSS de base de Daisy2 -->
	<xsl:template match="/">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/css" href="http://www.daisy.org/z3986/2005/dtbook.2005.basic.css"</xsl:text>
		</xsl:processing-instruction>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dtb:div">
		<xsl:choose>
			<xsl:when test="containWord(@class, 'poem_div')"><poem><xsl:apply-templates mode="poem"/></poem></xsl:when>
			<xsl:when test="containWord(@class, 'side_div')"><sidebar render="{dtb:att/@render}"><xsl:apply-templates/></sidebar></xsl:when>
			<xsl:when test="containWord(@class, 'blockquote_div')"><blockquote><xsl:apply-templates/></blockquote></xsl:when>
			<xsl:when test="containWord(@class, 'epigraph_div')"><epigraph><xsl:apply-templates/></epigraph></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="poem">
		<xsl:apply-templates mode="poem"/>
	</xsl:template>

	<xsl:template match="dtb:p" mode="poem">
			<line><xsl:apply-templates/></line>
	</xsl:template>

	<xsl:template match="dtb:div" mode="poem">
	<xsl:choose>
		<xsl:when test="containWord(@class, 'poem_div')"><xsl:apply-templates mode="poem"/></xsl:when> <!-- on ignore les doubles structures de poeme -->
  	<xsl:when test="containWord(@class, 'side_div')"><sidebar render="{dtb:att/@render}"><xsl:apply-templates/></sidebar></xsl:when>
  	<xsl:when test="containWord(@class, 'blockquote_div')"><blockquote><xsl:apply-templates/></blockquote></xsl:when>
  	<xsl:when test="containWord(@class, 'epigraph_div')"><epigraph><xsl:apply-templates/></epigraph></xsl:when>
	</xsl:choose>
	</xsl:template>

	<xsl:template match="dtb:span[containWord(@class, 'author_is')][ancestor::dtb:div[containWord(' blockquote_div  epigraph_div ', @class)] or ancestor::dtb:cite]">
		<xsl:choose>
			<xsl:when test="not(parent::dtb:cite)">
				<cite><author><xsl:apply-templates/></author></cite>
			</xsl:when>
			<xsl:otherwise><author><xsl:apply-templates/></author></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dtb:span[containWord(@class, 'title_is')][ancestor::dtb:div[containWord(' blockquote_div  epigraph_div ', @class)] or ancestor::dtb:cite]">
		<xsl:choose>
			<xsl:when test="not(parent::dtb:cite)">
				<cite><title><xsl:apply-templates/></title></cite>
			</xsl:when>
			<xsl:otherwise><title><xsl:apply-templates/></title></xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="dtb:ol|dtb:ul">
		<list type="{local-name()}">
			<xsl:apply-templates select="@*|node()"/>
		</list>
	</xsl:template>

	<xsl:template match="dtb:abbr|dtb:acronym">
		<xsl:copy>
			<xsl:for-each select="dtb:att">
				<xsl:attribute name="{@name}"><xsl:value-of select="text()"/></xsl:attribute>
			</xsl:for-each>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dtb:att"/>

	<xsl:template match="@style"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
