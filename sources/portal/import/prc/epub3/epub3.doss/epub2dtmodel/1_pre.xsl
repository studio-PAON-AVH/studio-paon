<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sp="http://www.utc.fr/ics/scenari/v3/primitive"
								xmlns:sc="http://www.utc.fr/ics/scenari/v3/core"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
								xmlns:opf="http://www.idpf.org/2007/opf"
								xmlns:dc="http://purl.org/dc/elements/1.1/"
								xmlns:dcterms="http://purl.org/dc/terms/"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								xmlns:epub="http://www.idpf.org/2007/ops"
								xmlns:paon="editadapt.fr:paon"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								version="1.0"
								extension-element-prefixes="redirect" exclude-result-prefixes="xalan java sc sp" xsi:schemaLocation="editadapt.fr:paon ">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<!-- Set des fichiers déjà importés -->
	<xsl:variable name="files" select="java:java.util.HashSet.new()"/>

	<!-- Structure principale de l'item -->
	<xsl:template match="opf:package">
		<sc:item>
			<paon:book>
				<!-- méta données -->
				<paon:bookM>
					<sp:title><xsl:apply-templates select="opf:metadata/dc:title" mode="meta"/></sp:title>
					<sp:author><xsl:apply-templates select="opf:metadata/dc:creator" mode="meta"/></sp:author>
					<!-- Appel pour publier chaque balise meta inconnue dans un commentaire autonome -->
					<xsl:apply-templates select="opf:metadata/*"/>
				</paon:bookM>
				<sp:frontmatter>
					<paon:frontmatterM>
						<xsl:if test="opf:metadata/dc:subject"><sp:typeOuvrage><xsl:apply-templates select="opf:metadata/dc:subject" mode="meta"/></sp:typeOuvrage></xsl:if>
						<xsl:if test="opf:metadata/dc:publisher"><sp:publisher><xsl:apply-templates select="opf:metadata/dc:publisher" mode="meta"/></sp:publisher></xsl:if>
						<sp:legalsException>Cette adaptation est réalisée et diffusée dans le cadre de l’exception au droit d’auteur en faveur des personnes en situation de handicap prévue aux articles L. 122-5, L. 122-5-1 et L. 122-5-2 et R. 122-13 à 22 du code de la propriété intellectuelle. Cette adaptation ne peut être utilisée que par la personne qui l’a empruntée et ne doit en aucune manière être transmise à un tiers de quelque façon que ce soit.</sp:legalsException>
					</paon:frontmatterM>
				</sp:frontmatter>
				<sp:backcover>
					<paon:backcoverM>
						<sp:backResume>
							<paon:text>
								<xsl:value-of select="java:get(java:getVar($vDialog, 'persistMetas'), 'resumeElectre')" disable-output-escaping="yes"/>
							</paon:text>
						</sp:backResume>
					</paon:backcoverM>
				</sp:backcover>
				<xsl:variable name="toc" select="opf:manifest/opf:item[@properties='nav']/@href"/>
				<xsl:value-of select="java:setVar($vDialog, 'toc_path', substring-before($toc, extractFileNameFromPath($toc)))"/>
				<content>
					<xsl:apply-templates select="document(concat('inDir:', $toc))//xhtml:nav[@epub:type='toc']/xhtml:ol" mode="toc"/>
				</content>
				<sp:backmatter>
					<paon:backmatterM>
						<sp:isbn>
							<xsl:comment>isbn importé depuis le tableau de bord</xsl:comment>
							<xsl:value-of select="java:get(java:getVar($vDialog, 'persistMetas'), 'isbn')"/>
						</sp:isbn>
						<xsl:for-each select="opf:metadata/dc:identifier">
							<sp:secondaryIsbn>
								<xsl:comment>isbn importé depuis le fichier importé</xsl:comment>
								<xsl:apply-templates/>
							</sp:secondaryIsbn>
						</xsl:for-each>
						<xsl:if test="opf:metadata/dc:language|opf:metadata/dc:rights|opf:metadata/dc:description|opf:metadata/dc:contributor">
							<sp:others>
								<paon:text>
									<xsl:if test="opf:metadata/dc:language"><sc:para xml:space="preserve">Langue : <xsl:apply-templates select="opf:metadata/dc:language" mode="meta"/></sc:para></xsl:if>
									<xsl:if test="opf:metadata/dc:rights"><sc:para xml:space="preserve">Droits : <xsl:apply-templates select="opf:metadata/dc:rights" mode="meta"/></sc:para></xsl:if>
									<xsl:if test="opf:metadata/dc:description"><sc:para xml:space="preserve">Description :</sc:para></xsl:if>
									<xsl:for-each select="opf:metadata/dc:description">
										<sc:para xml:space="preserve"><xsl:apply-templates/></sc:para>
									</xsl:for-each>
									<xsl:for-each select="opf:metadata/dc:contributor">
										<sc:para xml:space="preserve">Contributeur : <xsl:apply-templates/></sc:para>
									</xsl:for-each>
								</paon:text>
							</sp:others>
						</xsl:if>
					</paon:backmatterM>
				</sp:backmatter>
			</paon:book>
		</sc:item>
	</xsl:template>

	<!-- Traitement spécifique des métas -->
	<xsl:template match="text()" mode="meta">
		<xsl:copy/>
	</xsl:template>

	<!-- supp d'éléments traités dans le tag racine -->
	<xsl:template match="dc:title"/>
  <xsl:template match="dc:creator"/>

	<!-- éléments traités dans le frontmatter -->
	<xsl:template match="dc:publisher"/>
	<xsl:template match="dc:subject"/>

	<!-- Récupéré dans le backmatter -->
	<xsl:template match="dc:identifier"/>
	<xsl:template match="dc:language"/>
	<xsl:template match="dc:rights"/>
	<xsl:template match="dc:description"/>
	<xsl:template match="dc:contributor"/>


	<xsl:template match="xhtml:ol" mode="toc">
		<xsl:for-each select="descendant::xhtml:a">
			<xsl:variable name="href" select="java:java.lang.String.new(returnFirst(substring-before(@href, '#'), @href))"/>
			<xsl:if test="not(java:contains($files, $href))">
				<xsl:value-of select="execute(java:add($files, $href))"/>
				<xsl:apply-templates select="document(concat('inDir:',java:getVar($vDialog, 'toc_path') ,$href))/xhtml:html/xhtml:body/*" mode="html"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="@*|node()" mode="html">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="html"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="xhtml:section|xhtml:div" mode="html">
		<xsl:apply-templates mode="html"/>
	</xsl:template>

	<xsl:template match="xhtml:hgroup" mode="html">
		<xsl:apply-templates select="xhtml:*[1][contains('h1 h2 h3 h4 h5 h6', local-name())]" mode="hgroup"/>
	</xsl:template>

	<xsl:template match="xhtml:h1|xhtml:h2|xhtml:h3|xhtml:h4|xhtml:h5|xhtml:h6" mode="hgroup">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="following-sibling::xhtml:h1|following-sibling::xhtml:h2|following-sibling::xhtml:h3|following-sibling::xhtml:h4|following-sibling::xhtml:h5|following-sibling::xhtml:h6">
				<xsl:text> - </xsl:text><xsl:apply-templates select="node()"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<!-- Recopie des balises inconnues en commentaire pour affiner la XSL -->
	<xsl:template match="@*|node()">
		<xsl:choose>
			<xsl:when test="self::processing-instruction()"/>
			<xsl:when test="self::text()">
				<xsl:copy/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" mode="copy"/>
				</xsl:copy>
				<xsl:text disable-output-escaping="yes"> --&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node()" mode="copy">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="copy"/>
			</xsl:copy>
		</xsl:template>
</xsl:stylesheet>
