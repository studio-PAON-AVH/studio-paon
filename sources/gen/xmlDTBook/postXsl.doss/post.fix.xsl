<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes=" dtb ">

    <!--Output the dtbook with doctype-->
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no"
        doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd"
        doctype-public="-//NISO//DTD dtbook 2005-3//EN"/>

    <!-- Par défaut on copie tout-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- correction des niveaux sans paragraphe -->
    <xsl:template match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:if test="not(./dtb:p)">
                <p xmlns="http://www.daisy.org/z3986/2005/dtbook/"/>
                <!--<xsl:text disable-output-escaping="yes">&lt;p/&gt;</xsl:text>-->
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>