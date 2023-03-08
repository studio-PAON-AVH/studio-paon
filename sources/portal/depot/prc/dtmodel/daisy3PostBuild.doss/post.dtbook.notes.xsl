<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:java="http://xml.apache.org/xslt/java"

	exclude-result-prefixes="dtb java">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:variable name="notesIds" select="java:java.util.HashSet.new()"/>

	<xsl:variable name="mode" select="//dtb:note-processing/@class"/>

	<xsl:template match="dtb:note-processing"/>

	<xsl:template match="dtb:level1[not(id='dnotes')]|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:if test="$mode='flow-dtb'">
				<xsl:apply-templates select="node()" mode="notes"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6" mode="notes"/>

	<xsl:template match="dtb:note">
		<xsl:if test="$mode='end-dtb'">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<xsl:template match="dtb:span[@class='sentence' and (parent::dtb:note or child::dtb:note)]"/>
	<xsl:template match="dtb:sup[dtb:noteref and string-length(normalize-space()) = 0]"/>

	<xsl:template match="@*|node()" mode="notes">
		<xsl:apply-templates select="@*|node()" mode="notes"/>
	</xsl:template>

	<xsl:template match="dtb:note" mode="notes">
		<xsl:variable name="id" select="@id"/>
		<xsl:choose>
			<xsl:when test="preceding::dtb:note[@id=$id]"/>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<!-- Re construction d'un bloc notes en mode flow -->
					<p id="{@id}_0">
					<xsl:apply-templates select="ancestor::*[starts-with(local-name(), 'level')]/descendant::dtb:span[@class='sentence' and (parent::dtb:note[@id=$id] or child::dtb:note[@id=$id])]" mode="copySpan"/>
					</p>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dtb:note" mode="copySpan">
		<xsl:apply-templates mode="copySpan"/>
	</xsl:template>

	<xsl:template match="@*|node()" mode="copySpan">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copySpan"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>



</xsl:stylesheet>
