<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:sp="http://www.utc.fr/ics/scenari/v3/primitive"
								xmlns:sc="http://www.utc.fr/ics/scenari/v3/core"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
								xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
								extension-element-prefixes="redirect"
								exclude-result-prefixes="xalan java sc sp" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="editadapt.fr:paon ">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<!-- post XSL de normalisation du texte -->
	<xsl:template match="text()">
		<xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.normalizeString(., false())"/>
	</xsl:template>
	<xsl:template match="text()" mode="uppercase">
		<xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.normalizeString(., true())"/>
	</xsl:template>

	<xsl:template match="span[@class='smallcaps']">
		<xsl:apply-templates select="node()" mode="uppercase"/>
	</xsl:template>

	<xsl:template match="@*|*|comment()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|*|comment()" mode="uppercase">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="uppercase"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
