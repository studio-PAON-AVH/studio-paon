<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
							<callDialog svcCode="export">
								<param key="cdaction" value="SendTo"/>
								<param key="scope" value="net"/>
								<param key="format" value="jar"/>
								<param key="mode" value="wspTree"/>
								<param key="link" value="absolute"/>
								<param key="param" value="${{_CurrentWspCode}}"/>
								<param key="downloadFileName" value="export_scar"/>
								<param key="refUris" value="${{_CurrentSrcUri}}"/>
								<param key="sendProps">
									{
										"method":"PUT",
										"url":"¤builder;prl-depot#write.public.url¤/web/u/cid",
										"addQSParams":{
											"synch":"true",
											"createMetas":"true",
											"processing":"dtmodel",
											"srcUri":"${_CurrentSrcUri}",
										}
									}
								</param>
							</callDialog>
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