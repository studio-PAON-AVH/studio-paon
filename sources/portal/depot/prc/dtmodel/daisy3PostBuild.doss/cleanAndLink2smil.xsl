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

	<xsl:template match="@clipBegin"/>
	<xsl:template match="@clipEnd"/>

	<xsl:template match="*[@id]">
		<xsl:variable name="smilId"><xsl:apply-templates select="." mode="id"/>.smil</xsl:variable>

		<xsl:copy>
			<xsl:attribute name="smilref"><xsl:value-of select="$smilId"/>#<xsl:value-of select="@id"/></xsl:attribute>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*" mode="id">
  		<xsl:apply-templates select="parent::*" mode="id"/>
  	</xsl:template>

	<xsl:template match="dtb:frontmatter[@id]|dtb:level1[@id]|dtb:level2[@id]|dtb:level3[@id]|dtb:level4[@id]|dtb:level5[@id]|dtb:level6[@id]" mode="id"><xsl:value-of select="substring(@id,string-length($dPfx)+1)"/></xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
