<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:java="http://xml.apache.org/xslt/java"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
                office:version="1.3" xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:css3t="http://www.w3.org/TR/css3-text/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:drawooo="http://openoffice.org/2010/draw" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:officeooo="http://openoffice.org/2009/office" xmlns:ooo="http://openoffice.org/2004/office" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:rpt="http://openoffice.org/2005/report" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                extension-element-prefixes="redirect"
                exclude-result-prefixes="xalan java xhtml">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="vDialog"/>
    <xsl:param name="vAgent"/>
    <xsl:variable name="seperators" select="'  ,.'"/>

    <!-- Déplacement des notes situé just avant une ou plusieurs ponctuations fermantes-->
    <xsl:template match="text:p[text:note]">
        <!-- Sérialisation du contenu (avec encadrement des notes par un ☂)
        (la conversion en String de la variable ne semble renvoyer que les noeuds text()) -->
        <xsl:variable name="txt"><xsl:apply-templates mode="serialize"/></xsl:variable>
        <xsl:copy>
            <!-- Recopie du paragraphe et de ses attributs -->
            <xsl:apply-templates select="@*"/>
            <!-- Désérialisation du contenu post-traité
                Note : le moveNote prenant en entré un texte en string,
                il risque d'y avoir un problème avec les entités par la suite, notamment
                les < et > dans du texte
                 Il faudrait que pour la suite nuite, le moveNote prenne en entrée et retourne des noeuds XML
                En attendant, j'ai fait un template de déserialization pour que seul les balises soit déséchappés
                en considérant qu'une balise est forcément un < qui n'est pas suivi d'un espace-->
            <xsl:call-template name="un-serialize">
                <xsl:with-param name="text" select="java:eu.scenari.editadapt.utils.Utils.moveNote($txt)" />
            </xsl:call-template>
            <!--<xsl:value-of select="$noteMoved" />-->
        </xsl:copy>
    </xsl:template>


    <xsl:template match="@*|*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <!-- enlève les balises "espaces" et les remplaces par un simple espace -->
    <xsl:template match="text:s" mode="serialize">
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Serialisation du contenu
       Pour les notes, un caractère encadrant ☂ est ajouté autour de la balise
       pour simplifier le déplacement après ponctuation en post traitement.
       les < et > sont remplacés respectivement par ￼ et � pour encodés les balises
       et faciliter la désérialization de texte contenant des chevrons.
       -->
    <xsl:template match="*" mode="serialize">
        <xsl:choose>
            <xsl:when test="name() = 'text:note'">
                <xsl:text>☂</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:text>￼</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:apply-templates select="@*" mode="serialize" />
        <xsl:choose>
            <xsl:when test="node()">
                <xsl:text>�</xsl:text>
                <xsl:apply-templates mode="serialize" />
                <xsl:text>￼/</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>�</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> /�</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="name() = 'text:note'">
                <xsl:text>☂</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@*" mode="serialize">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="text()" mode="serialize">
        <xsl:value-of disable-output-escaping="yes" select="." />
    </xsl:template>

    <!-- Template de désérialization de contenu sérializé avec le template précédent -->
    <xsl:template name="un-serialize">
        <xsl:param name="text" />
        <xsl:choose>
            <xsl:when test="$text = ''" >
                <!-- Prevent this routine from hanging -->
                <xsl:value-of select="$text" />
            </xsl:when>
            <!-- Si le texte contient un symbole '￼' balise ouvrante-->
            <xsl:when test="contains($text, '￼')">
                <!-- On copie le contenu avant le symbole d'ouverture-->
                <xsl:value-of select="substring-before($text,'￼')" />
                <!-- Recréation du < d'ouverture de balise -->
                <xsl:value-of
                        disable-output-escaping="yes"
                        select="'&lt;'" />
                <!-- copie du contenu de la balise -->
                <xsl:value-of select="substring-before(substring-after($text,'￼'), '�')" />
                <!-- fermeture de la balise -->
                <xsl:value-of
                        disable-output-escaping="yes"
                        select="'&gt;'" />
                <!-- on continue sur le reste du contenu textuel après la balise -->
                <xsl:call-template name="un-serialize">
                    <xsl:with-param name="text" select="substring-after($text,'�')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- le texte ne contient pas de symbole de balisage, on le copie tel quel-->
                <xsl:value-of select="$text" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
