<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>
	<xsl:param name="ctx.dev"/>
	<xsl:param name="ctx.mode"/>
	<xsl:param name="ctx.svMakeName"/>
	<xsl:template match="service[@code='executor']">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<!--  Cas général -->
			<jobCreations>
				<jobDef code="publish" class="eu.scenari.core.executor.BatchJob" addProps="(svcBatch'batch' forceExecFrame'Web')" permFromClass="eu.scenari.wsp.item.Item_Perms" perm="callTransition.item">
					<xmlProp key="batch">
						<try errorVar="pushErrors">
							
							<execLcTransition transition="xToPublicationSuccess" wspCode="${{_CurrentWspCode}}" rootItemUri="${{_CurrentSrcUri}}"/>
							
							<removeSlaveInst/>
							<failed>
								<execLcTransition transition="xToPublicationError" wspCode="${{_CurrentWspCode}}" rootItemUri="${{_CurrentSrcUri}}"/>
								
							</failed>
						</try>
					</xmlProp>
				</jobDef>
			</jobCreations>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>