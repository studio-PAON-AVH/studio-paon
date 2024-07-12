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

		<!-- la durée du smil n'est pas la durée des fichiers mp3, mais le total des durées des séquences-->
		<xsl:variable name="smilsDurations">
			<xsl:for-each select="descendant::xhtml:div[@id and not(containWord(@class, 'note'))]">
				<xsl:variable name="package_id" select="substring(@id,string-length($dPfx)+2)"/>
				<xsl:variable name="package" select="document(concat('inDir:./',$package_id, '.tmp.smil'))"/>
				<temps>
					<xsl:attribute name="value">
						<xsl:choose>
							<xsl:when test="$package/fileNotFound">
								<xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse('PT0s')))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="execute(java:add($durations, java:java.time.Duration.parse(concat('PT',number(substring-before($package/smil/body/seq[@dur]/@dur,'s')),'s'))))"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</temps>
			</xsl:for-each>
		</xsl:variable>
		<!-- On stocke la liste des durées dans le dialog courrant -->
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
		<xsl:variable name="smilId" select="substring(parent::xhtml:div/@id,string-length($dPfx)+2)" />
		<xsl:variable name="parId" select="substring(xhtml:span/@id,string-length($sPfx)+1)"/>
		<ref title="{xhtml:span/text()}" src="{$smilId}.smil#par{$parId}" id="smil_{$smilId}"/>
	</xsl:template>
</xsl:stylesheet>
