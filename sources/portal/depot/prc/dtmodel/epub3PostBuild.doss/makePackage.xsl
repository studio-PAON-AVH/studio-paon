<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:opf="http://www.idpf.org/2007/opf"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:dc="http://purl.org/dc/elements/1.1/"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:dcterms="http://purl.org/dc/terms/"
								exclude-result-prefixes="xalan java xhtml opf">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="dPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>
	<xsl:variable name="durations" select="java:java.util.LinkedList.new()"/>

	

	<xsl:template match="/">
		<opf:package unique-identifier="{/xhtml:html/xhtml:head/xhtml:meta[@name='dc:identifier']/@content}" version="3.0">
			<opf:metadata>
				<xsl:apply-templates select="/xhtml:html/xhtml:head/xhtml:meta[starts-with(@name, 'dc')]" mode="dcMeta"/>
				<xsl:apply-templates select="/xhtml:html/xhtml:head/xhtml:meta[not(starts-with(@name, 'dc'))]"/>
				<!-- On stocke dans une liste java les durées de tous les modules -->
				<xsl:for-each select="descendant::xhtml:section[@id]">
					<xsl:variable name="package_id" select="substring(@id,string-length($dPfx)+1)"/>
					<xsl:variable name="xon" select="document(concat('inDir:',$package_id, '.acapela.tts.zip/events.xon'))"/>
					<xsl:choose>
						<xsl:when test="$xon/fileNotFound"><xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse('PT0s')))"/></xsl:when>
						<xsl:otherwise>
							<xsl:variable name="duration" select="concat('PT',$xon/o/a/o[last()-1]/s[@k='Time']/text(),'s')"/>
							<xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse($duration)))"/>
							<opf:meta property="media:duration" refines="#opf_{@id}_smil"><xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.formatDuration($durations, java:size($durations)-1,  $format-audio-duration)"/></opf:meta>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>

				<!-- On stocke la liste des durée dans le dialog courrant -->
				<xsl:value-of select="java:setVar($vDialog, 'durations', $durations)"/>
				<!-- init d'un iterateur pour retrouver les durée dans la créationd es SMIL -->
				<xsl:value-of select="java:setVar($vDialog, 'iterator', 0)"/>

				<opf:meta property="media:duration"><xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $format-audio-duration)"/></opf:meta>
				<opf:meta property="dcterms:modified"><xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.isoDate()"/></opf:meta>
			</opf:metadata>
			<opf:manifest>
				<opf:item href="nav.xhtml" id="nav" media-type="application/xhtml+xml" properties="nav"/>
				<xsl:apply-templates select="descendant::xhtml:section[@id]"/>
			</opf:manifest>
			<opf:spine>
				<xsl:apply-templates select="descendant::xhtml:section[@id]" mode="spine"/>
			</opf:spine>
		</opf:package>
	</xsl:template>

	<xsl:template match="xhtml:section[@id]">
		<xsl:variable name="sectionId" select="substring(@id,string-length($dPfx)+1)"/>
		<opf:item href="{$sectionId}.xhtml" id="opf_{@id}_xhtml" media-overlay="opf_{@id}_smil" media-type="application/xhtml+xml"/>
		<opf:item href="{$sectionId}.smil" id="opf_{@id}_smil" media-type="application/smil+xml"/>
		<opf:item href="{$sectionId}.mp3" id="opf_{@id}_aud" media-type="audio/mpeg"/>
	</xsl:template>

	<xsl:template match="xhtml:section[@id]" mode="spine">
		<opf:itemref id="opf_{@id}_spine" idref="opf_{@id}_xhtml"/>
	</xsl:template>

	<xsl:template match="xhtml:meta" mode="dcMeta">
		<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="@name"/><xsl:if test="@name='dc:Identifier'"><xsl:text> id="uid"</xsl:text></xsl:if><xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="@content"/><xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="@name"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
	</xsl:template>

	<xsl:template match="xhtml:meta[@charset]"/>
	<xsl:template match="xhtml:meta">
		<opf:meta>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</opf:meta>
	</xsl:template>

	<xsl:template match="@*|node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
