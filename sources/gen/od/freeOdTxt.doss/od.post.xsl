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
	<xsl:variable name="publishNotesEnd" select="/descendant::text:p[@text:style-name='publishNotes']/text()='end'"/>

	<!-- Normalisation du flux text-->
	<xsl:template match="text()"><xsl:value-of select="java:eu.scenari.editadapt.utils.Utils.postOdTxt(.)"/></xsl:template>

	<!-- Gestion des notes -->
	<!-- supp param -->
	<xsl:template match="text:p[@text:style-name='publishNotes']"/>

	<xsl:template match="text:p">
		<xsl:variable name="txt" select="normalize-space(.)"/>
		<xsl:choose>
			<xsl:when test="$txt='  ' or $txt='   '"/>
			<xsl:otherwise>
					<xsl:copy>
						<xsl:apply-templates select="@*|node()"/>
					</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="text:note">
		<xsl:variable name="prevPara" select="preceding-sibling::text()[1]"/>
		<xsl:variable name="prevLastChar" select="substring($prevPara, string-length($prevPara))"/>
		<xsl:variable name="follFirstChar" select="substring(following-sibling::text(), 1, 1)"/>
		<xsl:if test="not($prevLastChar = ' ' or $prevLastChar = ' ' or $prevLastChar = '')"><xsl:text> </xsl:text></xsl:if>
		<xsl:text>[[*ind5*]][[*tab7*]]Note </xsl:text><xsl:choose>
			<xsl:when test="$publishNotesEnd"><xsl:value-of select="text:note-citation/text()"/></xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="text:note-body/descendant::text:p"><xsl:apply-templates/><xsl:if test="following-sibling::text:p"><xsl:text> </xsl:text></xsl:if></xsl:for-each>
			</xsl:otherwise>
		</xsl:choose><xsl:text>[[*ind1*]]</xsl:text>
		<xsl:if test="not(contains($seperators,$follFirstChar) or $follFirstChar = '')"><xsl:text> </xsl:text></xsl:if>
	</xsl:template>

	<xsl:template match="office:text/text:section[last()]">
		<xsl:choose>
			<xsl:when test="$publishNotesEnd">
				<!--NP 2022/12/14 : dans l'ODT produit, il n'y a pas de text:h.
					les style de titre sont aussi des <text:p> mais avec un style Titre1-->
				<text:p text:style-name="Titre1">Notes</text:p>
				<xsl:for-each select="/descendant::text:note">
					<text:p text:style-name="p"><xsl:value-of select="text:note-citation/text()"/></text:p>
					<xsl:apply-templates select="text:note-body/*"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
