<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:epub="http://www.idpf.org/2007/ops"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="dPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="durations" select="java:getVar($vDialog, 'durations')"/>
	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>

	<xsl:template match="xhtml:html">
		<xhtml:html>
			<xhtml:head>
				<xsl:apply-templates select="xhtml:head/xhtml:title" mode="copy"/>
			</xhtml:head>
			<xhtml:body>
				<xhtml:nav epub:type="toc">
					<xhtml:h1>￼Table des matières￼</xhtml:h1>
					<xhtml:ol>
						<xsl:apply-templates mode="toc"/>
					</xhtml:ol>
				</xhtml:nav>
				<xhtml:nav epub:type="page-list">
					<xhtml:h1>￼Liste des pages￼</xhtml:h1>
					<xhtml:ol>
						<xsl:apply-templates mode="pages"/>
					</xhtml:ol>
				</xhtml:nav>
			</xhtml:body>
		</xhtml:html>
	</xsl:template>

	<xsl:template match="@*|node()" mode="toc">
		<xsl:apply-templates select="@*|node()" mode="toc"/>
	</xsl:template>

	<xsl:template match="xhtml:section[@id]" mode="toc">
		<xhtml:li id="{@id}">
			<xhtml:a href="{substring(@id,string-length($dPfx)+1)}.xhtml"><xsl:apply-templates select="xhtml:h1" mode="copyTxt"/></xhtml:a>
		</xhtml:li>
	</xsl:template>

	<xsl:template match="@*|node()" mode="pages">
  		<xsl:apply-templates select="@*|node()" mode="pages"/>
  	</xsl:template>

	<xsl:template match="xhtml:span[@class='sentence']" mode="pages">
		<xsl:variable name="packageId"><xsl:apply-templates select="parent::*" mode="packageId"/></xsl:variable>
		<xhtml:li id="{@id}">
			<xsl:choose>
				<xsl:when test="parent::xhtml:h1|parent::xhtml:h2|parent::xhtml:h3|parent::xhtml:h4|parent::xhtml:h5|parent::xhtml:h6">
					<xsl:attribute name="class">pagetitle</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">pagenum</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xhtml:a href="{$packageId}.xhtml#{@id}"/>
		</xhtml:li>
	</xsl:template>

	<xsl:template match="*" mode="packageId">
		<xsl:apply-templates select="parent::*" mode="packageId"/>
	</xsl:template>

	<xsl:template match="xhtml:section[@id]" mode="packageId"><xsl:value-of select="substring(@id,string-length($dPfx)+1)"/></xsl:template>

	<xsl:template match="*" mode="copyTxt">
			<xsl:apply-templates select="node()" mode="copyTxt"/>
	</xsl:template>

	<xsl:template match="text()" mode="copyTxt">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copyTxt"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()" mode="copy">
  		<xsl:copy>
  			<xsl:apply-templates select="@*|node()" mode="copy"/>
  		</xsl:copy>
  	</xsl:template>

	<xsl:template match="@*|node()">
			<xsl:apply-templates select="@*|node()"/>
	</xsl:template>

</xsl:stylesheet>
