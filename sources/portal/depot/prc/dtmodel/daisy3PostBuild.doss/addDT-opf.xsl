<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsm="http://www.w3.org/1999/XSL/Transform">
	<!-- changement de processor xslt pour ajout du doctype -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" doctype-public="+//ISBN 0-9673008-1-9//DTD OEB 1.2 Package//EN" doctype-system="http://openebook.org/dtds/oeb-1.2/oebpkg12.dtd"/>
	<xsl:template match="@*|node()">
	    <xsl:copy>
	        <xsl:apply-templates select="@*|node()"/>
	    </xsl:copy>
	</xsl:template>
</xsl:stylesheet>