<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<!-- Complete metas and acapela tag cleanup -->

	<xsl:template match="xhtml:html">
		<xsl:variable name="lang" select="xhtml:head/xhtml:meta[@name='dc:language']/@content"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="lang"><xsl:value-of select="$lang"/></xsl:attribute>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:meta[@http-equiv='content-type']/@content">
		<xsl:attribute name="content">text/html; charset=UTF-8</xsl:attribute>
	</xsl:template>

		<!-- clean up des balises scripts -->
  	<xsl:template match="xhtml:script"/>

  	<xsl:template match="xhtml:link">
  	<xsl:copy>
	  	<xsl:attribute name="href"><xsl:value-of select="substring(@href, 9)"/></xsl:attribute>
	  	<xsl:apply-templates select="@*[name() != 'href']"/>
		</xsl:copy>
		</xsl:template>

	<xsl:template match="xhtml:meta[@name='ncc:generator']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="content"><xsl:value-of select="preceding-sibling::xhtml:meta[@name='generator']/@content"/></xsl:attribute>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:meta[@name='ncc:files']">
    		<xsl:copy>
    			<xsl:apply-templates select="@*"/>
    			<xsl:attribute name="content"><xsl:value-of select="count(/xhtml:html/xhtml:body/descendant::xhtml:div[not(containWord(@class, 'note')) and @id])*2+3"/></xsl:attribute>
    		</xsl:copy>
    	</xsl:template>

	<xsl:template match="xhtml:meta[@name='ncc:depth']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="content"><xsl:choose>
				<xsl:when test="//xhtml:h6">6</xsl:when>
				<xsl:when test="//xhtml:h5">5</xsl:when>
				<xsl:when test="//xhtml:h4">4</xsl:when>
				<xsl:when test="//xhtml:h3">3</xsl:when>
				<xsl:when test="//xhtml:h2">2</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose></xsl:attribute>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:meta[@name='ncc:footnotes']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="content"><xsl:value-of select="count(//xhtml:note)"/></xsl:attribute>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
