<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:java="http://xml.apache.org/xslt/java"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xalan java xhtml">

    <xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="vDialog"/>
    <xsl:param name="vAgent"/>

    <xsl:param name="main_html_file"/>
    <xsl:param name="view_path"/>
    <xsl:param name="package"/>

    <xsl:param name="dPfx"/>
    <xsl:param name="pPfx"/>
    <xsl:param name="sPfx"/>

    <xsl:variable name="html" select="document(concat('inDir:./', $main_html_file))/xhtml:html"/>
    <xsl:variable name="div" select="$html/xhtml:body/descendant::xhtml:div[@id=concat($dPfx, '_', $package)]"/>
    <xsl:variable name="sentences" select="$div/descendant::xhtml:span[containWord(@class, 'sentence')]"/>
    <xsl:variable name="audio_file" select="concat($package, '.mp3')"/>
    <!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
    <xsl:variable name="total_time" select="returnFirst(/o/a/o[last()-1]/o[@k='Time']/n/text(), /o/a/o[last()-1]/s[@k='Time']/text())"/>
    <xsl:variable name="durations" select="java:getVar($vDialog, 'durations')"/>
    <xsl:variable name="previous-audio" select="count($div/preceding::xhtml:div[not(containWord(@class, 'note')) and @id]) + count($div/ancestor::xhtml:div[not(@class='note') and @id])"/>



    <xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>


    <xsl:template match="meta[@name='ncc:totalElapsedTime']">
        <meta name="ncc:totalElapsedTime" content="{java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $previous-audio, $format-audio-duration)}"/>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
