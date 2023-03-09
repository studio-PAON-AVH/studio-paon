<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="dPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="head" select="/xhtml:html/xhtml:head"/>
	<xsl:variable name="body" select="/xhtml:html/xhtml:body"/>

	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>
	<xsl:variable name="durations" select="java:java.util.LinkedList.new()"/>
	

	<xsl:template match="/">
        <!-- On stocke dans une liste java les durée de tous les modules -->
        <xsl:for-each select="descendant::xhtml:div[@id and not(containWord(@class, 'note'))]">
            <xsl:variable name="package_id" select="substring(@id,string-length($dPfx)+1)"/>
            <xsl:variable name="xon" select="document(concat('inDir:',$package_id, '.acapela.tts.zip/events.xon'))"/>
            <xsl:choose>
            	<xsl:when test="$xon/fileNotFound"><xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse('PT0s')))"/></xsl:when>
				<!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
            	<xsl:otherwise><xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse(concat('PT',returnFirst($xon/o/a/o[last()-1]/o[@k='Time']/n/text(),$xon/o/a/o[last()-1]/s[@k='Time']/text()),'s'))))"/></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!-- On stocke la liste des durée dans le dialog courrant -->
        <xsl:value-of select="java:setVar($vDialog, 'durations', $durations)"/>
		<smil>
			<head>
				<meta name="ncc:generator" content="{$head/xhtml:meta[@name='ncc:generator']/@content}"/>
				<meta name="dc:format" content="Daisy 2.02"/>
				<meta name="dc:title" content="{$head/xhtml:meta[@name='dc:title']/@content}"/>
				<meta name="dc:identifier" content="{$head/xhtml:meta[@name='dc:identifier']/@content}"/>
				<meta name="ncc:timeInThisSmil" content="{java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $format-audio-duration)}"/>
				<layout>
					<region id="txtView"/>
				</layout>
			</head>
			<body>
				<xsl:apply-templates select="$body//xhtml:h1|$body//xhtml:h2|$body//xhtml:h3|$body//xhtml:h4|$body//xhtml:h5|$body//xhtml:h6"/>
			</body>
		</smil>
	</xsl:template>

	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6">
		<xsl:variable name="smilId" select="substring(parent::xhtml:div/@id,string-length($dPfx)+1)"/>
		<xsl:variable name="parId" select="substring(xhtml:span/@id,string-length($sPfx)+1)"/>
		<ref title="{xhtml:span/text()}" src="{$smilId}.smil#par_{$parId}" id="smil_{$smilId}"/>
	</xsl:template>
</xsl:stylesheet>
