<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								extension-element-prefixes="redirect"
								exclude-result-prefixes="xalan java">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:variable name="voice1">￼Manon￼</xsl:variable>
	<xsl:variable name="voice2">￼Antoine￼</xsl:variable>


	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6">
		<xsl:text>\vce=speaker=</xsl:text><xsl:value-of select="$voice2"/><xsl:text>\</xsl:text>
		<xsl:apply-templates mode="copyTxt">
			<xsl:with-param name="voice" select="$voice2"/>
		</xsl:apply-templates>
		<xsl:text>\break\ </xsl:text>
	</xsl:template>

	<xsl:template match="xhtml:p">
		<xsl:choose>
		<xsl:when test="containWord(@class, 'secondaryVoice')"><xsl:text>\vce=speaker=</xsl:text><xsl:value-of select="$voice2"/><xsl:text>\ </xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>\vce=speaker=</xsl:text><xsl:value-of select="$voice1"/><xsl:text>\ </xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="copyTxt">
			<xsl:with-param name="voice" select="$voice1"/>
		</xsl:apply-templates>
		<xsl:text>\break\ </xsl:text>
	</xsl:template>

	<xsl:template match="xhtml:table">
		<xsl:apply-templates select="xhtml:caption"/>
		<xsl:apply-templates select="descendant::xhtml:p"/>
	</xsl:template>

	<xsl:template match="xhtml:caption">
		<xsl:text>\vce=speaker=</xsl:text><xsl:value-of select="$voice1"/><xsl:text>\</xsl:text>
				<xsl:apply-templates mode="copyTxt"/>
  		<xsl:text>\break\ </xsl:text>
	</xsl:template>

	<xsl:template match="xhtml:span[@cmd]" mode="copyTxt">
			<xsl:value-of select="@cmd"/>
	</xsl:template>

	<!-- NP 2022-11-10 : le ticket Acapela 6146988-7856 semble résolu sur mes test -->
	<xsl:template match="xhtml:span[@class='secondaryVoice']" mode="copyTxt">
		<xsl:param name="voice"/>
			<xsl:text> \vce=speaker=</xsl:text><xsl:value-of select="$voice2"/><xsl:text>\ </xsl:text>
			<xsl:apply-templates mode="copyTxt">
				<xsl:with-param name="voice" select="$voice2"/>
			</xsl:apply-templates>
			<xsl:text> \vce=speaker=</xsl:text><xsl:value-of select="$voice"/><xsl:text>\ </xsl:text>
  	</xsl:template>

	<!-- Pour résoudre un problème de prononciation des appels de notes qui sont après la ponctuation
	  et se retrouve intégré en début de la phrase suivante :
	  Les appels de notes du daisy2 sont encadré dans un span spécial qui ajoute un break après le texte de l'appel -->
	<xsl:template match="xhtml:span[@class='noteref']" mode="copyTxt">
		<xsl:param name="voice"/>
		<xsl:apply-templates mode="copyTxt">
			<xsl:with-param name="voice" select="$voice"/>
		</xsl:apply-templates>
		<xsl:text>\break\ </xsl:text>
	</xsl:template>

	<xsl:template match="@*|*" mode="copyTxt">
		<xsl:apply-templates select="node()" mode="copyTxt"/>
	</xsl:template>

	<!--xsl:template match="text()" mode="copyTxt"><xsl:value-of select="java:eu.scenari.core.service.oauth.OAuthUrlEncoder.encode(.)"/></xsl:template-->

	<xsl:template match="text()" mode="copyTxt"><xsl:copy/></xsl:template>

	<xsl:template match="xhtml:div">
		<xsl:choose>
			<xsl:when test="containWord(@class, 'note')"><xsl:text>
</xsl:text>
				<xsl:apply-templates select="node()"/>
			</xsl:when>
			<xsl:when test="descendant::text()">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
					<xsl:text>\pau=500\</xsl:text>
				</xsl:copy>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
