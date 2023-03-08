<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:java="http://xml.apache.org/xslt/java"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
	extension-element-prefixes="redirect"
	exclude-result-prefixes="xalan java xhtml dtb">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:variable name="seperators" select="'  ,.'"/>

	<xsl:variable name="mode"><xsl:choose>
		<xsl:when test="//xhtml:note-processing"><xsl:value-of select="//xhtml:note-processing/@class"/></xsl:when>
		<xsl:when test="//dtb:note-processing"><xsl:value-of select="//dtb:note-processing/@class"/></xsl:when>
</xsl:choose></xsl:variable>

	<xsl:template match="xhtml:note-processing"/>

	<xsl:template match="xhtml:note|dtb:note">
		<xsl:variable name="firstChar" select="substring(descendant::*[local-name()='p'][1]/text()[1], 1, 1)"/>
		<xsl:variable name="lastPata" select="descendant::*[local-name()='p'][last()]"/>
		<xsl:variable name="lastChar" select="substring($lastPata, string-length($lastPata))"/>

		<xsl:variable name="prevPara" select="preceding-sibling::text()[1]"/>
		<xsl:variable name="prevLastChar" select="substring($prevPara, string-length($prevPara))"/>
		<xsl:variable name="follFirstChar" select="substring(following-sibling::text(), 1, 1)"/>
		<!--varsdebug firstChar="{$firstChar}" lastPata="{$lastPata}" lastChar="{$lastChar}" prevPara="{$prevPara}" prevLastChar="{$prevLastChar}" follFirstChar="{$follFirstChar}"/-->
		<xsl:choose>
		<xsl:when test="$mode='flow-aud'">
				<xsl:if test="not($prevLastChar = ' ' or $prevLastChar = ' ' or $prevLastChar = '')"><xsl:text> </xsl:text></xsl:if>
				<!-- les breaks permettent d'éviter un changement de phrase dans `(note)` ce qui couperait le noteref en deux dans un contexte de note en flow dans daisy3 -->
				<span class="secondaryVoice"><xsl:text>\break\</xsl:text><xsl:text>￼(note)￼</xsl:text><xsl:text>\break\</xsl:text></span>
				<xsl:if test="not($firstChar = ' ' or $firstChar = ' ')"><xsl:text> </xsl:text></xsl:if>
				<xsl:for-each select="descendant::xhtml:p"><xsl:value-of select="normalize-space()"/>
					<xsl:if test="following-sibling::*"><xsl:text> </xsl:text></xsl:if></xsl:for-each>
				<xsl:if test="not($lastChar = ' ' or  $lastChar = ' ')"><xsl:text> </xsl:text></xsl:if>
				<span class="secondaryVoice"><xsl:text>\break\￼(fin de note)￼\break\</xsl:text></span>
				<xsl:if test="not(contains($seperators,$follFirstChar) or $follFirstChar = '')"><xsl:text> </xsl:text></xsl:if>
			</xsl:when>
			<xsl:when test="$mode='flow'">
				<xsl:if test="not($prevLastChar = ' ' or $prevLastChar = ' ' or $prevLastChar = '')"><xsl:text> </xsl:text></xsl:if>
				<span class="secondaryVoice"><xsl:text>￼(note)￼</xsl:text></span>
				<xsl:if test="not($firstChar = ' ' or $firstChar = ' ')"><xsl:text> </xsl:text></xsl:if>
				<xsl:for-each select="descendant::xhtml:p"><xsl:value-of select="normalize-space()"/>
					<xsl:if test="following-sibling::*"><xsl:text> </xsl:text></xsl:if></xsl:for-each>
				<xsl:if test="not($lastChar = ' ' or  $lastChar = ' ')"><xsl:text> </xsl:text></xsl:if>
				<span class="secondaryVoice"><xsl:text>￼(fin de note)￼</xsl:text></span>
				<xsl:if test="not(contains($seperators,$follFirstChar) or $follFirstChar = '')"><xsl:text> </xsl:text></xsl:if>
			</xsl:when>
			<xsl:when test="$mode='flow-dtb'">
				<xsl:if test="not($prevLastChar = ' ' or $prevLastChar = ' ' or $prevLastChar = '')"><xsl:text> </xsl:text></xsl:if>
				<sup><noteref><xsl:attribute name="idref">#<xsl:value-of select="@id"/></xsl:attribute><xsl:text>￼(note)￼</xsl:text></noteref></sup>
				<xsl:if test="not($firstChar = ' ' or $firstChar = ' ')"><xsl:text> </xsl:text></xsl:if>
				<note>
					<xsl:apply-templates select="@*"/>
					<xsl:for-each select="descendant::dtb:p"><xsl:value-of select="normalize-space()"/>
					<xsl:if test="following-sibling::*"><xsl:text> </xsl:text></xsl:if></xsl:for-each>
					<xsl:if test="not($lastChar = ' ' or  $lastChar = ' ')"><xsl:text> </xsl:text></xsl:if>
					<xsl:text>￼(fin de note)￼</xsl:text>
					<xsl:if test="not(contains($seperators,$follFirstChar) or $follFirstChar = '')"><xsl:text> </xsl:text></xsl:if>
				</note>

			</xsl:when>
			<xsl:when test="$mode='end-xhtml1'">
				<xsl:if test="not($prevLastChar = ' ' or $prevLastChar = ' ' or $prevLastChar = '')"><xsl:text> </xsl:text></xsl:if>
				<span class="secondaryVoice"><a href="#d{@id}">￼Voir note ￼<xsl:value-of select="count(preceding::xhtml:note)+1"/></a></span>
				<xsl:if test="not(contains($seperators,$follFirstChar) or $follFirstChar = '')"><xsl:text> </xsl:text></xsl:if>
			</xsl:when>
			<xsl:when test="$mode='end-dtb'">
				<xsl:if test="not($prevLastChar = ' ' or $prevLastChar = ' ' or $prevLastChar = '')"><xsl:text> </xsl:text></xsl:if>
				<sup><noteref><xsl:attribute name="idref">#<xsl:value-of select="@id"/></xsl:attribute>￼Voir note ￼<xsl:value-of select="count(preceding::dtb:note)+1"/></noteref></sup>
				<xsl:if test="not(contains($seperators,$follFirstChar) or $follFirstChar = '')"><xsl:text> </xsl:text></xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xhtml:span[containWord(@class, 'cite_ph')]|dtb:cite">
		<xsl:variable name="firstChar" select="substring(descendant::text()[1], 1, 1)"/>
		<xsl:variable name="lastPata" select="descendant::text()[last()]"/>
		<xsl:variable name="lastChar" select="substring($lastPata, string-length($lastPata))"/>

		<xsl:variable name="prevPara" select="preceding-sibling::text()[1]"/>
		<xsl:variable name="prevLastChar" select="substring($prevPara, string-length($prevPara))"/>
		<xsl:variable name="follFirstChar" select="substring(following-sibling::text(), 1, 1)"/>

		<xsl:if test="not($prevLastChar = ' ' or $prevLastChar = ' ' or $prevLastChar = '')"><xsl:text> </xsl:text></xsl:if>
		<xsl:text>￼(Citation)￼</xsl:text>
		<xsl:if test="not($firstChar = ' ' or $firstChar = ' ')"><xsl:text> </xsl:text></xsl:if>
		<xsl:apply-templates select="node()"/>
		<xsl:if test="not($lastChar = ' ' or  $lastChar = ' ')"><xsl:text> </xsl:text></xsl:if>
		<xsl:text>￼(Fin de citation)￼</xsl:text>
		<xsl:if test="not(contains($seperators,$follFirstChar) or $follFirstChar = '')"><xsl:text> </xsl:text></xsl:if>
	</xsl:template>


	<xsl:template match="xhtml:div[containWord(@class,'level1') and not(following-sibling::*[1][containWord(@class,'level1')])]|dtb:level1[not(following::dtb:level1)]">
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
		<xsl:choose>
			<xsl:when test="$mode='end-xhtml1' and //xhtml:note">
				<div class="level1" id="notes">
					<h1>￼Notes￼</h1>
					<xsl:for-each select="//xhtml:note">
						<div id="{@id}" class="note">
							<p class="secondaryVoice">￼Note ￼<xsl:value-of select="position()"/></p>
							<xsl:apply-templates/>
						</div>
					</xsl:for-each>
				</div>
			</xsl:when>
			<xsl:when test="$mode='end-dtb'">
				<level1 class="endnotes" id="notes">
					<h1>￼Notes￼</h1>
					<xsl:for-each select="//dtb:note">
						<xsl:copy>
							<xsl:apply-templates select="@*"/>
							<p>￼Note ￼<xsl:value-of select="position()"/></p>
							<xsl:apply-templates/>
						</xsl:copy>
					</xsl:for-each>
				</level1>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="xhtml:div[containWord(@class, 'citation_div')]">
		<p class="secondaryVoice">￼(Citation)￼</p>
		<xsl:apply-templates/>
		<p class="secondaryVoice">￼(Fin de citation)￼</p>
	</xsl:template>

	<xsl:template match="dtb:blockquote">
		<p>￼(Citation)￼</p>
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
		<p>￼(Fin de citation)￼</p>
	</xsl:template>

	<xsl:template match="xhtml:div[containWord(@class, 'poem_div')]">
		<p class="secondaryVoice">￼(Poésie)￼</p>
		<xsl:apply-templates/>
		<p class="secondaryVoice">￼(Fin de poésie)￼</p>
	</xsl:template>

	<xsl:template match="dtb:poem">
		<p>￼(Poésie)￼</p>
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
		<p>￼(Fin de poésie)￼</p>
	</xsl:template>

	<!-- Texte en marge -->
	<xsl:template match="xhtml:div[containWord(@class, 'side_div')]">
		<p class="secondaryVoice">￼(Texte en marge)￼</p>
		<xsl:apply-templates/>
		<p class="secondaryVoice">￼(Fin du texte en marge)￼</p>
	</xsl:template>
	<xsl:template match="dtb:sidebar">
		<p class="secondaryVoice">￼(Texte en marge)￼</p>
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
		<p class="secondaryVoice">￼(Fin du texte en marge)￼</p>
	</xsl:template>

	<xsl:template match="xhtml:div[containWord(@class, 'epigraph_div')]">
		<p class="secondaryVoice">￼(Épigraphe)￼</p>
		<xsl:apply-templates/>
		<p class="secondaryVoice">￼(Fin d'épigraphe)￼</p>
	</xsl:template>

	<xsl:template match="dtb:epigraph">
		<p>￼(Épigraphe)￼</p>
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
		<p>￼(Fin d'épigraphe)￼</p>
	</xsl:template>

  <xsl:template match="@class[contains(., 'secondaryVoice_p')]">
  	<xsl:variable name="replaced_class"><xsl:value-of select="substring-before(., 'secondaryVoice_p')"/> secondaryVoice <xsl:value-of select="substring-after(., 'secondaryVoice_p')"/></xsl:variable>
  	<xsl:attribute name="class"><xsl:value-of select="normalize-space($replaced_class)"/></xsl:attribute>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
	</xsl:template>
</xsl:stylesheet>
