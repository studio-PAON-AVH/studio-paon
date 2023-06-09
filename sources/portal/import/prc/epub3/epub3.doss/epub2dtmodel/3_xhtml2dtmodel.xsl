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
								version="1.0" xmlns:xsm="http://www.w3.org/1999/XSL/Transform"
								extension-element-prefixes="redirect" exclude-result-prefixes="xalan java sc sp" xsi:schemaLocation="editadapt.fr:paon ">

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:template match="sc:*|sp:*|paon:*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="level">
		<xsl:choose>
			<xsl:when test="count(ancestor::level) = 0">
				<sp:level1>
					<xsl:apply-templates select="sp:title"/>
					<paon:level1><xsl:apply-templates select="flow"/><xsl:apply-templates select="level"/></paon:level1>
				</sp:level1>
			</xsl:when>
			<xsl:when test="count(ancestor::level) = 1">
				<sp:level2>
					<xsl:apply-templates select="sp:title"/>
					<paon:level2><xsl:apply-templates select="flow"/><xsl:apply-templates select="level"/></paon:level2>
				</sp:level2>
			</xsl:when>
			<xsl:when test="count(ancestor::level) = 2">
				<sp:level3>
					<xsl:apply-templates select="sp:title"/>
					<paon:level3><xsl:apply-templates select="flow"/><xsl:apply-templates select="level"/></paon:level3>
				</sp:level3>
			</xsl:when>
			<xsl:when test="count(ancestor::level) = 3">
				<sp:level4>
					<xsl:apply-templates select="sp:title"/>
					<paon:level4><xsl:apply-templates select="flow"/><xsl:apply-templates select="level"/></paon:level4>
				</sp:level4>
			</xsl:when>
			<xsl:when test="count(ancestor::level) = 4">
				<sp:level5>
					<xsl:apply-templates select="sp:title"/>
					<paon:level5><xsl:apply-templates select="flow"/><xsl:apply-templates select="level"/></paon:level5>
				</sp:level5>
			</xsl:when>
			<xsl:otherwise>
				<sp:level6>
					<xsl:apply-templates select="sp:title"/>
					<paon:level6><xsl:apply-templates select="flow"/><xsl:apply-templates select="level"/></paon:level6>
				</sp:level6>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="level/sp:title"><paon:title><xsl:copy><xsl:apply-templates/></xsl:copy></paon:title></xsl:template>

	<xsl:template match="flow">
		<xsl:if test="*">
			<xsl:choose>
				<xsl:when test="count(ancestor::level) = 0">
					<sp:level1>
						<xsl:apply-templates select="sp:title"/>
						<paon:level1><sp:flow><paon:flow><sp:content><paon:text><xsl:apply-templates/></paon:text></sp:content></paon:flow></sp:flow></paon:level1>
					</sp:level1>
				</xsl:when>
				<xsl:otherwise>
					<sp:flow><paon:flow><sp:content><paon:text><xsl:apply-templates/></paon:text></sp:content></paon:flow></sp:flow>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- transformation du texte -->
	<xsl:template match="xhtml:p"><sc:para xml:space="preserve"><xsl:apply-templates/></sc:para></xsl:template>
	<xsl:template match="xhtml:span[@epub:type='pagebreak']"><sc:emptyLeaf role="pageNumber"><paon:pageNumber><sp:pageNumber><xsl:value-of select="@title"/></sp:pageNumber><xsl:apply-templates/></paon:pageNumber></sc:emptyLeaf></xsl:template>
	<xsl:template match="xhtml:img"><sc:para xml:space="preserve">Image alt : <xsl:value-of select="@alt"/></sc:para></xsl:template>
	<xsl:template match="xhtml:strong|xhtml:b"><sc:inlineStyle role="strong"><xsl:apply-templates/></sc:inlineStyle></xsl:template>
	<xsl:template match="xhtml:em|xhtml:i|span[@class='i']"><sc:inlineStyle role="emphase"><xsl:apply-templates/></sc:inlineStyle></xsl:template>
	<xsl:template match="xhtml:sup"><sc:inlineStyle role="exposant"><xsl:apply-templates/></sc:inlineStyle></xsl:template>
	<xsl:template match="xhtml:sub"><sc:inlineStyle role="inferieur"><xsl:apply-templates/></sc:inlineStyle></xsl:template>
	<xsl:template match="xhtml:aside[@noteID]">
		<xsl:variable name="nodeID" select="@noteID"/>
		<xsl:choose>
			<xsl:when test="//xhtml:a[@noteRefID=$nodeID]"/>
			<xsl:otherwise><sc:inlineStyle role="error">[Balise:<xsl:value-of select="local-name()"/><xsl:apply-templates select="@*" mode="inlineError"/>. Référence à la note non trouvée]<error/><xsl:value-of select="normalize-space()"/></sc:inlineStyle></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="xhtml:a">
		<xsl:choose>
			<xsl:when test="self::xhtml:a[@noteRefID]">
			<xsl:variable name="noteRefID" select="@noteRefID"/>
			<xsl:variable name="aside" select="//xhtml:aside[@noteID=$noteRefID]"/>
			<xsl:choose>
				<xsl:when test="$aside"><sc:emptyLeaf role="note">
					<paon:note>
						<sp:content>
							<paon:text>
								<xsl:apply-templates select="$aside/*"/>
							</paon:text>
						</sp:content>
					</paon:note>
				</sc:emptyLeaf></xsl:when>
				<xsl:otherwise><sc:inlineStyle role="error">[Balise:<xsl:value-of select="local-name()"/><xsl:apply-templates select="@*" mode="inlineError"/>. Contenu de la note non trouvé]<error/><xsl:value-of select="normalize-space()"/></sc:inlineStyle></xsl:otherwise>
			</xsl:choose></xsl:when>
			<xsl:when test="starts-with(@href, 'http') or starts-with(@href, 'mailto')"><sc:inlineStyle role="url">
				<paon:url>
					<sp:url><xsl:value-of select="@href"/></sp:url>
					<xsl:if test="@title"><sp:title><xsl:value-of select="@title"/></sp:title></xsl:if>
				</paon:url><xsl:apply-templates/></sc:inlineStyle> </xsl:when>
			<xsl:otherwise><sc:inlineStyle role="error">[Balise:<xsl:value-of select="local-name()"/><xsl:apply-templates select="@*" mode="inlineError"/>]<error/><xsl:value-of select="normalize-space()"/></sc:inlineStyle></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="xhtml:cite"><sc:phrase role="cite"><xsl:apply-templates/></sc:phrase></xsl:template>
	<xsl:template match="xhtml:br"><xsl:text> </xsl:text></xsl:template>
	<xsl:template match="xhtml:span[@class='pc']|xhtml:span[@class='lettrine']"><span class="smallcaps"><xsl:apply-templates select="*"/></span></xsl:template>
	<xsl:template match="xhtml:span[@lang]|xhtml:span[@xml:lang]"><sc:inlineStyle role="lang"><paon:langM><sp:lang><xsl:value-of select="@lang|@xml:lang"/></sp:lang></paon:langM><xsl:apply-templates/></sc:inlineStyle></xsl:template>
	<xsl:template match="xhtml:blockquote"><sc:div role="citation"><xsl:apply-templates/></sc:div></xsl:template>

	<!-- Balises ignorés dont le contenu est traité -->
	<xsl:template match="span[@class='nchap']"><xsl:apply-templates/></xsl:template>
	<xsl:template match="span[@class='chap']"><xsl:apply-templates/></xsl:template>

	<!-- Recopie des balises inconnues en commentaire pour affiner la XSL -->
	<xsl:template match="@*|node()">
		<xsl:choose>
			<xsl:when test="self::processing-instruction()"/>
			<xsl:when test="self::comment()"><xsl:copy/></xsl:when>
			<xsl:when test="self::text()"><xsl:copy/></xsl:when>
			<xsl:when test="ancestor::xhtml:p"><sc:inlineStyle role="error">[Balise:<xsl:value-of select="local-name()"/><xsl:apply-templates select="@*" mode="inlineError"/>]<error/><xsl:value-of select="normalize-space()"/></sc:inlineStyle></xsl:when>
			<xsl:when test="ancestor::flow"><sc:para xml:space="preserve"><sc:inlineStyle role="error">[Balise:<xsl:value-of select="local-name()"/><xsl:apply-templates select="@*" mode="inlineError"/>]<error/><xsl:value-of select="normalize-space()"/></sc:inlineStyle></sc:para></xsl:when>
			<xsl:when test="*">
				<xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
					<xsl:copy>
						<xsl:apply-templates select="@*|node()" mode="copy"/>
					</xsl:copy>
					<xsl:text disable-output-escaping="yes"> --&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()" mode="copy"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*|node" mode="copy">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="copy"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*" mode="inlineError"><xsl:text> </xsl:text><xsl:value-of select="local-name()"/><xsl:text>="</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text></xsl:template>

</xsl:stylesheet>
