<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
								xmlns="http://www.w3.org/2001/SMIL20/"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsm="http://www.w3.org/1999/XSL/Transform"
								exclude-result-prefixes="xalan java dtb smil">

	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="package_id"/>

	<xsl:param name="dPfx"/>
	<xsl:param name="pPfx"/>
	<xsl:param name="sPfx"/>


	<xsl:variable name="durations" select="java:getVar($vDialog, 'durations')"/>
	<xsl:variable name="previous-audio" select="java:getVar($vDialog, 'iterator')"/>
	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>

	<xsl:template match="*[@id=concat($dPfx,$package_id)]">
		<smil>
			<head>
				<meta name="dtb:uid" content="{/dtb:dtbook/dtb:head/dtb:meta[@name='dtb:uid']/@content}" />
				<meta name="dtb:generator" content="{/dtb:dtbook/dtb:head/dtb:meta[@name='dtb:generator']/@content}" />
				<meta name="dtb:totalElapsedTime" content="{java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $previous-audio, $format-audio-duration)}"/>
				<customAttributes>
					<!-- TODO -->
				</customAttributes>
			</head>
			<body>
				<seq class="{local-name()}" fill="remove" id="{@id}" dur="{java:eu.scenari.editadapt.utils.Utils.formatDuration($durations, $previous-audio, $format-audio-duration)}">
					<xsl:apply-templates select="*" mode="smil"/>
				</seq>
			</body>
		</smil>
		<!-- iterator++ -->
		<xsl:value-of select="java:setVar($vDialog, 'iterator', java:getVar($vDialog, 'iterator')+1)"/>
		<!-- -->
	</xsl:template>

	<xsl:template match="*" mode="smil">
		<seq class="{local-name()}">
			<xsl:if test="@id"><xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute></xsl:if>
			<xsl:apply-templates select="*" mode="smil"/>
		</seq>
	</xsl:template>

	<xsl:template match="dtb:span[@class='sentence']" mode="smil">
		<par id="{@id}">
				<text id="text_{@id}" src="dtbook.xml#{@id}"/>
				<audio clipBegin="{@clipBegin}" clipEnd="{@clipEnd}" id="audio_{@id}" src="{$package_id}.mp3"/>
		</par>
	</xsl:template>

	<xsl:template match="dtb:frontmatter[@id]|dtb:level1[@id]|dtb:level2[@id]|dtb:level3[@id]|dtb:level4[@id]|dtb:level5[@id]|dtb:level6[@id]" mode="smil"/>

	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>
</xsl:stylesheet>
