<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsm="http://www.w3.org/1999/XSL/Transform">
	<!-- changement de processor xslt pour ajout du doctype -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" doctype-public="-//NISO//DTD dtbsmil 2005-2//EN" doctype-system="http://www.daisy.org/z3986/2005/dtbsmil-2005-2.dtd"/>
	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>
</xsl:stylesheet>