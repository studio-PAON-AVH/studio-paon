<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:java="http://xml.apache.org/xslt/java"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xalan java">

    <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="vDialog"/>
    <xsl:param name="vAgent"/>
    <xsl:param name="path"/>

   <xsl:template match="o[s[@k='EventKind' and text()='Sentence'] and string-length(s[@k='Sentence']/text()) > 0]"><xsl:value-of select="s[@k='Sentence']/text()"/><xsl:text>
</xsl:text></xsl:template>

    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>
</xsl:stylesheet>
