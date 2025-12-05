<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pa="http://avh.asso.fr/paon/alternatives"
    exclude-result-prefixes=" dtb ">

    <!--Output the dtbook with doctype
    doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd"
        doctype-public="-//NISO//DTD dtbook 2005-3//EN"
    -->
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="no"/>
    <!-- NP 2025 12 04 : extension de format pour conserver les alternatives dans le texte -->
    <xsl:template match="dtb:dtbook">
        <xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE dtbook PUBLIC "-//NISO//DTD dtbook 2005-3//EN" "http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd" [
    &lt;!ENTITY % externalNamespaces "xmlns:pa CDATA #FIXED 'http://avh.asso.fr/paon/alternatives'"&gt;
    &lt;!ATTLIST span
        xmlns:pa        CDATA               #FIXED 'http://avh.asso.fr/paon/alternatives'
        pa:altphonemes  CDATA               #IMPLIED
        pa:alttext      CDATA               #IMPLIED
        pa:altbrl       CDATA               #IMPLIED
        pa:protecbrl    (yes|no)            #IMPLIED
        id              ID                  #IMPLIED
        class           CDATA               #IMPLIED
        title           CDATA               #IMPLIED
        xml:space 	    (default|preserve) 	#IMPLIED
        smilref         CDATA               #IMPLIED
        xml:lang        NMTOKEN             #IMPLIED
        dir             (ltr|rtl)           #IMPLIED
    &gt;
] &gt;
</xsl:text>
    <dtbook xmlns="http://www.daisy.org/z3986/2005/dtbook/" xmlns:pa="http://avh.asso.fr/paon/alternatives" >
        <xsl:apply-templates select="@*|node()"/>
    </dtbook>
    </xsl:template>

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