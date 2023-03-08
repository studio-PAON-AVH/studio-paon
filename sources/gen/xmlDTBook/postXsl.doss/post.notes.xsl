<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="dtb">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:apply-templates select="node()" mode="notes"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6" mode="notes"/>

	<xsl:template match="dtb:note"><sup><noteref><xsl:attribute name="idref">#<xsl:value-of select="@id"/></xsl:attribute>note <xsl:value-of select="count(preceding::dtb:note)+1"/></noteref></sup></xsl:template>

	<xsl:template match="@*|node()" mode="notes">
		<xsl:apply-templates select="@*|node()" mode="notes"/>
	</xsl:template>

	<xsl:template match="dtb:note" mode="notes">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
