<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="ctx.dev"/>
	<xsl:param name="ctx.mode"/>
	<xsl:param name="ctx.svMakeName"/>
	<xsl:template match="transform[last()]">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
		<transform code="json2xml" type="eu.scenari.transform.json.TfmJson2Xml"/>
        <transform code="acapelaTTS" type="eu.scenari.editadapt.tts.acapela.TfmAcapelaTTS">
            <property key="enable" value="§§enable.electre.api§§"/>
            <property key="url" value="§§acapela.url§§"/>
            <property key="user" value="§§acapela.user§§"/>
            <property key="password" value="§§acapela.password§§"/>
        </transform>
	</xsl:template>
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>