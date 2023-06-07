<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:sm="http://www.utc.fr/ics/scenari/v3/modeling"
								xmlns:sc="http://www.utc.fr/ics/scenari/v3/core"
								xmlns:smp="scenari.eu:builder:portal:1.0"
  							xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"/>

	<!-- portalDef -->
  <xsl:template match="/smp:portalDefinition">
		<xsl:copy>
			<xsl:attribute name="keyPortal">studioPaonCommonsLight</xsl:attribute>
			<xsl:apply-templates select="@name|@majorVersion|@mediumVersion|@minorVersion"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:portletLinker[@sc:refUri='/portalLight/depot/depot.linker']"/>
	<xsl:template match="smp:mainToolbarPlugin"/>
	<xsl:template match="smp:freeMjs"/>

	<!-- import.portlet -->
	<xsl:template match="/smp:depotPrl">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:processing[@sc:refUri='/portalLight/_commons/prc/folder/folder.processing']"/>
	<xsl:template match="smp:processing[@sc:refUri='/portalLight/_commons/prc/folder/home.processing']"/>
	<xsl:template match="smp:processing[@sc:refUri='/portalLight/import/prc/data/data.processing']"/>
  <xsl:template match="smp:processing[@sc:refUri='/portalLight/import/prc/archived/archived.processing']"/>
  <xsl:template match="smp:processing[@sc:refUri='/portalLight/import/prc/reopened/reopened.processing']"/>
	<xsl:template match="smp:freeRendering"/>
	<xsl:template match="smp:esIndex"/>
	<xsl:template match="sm:role[@sc:refUri='/collab/roles/main/1_reader.role']">
		<sm:role sc:refUri="/portalLight/collab/roles/1_reader.role"/>
	</xsl:template>
  <xsl:template match="smp:transformXsl[@sc:refUri='/portalLight/import/free/prc.import.archived.xsl']"/>

	<!-- import.linker -->
	<xsl:template match="/smp:depotLnk">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:esEngine"/>

	<!-- xml.processing -->
	<xsl:template match="/smp:binaryProc">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:metaList[not(@info='identification')]"/>
	<xsl:template match="smp:indexings"/>

	<!-- prl.chain.lc.universeInit.xsl -->
	<xsl:template match="callDialog"/>
  <xsl:template match="updateImportMeta"/>
  <!-- lnk.chain.batch.universeInit.xsl -->
	<xsl:template match="taskDef[@localName='updateImportMeta']"/>
  

	<!-- 1_reader.role -->
	<xsl:template match="/sm:role">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="sm:denyPerms"/>

	<!-- chain.portlet -->
	<xsl:template match="/smp:chainPrl">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- paon.svmake -->
	<xsl:template match="/smp:svMake">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:description/@name">
		<xsl:attribute name="name">studioPaonCommonsLight</xsl:attribute>
	</xsl:template>

	<!-- paon.props -->
	<xsl:template match="/smp:properties">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:property[@key='user.writer.password']"/>
	<xsl:template match="smp:property[@key='app.ext.es.host']"/>
	<xsl:template match="smp:property[@group='acapela']"/>

	<!-- dev.portaldef -->
	<xsl:template match="/smp:portalDefinition4test">
		<xsl:copy>
			<xsl:attribute name="keyPortal">studioPaonCommonsLight</xsl:attribute>
			<xsl:attribute name="name">Studio Paon Light</xsl:attribute>
			<xsl:apply-templates select="@majorVersion|@mediumVersion|@minorVersion"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:portletLinker[@sc:refUri='/portalLight/_test/depot.linker']"/>

	<!-- import.linker [dev] -->
	<xsl:template match="/smp:depotLnk4test">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- chain.linker -->
	<xsl:template match="/smp:chainLnk">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="smp:volatileUser[@account='writer']"/>
	<xsl:template match="smp:scDepot"/>

	<!-- chain.linker [dev] -->
	<xsl:template match="/smp:chainLnk4test">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="xmlns:sc">http://www.utc.fr/ics/scenari/v3/core</xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>