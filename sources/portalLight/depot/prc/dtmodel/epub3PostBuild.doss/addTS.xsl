<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="dPfx"/>
	<xsl:param name="pPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="vars" select="java:java.util.HashMap.new()"/>


	<xsl:template match="xhtml:section[@id]">
		<xsl:variable name="package_id" select="substring(@id,string-length($dPfx)+1)"/>
		<xsl:variable name="xon" select="document(concat('inDir:',$package_id, '.acapela.tts.zip/events.xon'))"/>
		<xsl:value-of select="execute(java:put($vars, 'xon_sentences', $xon/o/a/o[s[@k='EventKind' and text()='Sentence']][s[@k='Sentence' and string-length(text()) > 0 and  not(starts-with(text(),'\pau='))]]))"/>
		<xsl:value-of select="execute(java:put($vars, 'total_time', returnFirst($xon/o/a/o[last()-1]/o[@k='Time']/n/text(), $xon/o/a/o[last()-1]/s[@k='Time']/text()) ))"/>
		<xsl:value-of select="execute(java:put($vars, 'section', .))"/>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:span[@class='sentence']">
		<xsl:variable name="xon_sentences" select="java:get($vars, 'xon_sentences')"/>
		<xsl:variable name="xhtml_sentences" select="java:get($vars, 'section')/descendant::xhtml:span[@class='sentence']"/>
		<xsl:variable name="total_time" select="java:get($vars, 'total_time')"/>
		<xsl:variable name="id" select="@id"/>
		<xsl:variable name="pos" select="java:eu.scenari.editadapt.utils.Utils.sentencesIndex($xhtml_sentences, @id)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="clipBegin"><xsl:value-of select="returnFirst($xon_sentences[$pos]/o[@k='Time']/n/text(), $xon_sentences[$pos]/s[@k='Time']/text())"/></xsl:attribute>
			<xsl:attribute name="clipEnd"><xsl:choose>
				<xsl:when test="$xon_sentences[$pos+1]"><xsl:value-of select="returnFirst($xon_sentences[$pos+1]/o[@k='Time']/n/text(), $xon_sentences[$pos+1]/s[@k='Time']/text())"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$total_time"/></xsl:otherwise>
			</xsl:choose></xsl:attribute>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
