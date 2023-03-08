<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/" xmlns:xal="http://www.w3.org/1999/XSL/Transform"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java dtb">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="dPfx"/>
	<xsl:param name="pPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="vars" select="java:java.util.HashMap.new()"/>


	<xsl:template match="dtb:frontmatter|dtb:level1[@id]|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6">
		<xsl:variable name="package_id" select="substring(@id,string-length($dPfx)+1)"/>
		<xsl:variable name="xon" select="document(concat('inDir:',$package_id, '.acapela.tts.zip/events.xon'))"/>
		<xsl:value-of select="execute(java:put($vars, 'xon_sentences', $xon/o/a/o[s[@k='EventKind' and text()='Sentence']][s[@k='Sentence' and string-length(text()) > 0 and  not(starts-with(text(),'\pau='))]]))"/>
		<!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
		<xsl:value-of select="execute(java:put($vars, 'total_time', returnFirst($xon/o/a/o[last()-1]/o[@k='Time']/n/text(), $xon/o/a/o[last()-1]/s[@k='Time']/text()) ))"/>
		<xsl:value-of select="execute(java:put($vars, 'div', .))"/>
		<xsl:copy>
			<xal:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dtb:span[@class='sentence']">
		<xsl:variable name="xon_sentences" select="java:get($vars, 'xon_sentences')"/>
		<xsl:variable name="dtb_sentences" select="java:get($vars, 'div')/descendant::dtb:span[@class='sentence']"/>
		<xsl:variable name="total_time" select="java:get($vars, 'total_time')"/>
		<xsl:variable name="id" select="@id"/>
		<xsl:variable name="pos" select="java:eu.scenari.editadapt.utils.Utils.sentencesIndex($dtb_sentences, @id)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
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
