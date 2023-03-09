<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:java="http://xml.apache.org/xslt/java"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                extension-element-prefixes="redirect"
                exclude-result-prefixes="xalan java xhtml">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="xhtml1-transitional.dtd"/>
    <xsl:param name="vDialog"/>
    <xsl:param name="vAgent"/>

    <!-- Nombre de phrases par page -->
    <xsl:variable name="sPerPage" select="17"/>

    <xsl:template match="xhtml:div[@cat]">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="xhtml:span">
        <xsl:variable name="prec" select="count(preceding-sibling::xhtml:span)"/>
        <xsl:if test="($prec mod $sPerPage = 0 and $prec != 0) or @title">
            <xsl:copy><xsl:apply-templates select="@*|node()" mode="spanCopy"/></xsl:copy><xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
    </xsl:template>

    <xsl:template match="@title" mode="spanCopy"/>

    <xsl:template match="@*|node()" mode="spanCopy">
        <xsl:copy><xsl:apply-templates select="@*|node()" mode="spanCopy"/></xsl:copy>
    </xsl:template>
</xsl:stylesheet>