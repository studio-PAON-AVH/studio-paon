<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- changement de processor xslt pour ajout du doctype -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD SMIL 1.0//EN" doctype-system="SMIL10.dtd"/>

	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>

</xsl:stylesheet>