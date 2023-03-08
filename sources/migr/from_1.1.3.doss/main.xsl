<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:java="http://xml.apache.org/xslt/java"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:sp="http://www.utc.fr/ics/scenari/v3/primitive"
                extension-element-prefixes="redirect"
                exclude-result-prefixes="xalan java xhtml">

    <xsl:template match="@*|node()" >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <!-- la fonction matches est une fonction XSLT 2, abandon de la migration pour le moment -->
   <!-- <xsl:template match="sp:publishingYear">
        <sp:publishingYear>
            <xsl:choose>
                <xsl:when test="matches(normalize-space(text()),'^[\n\s]*\d\d\d\d[\n\s]*$')">
                    <xsl:apply-templates select="@*" />
                    <xsl:value-of select="normalize-space(text())" />
                </xsl:when>
                <xsl:otherwise>
                    <sp:error>
                        <xsl:value-of select="text()" />
                        <xsl:text> n'est pas une année au format YYYY</xsl:text>
                    </sp:error>
                </xsl:otherwise>
            </xsl:choose>
        </sp:publishingYear>
    </xsl:template>-->

</xsl:stylesheet>