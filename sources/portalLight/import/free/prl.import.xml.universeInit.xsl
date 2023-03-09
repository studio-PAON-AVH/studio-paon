<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="ctx.dev"/>
	<xsl:param name="ctx.mode"/>
	<xsl:param name="ctx.svMakeName"/>

	<xsl:template match="service[@code='store']">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<service code="chainImport" type="eu.scenari.editadapt.import2chain.SvcImport2ChainLoader">
			<defaultWspType>
				<wspType version="1.2.0" key="paoncommons" lang="fr-FR" title="Paon 1" uri="paoncommons_fr-FR_1-2-0"/>
			</defaultWspType>
		</service>
	</xsl:template>

	<xsl:template match="nextTask[not(following-sibling::nextTask)]">
		<xsl:copy><xsl:apply-templates select="@*"/></xsl:copy>
		<nextTask svcCode="chainImport"/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
