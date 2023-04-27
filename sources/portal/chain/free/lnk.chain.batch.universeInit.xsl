<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="vDialog"/>
    <xsl:param name="vAgent"/>
    <xsl:param name="ctx.dev"/>
    <xsl:param name="ctx.mode"/>
    <xsl:param name="ctx.svMakeName"/>

    <xsl:template match="taskDef[last()]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <taskDef localName="updateImportMeta" className="eu.scenari.editadapt.chain2import.UpdateImportMetaTask" />
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>