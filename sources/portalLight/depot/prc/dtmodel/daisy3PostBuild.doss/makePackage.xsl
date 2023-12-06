<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns="http://openebook.org/namespaces/oeb-package/1.0/"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:dc="http://purl.org/dc/elements/1.1/"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								exclude-result-prefixes="xalan java dtb">

	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes" doctype-public="+//ISBN 0-9673008-1-9//DTD OEB 1.2 Package//EN" doctype-system="http://openebook.org/dtds/oeb-1.2/oebpkg12.dtd"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="dPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>
	<xsl:variable name="durations" select="java:java.util.LinkedList.new()"/>

	

	<xsl:template match="/">
		<!-- On stocke dans une liste java les durées de tous les modules -->
		<xsl:for-each select="(descendant::dtb:frontmatter[@id]|descendant::dtb:level1[@id]|descendant::dtb:level2[@id]|descendant::dtb:level3[@id]|descendant::dtb:level4[@id]|descendant::dtb:level5[@id]|descendant::dtb:level6[@id])">
				<xsl:variable name="package_id" select="substring(@id,string-length($dPfx)+1)"/>
				<xsl:variable name="xon" select="document(concat('inDir:',$package_id, '.acapela.tts.zip/events.xon'))"/>
				<xsl:choose>
					<xsl:when test="$xon/fileNotFound"><xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse('PT0s')))"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse(concat('PT',$xon/o/a/o[last()-1]/s[@k='Time']/text(),'s'))))"/></xsl:otherwise>
				</xsl:choose>
		</xsl:for-each>
		<!-- On stocke la liste des durée dans le dialog courrant -->
		<xsl:value-of select="java:setVar($vDialog, 'durations', $durations)"/>
		<!-- init d'un iterateur pour retrouver les durée dans la créationd es SMIL -->
		<xsl:value-of select="java:setVar($vDialog, 'iterator', 0)"/>


		<package unique-identifier="uid">
			<metadata>
				<dc-metadata>
					<xsl:apply-templates select="descendant::dtb:head/dtb:meta[starts-with(@name, 'dc')]" mode="dcMeta"/>
				</dc-metadata>
				<x-metadata>
					<xsl:apply-templates select="descendant::dtb:head/dtb:meta[not(starts-with(@name, 'dc'))]"/>
					<meta name="dtb:totalTime" content="{java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $format-audio-duration)}"/>
				</x-metadata>
			</metadata>
			<manifest>
				<item href="navigation.ncx" id="ncx" media-type="application/x-dtbncx+xml" />
				<item href="dtbook.xml" id="dtb" media-type="application/x-dtbook+xml" />
				<item href="package.opf" id="opf" media-type="text/xml" />
				<xsl:apply-templates select="descendant::dtb:frontmatter[@id]|descendant::dtb:level1[@id]|descendant::dtb:level2[@id]|descendant::dtb:level3[@id]|descendant::dtb:level4[@id]|descendant::dtb:level5[@id]|descendant::dtb:level6[@id]"/>
			</manifest>
			<spine>
				<xsl:apply-templates select="descendant::dtb:frontmatter[@id]|descendant::dtb:level1[@id]|descendant::dtb:level2[@id]|descendant::dtb:level3[@id]|descendant::dtb:level4[@id]|descendant::dtb:level5[@id]|descendant::dtb:level6[@id]" mode="spine"/>
			</spine>
		</package>
	</xsl:template>

	<xsl:template match="dtb:frontmatter[@id]|dtb:level1[@id]|dtb:level2[@id]|dtb:level3[@id]|dtb:level4[@id]|dtb:level5[@id]|dtb:level6[@id]	">
		<xsl:variable name="smilId" select="substring(@id,string-length($dPfx)+1)"/>
		<item href="{$smilId}.smil" id="opf_{@id}" media-type="application/smil"/>
		<item href="{$smilId}.mp3" id="opf_{@id}_aud" media-type="audio/mpeg"/>
	</xsl:template>

	<xsl:template match="dtb:frontmatter[@id]|dtb:level1[@id]|dtb:level2[@id]|dtb:level3[@id]|dtb:level4[@id]|dtb:level5[@id]|dtb:level6[@id]	" mode="spine">
		<itemref idref="opf_{@id}"/>
	</xsl:template>

	<xsl:template match="dtb:meta" mode="dcMeta">
		<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="@name"/><xsl:if test="@name='dc:Identifier'"><xsl:text> id="uid"</xsl:text></xsl:if><xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="@content"/><xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
	</xsl:template>

	<xsl:template match="dtb:meta">
		<meta>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</meta>
	</xsl:template>

	<xsl:template match="@*|node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
