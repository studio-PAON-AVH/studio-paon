<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                xmlns:java="http://xml.apache.org/xslt/java"
                exclude-result-prefixes="xs"
                version="1.0">
    <!-- 17/03/2021 XSLT développée par Luc Audrain dans le cadre du projet PAON piloté par Gautier Chomel -->
    <!-- XML source selon DTD LG ou Text Content toutes versions -->
    <!-- Sortie indentée, avec appel de la DTD DTBook 2005-3 -->
    <!-- 17/06/21 Passage en XSLT 1.0 par Thibaut Arribe (Kelis)-->
    <!-- 17/12/21 Ajustements et modifications pour correspondre au modéle PAON/scenari 6 par Gautier Chomel -->
    <xsl:output indent="yes" doctype-public="-//NISO//DTD dtbook 2005-3//EN" doctype-system="dtbook-2005-3.dtd"/>

    <!-- Initialisation : attraper la racine de l'arbre XML -->
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- ******************************************** -->
    <!-- Template maitre sur la balise <livre>
         Contruire l'arbre pricipal DTBook :
         dtbook avec version et namespace
         head
         book
         frontmatter
         bodymatter
         rearmatter
    -->
    <xsl:template match="livre">
        <dtbook version="2005-3" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xml:lang="fr-FR">
            <head>
                <!-- Alimenter le bloc head avec le bloc source ident -->
                <xsl:apply-templates select="
                    ident/node()[not(self::collec or self::dedi or self::exer)] |
                    métadonnées/node()"/>
            </head>
            <book>
                <frontmatter>
                    <doctitle>
                        <xsl:apply-templates select="ident/tit | métadonnées/titre" mode="doctitle"/>
                    </doctitle>
                    <docauthor>
                        <xsl:apply-templates select="ident/auteur | métadonnées/auteur " mode="doctitle"/>
                    </docauthor>
                    <xsl:if test="ident/collec | collec | appen/collec">
                        <level1 class="collection">
                            <xsl:apply-templates select="
                                ident/collec/node()
                                | collec/node()
                                | appen/collec/node()"/>
                        </level1>
                    </xsl:if>
                    <!-- Traitement element collecion de libella -->
                    <xsl:if test="collection">
                        <level1 class="collection">
                            <p><xsl:apply-templates select="node()" /></p>
                        </level1>
                    </xsl:if>
                    <xsl:if test="ident/dedi | ident/exer">
                        <level1 class="dedicace">
                            <xsl:apply-templates select="ident/dedi | ident/exer"/>
                        </level1>
                    </xsl:if>

                    <xsl:apply-templates select="pre|MalleAvant"/>
                </frontmatter>
                <bodymatter>
                    <!-- Alimenter le bloc bodymatter avec le bloc source corps -->
                    <xsl:apply-templates select="corps|vol"/>
                </bodymatter>
                <!-- NP 20230706 : il peut aussi y avoir des appcrit enhors du corps -->
                <xsl:if test="appen | appcrit">
                    <!-- Il y a des appendices hors du corps -->
                    <rearmatter>
                        <!-- Alimenter le bloc rearmatter avec le(s) bloc(s) source appen -->
                        <xsl:apply-templates select="appen | appcrit"/>
                    </rearmatter>
                </xsl:if>
            </book>
        </dtbook>
    </xsl:template>

    <!-- On ignore pour le moment livre2, potentiellement à traiter ultérieurement -->
    <xsl:template match="livre2"/>

    <!-- ******************************************** -->

    <!-- ******************************************** -->
    <!-- Traitement des éléments du bloc source ident -->

    <!-- ajout gautier-->
    <xsl:template match="ident/titreVO">
        <!-- Titre original -->
        <meta name="dc:Relation" content="{.}"/>
    </xsl:template><!-- fin ajout gautier-->

    <xsl:template match="ident">
        <xsl:apply-templates/>
        <xsl:if test="../@compo">
            <!-- Métadonnées pour l'information compositeur -->
            <meta name="dtb:producer" content="{../@compo}"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ident/tit | métadonnées/titre">
        <!-- Métadonnées pour l'information titre en mode ident -->
        <!-- le titre venant ici dans un attribut content, il faut traiter les balises éventuelles -->
        <!-- notamment remplacer les passages à la ligne <br/> par un espace-->
        <xsl:variable name="normalizedTitle">
            <xsl:apply-templates select="node()"/>
            <xsl:if test="../stit">
                <xsl:text> - </xsl:text>
                <xsl:value-of select="../stit/text()"/>
            </xsl:if>
        </xsl:variable>
        <meta name="dc:Title" content="{normalize-space($normalizedTitle)}"/>
    </xsl:template>

    <xsl:template match="ident/stit"/>
    <xsl:template match="métadonnées/faux-titre"/>
    <xsl:template match="métadonnées/type"/>
    <xsl:template match="métadonnées/nom">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="nom" mode="doctitle">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="métadonnées/prénom">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="prénom" mode="doctitle">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="paragraphe">
        <p><xsl:apply-templates select="node()"/></p>
    </xsl:template>

    <xsl:template
        match="pbib
            | collec/pbib">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <xsl:template
        match="collec/cint
            | collec/cint2">
        <bridgehead>
            <xsl:apply-templates/>
        </bridgehead>
    </xsl:template>

    <xsl:template match="collec/tit">
        <bridgehead><xsl:apply-templates /></bridgehead>
    </xsl:template>

    <xsl:template match="ident/auteur | métadonnées/auteur">
        <!-- Métadonnées pour l'information auteur -->
        <meta name="dc:Creator" content="{normalize-space(.)}"/>
    </xsl:template>
    <xsl:template match="ident/autcritique">
        <!-- Métadonnées pour l'information auteur -->
        <meta name="dc:Contributor" content="{normalize-space(.)}"/>
    </xsl:template>
    <xsl:template match="ident/surtit">
        <!-- Métadonnées pour l'information sur-titre -->
        <meta name="dc:surtit" content="{normalize-space(.)}"/>
    </xsl:template>
    <xsl:template match="ident/edit | métadonnées/éditeur">
        <!-- Métadonnées pour l'information éditeur -->
        <meta name="dc:Publisher" content="{normalize-space(.)}"/>
    </xsl:template>
    <xsl:template match="ident/copy | métadonnées/copyright">
        <!-- Métadonnées pour l'information copyright -->
        <meta name="dc:Rights" content="{normalize-space(.)}"/>
    </xsl:template>
    <xsl:template match="ident/ean | métadonnées/ean">
        <!-- Métadonnées pour l'information EAN uid + source - ajout gautier : FR-lg2dtb2021- (differencier de l'original-->
        <meta name="dtb:uid" content="FR-lg2dtb2021-{.}"/>
        <meta name="dtb:source" content="{.}"/>
    </xsl:template>
    <xsl:template
        match="ident/info
            | ident/modulus
            | ident/trad
            | ident/ref
            | métadonnées/divers"
    >
        <!-- On préserve en métadonnées description toutes les autres informations de l'ident en les préfixant avec leur balise d'origine  -->
        <!--exclusion de  | ident/isbn-->
        <xsl:if test="string-length(normalize-space(.)) &gt; 0">
            <meta name="dc:description" content="[{local-name()}]{normalize-space(.)}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ident/isbn | métadonnées/isbn">
        <!-- Métadonnées pour l'information source isbn-->
        <meta name="dtb:source" content="{.}"/>
    </xsl:template>

    <!--Gautier : passage en balise level1 class="dedication"-->
    <xsl:template match="ident/dedi">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <!--Gautier : on récupére le bloc collec = les livres du même auteur-->

    <!--fin ajout gautier-->

    <!-- Informations de l'ident ignorées : pas de correspondance en DTBook -->
    <!--exclusion de  | ident/isbn-->
    <xsl:template
        match="ident/type
            | ident/pagetitre
            | ident/ftit
            | ident/coned
            | ident/issn
            | ident/nbpages
            | ident/fstit"/>

    <!-- On ignore le bloc collec = les livres du même auteur (traité en frontmatter appelé depuis livre@mode='frontmatter'-->
    <!-- <xsl:template match="corps/collec"/> -->
    <!--on récupérera le bloc collec = les livres du même auteur en mode frontmatter-->

    <!-- Fin du traitemnt du bloc ident -->
    <!-- ******************************************** -->

    <!-- ******************************************** -->
    <!-- Mode frontmatter : traitement des dédicaces et des exergues de ident -->
    <xsl:template match="ident/exer">
        <epigraph>
            <xsl:apply-templates/>
        </epigraph>
    </xsl:template>
    <!--Gautier : passage en balise level1 class="dedication"-->
    <!-- <xsl:template match="ident/dedi">

         <p><xsl:apply-templates/></p>
         </xsl:template> -->
    <!--Gautier : on récupére le bloc collec = les livres du même auteur-->
    <!-- <xsl:template match="collec">
         <xsl:apply-templates/>
         </xsl:template> -->

    <xsl:template match="exer/source">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <!--Gautier : passage en balise source-->
        <!-- La balise cite ne semble pas gérer par la feuille dtbook vers dtmodel -->
        <xsl:choose>
            <xsl:when test="./p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <p class="source"><xsl:apply-templates/></p>
            </xsl:otherwise>
        </xsl:choose>
        <!-- <p class="source"><xsl:apply-templates/></p> -->
    </xsl:template>
    <xsl:template match="exer/auteur">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <!--Gautier : passage en balise author-->
        <author>
            <xsl:apply-templates/>
        </author>
    </xsl:template>

    <!-- ******************************************** -->

    <!-- ******************************************** -->
    <!-- Traitement des préliminaires, on est dans le frontmatter -->

    <!-- <xsl:template match="livre/pre">
         <level1>
         <xsl:if test="@folio">
         <pagenum id="p{@folio}">
         <xsl:value-of select="@folio"></xsl:value-of>
         </pagenum>
         </xsl:if>
         <xsl:for-each select="/livre/ident/dedi
         | /livre/ident/exer">
         <xsl:apply-templates select="."/>
         </xsl:for-each>
         <xsl:apply-templates/>
         </level1>
         </xsl:template> -->
    <xsl:template match="tit
        | titre
        | auteur" mode="doctitle">
        <!-- injection du titre et de l'auteur dans les balise doctitle et docauthor :
             on préserve le balisage interne mode doctitle -->
        <xsl:apply-templates mode="doctitle"/>
    </xsl:template>

    <xsl:template match="auteur">
        <author><xsl:apply-templates/></author>
    </xsl:template>

    <xsl:template match="i" mode="doctitle">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template match="b" mode="doctitle">
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>
    <xsl:template match="br" mode="doctitle">
        <!-- on préserve le br en mode doctitle -->
        <br/>
    </xsl:template>
    <xsl:template match="rp" mode="doctitle">
        <pagenum id="p{@folio}">
            <xsl:value-of select="@folio"/>
        </pagenum>
    </xsl:template>

    <xsl:template match="pre/exer">
        <epigraph>
            <xsl:apply-templates/>
        </epigraph>
    </xsl:template>
    <xsl:template match="chapeau">
        <epigraph>
            <xsl:apply-templates/>
        </epigraph>
    </xsl:template>
    <xsl:template match="/livre/pre/tit">
        <h1>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>
    <!-- ******************************************** -->

    <!-- ******************************************** -->
    <!-- traitement de la super structure du corps de texte -->
    <xsl:template match="corps">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="stit">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <p class="stit"><xsl:apply-templates/></p>
        <!-- probleme feuille d'import dtbook vers modele -->
        <!-- <bridgehead>
             <xsl:apply-templates/>
             </bridgehead> -->
    </xsl:template>

    <xsl:template
        match="appen/sect/tit
            | appcrit/sect/tit"
    >
        <h2 class="{local-name(..)}tit">
            <xsl:if test="local-name(preceding-sibling::*[1]) = 'n'">
                <xsl:value-of select="preceding-sibling::*[1]"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <!-- ******************************************** -->
    <!-- Traitement des développements de texte -->
    <xsl:template match="dev">
        <!-- on ne garde pas la balise dev, mais on injecte son contenu -->
        <xsl:apply-templates/>
    </xsl:template>

    <!-- on ne garde pas la balise vol, mais on injecte son contenu -->
    <!-- <xsl:template match="vol">
         <xsl:apply-templates/>
         </xsl:template>  -->

    <xsl:template match="r">
        <!-- on ne garde pas la balise r, mais on injecte son contenu -->
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Traitement paragraphes de texte -->
    <xsl:template match="p">
        <xsl:element name="p">
            <xsl:if test="preceding-sibling::let">
                <xsl:value-of select="preceding-sibling::let/text()"/>
            </xsl:if>
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="local-name() = 'igsStyle'">
                        <!-- passage de l'attribut igsStyle en attribut class -->
                        <xsl:attribute name="class">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:when>
                    <!-- suppression de l'attribut align -->
                    <xsl:when test="local-name() = 'align'"/>
                    <!-- suppression de l'attribut retrait -->
                    <xsl:when test="local-name() = 'retrait'"/>
                    <!-- conversion de lang en xml:lang
                    NP 2025 04 22 : pas de prefix xml, ne marche pas coter scenari-->
                    <xsl:when test="local-name() = 'lang'">
                        <xsl:attribute name="lang">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- on garde les autres attributs -->
                        <xsl:attribute name="{local-name()}">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <!-- avant d'injeter le contenu du paragraphe,
                 on recherche la présence d'une lettrine juste avant-->
            <xsl:if test="local-name(preceding-sibling::node()[1]) = 'let'">
                <!--  si ce paragraphe est précédé immédiatement par une balise lettrine,
                     l'injecter ici au début du paragraphe, mode lettrine -->
                <xsl:value-of select="preceding-sibling::node()[1]"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!-- on ignore la letrine au moment où elle est recontrée -->
    <!-- <xsl:template match="let"> -->
    <!-- la letrine est traitée dans le premier paragraphe qui la suit : mode lettrine -->

    <xsl:template match="let" mode="lettrine">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="let">
        <xsl:if test="parent::p">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <!-- Traitement lettre -->
    <xsl:template match="lettre">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>
    <!-- Pas de titre gérer dans blockquote
         reconversion de l'entete en paragraphe -->
    <xsl:template match="lettre/entete | cita/entete">
        <p class="entete"><xsl:apply-templates/></p>
    </xsl:template>

    <!--ajouts Gautier-->
    <!-- Traitement line -->
    <xsl:template match="line">
        <line>
            <xsl:apply-templates/>
        </line>
    </xsl:template>

    <!-- Traitement sms -->
    <xsl:template match="sms">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>
    <!-- suppression emetteur / recepteur -->
    <xsl:template match="sms/emetteur">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="sms/recepteur">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- conservation du nom vers author (vaut pour d'autres cas que SMS) -->
    <xsl:template match="nom">
        <author>
            <xsl:apply-templates/>
        </author>
    </xsl:template>
    <!-- Traitement infratexte -->
    <xsl:template match="infratexte">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>
    <!-- Traitement extrait -->
    <xsl:template match="extrait">
        <blockquote>
            <xsl:apply-templates/>
        </blockquote>
    </xsl:template>

    <!-- Source d'extrait ignoré (unwrapped) -->
    <xsl:template match="extrait/source">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <!-- Traitement exer -->
    <xsl:template match="exer">
        <epigraph>
            <xsl:apply-templates/>
        </epigraph>
    </xsl:template>
    <!-- Traitement dedi-->
    <xsl:template match="dedi">
        <epigraph>
            <p>
                <xsl:apply-templates/>
            </p>
        </epigraph>
    </xsl:template>
    <!-- Traitement lieu -->
    <xsl:template match="lieu">
        <address>
            <xsl:apply-templates/>
        </address>
    </xsl:template>

    <!-- Traitement ps -->
    <xsl:template match="ps">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <!-- Traitement fin -->
    <xsl:template match="fin">
        <p><xsl:apply-templates/></p>
    </xsl:template>

    <!-- Traitement enc (encadrés)-->
    <xsl:template match="enc">
        <!-- Si plusieurs niv1 + niv1/tit -->
        <!-- Créer des sidebar pour chaque section de l'encart -->
        <xsl:choose>
            <xsl:when test="count(dev/niv1) &gt; 0">
                <xsl:for-each select="dev/niv1">
                    <xsl:apply-templates select="." mode="encart"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <sidebar render="required">
                    <xsl:apply-templates/>
                </sidebar>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="niv1 | niv2 | niv3 | niv4 | niv5" mode="encart">
        <sidebar render="required">
            <xsl:apply-templates mode="encart"/>
        </sidebar>
    </xsl:template>
    <!-- TODO : remplacer les p par des hd dans les encarts/sidebar
         lorsque la xsl d'import du dtbook sera corrigé -->
    <xsl:template match="int" mode="encart">
        <p><xsl:apply-templates /></p>
    </xsl:template>
    <xsl:template match="node()|@*" mode="encart">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="enc/tit">
        <p><xsl:apply-templates/></p>
    </xsl:template>

    <!-- Traitement entete -->

    <xsl:template match="entete">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <!-- fin ajouts Gautier-->

    <!--Ajout Gautier-->
    <xsl:template match="poem/tit">
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <xsl:template match="item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <!--fin Ajout Gautier-->

    <!-- Traitement citation -->
    <xsl:template match="cita">
        <xsl:element name="blockquote">
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="local-name() = 'type'">
                        <!-- passage de l'attribut type en attribut class -->
                        <xsl:attribute name="class">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- on garde les autres attributs -->
                        <xsl:attribute name="{local-name()}">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="cita/auteur">
        <author>
            <xsl:apply-templates/>
        </author>
    </xsl:template>
    <xsl:template match="cita/source">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <p class="source"><xsl:apply-templates/></p>
    </xsl:template>
    <xsl:template match="date">
        <dateline>
            <xsl:apply-templates/>
        </dateline>
    </xsl:template>

    <!-- ******************************************** -->
    <!-- traitement des niv1, niv2, niv3, niv4, niv5 en intertitres -->
    <!-- <xsl:template
         match="niv1
         | niv2
         | niv3
         | niv4
         | niv5"
         >
         <xsl:apply-templates/>
         </xsl:template> -->
    <xsl:template match="int">
        <xsl:element name="bridgehead">
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="local-name() = 'igsStyle'">
                        <xsl:attribute name="class">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{local-name()}">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!-- ******************************************** -->
    <!-- Traitement de la typo et des éléments dans les textes -->
    <xsl:template match="sup">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    <xsl:template match="inf">
        <sub>
            <xsl:apply-templates/>
        </sub>
    </xsl:template>
    <xsl:template match="i
        | mev">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template
        match="b
            | sl
            | cint
            | titbib"
    >
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>

    <xsl:template match="pc">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- <xsl:template match="pc">
         <span class="smallcaps">
         <xsl:apply-templates/>
         </span>
         </xsl:template> -->
    <!-- ligne de blanc : suppression -->
    <xsl:template match="bl"/>
    <xsl:template match="sep">
        <!-- Séparateur, remplacés par étoiles-->
        <p><xsl:text>***</xsl:text>
            <!-- garder le type en attribut
                 Pas de possibilité de mettre des br en dehors des paragraphes,
                 donc report du br dans un p
                 <br title="{@type}"/>--></p>
    </xsl:template>
    <xsl:template match="paragraphe/sep">
        <!-- Séparateur, remplacés par étoiles-->
        <xsl:text>***</xsl:text>
        <!-- garder le type en attribut
             Pas de possibilité de mettre des br en dehors des paragraphes,
             donc report du br dans un p
             <br title="{@type}"/>-->
    </xsl:template>

    <!-- Remplacement des br dans du contenu par un espace-->
    <xsl:template match="br">
        <xsl:choose>
            <xsl:when test="
                ancestor::p
                or ancestor::int
                or ancestor::sint
                or ancestor::tit
                or ancestor::stit">
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <br/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="rp">
        <xsl:variable name="folio" select="@folio/."/>
        <xsl:choose>
            <xsl:when test="(preceding::node()/@folio/. = $folio)
                or (ancestor::node()/@folio/. = $folio)"/>
            <xsl:otherwise>
                <pagenum id="p{@folio}">
                    <xsl:value-of select="@folio" />
                </pagenum>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="sign">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <p class="sign"><xsl:apply-templates/></p>
    </xsl:template>
    <xsl:template match="hyperlink">
        <a href="{@uri}" external="true"/>
    </xsl:template>

    <xsl:template match="url/libelle">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="url">
        <xsl:choose>
            <xsl:when test="libelle and libelle/@cible">
                <a href="{libelle/@cible}" external="true">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>

            <xsl:when test="@cible">
                <a href="{@cible}" external="true">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a external="true">
                    <xsl:attribute name="href">
                        <xsl:value-of select="text()"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--  balise spécifique Flammarion -->
    <!-- <xsl:template match="refcible">
         <a href="{@id}"/>
         </xsl:template> -->

    <xsl:template match="pbib">
        <xsl:choose>
            <xsl:when test="ancestor::p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <p class="pbib"><xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="renv">
        <xsl:choose>
            <xsl:when test="ancestor::p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <p class="renv"><xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="renvlnk">
        <xsl:choose>
            <xsl:when test="ancestor::p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <p class="renvlnk"><xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- <!ELEMENT dialogue (((interloc?, (p | question | reponse | stroplg | bl | sep | list | cita | fig | tableau | enc)+))+, fin*)>  -->
    <xsl:template match="dialogue">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="interloc">
        <xsl:choose>
            <xsl:when test="./p">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
                <p class="interloc"><xsl:apply-templates /></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- <!ELEMENT question (p)*>
         Pas toujours vrai : sur la V5 il peut y avoir des question sans paragraphe-->
    <xsl:template match="question">
        <xsl:choose>
            <xsl:when test="./p">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
                <p class="question"><xsl:apply-templates /></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- <!ELEMENT reponse (p)*> -->
    <xsl:template match="reponse">
        <xsl:choose>
            <xsl:when test="./p">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
                <p class="reponse"><xsl:apply-templates /></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ******************************************** -->
    <!-- traitement des notes -->
    <xsl:template match="defnotes">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="apnb|apnb2|apnb3">
        <!--  appel de note -->
        <noteref class="footnote" idref="#{@id}">
            <xsl:value-of select="substring-after(@id,'ntb-')"/>
        </noteref>
    </xsl:template>
    <!-- Les notes de libella sont "inline"
         Separation en 2 template, avec l'insertion de la ref par défaut-->
    <xsl:template match="note">
        <!--  appel de note -->
        <noteref class="footnote" idref="#{@id}">
            <xsl:value-of select="count(preceding::note) + 1" />
        </noteref>
    </xsl:template>
    <xsl:template match="note" mode="notesSelector">
        <note class="footnote" id="{@id}">
            <p><xsl:apply-templates select="texte/text()"/></p>
        </note>
    </xsl:template>
    <xsl:template match="ntb|ntb2|ntb3">
        <!--  note -->
        <note class="endnote" id="{@id}">
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <!-- Ajout des notes de type apnf (note de fin) (GC)-->
    <xsl:template match="apnf">
        <!--  appel de note -->
        <noteref class="endnote" idref="#{@id}">
            <xsl:value-of select="substring-after(@id,'ntf-')"/>
        </noteref>
    </xsl:template>
    <xsl:template match="ntf">
        <!--  note -->
        <note class="endnote" id="{@id}">
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <!-- ******************************************** -->
    <!-- traitement des vers et des strophes -->
    <xsl:template match="stroplg">
        <poem class="stroplg">
            <xsl:apply-templates/>
        </poem>
    </xsl:template>
    <xsl:template match="verslg">
        <line class="verslg">
            <xsl:apply-templates/>
        </line>
    </xsl:template>

    <!-- Traitement des index -->
    <!-- On ignore les index-->
    <xsl:template match="indx|indx2|indx3|indx4|indx5|indx6|indx7|indx8">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- ******************************************** -->
    <!-- traitement des figures et appels d'image -->

    <!-- On ignore les appels de figure -->
    <xsl:template match="apfi"/>

    <!-- On ignore les images, figres dans ident -->
    <xsl:template match="ident/fig"/>

    <xsl:template match="fig">
        <xsl:element name="imggroup">
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="local-name() = 'folio'"/>
                    <xsl:otherwise>
                        <xsl:attribute name="{local-name()}">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="fig/leg">
        <caption>
            <xsl:apply-templates/>
            <xsl:apply-templates select="following-sibling::source/node()"/>
        </caption>
    </xsl:template>

    <xsl:template match="fig/source" />

    <xsl:template match="img">
        <xsl:element name="img">
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="local-name() = 'role'"/>
                    <xsl:otherwise>
                        <xsl:attribute name="{local-name()}">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>
            <xsl:if test="not(@alt)">
                <xsl:attribute name="alt">
                    <xsl:value-of select="'Aucune description disponible'"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!--
    -->

    <!-- Traitement des noeuds texte -->
    <xsl:template match="text()">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="text()" mode="doctitle">
        <xsl:copy/>
    </xsl:template>

    <!-- ******************************************************************** -->
    <!-- Voitures balais : signaler toute balise non traitée dans chaque mode -->
    <xsl:template match="*" mode="doctitle">
        <xsl:message>Elément XML non traduit [<xsl:value-of select="local-name()"/>] en mode doctitle
        </xsl:message>
        <!-- Voitures balais sans h& (donne un commentaire dans scenari):
             signaler toute balise non traitée dans chaque mode -->
        <xsl:element name="{local-name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*" mode="lettrine">
        <xsl:message>
            Elément XML non traduit [<xsl:value-of select="local-name()"/>] en mode lettrine
        </xsl:message>
        <!-- Voitures balais sans h& (donne un commentaire dans scenari):
             signaler toute balise non traitée dans chaque mode -->
        <xsl:element name="{local-name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*">
        <xsl:message>Elément XML non traduit [<xsl:value-of select="local-name()"/>]
        </xsl:message>
        <!-- Voitures balais sans h& (donne un commentaire dans scenari):
             signaler toute balise non traitée dans chaque mode -->
        <xsl:element name="{local-name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Essai refonte fonction de traitement des parties :
         marqueur de niveau considéré d'apres les demandes des
         transcripteurs et les précédents templates

         ancestor-or-self::conclusion
         | ancestor-or-self::epilogue
         | ancestor-or-self::annexe
         | ancestor-or-self::bio
         | ancestor-or-self::glossaire
         | ancestor-or-self::genealogie
         | ancestor-or-self::lexique
         | ancestor-or-self::historique
         | ancestor-or-self::notes
         | ancestor-or-self::remer
         | ancestor-or-self::biblio
         | ancestor-or-self::remarque
         | ancestor-or-self::chrono
         | ancestor-or-self::table
         | ancestor-or-self::table_aut
         | ancestor-or-self::table_noms
         | ancestor-or-self::table_alpha
         | ancestor-or-self::sommaire
         | ancestor-or-self::tdm
         | ancestor-or-self::index
         | ancestor-or-self::personnages
         | ancestor-or-self::horstexte
         | ancestor-or-self::autre
         | ancestor-or-self::part
         | ancestor-or-self::partie
         | ancestor-or-self::vol
         | ancestor-or-self::chap
         | ancestor-or-self::chapitre
         | ancestor-or-self::schap
         | ancestor-or-self::appen
         | ancestor-or-self::MalleArrière
         | ancestor-or-self::appcrit
         | ancestor-or-self::pre
         | ancestor-or-self::MalleAvant
         | ancestor-or-self::sect
         | ancestor-or-self::niv1
         | ancestor-or-self::niv2
         | ancestor-or-self::niv3
         | ancestor-or-self::niv4
         | ancestor-or-self::niv5
         | ancestor-or-self::collec
    -->

    <xsl:template match="
        vol
        | part
        | chap
        | schap
        | pre
        | sect
        | appen
        | appcrit
        | conclusion
        | epilogue
        | annexe
        | bio
        | glossaire
        | genealogie
        | lexique
        | historique
        | notes
        | remer
        | biblio
        | remarque
        | chrono
        | table_aut
        | table_noms
        | table_alpha
        | sommaire
        | tdm
        | index
        | personnages
        | horstexte
        | autre">
        <xsl:variable name="titleValue">
            <xsl:if test="n">
                <xsl:apply-templates select="n" mode="asTitle"/>
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:if test="surtit">
                <xsl:apply-templates select="surtit" mode="asTitle"/>
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="tit" mode="asTitle"/>
        </xsl:variable>
        <xsl:call-template name="createLevel">
            <xsl:with-param name="contentSelector" select="node()[
                    not(self::tit or self::n or self::surtit)
                ]"/>
            <xsl:with-param name="titleValue" select="normalize-space($titleValue)" />
        </xsl:call-template>
    </xsl:template>

    <!-- Reconversion des niveaux en sous-parties -->
    <xsl:template match="niv1 | niv2 | niv3 | niv4 | niv5">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::enc">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="titleValue">
                    <xsl:if test="n">
                        <xsl:apply-templates select="n" mode="asTitle"/>
                        <xsl:text> - </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="int" mode="asTitle"/>
                </xsl:variable>
                <xsl:call-template name="createLevel">
                    <xsl:with-param name="contentSelector" select="node()[
                            not(self::int or self::n)
                        ]"/>
                    <xsl:with-param name="titleValue" select="normalize-space($titleValue)" />
                </xsl:call-template>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="int|tit|surtit|TITRE|n|titre" mode="asTitle">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="list">
        <list type="ul">
            <xsl:choose>
                <xsl:when test="@type = 'num'">
                    <xsl:attribute name="type">ol</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type">ul</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
        </list>
    </xsl:template>

    <!-- Les sections tableau semblent regrouper des table en fin de sections
    -->
    <xsl:template match="tableau">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tableau/leg">
        <p><xsl:apply-templates select="node()"/></p>
    </xsl:template>
    <xsl:template match="tableau/source">
        <cite><xsl:apply-templates select="node()"/></cite>
    </xsl:template>

    <xsl:template match="table/title">
        <bridgehead><xsl:apply-templates select="node()"/></bridgehead>
    </xsl:template>
    <xsl:template match="table">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tgroup">
        <table>
            <xsl:apply-templates select="node()"/>
        </table>
    </xsl:template>

    <xsl:template match="thead">
        <thead>
            <xsl:apply-templates select="node()"/>
        </thead>
    </xsl:template>
    <xsl:template match="tbody">
        <tbody>
            <xsl:apply-templates select="node()"/>
        </tbody>
    </xsl:template>

    <xsl:template match="thead/row | tbody/row | tfoot/row">
        <tr>
            <xsl:apply-templates select="node()"/>
        </tr>
    </xsl:template>
    <xsl:template match="thead/row/entry | tbody/row/entry | tfoot/row/entry">
        <td>
            <xsl:apply-templates select="node()"/>
        </td>
    </xsl:template>
    <xsl:template match="colspec"/>

    <xsl:template match="sint">
        <bridgehead>
            <xsl:apply-templates select="node()"/>
        </bridgehead>
    </xsl:template>

    <xsl:template match="reforg">
        <xsl:apply-templates select="node()" />
    </xsl:template>
    <xsl:template match="refcible">
        <xsl:apply-templates select="node()" />
    </xsl:template>

    <!-- Theatre (flammarion) -->
    <xsl:template match="vers">
        <p><xsl:apply-templates select="node()"/></p>
    </xsl:template>

    <xsl:template match="replique">
        <p><xsl:apply-templates select="pers//text()"/> :</p>
        <xsl:apply-templates select="pers/following-sibling::*"/>
    </xsl:template>

    <xsl:template match="pers">
        <p><xsl:apply-templates select=".//text()"/></p>
    </xsl:template>
    <xsl:template match="extrait/tit">
        <p class="extrait-tit"><xsl:apply-templates /></p>
    </xsl:template>

    <xsl:template match="theatre">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="role">
        <xsl:apply-templates />
    </xsl:template>
    <xsl:template match="expos">
        <p><xsl:apply-templates /></p>
    </xsl:template>
    <xsl:template match="didasc">
        <p><xsl:apply-templates /></p>
    </xsl:template>

    <xsl:template match="acte | scene | distrib">
        <xsl:choose>
            <xsl:when test="ancestor-or-self::extrait">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="titleValue">
                    <xsl:if test="n">
                        <xsl:apply-templates select="n" mode="asTitle"/>
                    </xsl:if>
                    <xsl:if test="tit">
                        <xsl:apply-templates select="tit" mode="asTitle"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:call-template name="createLevel">
                    <xsl:with-param name="contentSelector" select="node()[
                            not(self::n or self::tit)
                        ]"/>
                    <xsl:with-param name="titleValue" select="normalize-space($titleValue)" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- gestion par défaut des titres de scene (pour les extraits) -->
    <xsl:template match="scene/tit">
        <p class="scene-tit"><xsl:apply-templates select="node()"/></p>
    </xsl:template>
    <xsl:template match="scene/n">
        <p class="scene-n"><xsl:apply-templates select="node()"/></p>
    </xsl:template>

    <xsl:template match="MalleAvant">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <!-- libella : element section
         NP 2025 04 10 : des section existe dans flammarion et sont mélanger avec du LG -->
    <xsl:template match="partie | chapitre | section">
        <xsl:variable name="titleValue">
            <xsl:choose>
                <xsl:when test="MalleAvant/péritexte/titre">
                    <xsl:apply-templates select="MalleAvant/péritexte/titre" mode="asTitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="n">
                        <xsl:apply-templates select="n" mode="asTitle"/>
                        <xsl:text> - </xsl:text>
                    </xsl:if>
                    <xsl:if test="surtit">
                        <xsl:apply-templates select="surtit" mode="asTitle"/>
                        <xsl:text> - </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="tit" mode="asTitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="createLevel">
            <xsl:with-param name="contentSelector" select="chap | chapitre | contenu/node()"/>
            <xsl:with-param name="titleValue" select="normalize-space($titleValue)" />
            <xsl:with-param name="notesSelector" select="contenu//note" />
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="péritexte">
        <xsl:variable name="titleValue">
            <xsl:apply-templates select="titre" mode="asTitle"/>
        </xsl:variable>
        <xsl:call-template name="createLevel">
            <xsl:with-param name="contentSelector" select="corps[not(following-sibling::référence)]/contenu/node() | corps[following-sibling::référence]"/>
            <xsl:with-param name="titleValue" select="normalize-space($titleValue)" />
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="corps[following-sibling::référence]">
        <blockquote>
            <xsl:apply-templates select="contenu/node()"/>
            <xsl:apply-templates select="../référence"/>
        </blockquote>
    </xsl:template>
    <xsl:template match="référence">
        <p><xsl:apply-templates select="node()"/></p>
    </xsl:template>
    <xsl:template match="oeuvre-titre">
        <em><xsl:apply-templates select="node()"/></em>
    </xsl:template>

    <!--
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         Portage traitement IGS
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    -->
    <xsl:template match="LIVRE">
        <xsl:variable name="titre" select="normalize-space(INFO/TITRE/text())"/>
        <xsl:variable name="auteur" select="normalize-space(INFO/AUTEUR/text())"/>
        <xsl:variable name="editeur" select="normalize-space(INFO/EDITEUR/text())"/>
        <xsl:variable name="ISBN" select="concat('978',substring-after(normalize-space(INFO/ISBN/text()), '978'))"/>
        <dtbook version="2005-3" xmlns="http://www.daisy.org/z3986/2005/dtbook/" xml:lang="fr-FR">
            <head>
                <meta content="{$titre}" name="dc:Title"/>
                <meta content="{$auteur}" name="dc:Creator"/>
                <meta scheme="ISBN" content="{$ISBN}" name="dc:Identifier"/>
                <meta content="{$editeur}" name="dc:Publisher"/>
                <meta content="fr-FR" name="dc:Language"/>
            </head>
            <book>
                <frontmatter>
                    <doctitle><xsl:value-of select="$titre"/></doctitle>
                    <docauthor><xsl:value-of select="$auteur"/></docauthor>
                    <level1>
                        <xsl:apply-templates select="INFO/node()"/>
                    </level1>
                    <xsl:apply-templates select="LIMINAIRE"/>
                </frontmatter>
                <xsl:apply-templates select="CORPS"/>

                <rearmatter>
                    <xsl:apply-templates select="APPENDICE"/>
                    <level1>
                        <h1></h1>
                        <p>ISBN: <xsl:value-of select="$ISBN"/></p>
                    </level1>
                </rearmatter>
            </book>
        </dtbook>
    </xsl:template>

    <xsl:template match="ITAL">
        <em><xsl:apply-templates/></em>
    </xsl:template>
    <xsl:template match="GRAS">
        <strong><xsl:apply-templates/></strong>
    </xsl:template>
    <xsl:template match="EXP">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>
    <xsl:template match="INTERTITRE">
        <bridgehead><xsl:apply-templates select="node()"/></bridgehead>
    </xsl:template>

    <xsl:template match="PCAP">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="LIENINTERNE">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="TABLEAU">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="IMAGE">
        <xsl:text>(Voir image </xsl:text><xsl:value-of select="@fichier" /><xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:template match="RP|BLANC|INDEX|BR|SEP" />

    <xsl:template match="SIGNATURE">
        <p><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="
        P
        | entry/P
        | PBIB
        | INFO/FXTITRE
        | INFO/TITRE
        | INFO/STITRE
        | INFO/DIRECTION
        | INFO/AUTEUR
        | INFO/EDITEUR
        | INFO/ISBN
        | INFO/DEPOT
        | INFO/COPYRIGHT">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <!-- <xsl:template match="INFO/TITRE">
         <h1><xsl:apply-templates/></h1>
         </xsl:template> -->

    <xsl:template match="LIMINAIRE|APPENDICE">
        <level1>
            <h1><xsl:apply-templates select="TITRE/node()"/></h1>
            <xsl:apply-templates select="DEV/node()"/>
            <xsl:if test="SIGNATURE">
                <p><xsl:apply-templates select="SIGNATURE/node()"/></p>
            </xsl:if>
        </level1>
    </xsl:template>

    <xsl:template match="LETTRINE">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="TYPE"/>

    <xsl:template match="EXERGUE">
        <epigraph>
            <xsl:apply-templates select="node()"/>
        </epigraph>
    </xsl:template>

    <xsl:template match="CORPS">
        <bodymatter>
            <xsl:apply-templates select="node()"/>
        </bodymatter>
    </xsl:template>

    <xsl:template match="CITATION">
        <blockquote>
            <xsl:apply-templates select="node()"/>
        </blockquote>
    </xsl:template>

    <xsl:template match="DEV">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="PARTIE | CHAPITRE">
        <xsl:variable name="titleValue">
            <xsl:if test="NUMERO">
                <xsl:value-of select="NUMERO/text()"/>
                <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="TITRE" mode="asTitle"/>
        </xsl:variable>
        <xsl:call-template name="createLevel">
            <xsl:with-param name="contentSelector" select="node()[
                    not(self::TITRE or self::NUMERO)
                ]"/>
            <xsl:with-param name="titleValue" select="normalize-space($titleValue)" />
        </xsl:call-template>
    </xsl:template>

    <!-- /////////////// UTILITAIRES ///////////////// -->

    <xsl:template name="createLevel">
        <xsl:param name="contentSelector"/>
        <xsl:param name="titleValue"/>
        <xsl:param name="notesSelector" select="comment()"/>
        <xsl:variable name="levelCount" select="count(
                ancestor-or-self::conclusion
                | ancestor-or-self::epilogue
                | ancestor-or-self::annexe
                | ancestor-or-self::bio
                | ancestor-or-self::glossaire
                | ancestor-or-self::genealogie
                | ancestor-or-self::lexique
                | ancestor-or-self::historique
                | ancestor-or-self::notes
                | ancestor-or-self::remer
                | ancestor-or-self::biblio
                | ancestor-or-self::remarque
                | ancestor-or-self::chrono
                | ancestor-or-self::table
                | ancestor-or-self::table_aut
                | ancestor-or-self::table_noms
                | ancestor-or-self::table_alpha
                | ancestor-or-self::sommaire
                | ancestor-or-self::tdm
                | ancestor-or-self::index
                | ancestor-or-self::personnages
                | ancestor-or-self::horstexte
                | ancestor-or-self::autre
                | ancestor-or-self::part
                | ancestor-or-self::partie
                | ancestor-or-self::PARTIE
                | ancestor-or-self::vol
                | ancestor-or-self::chap
                | ancestor-or-self::chapitre
                | ancestor-or-self::CHAPITRE
                | ancestor-or-self::schap
                | ancestor-or-self::appen
                | ancestor-or-self::appcrit
                | ancestor-or-self::pre
                | ancestor-or-self::sect
                | ancestor-or-self::péritexte
                | ancestor-or-self::section
                | ancestor-or-self::partie
                | ancestor-or-self::chapitre
                | ancestor-or-self::niv1
                | ancestor-or-self::niv2
                | ancestor-or-self::niv3
                | ancestor-or-self::niv4
                | ancestor-or-self::niv5
                | ancestor-or-self::collec
                | ancestor-or-self::distrib
                | ancestor-or-self::acte
                | ancestor-or-self::scene
            )"/>
        <xsl:choose>
            <xsl:when test="$levelCount = 1">
                <level1 class="{name()}">
                    <h1><xsl:value-of select="$titleValue"/></h1>
                    <xsl:apply-templates select="$contentSelector"/>
                    <xsl:if test="$notesSelector">
                        <xsl:apply-templates select="$notesSelector" mode="notesSelector"/>
                    </xsl:if>
                </level1>
            </xsl:when>
            <xsl:when test="$levelCount = 2">
                <level2 class="{name()}">
                    <h2><xsl:value-of select="$titleValue"/></h2>
                    <xsl:apply-templates select="$contentSelector"/>
                    <xsl:if test="$notesSelector">
                        <xsl:apply-templates select="$notesSelector" mode="notesSelector"/>
                    </xsl:if>
                </level2>
            </xsl:when>
            <xsl:when test="$levelCount = 3">
                <level3 class="{name()}">
                    <h3><xsl:value-of select="$titleValue"/></h3>
                    <xsl:apply-templates select="$contentSelector"/>
                    <xsl:if test="$notesSelector">
                        <xsl:apply-templates select="$notesSelector" mode="notesSelector"/>
                    </xsl:if>
                </level3>
            </xsl:when>
            <xsl:when test="$levelCount = 4">
                <level4 class="{name()}">
                    <h4><xsl:value-of select="$titleValue"/></h4>
                    <xsl:apply-templates select="$contentSelector"/>
                    <xsl:if test="$notesSelector">
                        <xsl:apply-templates select="$notesSelector" mode="notesSelector"/>
                    </xsl:if>
                </level4>
            </xsl:when>
            <xsl:when test="$levelCount = 5">
                <level5 class="{name()}">
                    <h5><xsl:value-of select="$titleValue"/></h5>
                    <xsl:apply-templates select="$contentSelector"/>
                    <xsl:if test="$notesSelector">
                        <xsl:apply-templates select="$notesSelector" mode="notesSelector"/>
                    </xsl:if>
                </level5>
            </xsl:when>
            <xsl:when test="$levelCount = 6">
                <level6 class="{name()}">
                    <h6><xsl:value-of select="$titleValue"/></h6>
                    <xsl:apply-templates select="$contentSelector"/>
                    <xsl:if test="$notesSelector">
                        <xsl:apply-templates select="$notesSelector" mode="notesSelector"/>
                    </xsl:if>
                </level6>
            </xsl:when>
            <xsl:otherwise>
                <bridgehead class="{name()}">
                    <xsl:value-of select="$titleValue"/>
                </bridgehead>
                <xsl:apply-templates select="$contentSelector"/>
                <xsl:if test="$notesSelector">
                    <xsl:apply-templates select="$notesSelector" mode="notesSelector"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
