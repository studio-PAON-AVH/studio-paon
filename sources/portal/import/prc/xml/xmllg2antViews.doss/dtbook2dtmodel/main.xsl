<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sp="http://www.utc.fr/ics/scenari/v3/primitive"
								xmlns:sc="http://www.utc.fr/ics/scenari/v3/core"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:redirect="com.scenari.xsldom.xalan.lib.Redirect"
								xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
								xmlns:paon="editadapt.fr:paon"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								version="1.0"
								extension-element-prefixes="redirect" exclude-result-prefixes="xalan java sc sp" xsi:schemaLocation="editadapt.fr:paon ">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:variable name="notFlow" select="'level1 level2 level3 level4 level5 level6 h1 h2 h3 h4 h5 h6 note bridgehead'"/>

	<!-- Structure principale de l'item -->
	<xsl:template match="dtb:dtbook">
		<sc:item>
			<paon:book>
				<!-- méta données -->
				<paon:bookM>
					<sp:title>
						<xsl:apply-templates select="dtb:book/dtb:frontmatter/dtb:doctitle" mode="meta"/>
					</sp:title>
					<sp:author>
						<xsl:apply-templates select="dtb:book/dtb:frontmatter/dtb:docauthor" mode="meta"/>
					</sp:author>
					<!-- Appel pour publier chaque balise meta inconnue dans un commentaire autonome -->
					<xsl:apply-templates select="dtb:head/*"/>
				</paon:bookM>
				<sp:frontmatter>
					<paon:frontmatterM>
						<sp:publisher>
							<xsl:value-of select="dtb:head/dtb:meta[@name='dc:Publisher']/@content"/>
						</sp:publisher>
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
				<xsl:apply-templates select="dtb:book/dtb:frontmatter/*"/>
				<xsl:apply-templates select="dtb:book/dtb:bodymatter/*"/>
				<xsl:apply-templates select="dtb:book/dtb:rearmatter/*"/>
				<sp:backmatter>
					<paon:backmatterM>
						<!-- FIXME : activer le transfert de la date de parution si demander -->
						<!--<xsl:variable name="dateparution" select="java:get(java:getvar($vdialog, 'persistmetas'), 'dateparution')" />
						<xsl:if test="$dateparution">
							<xsl:variable name="anneeparution" select="substring-before($dateparution,'-')" />
							<xsl:variable name="moisparution" select="substring-after($dateparution,'-')" />
							<xsl:choose>
								<xsl:when test="$anneeparution">
									<sp:publishingyear>
										<xsl:comment>année importée depuis le tableau</xsl:comment>
										<xsl:value-of select="$anneeparution"/>
									</sp:publishingyear>
								</xsl:when>
								<xsl:otherwise> &lt;!&ndash; (une date de parution trouvé mais pas de tiret : date de parution sans mois&ndash;&gt;
									<sp:publishingyear>
										<xsl:comment>année importée depuis le tableau</xsl:comment>
										<xsl:value-of select="$dateparution"/>
									</sp:publishingyear>
								</xsl:otherwise>
							</xsl:choose>

							<xsl:if test="$moisparution">
								<sp:publishingmonth>
									<xsl:comment>mois importé depuis le tableau</xsl:comment>
									<xsl:value-of select="$moisparution"/>
								</sp:publishingmonth>
							</xsl:if>
						</xsl:if>-->
						<sp:isbn>
							<xsl:comment>isbn importé depuis le tableau de bord</xsl:comment>
							<xsl:value-of select="java:get(java:getVar($vDialog, 'persistMetas'), 'isbn')"/>
						</sp:isbn>
						<xsl:for-each select="dtb:head/dtb:meta[@name='dtb:source']">
							<sp:secondaryIsbn>
								<xsl:comment>isbn importé depuis le fichier importé</xsl:comment>
								<xsl:value-of select="@content"/>
							</sp:secondaryIsbn>
						</xsl:for-each>
						<xsl:if test="dtb:head/dtb:meta[@name='dtb:rights' or @name='dc:rights']">
							<sp:others>
								<paon:text>
									<xsl:for-each select="dtb:head/dtb:meta[@name='dtb:rights' or @name='dc:rights']">
										<sc:para xml:space="preserve"><xsl:value-of select="@content"/></sc:para>
									</xsl:for-each>
									<xsl:for-each select="dtb:head/dtb:meta[@name='dc:description']">
										<sc:para xml:space="preserve"><xsl:value-of select="@content"/></sc:para>
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
	<xsl:template match="dtb:doctitle" mode="meta">
		<xsl:apply-templates select="node()" mode="meta"/>
	</xsl:template>
	<xsl:template match="dtb:docauthor" mode="meta">
		<xsl:apply-templates select="node()" mode="meta"/>
	</xsl:template>
	<xsl:template match="text()" mode="meta">
		<xsl:copy/>
	</xsl:template>
	<xsl:template match="dtb:br" mode="meta">
		<xsl:text> </xsl:text>
	</xsl:template>

	<!-- supp d'éléments traités dans le tag racine -->
	<xsl:template match="dtb:doctitle"/>
	<xsl:template match="dtb:docauthor"/>
	<xsl:template match="dtb:meta[@name='dc:Publisher']"/>
	<xsl:template match="dtb:meta[@name='dc:description']"/>
	<xsl:template match="dtb:meta[@name='dtb:rights' or @name='dc:Rights']"/>
	<xsl:template match="dtb:meta[@name='dtb:source']"/>
	<!-- Récupéré dans le frontmatter -->
	<xsl:template match="dtb:meta[@name='dc:Title']"/>
	<xsl:template match="dtb:meta[@name='dc:Creator']"/>

	<!-- Infos volonrairement supprimmées -->
	<xsl:template match="dtb:meta[@name='dc:Identifier']"/>
	<xsl:template match="dtb:meta[@name='dc:Date']"/>
	<xsl:template match="dtb:meta[@name='dc:Language']"/>
	<xsl:template match="dtb:meta[@name='dt:version']"/>
	<xsl:template match="dtb:meta[@name='dtb:uid']"/>
	<xsl:template match="dtb:meta[@name='dtb:producer']"/>


	<!-- Éléments de structure -->
	<xsl:template match="dtb:level1">
		<xsl:choose>
			<xsl:when test="@class='dedicace'">
				<sp:inscription>
					<paon:inscriptionM/>
					<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
						<paon:flow>
							<xsl:apply-templates select="*[1]" mode="flow"/>
						</paon:flow>
					</xsl:if>
				</sp:inscription>
			</xsl:when>
			<xsl:when test="@class='collection'">
				<sp:sameAuthor>
					<paon:sameAuthorM/>
					<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
						<paon:flow>
							<xsl:apply-templates select="*[1]" mode="flow"/>
						</paon:flow>
					</xsl:if>
				</sp:sameAuthor>
			</xsl:when>
			<xsl:otherwise>
				<sp:level1>
					<paon:title>
						<xsl:for-each select="dtb:h1">
							<xsl:if test="string-length(normalize-space()) > 0">
								<sp:title>
									<xsl:apply-templates mode="meta"/>
								</sp:title>
							</xsl:if>
						</xsl:for-each>
					</paon:title>
					<paon:level1>
						<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
							<sp:flow>
								<paon:flow>
									<xsl:apply-templates select="*[1]" mode="flow"/>
								</paon:flow>
							</sp:flow>
						</xsl:if>
						<xsl:apply-templates select="*" mode="level"/>
					</paon:level1>
				</sp:level1>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dtb:level2" mode="level">
		<sp:level2>
			<paon:title>
				<xsl:for-each select="dtb:h2">
					<xsl:if test="string-length(normalize-space()) > 0">
						<sp:title>
							<xsl:apply-templates mode="meta"/>
						</sp:title>
					</xsl:if>
				</xsl:for-each>
			</paon:title>
			<paon:level2>
				<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
					<sp:flow>
						<paon:flow>
							<xsl:apply-templates select="*[1]" mode="flow"/>
						</paon:flow>
					</sp:flow>
				</xsl:if>
				<xsl:apply-templates select="*" mode="level"/>
			</paon:level2>
		</sp:level2>
	</xsl:template>

	<xsl:template match="dtb:level3" mode="level">
		<sp:level3>
			<paon:title>
				<xsl:for-each select="dtb:h3">
					<xsl:if test="string-length(normalize-space()) > 0">
						<sp:title>
							<xsl:apply-templates mode="meta"/>
						</sp:title>
					</xsl:if>
				</xsl:for-each>
			</paon:title>
			<paon:level3>
				<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
					<sp:flow>
						<paon:flow>
							<xsl:apply-templates select="*[1]" mode="flow"/>
						</paon:flow>
					</sp:flow>
				</xsl:if>
				<xsl:apply-templates select="*" mode="level"/>
			</paon:level3>
		</sp:level3>
	</xsl:template>

	<xsl:template match="dtb:level4" mode="level">
		<sp:level4>
			<paon:title>
				<xsl:for-each select="dtb:h4">
					<xsl:if test="string-length(normalize-space()) > 0">
						<sp:title>
							<xsl:apply-templates mode="meta"/>
						</sp:title>
					</xsl:if>
				</xsl:for-each>
			</paon:title>
			<paon:level4>
				<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
					<sp:flow>
						<paon:flow>
							<xsl:apply-templates select="*[1]" mode="flow"/>
						</paon:flow>
					</sp:flow>
				</xsl:if>
				<xsl:apply-templates select="*" mode="level"/>
			</paon:level4>
		</sp:level4>
	</xsl:template>

	<xsl:template match="dtb:level5" mode="level">
		<sp:level5>
			<paon:title>
				<xsl:for-each select="dtb:h5">
					<xsl:if test="string-length(normalize-space()) > 0">
						<sp:title>
							<xsl:apply-templates mode="meta"/>
						</sp:title>
					</xsl:if>
				</xsl:for-each>
			</paon:title>
			<paon:level5>
				<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
					<sp:flow>
						<paon:flow>
							<xsl:apply-templates select="*[1]" mode="flow"/>
						</paon:flow>
					</sp:flow>
				</xsl:if>
				<xsl:apply-templates select="*" mode="level"/>
			</paon:level5>
		</sp:level5>
	</xsl:template>

	<xsl:template match="dtb:level6" mode="level">
		<sp:level6>
			<paon:title>
				<xsl:for-each select="dtb:h6">
					<xsl:if test="string-length(normalize-space()) > 0">
						<sp:title>
							<xsl:apply-templates mode="meta"/>
						</sp:title>
					</xsl:if>
				</xsl:for-each>
			</paon:title>
			<paon:level6>
				<xsl:if test="dtb:*[not(contains($notFlow, local-name()))]">
					<sp:flow>
						<paon:flow>
							<xsl:apply-templates select="*[1]" mode="flow"/>
						</paon:flow>
					</sp:flow>
				</xsl:if>
				<xsl:apply-templates select="*" mode="level"/>
			</paon:level6>
		</sp:level6>
	</xsl:template>

	<!-- Supprimés du mode level car adressé par ailleurs (parents, notes) -->
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6|dtb:note" mode="level"/>
	<!-- Éléments supprimés de la structure -->
	<xsl:template match="dtb:imggroup" mode="level"/>

	<!-- Ignoré si pas de level précédent (pris en mode flow). Déclenchement d'un mode flow sinon (sera en erreur mais contenu gardé pour restructuration -->
	<xsl:template match="dtb:*[not(contains($notFlow, local-name()))]|dtb:bridgehead" mode="level">
		<xsl:choose>
			<!-- Si le noeud précédent est un level. On relance un flow (pas dans le modèle car mauvaise pratique mais le contenu est conservé -->
			<xsl:when test="preceding-sibling::*[1][containWord('level1 level2 level3 level4 level 5 level6',local-name())]">
				<sp:flow>
					<paon:flow>
						<xsl:apply-templates select="current()" mode="flow"/>
					</paon:flow>
				</sp:flow>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- condition d'arrêt du parcours en mode flow -->
	<xsl:template match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6" mode="flow"/>

	<!-- Élément ignoré en mode flow -->
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6|dtb:note" mode="flow">
		<xsl:apply-templates select="following-sibling::*[1]" mode="flow"/>
	</xsl:template>

	<!-- Flow - titre flottant -->
	<xsl:template match="dtb:bridgehead" mode="flow">
		<sp:bridgehead>
			<paon:bridgehead>
				<sp:bridgehead>
					<xsl:value-of select="."/>
				</sp:bridgehead>
			</paon:bridgehead>
		</sp:bridgehead>
		<xsl:apply-templates select="following-sibling::*[1]" mode="flow"/>
	</xsl:template>

	<!-- Flow : contenu texte -->
	<xsl:template match="dtb:*[not(contains($notFlow, local-name()))]" mode="flow">
		<xsl:choose>
			<!-- Cas d'un level sans titre... la balise est en premier -->
			<xsl:when test="count(preceding-sibling::dtb:*)=0">
				<sp:content>
					<paon:text>
						<xsl:apply-templates select="current()" mode="para"/>
					</paon:text>
				</sp:content>
			</xsl:when>
			<!-- cas d'une balise qui suit une balise titre... on recrée un bloc content -->
			<xsl:when test="containWord($notFlow, local-name(preceding-sibling::dtb:*[1]))">
				<sp:content>
					<paon:text>
						<xsl:apply-templates select="current()" mode="para"/>
					</paon:text>
				</sp:content>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="following-sibling::dtb:*[containWord($notFlow, local-name())][1]" mode="flow"/>
	</xsl:template>


	<!-- Flux texte : para suivants -->
	<xsl:template match="dtb:p" mode="para">
		<sc:para xml:space="preserve"><xsl:apply-templates mode="txt"/></sc:para>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flux texte : para suivants -->
	<xsl:template match="dtb:pagenum" mode="para">
		<sc:para xml:space="preserve"><xsl:apply-templates select="." mode="txt"/></sc:para>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flux texte : list ordonnée -->
	<xsl:template match="dtb:list[@type='ol']" mode="para">
		<sc:orderedList>
			<xsl:for-each select="dtb:li">
				<sc:listItem>
					<xsl:apply-templates select="*[1]" mode="para"/>
				</sc:listItem>
			</xsl:for-each>
		</sc:orderedList>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flux texte : list non ordonnée -->
	<xsl:template match="dtb:list" mode="para">
		<sc:itemizedList>
			<xsl:for-each select="dtb:li">
				<sc:listItem>
					<xsl:apply-templates select="*[1]" mode="para"/>
				</sc:listItem>
			</xsl:for-each>
		</sc:itemizedList>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flux texte : balise author -->
	<xsl:template match="dtb:title" mode="para">
		<sc:para xml:space="preserve"><sc:inlineStyle role="titleCite"><xsl:apply-templates mode="txt"/></sc:inlineStyle></sc:para>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flux texte : balise author -->
	<xsl:template match="dtb:author|dtb:auteur" mode="para">
		<sc:para xml:space="preserve"><sc:inlineStyle role="author"><xsl:apply-templates mode="txt"/></sc:inlineStyle></sc:para>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flux texte : poème
	peut contenir (title | author | hd | dateline | epigraph | byline | linegroup | line | pagenum | img | imggroup | sidebar)* -->
	<xsl:template match="dtb:poem" mode="para">
		<sc:div role="poem">
			<xsl:apply-templates select="*[1]" mode="para"/>
		</sc:div>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>
	<!-- Ignorer les linegroup (pas prevu dans le model), garder son contenu -->
	<xsl:template match="dtb:linegroup" mode="para">
		<xsl:apply-templates mode="para"/>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>
	<!-- Conversion des lines en paragraphes -->
	<xsl:template match="dtb:line" mode="para">
		<sc:para xml:space="preserve"><xsl:apply-templates mode="txt"/></sc:para>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flow citation multi para -->
	<xsl:template match="dtb:blockquote" mode="para">
		<sc:div role="citation">
			<xsl:apply-templates select="*[1]" mode="para"/>
		</sc:div>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<xsl:template match="dtb:epigraph" mode="para">
		<sc:div role="epigraph">
			<xsl:apply-templates select="*[1]" mode="para"/>
		</sc:div>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flow sidebar -->
	<xsl:template match="dtb:sidebar" mode="para">
		<sc:div role="sidebar">
			<paon:sidebar>
				<sp:render>
					<xsl:value-of select="@render"/>
				</sp:render>
			</paon:sidebar>
			<xsl:apply-templates select="*[1]" mode="para"/>
		</sc:div>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Flux texte : conditions d'arrêts -->
	<xsl:template match="dtb:level1|dtb:level2|dtb:level3|dtb:level4|dtb:level5|dtb:level6" mode="para"/>
	<xsl:template match="dtb:bridgehead" mode="para"/>

	<!-- Flux texte : éléments ignorés -->
	<!-- br inutile si balise p -->
	<xsl:template match="dtb:imggroup|dtb:note|dtb:br" mode="para">
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- Tags internes au texte -->
	<!-- Strong -->
	<xsl:template match="dtb:strong" mode="txt">
		<sc:inlineStyle role="strong">
			<xsl:apply-templates mode="txt"/>
		</sc:inlineStyle>
	</xsl:template>
	<!-- Emphase -->
	<xsl:template match="dtb:em" mode="txt">
		<sc:inlineStyle role="emphase">
			<xsl:apply-templates mode="txt"/>
		</sc:inlineStyle>
	</xsl:template>
	<!-- sup -->
	<xsl:template match="dtb:sup" mode="txt">
		<sc:inlineStyle role="exposant">
			<xsl:apply-templates mode="txt"/>
		</sc:inlineStyle>
	</xsl:template>
	<!-- sub -->
	<xsl:template match="dtb:sub" mode="txt">
		<sc:inlineStyle role="inferieur">
			<xsl:apply-templates mode="txt"/>
		</sc:inlineStyle>
	</xsl:template>
	<!-- lettrine -->
	<xsl:template match="dtb:span[@class='let']" mode="txt">
		<xsl:apply-templates mode="txt"/>
	</xsl:template>
	<!-- smallcaps -->
	<xsl:template match="dtb:span[@class='smallcaps']" mode="txt">
		<span class="smallcaps">
			<xsl:apply-templates mode="txt"/>
		</span>
	</xsl:template>
	<!-- Abreviation -->
	<xsl:template match="dtb:abbr" mode="txt">
		<sc:inlineStyle role="abreviation">
			<paon:contentM>
				<sp:title>
					<xsl:value-of select="@title"/>
				</sp:title>
			</paon:contentM>
			<xsl:apply-templates mode="txt"/>
		</sc:inlineStyle>
	</xsl:template>
	<!-- lien -->
	<xsl:template match="dtb:a" mode="txt">
		<sc:inlineStyle role="url">
			<paon:url>
				<sp:url>
					<xsl:value-of select="@href"/>
				</sp:url>
				<xsl:if test="@title">
					<sp:title>
						<xsl:value-of select="@title"/>
					</sp:title>
				</xsl:if>
			</paon:url>
			<xsl:apply-templates mode="txt"/>
		</sc:inlineStyle>
	</xsl:template>

	<!-- br remplacé par espace -->
	<xsl:template match="dtb:br" mode="txt">
		<xsl:text> </xsl:text>
	</xsl:template>

	<!-- on ignore les tags w -->
	<xsl:template match="dtb:w" mode="txt">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="dtb:pagenum" mode="txt">
		<sc:emptyLeaf role="pageNumber">
			<paon:pageNumber>
				<sp:pageNumber>
					<xsl:apply-templates mode="txt"/>
				</sp:pageNumber>
			</paon:pageNumber>
		</sc:emptyLeaf>
	</xsl:template>

	<!-- Accronym -->
	<xsl:template match="dtb:acronym" mode="txt">
		<sc:inlineStyle role="acronym">
			<paon:contentM>
				<sp:title>
					<xsl:value-of select="@title"/>
				</sp:title>
				<sp:pronounce>
					<xsl:value-of select="returnFirst(@pronounce, 'no')"/>
				</sp:pronounce>
			</paon:contentM>
			<xsl:apply-templates mode="txt"/>
		</sc:inlineStyle>
	</xsl:template>
	<!-- note noteref -->
	<xsl:template match="dtb:noteref" mode="txt">
		<xsl:variable name="ref" select="substring(@idref, 2)"/>
		<sc:emptyLeaf role="note">
			<paon:note>
				<sp:content>
					<paon:text>
						<xsl:apply-templates select="//dtb:note[@id=$ref]/*[1]" mode="para"/>
					</paon:text>
				</sp:content>
			</paon:note>
		</sc:emptyLeaf>
	</xsl:template>
	<xsl:template match="dtb:note"/>
	<!-- recopie du flux texte -->
	<xsl:template match="text()" mode="txt">
		<xsl:value-of select="."/>
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

	<!-- Recopie des balises inconnues en commentaire pour affiner la XSL -->
	<xsl:template match="*" mode="level">
		<xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</xsl:copy>
		<xsl:text disable-output-escaping="yes"> --&gt;</xsl:text>
	</xsl:template>

	<!-- En mode flow, on ignore et passe en suivant (la recopie est faite au niveau level) -->
	<xsl:template match="*" mode="flow">
		<xsl:apply-templates select="following-sibling::*[1]" mode="flow"/>
	</xsl:template>

	<!-- en mode para, on recopie le flux texte dans un para avec inlineStyle erreur et tag error pour croix rouge -->
	<xsl:template match="*" mode="para">
		<sc:para xml:space="preserve"><sc:inlineStyle role="error">[Balise:<xsl:value-of select="local-name()"/>]
			<error/><xsl:value-of select="normalize-space()"/></sc:inlineStyle></sc:para>
		<xsl:apply-templates select="following-sibling::*[1]" mode="para"/>
	</xsl:template>

	<!-- en mode txt, on recopie le flux texte dans un inlineStyle erreur avec tag error pour croix rouge -->
	<xsl:template match="*" mode="txt">
		<sc:inlineStyle role="error"><error/>[Balise:<xsl:value-of select="local-name()"/>]<xsl:value-of select="normalize-space()"/>
		</sc:inlineStyle>
	</xsl:template>


	<xsl:template match="@*|node()" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<!-- suppression balises traitées par adressage direct (comme head ou h1...) -->
	<xsl:template match="dtb:h1|dtb:h2|dtb:h3|dtb:h4|dtb:h5|dtb:h6"/>
</xsl:stylesheet>
