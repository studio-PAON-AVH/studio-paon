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

	<!-- le découpage dans l'aside laisse des spans vides qu'on peut cleander -->
	<xsl:template match="xhtml:span[@class='secondaryVoice' and string-length(text())=0]"/>

	<!-- Déplacement des notes en mode flow -->
	<xsl:template match="xhtml:*[xhtml:aside[@epub:type='footnote']]">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="noNote"/>
		</xsl:copy>
		<xsl:apply-templates select="xhtml:aside"/>
	</xsl:template>

	<xsl:template match="@*|node()" mode="noNote">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="noNote"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:aside" mode="noNote"><a href="#{@id}" role="doc-noteref" epub:type="noteref">￼(note)￼</a></xsl:template>



	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>
