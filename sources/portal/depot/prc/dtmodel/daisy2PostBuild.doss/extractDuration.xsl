<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								version="1.0"
								extension-element-prefixes="redirect"
								exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="/">
		<xsl:value-of select="descendant::xhtml:meta[@name='ncc:totalTime']/@content"/>
	</xsl:template>
</xsl:stylesheet>
