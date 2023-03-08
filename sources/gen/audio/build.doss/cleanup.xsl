<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
				xmlns:xalan="http://xml.apache.org/xalan"
				xmlns:java="http://xml.apache.org/xslt/java"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
				xmlns:xhtml="http://www.w3.org/1999/xhtml"
				xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
				extension-element-prefixes="redirect"
				exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:variable name="mode" select="//xhtml:note-processing/@class"/>

	<!-- Suppression des div (package audio) qui n'ont pas réellement de plein texte -->
	<xsl:template match="xhtml:div[@id and java:eu.scenari.editadapt.utils.Utils.isEmptyStr(normalize-space()) != 'false']"/>

	<xsl:template match="dtb:*[starts-with(local-name(), 'level')][@id and java:eu.scenari.editadapt.utils.Utils.isEmptyStr(normalize-space()) != 'false']"/>

	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6|xhtml:p|dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6|dtb:p|dtb:line">
		<xsl:if test="java:eu.scenari.editadapt.utils.Utils.isEmptyStr(normalize-space()) != 'true'">
			<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
	</xsl:template>
</xsl:stylesheet>
