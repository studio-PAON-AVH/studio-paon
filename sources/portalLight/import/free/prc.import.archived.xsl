<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:sp="http://www.utc.fr/ics/scenari/v3/primitive" xmlns:sc="http://www.utc.fr/ics/scenari/v3/core" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="sc sp" xmlns:java="http://xml.apache.org/xslt/java" xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>


	<xsl:template match="storeSteps">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<ifCidMeta key="processing" valuePattern="archived">
				<step type="eu.scenari.editadapt.import2depot.CheckIfExported" url="¤builder;prl-depot#urlTree.url¤">
					<sendCidRequest url="¤builder;prl-depot#write.public.url¤/web/u/cid">
						<addStaticParam key="synch" value="true"/>
						<addStaticParam key="createMetas" value="true"/>
						<addStaticParam key="scContent" value="none"/>
						<addStaticParam key="action" value="removeAll"/>
						<addParamFromPersistMetas key="path"/>
					</sendCidRequest>
				</step>
			</ifCidMeta>
		</xsl:copy>
		<step type="eu.scenari.editadapt.utils.ImportLGUtilsStep"/>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>