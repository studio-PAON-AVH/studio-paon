<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="xhtml:body">
<indexViews><xsl:text>
	</xsl:text><view code="audioStruct.xml" urlPatterns="?V=audioStruct.xml" contentType="application/xml"><xsl:text>
		</xsl:text><singleSource src="index.xml"/><xsl:text>
	</xsl:text></view><xsl:text>
</xsl:text><xsl:apply-templates select="@*|node()"/></indexViews>
	</xsl:template>

	<xsl:template match="xhtml:div">
<xsl:text>	</xsl:text><view code="{@id}.acapela.tts.zip" urlPatterns="?V={@id}.acapela.tts.zip" contentType="application/zip"><xsl:text>
		</xsl:text><singleSource src="{@id}.acapela.tts.zip"/><xsl:text>
	</xsl:text></view><xsl:text>
</xsl:text>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>

</xsl:stylesheet>
