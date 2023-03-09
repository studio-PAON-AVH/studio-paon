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
		<service code="electre" class="eu.scenari.editadapt.electre.SvcElectre">
      <property name="enable" value="§§enable.electre.api§§"/>
			<property name="tokenUrl" value="§§electre.token.url§§"/>
			<property name="noticeUrl" value="§§electre.notice.url§§"/>
			<property name="user" value="§§electre.user§§"/>
			<property name="password" value="§§electre.password§§"/>
		</service>
	</xsl:template>

	<xsl:template match="storeSteps">
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
		<nextTask svcCode="electre"/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
