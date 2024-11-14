<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sp="http://www.utc.fr/ics/scenari/v3/primitive"
								xmlns:sc="http://www.utc.fr/ics/scenari/v3/core"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
								xmlns:opf="http://www.idpf.org/2007/opf"
								xmlns:dc="http://purl.org/dc/elements/1.1/"
								xmlns:dcterms="http://purl.org/dc/terms/"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								xmlns:epub="http://www.idpf.org/2007/ops"
								xmlns:paon="editadapt.fr:paon"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								version="1.0" xmlns:xsm="http://www.w3.org/1999/XSL/Transform"
								extension-element-prefixes="redirect" exclude-result-prefixes="xalan java sc sp" xsi:schemaLocation="editadapt.fr:paon ">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsm:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="content">
		<xsl:variable name="structuredNodeSet" select="splitNodeSet(*, array('self::xhtml:h1', 'self::xhtml:h2', 'self::xhtml:h3', 'self::xhtml:h4', 'self::xhtml:h5', 'self::xhtml:h6'), '', 'firstMatchLevelAndUppers')"/>
		<flow>
			<xsl:apply-templates select="$structuredNodeSet" mode="flow"/>
		</flow>
		<xsl:apply-templates select="$structuredNodeSet"/>
	</xsl:template>

		<xsl:template match="xhtml:*"/>

	<xsl:template match="@*|node()" mode="flow">
		<xsl:copy>
			<xsm:apply-templates select="@*|node()" mode="flow"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="subLevel">
		<level>
			<xsl:apply-templates select="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6" mode="title"/>
				<flow>
					<xsl:apply-templates mode="flow"/>
				</flow>
				<xsl:apply-templates/>
		</level>
	</xsl:template>

	<xsl:template match="subLevel" mode="flow"/>

	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6" mode="title">
		<sp:title><xsl:apply-templates/></sp:title>
	</xsl:template>

	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6" mode="flow"/>

</xsl:stylesheet>
