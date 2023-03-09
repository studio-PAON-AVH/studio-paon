<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
            xmlns:xalan="http://xml.apache.org/xalan"
            xmlns:java="http://xml.apache.org/xslt/java"
            xmlns:xhtml="http://www.w3.org/1999/xhtml"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            exclude-result-prefixes="xalan java">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
    <xsl:param name="vDialog"/>
    <xsl:param name="vAgent"/>
    <xsl:param name="path"/>


    <xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d'"/>
    <xsl:variable name="durations" select="java:getVar($vDialog, 'durations')"/>

    <xsl:template match="xhtml:meta[@name='ncc:totalTime']">
        <xsl:copy>
            <xsl:apply-templates select="@name|@scheme"/>
            <xsl:attribute name="content"><xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $format-audio-duration)"/></xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
    </xsl:template>

</xsl:stylesheet>
