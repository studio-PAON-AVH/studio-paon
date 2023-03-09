<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsm="http://www.w3.org/1999/XSL/Transform"
								exclude-result-prefixes="xhtml">

	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="ncc_file"/>

	<xsl:variable name="ncc" select="document(concat('inDir:', $ncc_file))/xhtml:html"/>

	<xsl:template match="par">
		<xsl:variable name="parId" select="@id"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="$ncc/descendant::xhtml:span/xhtml:a[substring-after(@href, '#') = $parId]">
				<xsl:attribute name="system-required">pagenumber-on</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsm:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
