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
                <xsl:apply-templates select="ident"/>
            </head>
            <book>
                <frontmatter>
                    <doctitle>
                        <xsl:apply-templates select="ident/tit" mode="doctitle"/>
                    </doctitle>
                    <docauthor>
                        <xsl:apply-templates select="ident/auteur" mode="doctitle"/>
                    </docauthor>
                    <xsl:for-each
                            select="ident/dedi|ident/exer
                                 | ident/collec
                                 | collec
                                 | appen/collec"
                    >
                        <level1>
                            <xsl:choose>
                                <xsl:when test="name()='collec'">
                                    <xsl:attribute name="class">collection</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="class">dedicace</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates select="." mode="frontmatter"/>
                        </level1>
                    </xsl:for-each>
                </frontmatter>
                <bodymatter>
                    <!-- Alimenter le bloc bodymatter avec le bloc source corps -->
                    <xsl:apply-templates select="pre|corps|vol"/>
                </bodymatter>
                <!-- NP 20230706 : il peut aussi y avoir des appcrit enhors du corps -->
                <xsl:if test="appen
                            | appcrit"
                >
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
    <xsl:template match="ident/tit">
        <!-- Métadonnées pour l'information titre en mode ident -->
        <!-- le titre venant ici dans un attribut content, il faut traiter les balises éventuelles -->
        <!-- notamment remplacer les passages à la ligne <br/> par un espace-->
        <xsl:element name="meta">
            <xsl:attribute name="name">dc:Title</xsl:attribute>
            <xsl:attribute name="content">
                <xsl:apply-templates select="." mode="ident"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tit" mode="ident">
        <!-- Mode ident : traitement des informations titre de ident pour insertion dans l'attribut content de la balise meta -->
        <xsl:apply-templates mode="ident"/>
    </xsl:template>
    <xsl:template match="br" mode="ident">
        <!-- Mode ident: remplacement de <br/> par un espace-->
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template
            match="b
                 | pbib
                 | sl
                 | cint
                 | ident/collec/pbib
                 | ident/collec/cint"
            mode="frontmatter"
    >
        <p>
            <xsl:apply-templates mode="frontmatter"/>
        </p>
    </xsl:template>

    <xsl:template match="ident/auteur">
        <!-- Métadonnées pour l'information auteur -->
        <meta name="dc:Creator" content="{.}"/>
    </xsl:template>
    <xsl:template match="ident/surtit">
        <!-- Métadonnées pour l'information sur-titre -->
        <meta name="dc:surtit" content="{.}"/>
    </xsl:template>
    <xsl:template match="ident/edit">
        <!-- Métadonnées pour l'information éditeur -->
        <meta name="dc:Publisher" content="{.}"/>
    </xsl:template>
    <xsl:template match="ident/copy">
        <!-- Métadonnées pour l'information copyright -->
        <meta name="dc:Rights" content="{.}"/>
    </xsl:template>
    <xsl:template match="ident/ean">
        <!-- Métadonnées pour l'information EAN uid + source - ajout gautier : FR-lg2dtb2021- (differencier de l'original-->
        <meta name="dtb:uid" content="FR-lg2dtb2021-{.}"/>
        <meta name="dtb:source" content="{.}"/>
    </xsl:template>
    <xsl:template
            match="ident/info
                 | ident/trad
                 | ident/ref"
    >
        <!-- On préserve en métadonnées description toutes les autres informations de l'ident en les préfixant avec leur balise d'origine  -->
        <!--exclusion de  | ident/isbn-->
        <meta name="dc:description" content="[{local-name()}]{.}"/>
    </xsl:template>

    <!-- ajout gautier-->
    <xsl:template match="ident/titreVO">
        <!-- Titre original -->
        <meta name="dc:Relation" content="{.}"/>
    </xsl:template>

    <xsl:template match="ident/isbn">
        <!-- Métadonnées pour l'information source isbn-->
        <meta name="dtb:source" content="{.}"/>
    </xsl:template>


    <!--Gautier : passage en balise level1 class="dedication"-->
    <xsl:template match="ident/dedi" mode="frontmatter">
        <p>
            <xsl:apply-templates mode="frontmatter"/>
        </p>
    </xsl:template>
    <!--Gautier : on récupére le bloc collec = les livres du même auteur-->


    <!--fin ajout gautier-->


    <!-- Les dédicaces et les exergues de ident sont traitées à l'intérieur du bloc frontmatter, voir mode frontmatter -->
    <xsl:template
            match="ident/exer
                 | ident/dedi"/>

    <!-- Informations de l'ident ignorées : pas de correspondance en DTBook -->
    <!--exclusion de  | ident/isbn-->
    <xsl:template
            match="ident/type
                 | ident/pagetitre
                 | ident/ftit
                 | ident/coned
                 | ident/issn
                 | ident/nbpages"/>

    <!-- On ignore le bloc collec = les livres du même auteur (traité en frontmatter appelé depuis livre@mode='frontmatter'-->
    <xsl:template match="collec"/>
    <!--on récupérera le bloc collec = les livres du même auteur en mode frontmatter-->

    <!-- Fin du traitemnt du bloc ident -->
    <!-- ******************************************** -->


    <!-- ******************************************** -->
    <!-- Mode frontmatter : traitement des dédicaces et des exergues de ident -->
    <xsl:template match="ident/exer" mode="frontmatter">
        <epigraph>
            <xsl:apply-templates mode="frontmatter"/>
        </epigraph>
    </xsl:template>
    <!--Gautier : passage en balise level1 class="dedication"-->
    <!-- <xsl:template match="ident/dedi" mode="frontmatter">

            <p><xsl:apply-templates mode="frontmatter"/></p>
    </xsl:template> -->
    <!--Gautier : on récupére le bloc collec = les livres du même auteur-->
    <xsl:template match="collec" mode="frontmatter">
        <xsl:apply-templates mode="frontmatter"/>
    </xsl:template>

    <xsl:template match="exer/source" mode="frontmatter">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <!--Gautier : passage en balise source-->
        <source>
            <xsl:apply-templates mode="frontmatter"/>
        </source>
    </xsl:template>
    <xsl:template match="exer/auteur" mode="frontmatter">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <!--Gautier : passage en balise author-->
        <author>
            <xsl:apply-templates mode="frontmatter"/>
        </author>
    </xsl:template>

    <xsl:template match="p" mode="frontmatter">
        <p>
            <xsl:apply-templates mode="frontmatter"/>
        </p>
    </xsl:template>
    <xsl:template match="i" mode="frontmatter">
        <em>
            <xsl:apply-templates mode="frontmatter"/>
        </em>
    </xsl:template>
    <xsl:template match="pc" mode="frontmatter">
        <span class="smallcaps">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="br" mode="frontmatter">
        <br/>
    </xsl:template>
    <xsl:template match="rp" mode="frontmatter">
        <pagenum id="p{@folio}">
            <xsl:value-of select="@folio"></xsl:value-of>
        </pagenum>
    </xsl:template>
    <!-- ******************************************** -->

    <!-- ******************************************** -->
    <!-- Traitement des préliminaires, on est dans le frontmatter -->

    <xsl:template match="livre/pre">
        <xsl:if test="position() = 1">
            <!-- Dans le premier préliminaires,
                injection du titre et de l'auteur issus de ident en mode doctitle-->
            <doctitle>
                <xsl:apply-templates select="/livre/ident/tit" mode="doctitle"/>
            </doctitle>
            <docauthor>
                <xsl:apply-templates select="/livre/ident/auteur" mode="doctitle"/>
            </docauthor>
        </xsl:if>
        <level1>
            <xsl:if test="@folio">
                <pagenum id="p{@folio}">
                    <xsl:value-of select="@folio"></xsl:value-of>
                </pagenum>
            </xsl:if>
            <xsl:for-each select="/livre/ident/dedi
                 | /livre/ident/exer">
                <!-- Injecter ici les dédicaces et exergues du bloc source ident en mode frontmatter -->
                <xsl:apply-templates select="." mode="frontmatter"/>
            </xsl:for-each>
            <xsl:apply-templates/>
        </level1>
    </xsl:template>
    <xsl:template match="tit
                 | auteur" mode="doctitle">
        <!-- injection du titre et de l'auteur dans les balise doctitle et docauthor :
            on préserve le balisage interne mode doctitle -->
        <xsl:apply-templates mode="doctitle"/>
    </xsl:template>
    <xsl:template match="i" mode="doctitle">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    <xsl:template match="br" mode="doctitle">
        <!-- on préserve le br en mode doctitle -->
        <br/>
    </xsl:template>
    <xsl:template match="rp" mode="doctitle">
        <pagenum id="p{@folio}">
            <xsl:value-of select="@folio"></xsl:value-of>
        </pagenum>
    </xsl:template>

    <xsl:template match="pre/exer">
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
    <!-- premiers descendants de corps : level1 -->
    <xsl:template
            match="corps/appcrit
                 | corps/part
                 | corps/chap
                 | pre
                 | corps/sect
                 | corps/conclusion
                 | corps/epilogue
                 | corps/annexe
                 | corps/bio
                 | corps/glossaire
                 | corps/genealogie
                 | corps/lexique
                 | corps/historique
                 | corps/notes
                 | corps/remer
                 | corps/biblio
                 | corps/remarque
                 | corps/chrono
                 | corps/table
                 | corps/table_aut
                 | corps/table_noms
                 | corps/table_alpha
                 | corps/sommaire
                 | corps/tdm
                 | corps/index
                 | corps/personnages
                 | corps/horstexte
                 | corps/autre
                 | corps/vol"
    >
        <level1 class="{name()}">
            <xsl:apply-templates/>
        </level1>
    </xsl:template>

    <xsl:template match="conclusion
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
                 | table
                 | table_aut
                 | table_noms
                 | table_alpha
                 | sommaire
                 | tdm
                 | index
                 | personnages
                 | horstexte
                 | autre
                 | appcrit">
        <level1 class="{name()}">
            <xsl:apply-templates/>
        </level1>
    </xsl:template>

    <!-- deuxièmes descendants de corps : level2 -->
    <xsl:template match="corps/vol/part
                 | corps/part/pre
                 | corps/part/chap
                 | corps/sect/chap
                 | corps/chap/schap
                 | corps/part/spart
                 | corps/vol/chap">
        <level2 class="{name()}">
            <xsl:apply-templates/>
        </level2>
    </xsl:template>

    <!-- troisièmes descendants de corps : level3 -->
    <xsl:template
            match="corps/vol/part/chap
                 | corps/part/chap/schap
                 | corps/sect/chap/schap
                 | corps/sect/chap/schap
                 | corps/vol/chap/schap
                 | corps/part/spart/chap"
    >
        <level3 class="{name()}">
            <xsl:apply-templates/>
        </level3>
    </xsl:template>


    <!-- traitement des titres et numéros -->
    <!-- level1 : on ignore les numéros quand on les rencontre avant un titre : ils seront traités avec les titres -->
    <xsl:template match="corps/col/n
                 | corps/part/n
                 | corps/chap/n
                 | corps/appen/n
                 | corps/sect/n
                 | corps/sect/n"
    >
        <xsl:choose>
            <xsl:when test="local-name(following-sibling::*[1]) = 'tit'"/>
            <xsl:otherwise>
                <h1>
                    <xsl:apply-templates/>
                </h1>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template
            match="corps/vol/tit
                | corps/part/tit
                | corps/chap/tit
                | corps/appen/tit
                | corps/sect/tit
                | corps/appen/sect/tit
                | corps/vol/tit"
    >
        <h1 class="{local-name(..)}tit">
            <xsl:if test="local-name(preceding-sibling::*[1]) = 'n'">
                <xsl:value-of select="preceding-sibling::*[1]"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>

    <!-- level2 : on ignore les numéros quand on les rencontre avant un titre :
        ils seront traités avec les titres -->
    <xsl:template
            match="corps/vol/part/n
                | corps/part/chap/n
                | corps/part/pre/n
                | corps/part/spart/n
                | corps/chap/schap/n
                | corps/vol/chap/n
                | corps/sect/chap/n"
    >
        <xsl:choose>
            <xsl:when test="local-name(following-sibling::*[1]) = 'tit'"/>
            <xsl:otherwise>
                <h2>
                    <xsl:apply-templates/>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template
            match="corps/vol/part/tit
                | corps/part/chap/tit
                | corps/part/pre/tit
                | corps/sect/chap/tit
                | corps/vol/chap/tit
                | corps/chap/schap/tit"
    >
        <h2 class="{local-name(..)}tit">
            <xsl:if test="local-name(preceding-sibling::*[1]) = 'n'">
                <xsl:value-of select="preceding-sibling::*[1]"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template
            match="corps/vol/part/chap/n
                | corps/sect/part/chap/n
                |corps/sect/chap/schap/n
                | corps/part/spart/chap/n
                | corps/part/chap/schap/n
                | corps/vol/chap/schap/n"
    >
        <xsl:choose>
            <xsl:when test="local-name(following-sibling::*[1]) = 'tit'"/>
            <xsl:otherwise>
                <h3 class="{local-name(..)}tit">
                    <xsl:apply-templates/>
                </h3>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template
            match="corps/vol/part/chap/tit
                 | corps/sect/part/chap/tit
                 | corps/sect/chap/schap/tit
                 | corps/part/spart/chap/tit
                 | corps/part/chap/schap/tit
                 | corps/vol/chap/schap/tit"
    >
        <h3 class="{local-name(..)}tit">
            <xsl:if test="local-name(preceding-sibling::*[1]) = 'n'">
                <xsl:value-of select="preceding-sibling::*[1]"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <xsl:template match="stit">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <p class="stit">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="appen/tit
                 | conclusion/tit
                 | epilogue/tit
                 | annexe/tit
                 | bio/tit
                 | glossaire/tit
                 | genealogie/tit
                 | lexique/tit
                 | historique/tit
                 | notes/tit
                 | remer/tit
                 | biblio/tit
                 | remarque/tit
                 | chrono/tit
                 | table/tit
                 | table_aut/tit
                 | table_noms/tit
                 | table_alpha/tit
                 | sommaire/tit
                 | tdm/tit
                 | index/tit
                 | personnages/tit
                 | horstexte/tit
                 | autre/tit
                 | appcrit/tit">
        <h1 class="{name()}">
            <xsl:apply-templates/>
        </h1>
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

    <xsl:template
            match="appen/n
                 | conclusion/n
                 | epilogue/n
                 | annexe/n
                 | bio/n
                 | glossaire/n
                 | genealogie/n
                 | lexique/n
                 | historique/n
                 | notes/n
                 | remer/n
                 | biblio/n
                 | remarque/n
                 | chrono/n
                 | table/n
                 | table_aut/n
                 | table_noms/n
                 | table_alpha/n
                 | sommaire/n
                 | tdm/n
                 | index/n
                 | personnages/n
                 | horstexte/n
                 | autre/n
                 | appcrit/n">
        <h1 class="{name()}">
            <xsl:apply-templates/>
        </h1>
    </xsl:template>
    <xsl:template
            match="appen/sect/n
                 | appcrit/sect/n"
    >
        <xsl:choose>
            <xsl:when test="local-name(following-sibling::*[1]) = 'tit'"/>
            <xsl:otherwise>
                <h2>
                    <xsl:apply-templates/>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ******************************************** -->

    <!-- ******************************************** -->
    <!-- traitement de la super structure des appareils critiques -->
    <xsl:template
            match="appen
                | appcrit"
    >
        <level1 class="{local-name(.)}">
            <xsl:apply-templates/>
        </level1>
    </xsl:template>

    <xsl:template
            match="appen/sect
                | appcrit/sect"
    >
        <level2 class="{local-name(.)}">
            <xsl:apply-templates/>
        </level2>
    </xsl:template>
    <!-- ******************************************** -->


    <!-- ******************************************** -->
    <!-- Traitement des développements de texte -->
    <xsl:template match="dev">
        <!-- on ne garde pas la balise dev, mais on injecte son contenu -->
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>

    <!-- on ne garde pas la balise vol, mais on injecte son contenu -->
    <!-- <xsl:template match="vol">
        <xsl:apply-templates/>
    </xsl:template>  -->

    <xsl:template match="r">
        <!-- on ne garde pas la balise r, mais on injecte son contenu -->
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>

    <!-- Traitement paragraphes de texte -->
    <xsl:template match="p">
        <xsl:element name="p">
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
        <adress>
            <xsl:apply-templates/>
        </adress>
    </xsl:template>

    <!-- Traitement ps -->
    <xsl:template match="ps">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- Traitement fin -->
    <xsl:template match="fin">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Traitement enc (encadrés)-->
    <xsl:template match="enc">
        <sidebar>
            <xsl:apply-templates/>
        </sidebar>
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
        <p class="source">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="date">
        <dateline>
            <xsl:apply-templates/>
        </dateline>
    </xsl:template>

    <!-- ******************************************** -->
    <!-- traitement des niv1, niv2, niv3, niv4, niv5 en intertitres -->
    <xsl:template
            match="niv1
                 | niv2
                 | niv3
                 | niv4
                 | niv5"
    >
        <xsl:apply-templates/>
    </xsl:template>
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
    <xsl:template match="br" mode="int">
        <!-- Mode int: remplacement de <br/> par un espace-->
        <xsl:text> </xsl:text>
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
                 | pbib
                 | sl
                 | cint
                 | ident/collec/pbib
                 | ident/collec/cint"
    >
        <strong>
            <xsl:apply-templates/>
        </strong>
    </xsl:template>

    <xsl:template match="pc">
        <span class="smallcaps">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- ligne de blanc : suppression -->
    <xsl:template match="bl"/>
    <xsl:template match="sep">
        <!-- Séparateur, remplacés par étoiles-->
        <p>
            <xsl:text>***</xsl:text>
            <!-- garder le type en attribut
                Pas de possibilité de mettre des br en dehors des paragraphes,
                donc report du br dans un p
            <br title="{@type}"/>-->
        </p>
    </xsl:template>
    <xsl:template match="br">
        <br/>
    </xsl:template>
    <xsl:template match="rp">
        <xsl:variable name="folio" select="@folio/."/>
        <xsl:choose>
            <xsl:when test="(preceding::node()/@folio/. = $folio)
                        or (ancestor::node()/@folio/. = $folio)"/>
            <xsl:otherwise>
                <pagenum id="p{@folio}">
                    <xsl:value-of select="@folio"></xsl:value-of>
                </pagenum>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="sign">
        <!-- Pas de balise en DTBook : passage de l'info en attribut class de p -->
        <p class="sign">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="hyperlink">
        <a href="{@uri}" external="true"/>
    </xsl:template>
    <xsl:template match="url">
        <xsl:choose>
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
    <xsl:template match="refcible">
        <!--  balise spécifuqe Flammarion -->
        <a href="{@id}"/>
    </xsl:template>

    <xsl:template match="pbib">
        <p class="pbib">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="renv">
        <p class="renv">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="renvlnk">
        <p class="renvlnk">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- <!ELEMENT dialogue (((interloc?, (p | question | reponse | stroplg | bl | sep | list | cita | fig | tableau | enc)+))+, fin*)>  -->
    <xsl:template match="dialogue">
        <xsl:apply-templates />
    </xsl:template>
    <!-- <!ELEMENT question (p)*> -->
    <xsl:template match="question">
        <xsl:apply-templates />
    </xsl:template>
    <!-- <!ELEMENT reponse (p)*> -->
    <xsl:template match="reponse">
        <xsl:apply-templates />
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
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="img">
        <xsl:element name="img">
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="alt">
                <!-- ajout d'un texte alternatif arbitraire -->
                <xsl:value-of select="'texte alternatif'"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Traitement des noeuds texte -->
    <xsl:template match="text()">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="text()" mode="frontmatter">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="text()" mode="doctitle">
        <xsl:copy/>
    </xsl:template>

    <!-- ******************************************************************** -->
    <!-- Voitures balais : signaler toute balise non traitée dans chaque mode -->
    <xsl:template match="*" mode="frontmatter">
        <xsl:message>
            Elément XML non traduit [<xsl:value-of select="local-name()"/>] en mode frontmatter
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
    <xsl:template match="*" mode="ident">
        <xsl:message>Elément XML non traduit [<xsl:value-of select="local-name()"/>] en mode ident
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
</xsl:stylesheet>
