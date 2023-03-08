<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:sp="http://www.utc.fr/ics/scenari/v3/primitive" xmlns:sc="http://www.utc.fr/ics/scenari/v3/core" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="sc sp" xmlns:java="http://xml.apache.org/xslt/java" xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>


	<xsl:template match="ifPersistMeta[@valuePattern='xml']/persistSingleMeta[@key='sourceXMLDoctype']">
		<step type="eu.scenari.editadapt.utils.ImportLGUtilsStep"/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>