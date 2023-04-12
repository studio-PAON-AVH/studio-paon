<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="ctx.dev"/>
	<xsl:param name="ctx.mode"/>
	<xsl:param name="ctx.svMakeName"/>

	<xsl:template match="esObjectMaker[ancestor::selector/preceding-sibling::persistentMetaAllowed[@regexp='dtmodel']]">
		<xsl:copy>
			<xsl:attribute name="type">eu.scenari.editadapt.index.RawEOM</xsl:attribute>
			<xsl:attribute name="rawTxtView">duration</xsl:attribute>
			<xsl:attribute name="esField">duration</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
