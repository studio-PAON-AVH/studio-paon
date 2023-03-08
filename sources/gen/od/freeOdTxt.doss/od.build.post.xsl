<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="target[@name='main']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:comment>Free post build - déclaration de la task ant</xsl:comment>
			<taskdef name="transformXsl" classname="com.scenari.m.co.ant.TransformXslTask"/><xsl:text>
		</xsl:text>
			<xsl:apply-templates select="node()"/>
			<xsl:text>
		</xsl:text><xsl:comment>Free post build - Ajout d'un post traitement sur le texte</xsl:comment><xsl:text>
		</xsl:text><unzip>
			<xsl:attribute name="src">${destination.odt.path}</xsl:attribute>
			<xsl:attribute name="dest">${vFolderDest}/post</xsl:attribute>
		</unzip><xsl:text>
		</xsl:text><delete>
			<xsl:attribute name="file">${destination.odt.path}</xsl:attribute>
		</delete><xsl:text>
			<!-- déplacement des notes situées avant une ponctuation fermante -->
		</xsl:text><transformXsl style="od.notes.xsl">
			<xsl:attribute name="inFile">${vFolderDest}/post/content.xml</xsl:attribute>
			<xsl:attribute name="outFile">${vFolderDest}/post/content.xml</xsl:attribute>
		</transformXsl><xsl:text>
			<!-- Remplacement des notes par des blocs avec code braille -->
		</xsl:text><transformXsl style="od.post.xsl">
			<xsl:attribute name="inFile">${vFolderDest}/post/content.xml</xsl:attribute>
			<xsl:attribute name="outFile">${vFolderDest}/post/content.xml</xsl:attribute>
		</transformXsl><xsl:text>
		</xsl:text><zip>
			<xsl:attribute name="destfile">${destination.odt.path}</xsl:attribute>
			<xsl:attribute name="basedir">${vFolderDest}/post</xsl:attribute>
		</zip><xsl:text>
		</xsl:text><delete>
			<xsl:attribute name="dir">${vFolderDest}/post</xsl:attribute>
		</delete><xsl:text>
	</xsl:text>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
