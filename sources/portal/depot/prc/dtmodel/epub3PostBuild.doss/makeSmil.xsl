<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns="http://www.w3.org/ns/SMIL"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsm="http://www.w3.org/1999/XSL/Transform"
								xmlns:epub="http://www.idpf.org/2007/ops"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
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
		<smil version="3.0">
			<body>
			<!-- dur="{java:eu.scenari.editadapt.utils.Utils.formatDuration($durations, $previous-audio, $format-audio-duration)}" -->
				<seq epub:textref="{$package_id}.xhtml#{@id}"  id="{@id}">
					<xsl:apply-templates select="@epub:type"/>
					<xsl:apply-templates select="*" mode="smil"/>
				</seq>
			</body>
		</smil>
		<!-- iterator++ -->
		<xsl:value-of select="java:setVar($vDialog, 'iterator', java:getVar($vDialog, 'iterator')+1)"/>
		<!-- -->
	</xsl:template>

	<xsl:template match="*[@id]" mode="smil">
		<seq epub:textref="{$package_id}.xhtml#{@id}"  id="{@id}">
			<xsl:apply-templates select="@epub:type"/>
			<xsl:apply-templates select="*" mode="smil"/>
		</seq>
	</xsl:template>

	<xsl:template match="xhtml:span[@class='sentence']" mode="smil">
		<par id="{@id}">
				<text id="text_{@id}" src="{$package_id}.xhtml#{@id}"/>
				<audio clipBegin="{@clipBegin}" clipEnd="{@clipEnd}" id="audio_{@id}" src="{$package_id}.mp3"/>
		</par>
	</xsl:template>

	<xsl:template match="text()" mode="smil"/>

	<xsl:template match="xhtml:section[@id]" mode="smil"/>

	<xsl:template match="epub:type">
		<xsl:copy/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>
</xsl:stylesheet>
