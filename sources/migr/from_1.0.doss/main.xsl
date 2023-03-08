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

    <xsl:template match="sp:infosAvh" />

</xsl:stylesheet>