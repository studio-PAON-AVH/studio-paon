<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
								xmlns:xalan="http://xml.apache.org/xalan"
								xmlns:java="http://xml.apache.org/xslt/java"
								xmlns:xhtml="http://www.w3.org/1999/xhtml"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								exclude-result-prefixes="xalan java xhtml">

	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="vDialog"/>
	<xsl:param name="vAgent"/>

	<xsl:param name="main_html_file"/>
	<xsl:param name="view_path"/>
	<xsl:param name="package"/>

	<xsl:param name="dPfx"/>
	<xsl:param name="pPfx"/>
	<xsl:param name="sPfx"/>

	<xsl:variable name="html" select="document(concat('inDir:../', $main_html_file))/xhtml:html"/>
	<xsl:variable name="div" select="$html/xhtml:body/descendant::xhtml:div[@id=concat($dPfx, $package)]"/>
	<xsl:variable name="sentences" select="$div/descendant::xhtml:span[containWord(@class, 'sentence')]"/>
	<xsl:variable name="audio_file" select="concat($package, '.mp3')"/>
	<!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
	<xsl:variable name="total_time" select="returnFirst(/o/a/o[last()-1]/o[@k='Time']/n/text(), /o/a/o[last()-1]/s[@k='Time']/text())"/>
	<xsl:variable name="durations" select="java:getVar($vDialog, 'durations')"/>
	<xsl:variable name="previous-audio" select="count($div/preceding::xhtml:div[not(containWord(@class, 'note')) and @id]) + count($div/ancestor::xhtml:div[not(@class='note') and @id])"/>

	<xsl:variable name="format-audio-duration" select="'%02d:%02d:%02d.%03d'"/>

	<xsl:template match="/">
		<smil>
			<head>
				<meta name="dc:format" content="Daisy 2.02"/>
				<meta name="ncc:timeInThisSmil" content="{java:eu.scenari.editadapt.utils.Utils.formatDuration($durations, $previous-audio, $format-audio-duration)}"/>
				<meta name="ncc:totalElapsedTime" content="{java:eu.scenari.editadapt.utils.Utils.formatSumDuration($durations, $previous-audio, $format-audio-duration)}"/>
				<layout>
					<region id="txtView"/>
				</layout>
				<meta name="ncc:generator" content="{$html/xhtml:head/xhtml:meta[@name='ncc:generator']/@content}"/>
				<meta name="title" content="{$div/*[1]/xhtml:span/text()}"/>
				<meta name="dc:title" content="{$html/xhtml:head/xhtml:meta[@name='dc:title']/@content}"/>
				<meta name="dc:identifier" content="{$html/xhtml:head/xhtml:meta[@name='dc:identifier']/@content}"/>
			</head>
			<body>
				<seq dur="{$total_time}s">
					<xsl:for-each select="o/a/o[s[@k='EventKind' and text()='Sentence']][s[@k='Sentence' and string-length(text()) > 0 and  not(starts-with(text(),'\pau='))]]">
						<xsl:variable name="pos" select="count(preceding-sibling::o/s[@k='EventKind' and text()='Sentence']/parent::o/s[@k='Sentence' and string-length(text()) > 0]/parent::o)+1"/>
						<xsl:variable name="next" select="following-sibling::o/s[@k='EventKind' and text()='Sentence']/parent::o/s[@k='Sentence' and string-length(text()) > 0]/parent::o"/>
						<xsl:variable name="sentence" select="$sentences[$pos]"/>
						<xsl:variable name="sentence_id" select="substring($sentence/@id, string-length($sPfx)+1)"/>

						<xsl:choose>
							<!-- Si le noeud est un span fils d'un h et qu'il a un preceding sibling de nom span
								-> pas de publication (la synchro ne fonctionne pas sur les span de phrases dans un heading)
							-->
							<xsl:when test="$sentence[parent::*[starts-with(local-name(), 'h')] and preceding-sibling::xhtml:span]"/>
							<xsl:otherwise>
								<par endsync="last" id="par_{$sentence_id}">
									<text src="{$main_html_file}#{$sPfx}{$sentence_id}" id="tts_{$sentence_id}"/>
									<seq>
										<!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
										<audio src="{$audio_file}" clip-begin="npt={returnFirst(o[@k='Time']/n/text(), s[@k='Time']/text())}s" id="audio_{$sentence_id}"><xsl:attribute name="clip-end">npt=<xsl:choose>
												<xsl:when test="$sentence[parent::*[starts-with(local-name(), 'h')]]">
													<!-- Dans les niveaux de titres, les spans de phrases sont supprimé en post traitement -->
													<xsl:variable name="deleted_spans" select="count($sentence/following-sibling::xhtml:span)+1"/>
													<xsl:variable name="next_not_deleted" select="following-sibling::o[s[@k='EventKind' and text()='Sentence'] and s[@k='Sentence' and string-length(text()) > 0]][$deleted_spans]" />
													<xsl:choose>
														<!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
														<xsl:when test="$next_not_deleted"><xsl:value-of select="returnFirst($next_not_deleted/o[@k='Time']/n/text(), $next_not_deleted/s[@k='Time']/text())"/></xsl:when>
														<xsl:otherwise><xsl:value-of select="$total_time"/></xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:when test="$next">
													<!-- FIXME : clean de la premiere écriture de récup du time après maj api acapela -->
													<xsl:value-of select="returnFirst($next/o[@k='Time']/n/text(), $next/s[@k='Time']/text())"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$total_time"/>
												</xsl:otherwise>
											</xsl:choose>s</xsl:attribute>
										</audio>
									</seq>
								</par>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</seq>
			</body>
		</smil>
	</xsl:template>

	<xsl:template match="@*|node()">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:template>
</xsl:stylesheet>
