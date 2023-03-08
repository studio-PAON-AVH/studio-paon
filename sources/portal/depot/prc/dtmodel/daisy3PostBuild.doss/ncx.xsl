<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
	xmlns="http://www.daisy.org/z3986/2005/ncx/"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java dtb ncx">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="dPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="durations" select="java:getVar($vDialog, 'durations')"/>
	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>

	<xsl:template match="dtb:dtbook">
		<ncx version="2005-1" xml:lang="fr-FR">
			<head>
				<meta name="dtb:uid" content="{dtb:head/dtb:meta[@name='dtb:uid']/@content}" />
				<meta name="dtb:generator" content="{dtb:head/dtb:meta[@name='dtb:generator']/@content}" />
				<meta name="dtb:depth">
					<xsl:attribute name="content"><xsl:choose>
						<xsl:when test="descendant::dtb:level6">6</xsl:when>
						<xsl:when test="descendant::dtb:level5">5</xsl:when>
						<xsl:when test="descendant::dtb:level4">4</xsl:when>
						<xsl:when test="descendant::dtb:level3">3</xsl:when>
						<xsl:when test="descendant::dtb:level2">2</xsl:when>
						<xsl:otherwise>1</xsl:otherwise></xsl:choose></xsl:attribute>
				</meta>
			</head>
			<xsl:apply-templates select="dtb:book/dtb:frontmatter/dtb:doctitle"/>
			<navMap>
				<xsl:apply-templates select="dtb:book/dtb:frontmatter/dtb:level1"/>
				<xsl:apply-templates select="dtb:book/dtb:bodymatter"/>
			</navMap>
		</ncx>
	</xsl:template>

	<xsl:template match="dtb:doctitle">
		<xsl:variable name="smilId" select="substring(parent::*/@id,string-length($dPfx)+1)"/>
		<docTitle>
			<text><xsl:value-of select="normalize-space()"/></text>
			<audio clipBegin="{descendant::dtb:span[1]/@clipBegin}" clipEnd="{java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, 1, $format-audio-duration)}" src="{$smilId}.smil" />
		</docTitle>
	</xsl:template>

	<xsl:template match="dtb:level1[@id]|dtb:level2[@id]|dtb:level3[@id]|dtb:level4[@id]|dtb:level5[@id]|dtb:level6[@id]">
		<xsl:variable name="smilId" select="substring(@id,string-length($dPfx)+1)"/>

		<navPoint class="{local-name(child::*[1])}" id="nav_{$smilId}">
			<navLabel>
				<text><xsl:value-of select="normalize-space(child::*[1])"/></text>
				<audio clipBegin="{child::*[1]/dtb:span[@class='sentence'][1]/@clipBegin}" clipEnd="{child::*[1]/dtb:span[@class='sentence'][last()]/@clipEnd}" src="{$smilId}.mp3" />
			</navLabel>
			<content src="{$smilId}.smil#par_{@id}" />
			<pages>
				<navPoint class="page-title" id="navp_{$smilId}">
					<navLabel>
						<audio clipBegin="{child::*[1]/dtb:span[@class='sentence'][1]/@clipBegin}" clipEnd="{child::*[1]/dtb:span[@class='sentence'][last()]/@clipEnd}" src="{$smilId}.mp3" />
					</navLabel>
					<content src="{$smilId}.smil#par_{@id}" />
				</navPoint>
				<xsl:apply-templates select="*"/>
			</pages>
		</navPoint>
	</xsl:template>

	<xsl:template match="dtb:span[@class='sentence']">
		<xsl:variable name="smilId"><xsl:apply-templates select="parent::*" mode="id"/></xsl:variable>
		<navPoint class="page" id="navp_{@id}">
			<navLabel>
				<audio clipBegin="{@clipBegin}" clipEnd="{@clipEnd}" src="{$smilId}.mp3" />
			</navLabel>
			<content src="{$smilId}.smil#par_{@id}" />
		</navPoint>
	</xsl:template>

	<xsl:template match="*" mode="id">
		<xsl:apply-templates select="parent::*" mode="id"/>
	</xsl:template>

	<xsl:template match="dtb:frontmatter[@id]|dtb:level1[@id]|dtb:level2[@id]|dtb:level3[@id]|dtb:level4[@id]|dtb:level5[@id]|dtb:level6[@id]" mode="id"><xsl:value-of select="substring(@id,string-length($dPfx)+1)"/></xsl:template>

	<xsl:template match="*" mode="copyTxt">
			<xsl:apply-templates select="@*|node()" mode="copyTxt"/>
	</xsl:template>

	<xsl:template match="text()" mode="copyTxt">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copyTxt"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="@*|node()">
			<xsl:apply-templates select="@*|node()"/>
	</xsl:template>

</xsl:stylesheet>
