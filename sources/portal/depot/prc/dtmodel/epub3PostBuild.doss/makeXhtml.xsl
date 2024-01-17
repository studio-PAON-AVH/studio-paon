<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsm="http://www.w3.org/1999/XSL/Transform"
								xmlns:epub="http://www.idpf.org/2007/ops"
								xmlns="http://www.w3.org/1999/xhtml"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="package_id"/>

	<xsl:param name="dPfx"/>
	<xsl:param name="pPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:template match="*[@id=concat($dPfx,$package_id)]">
		<html>
			<head>
				<meta charset="UTF-8"/>
				<title><xsl:value-of select="normalize-space(child::*[1])"/></title>
			</head>
			<body>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" mode="xhtml"/>
				</xsl:copy>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="@*|node()" mode="xhtml">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="xhtml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@cmd" />
	<xsl:template match="@cmd" mode="xhtml" />

	<xsl:template match="@clipBegin|@clipEnd" mode="xhtml"/>
	<xsl:template match="xhtml:section[@id]" mode="xhtml"/>

	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>
</xsl:stylesheet>
