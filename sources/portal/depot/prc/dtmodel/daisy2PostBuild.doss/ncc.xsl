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

	<xsl:param name="dPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:template match="xhtml:meta[@content='text/css']"/>
	<xsl:template match="xhtml:meta[@name='generator']"/>
	<xsl:template match="xhtml:meta[@name='revision']"/>
	<xsl:template match="xhtml:link"/>
	<xsl:template match="xhtml:table"/>


	<xsl:template match="xhtml:p">
		<xsl:apply-templates select="xhtml:span[containWord(@class, 'sentence')]"/>
	</xsl:template>

	<xsl:template match="xhtml:span[containWord(@class, 'sentence')]">
		<xsl:variable name="smilId" select="substring(parent::xhtml:p/ancestor::xhtml:div[@id]/@id,string-length($dPfx)+1)"/>
		<xsl:variable name="parId" select="substring(@id,string-length($sPfx)+1)"/>
		<span class="page-normal">
			<xsl:apply-templates select="@id"/>
			<a href="{$smilId}.smil#par_{$parId}"></a>
		</span>
	</xsl:template>

	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6" mode="title">
		<xsl:variable name="smilId" select="substring(ancestor::xhtml:div[@id]/@id,string-length($dPfx)+1)"/>
		<xsl:variable name="parId" select="substring(xhtml:span/@id,string-length($sPfx)+1)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*[local-name() != 'id']"/>
			<xsl:attribute name="id"><xsl:value-of select="xhtml:span/@id"/></xsl:attribute>
			<a href="{$smilId}.smil#par_{$parId}"><xsl:apply-templates select="descendant::text()"/></a>
		</xsl:copy>
		<span title="true" class="page-normal" id="s{@id}"><a href="{$smilId}.smil#par_{$parId}"></a></span>
	</xsl:template>

	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6"/>

	<xsl:template match="xhtml:div">
		<xsl:if test="@id">
			<xsl:apply-templates select="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6" mode="title"/>
		</xsl:if>
		<div cat="true">
			<xsl:apply-templates select="*"/>
		</div>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
