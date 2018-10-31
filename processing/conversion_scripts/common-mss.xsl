<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
        xmlns:jc="http://james.blushingbunny.net/ns.html" exclude-result-prefixes="tei jc xsi" version="2.0"
        xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">

    <!--
    Created by James Cummings james@blushingbunny.net
    2017-07 or so
    for up-conversion of existing TEI Catalogues

    This file is imported into individual XSLT conversion scripts to
    allow for common changes and per-catalogue changes.

    For an example see
    https://github.com/bodleian/tibetan-mss/blob/master/processing/convertTibetan2Bodley.xsl
    where it expects this xslt file to be at ../../common-mss.xsl

    Run on a commandline with something like:
    saxon -it:main -xsl:convertTibetan2Bodley.xsl

    -->

    <!-- variable for overall collection name -->
    <xsl:variable name="cat" select="'Fihrist'"/>

    <!-- variable for directory and URL usage  -->
    <xsl:variable name="catdir" select="'fihrist'"/>

    <!-- Set up the collection of files to be converted -->
    <!-- files and recurse parameters defaulting to '*.xml' and 'no' respectively -->
    <xsl:param name="files" select="'*.xml'"/>
    <!-- <xsl:param name="recurse" select="yes" /> -->

    <!-- path hard-coded to location on my desktop cuz that was convenient -->
    <xsl:variable name="path">
        <xsl:value-of select="concat('../working/old/?select=', $files,';on-error=warning;recurse=yes')" />
    </xsl:variable>

    <!-- the main collection of all the documents we are dealing with -->
    <xsl:variable name="doc" select="collection($path)"/>


    <!-- In case there are existing schema associations, let's get rid of those -->
    <xsl:template match="processing-instruction()"/>

    <!-- Named template which we call that starts off the whole thing-->
    <xsl:template name="main">
        <!-- For each item in the collection -->
        <xsl:for-each select="$doc">
            <xsl:sort select="tokenize(base-uri(), '/')[last()-1]"/>
            <xsl:sort select="tokenize(base-uri(), '/')[last()]"/>
            <xsl:variable name="baseURI">
                <xsl:value-of select="base-uri()"/>
            </xsl:variable>
            <xsl:variable name="filename">
                <xsl:value-of select="tokenize(base-uri(), '/')[last()]"/>
            </xsl:variable>
            <xsl:variable name="folder">
                <xsl:value-of select="tokenize(base-uri(), '/')[last()-1]"/>
            </xsl:variable>
            <xsl:variable name="fileNum">
                <xsl:value-of select="position()"/>
            </xsl:variable>
            <xsl:variable name="msID">
                <xsl:value-of select="jc:normalizeID(normalize-space(.//msDesc[1]/msIdentifier/idno[1]/text()))"/>
            </xsl:variable>
            <!--<xsl:variable name="collection">
                <xsl:value-of select="lower-case(.//msIdentifier[1]/collection/text()/normalize-space(.))" />
            </xsl:variable>-->
            <xsl:variable name="institution">
                <xsl:value-of select="lower-case(.//msIdentifier[1]/institution/text()/normalize-space(.))" />
            </xsl:variable>
            <xsl:variable name="foldername">
                <xsl:value-of select="$institution" />
            </xsl:variable>

            <!-- This is just a debugging message so I see the filnames whiz by on the screen
              and I know what the last file was when something breaks  -->
            <xsl:message> Base URI: <xsl:value-of select="$baseURI"/> Folder: <xsl:value-of select="$folder"/> Old Filename:
                <xsl:value-of select="$filename"/> New ID: <xsl:value-of select="$msID"/>
            </xsl:message>

            <!-- Create the (hard coded) output file name -->
            <xsl:variable name="outputFilename"
                    select="concat('../working/draft-updated/', $foldername, '/', $msID, '.xml')"/>
            <!-- create output file -->
            <xsl:result-document href="{$outputFilename}" method="xml" indent="yes">
                <!-- add relative schema associations -->
                <xsl:text>&#xA;</xsl:text>
                <xsl:processing-instruction name="xml-model">href="../bodley-msDesc.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
                <xsl:processing-instruction name="xml-model">href="../bodley-msDesc.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
                <!-- TEI/@xml:id contains the manuscript_12345 used on the website
                  we could do this by catalogue as well...
                -->
                <TEI xml:id="{concat('manuscript_', $fileNum)}">
                    <xsl:apply-templates/>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- By default we just copy the input to the output when it isn't empty -->
    <xsl:template match="*[jc:checkEmpty(.)='false']" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()|comment()"/>
        </xsl:copy>
    </xsl:template>
    <!-- By default we copy the text to the output except we normalize space since it is so messy -->
    <xsl:template match="text()" priority="2">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <!-- If something is entirely empty (no descendent text content or attributes)
          and not matched separately let's get rid of it. -->
    <xsl:template match="node()[jc:checkEmpty(.)='true']" priority="-1"/>

    <!-- By default, copy attributes -->
    <xsl:template match="@*" priority="-1">
        <xsl:if test="not(normalize-space(.) = '')">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>


    <!-- Make TEI element vanish since adding it above -->
    <xsl:template match="TEI">
        <xsl:apply-templates/>
        <xsl:if test="not(text)">
            <text>
                <body>
                    <p>
                        <xsl:comment>Body paragraph provided for validation and future transcription</xsl:comment>
                    </p>
                </body>
            </text>
        </xsl:if>
    </xsl:template>



    <!-- Add normalized ID to msDesc -->
    <xsl:template match="msDesc">
        <msDesc xml:id="{jc:normalizeID(msIdentifier/idno)}">
            <xsl:apply-templates select="@*[name() ne 'xml:id']|node()"/>
        </msDesc>
    </xsl:template>


    <!-- Schema normalisation mostly for medieval-mss -->
    <!-- bibl/@type -->
    <xsl:template match="bibl/@type">
        <xsl:variable name="type">
            <xsl:choose>
                <!--<xsl:when test=".='commentedOn'">commentary</xsl:when>-->
                <xsl:when test=".='digitised-version' or .='related-items' or .='realted-volumes' or .='related-volumes' or .='referred'"
                >related</xsl:when>
                <xsl:when test=".='extracts'">extract</xsl:when>
                <xsl:when test=".='ms'">MS</xsl:when>
                <xsl:when test=".='textual-relations'">text-relations</xsl:when>
                <xsl:when test=".='translated'">translation</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>


    <!-- decoNote/@type -->
    <xsl:template match="decoNote/@type">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test=".='frieze' ">border</xsl:when>
                <xsl:when test=".='decoration' or .='paratext' or .='printmark' or .='secondary' or .='unspecified'">other</xsl:when>
                <xsl:when test=".='diagrams'">diagram</xsl:when>
                <xsl:when test=".='ms'">MS</xsl:when>
                <xsl:when test=".='borderInitials'">initial_border</xsl:when>
                <xsl:when test=".='intials'">initial</xsl:when>
                <xsl:when test=".='marginalSketches'">marginal</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- dimensions/@type -->
    <xsl:template match="dimensions/@type">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="normalize-space(.)='number of folia'">folia</xsl:when>
                <xsl:when test=".='ruledColumn' or .='ruling'">ruled</xsl:when>
                <xsl:when test=".='leaves'">leaf</xsl:when>
                <xsl:when test=".='ms'">MS</xsl:when>
                <xsl:when test=".='unknown'">other</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- name/@type -->
    <xsl:template match="name/@type">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="normalize-space(.)=''"/>
                <xsl:when test=".='artist'">person</xsl:when>
                <xsl:when test=".='church' or .='corporate'">org</xsl:when>
                <xsl:when test=".='ms'">MS</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- title/@type -->
    <xsl:template match="title/@type">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="normalize-space(.)=''"/>
                <xsl:when test=".='alternative' or .='parallel'">alt</xsl:when>
                <xsl:when test=".='general' or .='uniform'">main</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(normalize-space(.), ' ', '_')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($type) != ''">
            <xsl:attribute name="type">
                <xsl:value-of select="$type"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Section of NON-TEI elements -->
    <xsl:template match="folia">
        <dim type="folia">
            <xsl:apply-templates/>
        </dim>
    </xsl:template>
    <xsl:template match="format">
        <dim type="format">
            <xsl:apply-templates/>
        </dim>
    </xsl:template>
    <xsl:template match="marginalia">
        <seg type="marginalia">
            <xsl:apply-templates/>
        </seg>
    </xsl:template>
    <!-- Is tittle  = title? or do they really mean _tittle_ which isn't an element leaving as title for now -JC -->
    <xsl:template match="tittle">
        <title>
            <xsl:apply-templates select="@*|node()"/>
        </title>
    </xsl:template>
    <xsl:template match="Rubric">
        <rubric>
            <xsl:apply-templates select="@*|node()"/>
        </rubric>
    </xsl:template>
    <xsl:template match="finalRubic">
        <finalRubric>
            <xsl:apply-templates select="@*|node()"/>
        </finalRubric>
    </xsl:template>
    <xsl:template match="inscribed">
        <note type="inscribed">
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    <xsl:template match="excipit">
        <explicit>
            <xsl:apply-templates/>
        </explicit>
    </xsl:template>
    <xsl:template match="@xsi:type" priority="1000"/>


    <!-- These attributes are not allowed on this element at they were using them wrong in any case they are dating attributes not folios! -->
    <xsl:template match="locus/@notBefore | locus/@otBefore">
        <xsl:attribute name="from">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="locus/@notAfter">
        <xsl:attribute name="to">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <!-- This is just stupid and unhelpful. Do these people not understand TEI at all? Or is this added by a form with no validation! -->
    <xsl:template match="@when[.='seecommentbelow']"/>

    <!-- There aren't types of foreign, foreign is used for marking text content in another language, not indicating as some of these
    poorly constructed msDescs do the language of the manuscript. (That should be textLang element.)
    -->
    <xsl:template match="foreign/@type"/>



    <!-- Get rid of empty elements sometimes checking in other was than above. -->
    <xsl:template match="taxonomy[jc:checkEmpty(.)='true']"/>
    <xsl:template match="taxonomy[normalize-space(.)='']"/>
    <xsl:template match="classDecl[jc:checkEmpty(.)='true']"/>
    <xsl:template match="classDecl[normalize-space(.)='']"/>
    <xsl:template match="sealDesc[jc:checkEmpty(.)='true']"/>
    <xsl:template match="encodingDesc[jc:checkEmpty(.)='true']" priority="2"/>
    <xsl:template match="encodingDesc[normalize-space(.)='']"/>
    <xsl:template match="msPart[jc:checkEmpty(.)='true']" priority="2"/>
    <xsl:template match="msPart[normalize-space(.)='']"/>
    <xsl:template match="bindingDesc[jc:checkEmpty(.)='true']"/>
    <xsl:template match="p[jc:checkEmpty(.)='true']"/>
    <xsl:template match="decoDesc[jc:checkEmpty(.)='true']" priority="2"/>
    <xsl:template match="msItem[jc:checkEmpty(.)='true']"/>
    <xsl:template match="availability[jc:checkEmpty(.)='true']"/>
    <xsl:template match="graphic[jc:checkEmpty(.)='true']"/>
    <xsl:template match="facsimile[jc:checkEmpty(.)='true']"/>
    <xsl:template match="keywords[normalize-space(.)='']" priority="10"/>
    <xsl:template match="textClass[normalize-space(.)='']" priority="10"/>
    <xsl:template match="profileDesc[normalize-space(.)='']" priority="10"/>
    <xsl:template match="respStmt[normalize-space(.)='']" priority="1000"/>


    <!-- various altIdentifier fun -->
    <xsl:template match="altIdentifier[.//node()/normalize-space(string(.))='']" priority="10"/>

    <!-- Why have an altIdentifier and not put the required idno in it? Are you working from a broken template?  -->
    <xsl:template match="altIdentifier[not(idno) or normalize-space(idno)='']" priority="2">
        <xsl:copy>
            <xsl:apply-templates/>
            <idno>
                <xsl:comment>Required idno missing in up-conversion -JC </xsl:comment>
            </idno>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="altIdentifier[idno][not(idno/normalize-space(.)='')]" priority="1">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="altIdentifier/idno[not(normalize-space(.)='')]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <!-- If you don't have a decoNote or p, you can't just have a summary, otherwise what are you summarising. -->
    <xsl:template match="decoDesc[count(*) gt 0][not(decoNote)][not(p)]/summary">
        <decoNote>
            <xsl:apply-templates/>
        </decoNote>
    </xsl:template>

    <!-- If you don't have a seal or p, you can't just have a summary, otherwise what are you summarising. -->
    <xsl:template match="sealDesc[count(*) gt 0][not(seal)][not(p)]/summary">
        <seal>
            <p>
                <xsl:apply-templates/>
            </p>
        </seal>
    </xsl:template>

    <!-- You *must* have a title in a titleStmt in fileDesc otherwise your file isn't valid, how the heck are you making files ...
    do you think the angry red square in oXygen is just for decoration?
    -->
    <xsl:template match="titleStmt[normalize-space(.)='']" priority="1000">
        <xsl:copy>
            <title>
                <xsl:value-of select="jc:normalizeLang(//msDesc[1]/msIdentifier/idno)"/>
            </title>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="titleStmt/title[normalize-space(.)='']" priority="1000">
        <title>
            <xsl:value-of select="jc:normalizeLang(//msDesc[1]/msIdentifier/idno)"/>
        </title>
    </xsl:template>
    <xsl:template match="titleStmt[not(title)]" priority="100">
        <xsl:copy>
            <title>
                <xsl:value-of select="jc:normalizeLang(//msDesc[1]/msIdentifier/idno)"/>
            </title>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- what is the point of having a respStmt without a resp in it? Have these people drunk too much absinthe?-->
    <xsl:template match="respStmt[not(resp) or normalize-space(resp)=''][not(normalize-space(.)='')]">
        <xsl:copy>
            <xsl:apply-templates select="*[not(name()='resp')]"/>
            <resp>
                <xsl:comment>Required resp added in conversion -JC </xsl:comment>
            </resp>
        </xsl:copy>
    </xsl:template>

    <!-- ptr not in schema intentionally and most uses of it are ref-like -->
    <xsl:template match="ptr">
        <xsl:text> </xsl:text>
        <ref>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="@target"/>
        </ref>
    </xsl:template>

    <!-- Make name/@type='person' into <persName> in the end easier just to do it for all of them and make nested persName vanish -->
    <xsl:template match="name[@type='person']|name[@type='artist']">
        <persName>
            <xsl:apply-templates select="@*[not(name()='type')][not(name()='subtype')]"/>
            <xsl:if test="@subtype">
                <xsl:attribute name="type">
                    <xsl:value-of select="@subtype"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </persName>
    </xsl:template>
    <!-- Then make the inside bit vanish -->
    <xsl:template match="name[@type='person' or @type='artist']/persName">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="name[@type='person' or @type='artist']/persName/text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <!-- Same with corporate to orgName  and church-->
    <xsl:template match="name[@type='corporate']|name[@type='church']">
        <orgName>
            <xsl:apply-templates select="@*[not(name()='type')]|node()"/>
        </orgName>
    </xsl:template>
    <xsl:template match="name[@type='corporate' or @type='church']/persName">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Why have a persName inside author? -->
    
    <!--Fihrist data does have these-->
    
    <!--<xsl:template match="author/persName">
        <xsl:apply-templates/>
    </xsl:template>-->

    <!-- Why does author sometimes have title in it? Let's move it to after -->
    <xsl:template match="author[title]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()[not(name()='title')]"/>
        </xsl:copy>
        <xsl:copy-of select="title"/>
    </xsl:template>
    <!-- make it vanish -->
    <xsl:template match="author/title"/>

    <!-- No, no, no, you can't have authors inside authors, that is just kinky! -->
    <xsl:template match="author/author">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- You have a date inside the origin, all my testing shows that you really mean origDate
    And it shouldn't be empty.
    -->
    <xsl:template match="origin//date" priority="1000">
        <origDate>
            <xsl:choose>
                <xsl:when test=".[normalize-space(.)=''][@calendar]">
                    <xsl:apply-templates select="@*|node()"/>
                    <xsl:value-of select="@calendar"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </origDate>
    </xsl:template>

    <!-- What is it with you people with empty dates -->
    <xsl:template match="date[@calendar][normalize-space(.)='']">
        <date>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="@calendar"/>
        </date>
    </xsl:template>

    <!-- @calendar is a pointer you mean to put a '#' in front of it. -->
    <xsl:template match="@calendar">
        <xsl:choose>
            <xsl:when test="starts-with(., 'http') or starts-with(., '#')">
                <xsl:attribute name="calendar">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="calendar">
                    <xsl:value-of select="concat('#', .)"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Just get rid of the decoDesc, keep decoNote -->
    <xsl:template match="msItem/decoDesc[decoNote]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Are you smoking crack? condition and foliation are not allowed inside extent. Move them afterwards. -->
    <xsl:template match="extent[condition or foliation]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()[not(name()='condition') and not(name()='foliation')]"/>
        </xsl:copy>
        <xsl:apply-templates select="foliation"/>
        <xsl:apply-templates select="condition"/>
    </xsl:template>

    <!-- collection inside collection (in georgian and others)
    I know you think you are marking sub collections, but this is not how it is done, just merging them.
    -->
    <xsl:template match="collection/collection">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>


    <!-- msPart/altIdentifier needs to be inside an msIdentifier -->
    <xsl:template match="msPart/altIdentifier" priority="1000">
        <msIdentifier>
            <xsl:copy-of select="jc:splitAltIdentifier(.)"/>
        </msIdentifier>
    </xsl:template>


    <!-- Give new ID to each msPart -->
    <xsl:template match="msPart">
        <xsl:variable name="num">
            <xsl:number count="msPart" level="any"/>
        </xsl:variable>
        <xsl:variable name="msID">
            <xsl:value-of select="jc:normalizeID(ancestor::msDesc[1]/msIdentifier[1]/idno[1])"/>
        </xsl:variable>
        <xsl:variable name="desc1">
            <xsl:if test="preceding::msDesc">
                <xsl:value-of select="concat('-desc', count(preceding::msDesc)+1)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="part1">
            <xsl:value-of select="concat('-part', count(preceding-sibling::msPart)+1)"/>
        </xsl:variable>
        <!-- Nested msParts -->
        <xsl:variable name="part2">
            <xsl:if test="parent::msPart">
                <xsl:value-of select="concat('-part', count(parent::msPart/preceding-sibling::msPart)+1)"/>
            </xsl:if>
        </xsl:variable>
        <msPart xml:id="{concat($msID,$desc1,$part2, $part1)}">
            <xsl:apply-templates select="@*[not(name()='xml:id')]|node()"/>
        </msPart>
    </xsl:template>

    <!-- update IDs on msItems and copy textLang if appropriate -->
    <xsl:template match="msItem">
        <xsl:variable name="msID">
            <xsl:value-of select="jc:normalizeID(ancestor::msDesc[1]/msIdentifier[1]/idno[1])"/>
        </xsl:variable>
        <xsl:variable name="desc1">
            <xsl:if test="preceding::msDesc">
                <xsl:value-of select="concat('-desc', count(preceding::msDesc)+1)"/>
            </xsl:if>
        </xsl:variable>
        <!-- Very manual way of creating ID that deals with nested msDescs, nested msParts and up to 6 levels of msItems
        I know I could have done this recursively but when I did I kept getting duplicate ids because of brokeness. So this made it nice
        and simple, though verbose.
        -->
        <xsl:variable name="msItemID">
            <xsl:value-of select="$msID"/>
            <xsl:if test="preceding::msDesc">
                <xsl:value-of select="$desc1"/>
            </xsl:if>
            <xsl:if test="ancestor::msPart[1]/parent::msPart">-part<xsl:value-of
                    select="count(ancestor::msPart[1]/parent::msPart/preceding-sibling::msPart)+1"/></xsl:if>
            <xsl:if test="ancestor::msPart">-part<xsl:value-of select="count(ancestor::msPart[1]/preceding-sibling::msPart)+1"
            /></xsl:if>
            <xsl:choose>
                <xsl:when test="parent::msItem/parent::msItem/parent::msItem/parent::msItem/parent::msItem/parent::msContents">
                    -item<xsl:value-of
                        select="count(parent::msItem/parent::msItem/parent::msItem/parent::msItem/parent::msItem/preceding-sibling::msItem)+1"
                /> -item<xsl:value-of
                        select="count(parent::msItem/parent::msItem/parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/>
                    -item<xsl:value-of select="count(parent::msItem/parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/>
                    -item<xsl:value-of select="count(parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(preceding-sibling::msItem)+1"/>
                </xsl:when>
                <xsl:when test="parent::msItem/parent::msItem/parent::msItem/parent::msItem/parent::msContents"> -item<xsl:value-of
                        select="count(parent::msItem/parent::msItem/parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/>
                    -item<xsl:value-of select="count(parent::msItem/parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/>
                    -item<xsl:value-of select="count(parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                            select="count(parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                            select="count(preceding-sibling::msItem)+1"/>
                </xsl:when>
                <xsl:when test="parent::msItem/parent::msItem/parent::msItem/parent::msContents"> -item<xsl:value-of
                        select="count(parent::msItem/parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(preceding-sibling::msItem)+1"/>
                </xsl:when>
                <xsl:when test="parent::msItem/parent::msItem/parent::msContents"> -item<xsl:value-of
                        select="count(parent::msItem/parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(preceding-sibling::msItem)+1"/>
                </xsl:when>
                <xsl:when test="parent::msItem/parent::msContents"> -item<xsl:value-of
                        select="count(parent::msItem/preceding-sibling::msItem)+1"/> -item<xsl:value-of
                        select="count(preceding-sibling::msItem)+1"/>
                </xsl:when>
                <xsl:when test="parent::msContents"> -item<xsl:value-of select="count(preceding-sibling::msItem)+1"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- Finally use the variable -->
        <msItem xml:id="{translate(normalize-space($msItemID), ' ', '')}">
            <xsl:apply-templates select="@*[name() ne 'xml:id']"/>
            <!-- If there is a locus, put it first, just like the schema tells you to! -->
            <xsl:choose>
                <xsl:when test="locus and not(*[1]/name()='locus')">
                    <xsl:apply-templates select="locus[1]"/>
                    <xsl:apply-templates select="*[not(name()='locus')]"/>
                </xsl:when>
                <xsl:when test="locus and *[1]/name()='locus'">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- If we are able to, then add in textLang to each msItem (for medieval-mss but makes good sense so keeping for all) -->
            <xsl:choose>
                <xsl:when test="not(.//textLang) and ancestor::msContents/textLang[not(@otherLangs)] and not(p)">
                    <xsl:apply-templates select="ancestor::msContents/textLang"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </msItem>
    </xsl:template>

    <!--
    Replace publicationStmt carefully
    -->
    <xsl:template match="publicationStmt">
        <xsl:copy>
            <xsl:variable name="msID">
                <xsl:value-of select="jc:normalizeID(//msDesc[1]/msIdentifier[1]/idno[1]/text())"/>
            </xsl:variable>
            <xsl:variable name="apos">'</xsl:variable>
            <xsl:choose>
                <!-- easier just to hard=-code this one -->
                <xsl:when
                        test="normalize-space(translate(., $apos, ''))='Wellcome Library; Bibliotheca Alexandrina; Kings College London'">
                    <publisher>Wellcome Library; Bibliotheca Alexandrina; King's College London</publisher>
                </xsl:when>
                <!-- If the publisher, authority, or distributor comes first, then all good -->
                <xsl:when test="./*[1]/local-name()='publisher' or ./*[1]/local-name()='authority' or ./*[1]/local-name()='distributor'">
                    <xsl:comment>First publisher</xsl:comment>
                    <xsl:apply-templates select="publisher"/> then <xsl:apply-templates select="*[not(name()='publisher')]"/>
                </xsl:when>
                <!-- otherwise when there is a publisher, distributor, or authority, put it first as the TEI requires -->
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="publisher">
                            <xsl:apply-templates select="publisher"/>
                            <xsl:apply-templates select="*[not(name()='publisher')]"/>
                        </xsl:when>
                        <xsl:when test="distributor">
                            <xsl:apply-templates select="distributor"/>
                            <xsl:apply-templates select="*[not(name()='distributor')]"/>
                        </xsl:when>
                        <xsl:when test="authority">
                            <xsl:apply-templates select="authority"/>
                            <xsl:apply-templates select="*[not(name()='authority')]"/>
                        </xsl:when>
                        <!-- Or just say it is the Bodleian Libraries -->
                        <xsl:otherwise>
                            <publisher>Bodleian Libraries</publisher>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Add idnos of the manuscript and the catalogue -->
            <idno type="msID">
                <xsl:value-of select="$msID"/>
            </idno>
            <idno type="catalogue">
                <xsl:value-of select="$cat"/>
            </idno>
        </xsl:copy>
    </xsl:template>

    <!-- in case of other publishers, well if it is empty, claim it for the Bodley -->
    <xsl:template match="publisher[normalize-space(.)='']">
        <publisher>Bodleian Libraries</publisher>
    </xsl:template>

    <!-- The WMS Arabic files have the msDesc in the <body> of course, they have to be different! -->
    <xsl:template match="sourceDesc">
        <xsl:choose>
            <xsl:when test="(normalize-space(.)='Born Digital') and ancestor::TEI//body/div/msDesc">
                <xsl:copy>
                    <xsl:apply-templates select="ancestor::TEI//body/div/msDesc"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="body[div/msDesc]">
        <xsl:copy>
            <p>
                <xsl:comment>Body paragraph provided for validation and future transcription</xsl:comment>
            </p>
        </xsl:copy>
    </xsl:template>


    <!-- Add revisionDesc to the teiHeader -->
    <xsl:template match="teiHeader">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:choose>
                <xsl:when test="revisionDesc">
                    <!--    <xsl:message>WARNING: Already has a revisionDesc element</xsl:message>-->
                </xsl:when>
                <xsl:otherwise>
                    <revisionDesc>
                        <change when="{substring(string(current-date()), 0, 11)}">
                            <persName>James Cummings</persName> Up-converted the markup using <ref
                                target="{concat('https://github.com/bodleian/', $catdir, '-mss/tree/master/processing/convert', $cat, '2Bodley.xsl')}"
                        ><xsl:value-of
                                select="concat('https://github.com/bodleian/', $catdir, '-mss/tree/master/processing/convert', $cat, '2Bodley.xsl')"
                        /></ref>
                        </change>
                    </revisionDesc>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- If it has a revisionDesc already -->
    <xsl:template match="revisionDesc">
        <xsl:copy>
            <change when="{substring(string(current-date()), 0, 11)}">
                <persName>James Cummings</persName> Up-converted the markup using <ref
                    target="{concat('https://github.com/bodleian/', $catdir, '-mss/tree/master/processing/convert', $cat, '2Bodley.xsl')}"
            ><xsl:value-of
                    select="concat('https://github.com/bodleian/', $catdir, '-mss/tree/master/processing/convert', $cat, '2Bodley.xsl')"
            /></ref>
            </change>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- Some have /@type in teiHeader -->
    <xsl:template match="teiHeader/@type"/>

    <!-- type not allowed on msItem either -->
    <xsl:template match="msItem/@type"/>

    <!-- there are default availability statuses for a reason -->
    <xsl:template match="availability/@status[.='unrestricted']">
        <xsl:attribute name="status">free</xsl:attribute>
    </xsl:template>

    <xsl:template match="availability[@status][normalize-space(.)='']" priority="2">
        <availability>
            <xsl:apply-templates select="@*"/>
            <p>
                <xsl:value-of select="@status"/>
            </p>
        </availability>
    </xsl:template>

    <xsl:template match="availability[@status][not(.//text())]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <p>
                <xsl:value-of select="@status"/>
            </p>
        </xsl:copy>
    </xsl:template>


    <!-- get rid of listBibl that have no child elements -->
    <xsl:template match="listBibl[normalize-space(.)='']"/>

    <xsl:template match="list[not(normalize-space(.)='')][not(item)]">
        <list>
            <item>
                <xsl:apply-templates/>
            </item>
        </list>
    </xsl:template>

    <!-- Arm: @material on supportDesc must not have spaces -->
    <xsl:template match="supportDesc/@material[contains(., ' ')]">
        <xsl:attribute name="material">
            <xsl:value-of select="translate(., ' ', '_')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Arm: @script can't contain apostrophe replace it and space while were at it-->
    <xsl:template match="handNote/@script">
        <xsl:variable name="apos"> '</xsl:variable>
        <xsl:attribute name="script">
            <xsl:value-of select="translate(., $apos, '_')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Arm: @form on objectDesc must not have spaces -->
    <xsl:template match="objectDesc/@form[contains(., ' ')]">
        <xsl:attribute name="form">
            <xsl:value-of select="translate(., ' ', '_')"/>
        </xsl:attribute>
    </xsl:template>


    <!-- Normalize langs -->
    <xsl:template match="*/@xml:lang | */@mainLang | */@otherLangs">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="jc:normalizeLang(.)"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Get rid of empty p elements -->
    <xsl:template match="p[jc:checkEmpty(.)='true']"/>


    <xsl:template match="p" priority="2">
        <xsl:choose>
            <xsl:when test="normalize-space(.)=''"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- why are you trying to put a paragraph inside a title? -->
    <xsl:template match="title/p" priority="1000">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- No, you mean @unit not @type -->
    <xsl:template match="biblScope[@type][not(@unit)]">
        <biblScope unit="{@type}">
            <xsl:apply-templates select="@*[not(name()='type')]|node()"/>
        </biblScope>
    </xsl:template>

    <!-- p inside msItems -->
    <xsl:template match="msItem/p">
        <xsl:choose>
            <xsl:when test="normalize-space(.)='' and  ancestor::msContents/textLang[not(@otherLangs)]">
                <xsl:apply-templates select="ancestor::msContents/textLang"/>
            </xsl:when>
            <xsl:when test="normalize-space(.)=''">
                <xsl:copy>
                    <xsl:comment>Empty paragraph in source of conversion</xsl:comment>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- and inside binding and layoutDesc -->
    <xsl:template match="binding/p|layoutDesc/p">
        <xsl:choose>
            <xsl:when test="normalize-space(.)=''">
                <xsl:copy>
                    <xsl:comment>Empty paragraph in source of conversion</xsl:comment>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- if text is entirely empty... add stuff -->
    <xsl:template match="text[jc:checkEmpty(.)='true']">
        <xsl:copy>
            <body>
                <p>
                    <xsl:comment>Body paragraph provided for validation and future transcription</xsl:comment>
                </p>
            </body>
        </xsl:copy>
    </xsl:template>

    <!-- Put comment in body/p -->
    <xsl:template match="body/p">
        <xsl:choose>
            <xsl:when test="normalize-space(.)=''">
                <xsl:copy>
                    <xsl:comment>Body paragraph provided for validation and future transcription</xsl:comment>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- FUNCTIONS -->
    <!-- function to replace characters in manuscript identifiers -->
    <xsl:function name="jc:normalizeID">
        <xsl:param name="ID" as="item()"/>
        <xsl:variable name="pass0">
            <xsl:choose>
                <!-- some idno have a 12.3 type format -->
                <xsl:when test="matches($ID, '[0-9]\.[0-9]')">
                    <xsl:variable name="part">
                        <xsl:analyze-string select="$ID" regex="([a-zA-Z]+)\.">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:value-of select="translate(normalize-space($part), '`!£$%^[_]°()}{,', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate(normalize-space($ID), '`!£$%^[_]°()}{,.', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="pass1">
            <xsl:value-of select="replace(normalize-space($pass0), ' - ', '-')"/>
        </xsl:variable>
        <xsl:variable name="pass2">
            <xsl:value-of select="replace(normalize-space($pass1), '\*', '-star')"/>
        </xsl:variable>
        <xsl:variable name="apos">&apos;</xsl:variable>
        <xsl:variable name="pass3">
            <xsl:value-of select="replace(normalize-space($pass2), $apos, '')"/>
        </xsl:variable>
        <xsl:value-of select="translate(normalize-space($pass3), ' \/','_..')"/>
    </xsl:function>


    <!-- function to split altIdentifiers on commas -->
    <xsl:function name="jc:splitAltIdentifier" as="item()*">
        <xsl:param name="altIdentifier" as="item()"/>
        <xsl:choose>
            <xsl:when
                    test="$altIdentifier/idno[@type='SCN' and not(contains(., 'Not in SC')) and contains(., ',')] | $altIdentifier/idno[@type='TM']">
                <xsl:for-each select="tokenize($altIdentifier/idno, ',')">
                    <altIdentifier>
                        <xsl:copy-of select="$altIdentifier/@*"/>
                        <idno>
                            <xsl:copy-of select="$altIdentifier/idno/@*"/>
                            <xsl:value-of select="normalize-space(.)"/>
                        </idno>
                    </altIdentifier>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <altIdentifier>
                    <xsl:apply-templates select="$altIdentifier/@*|$altIdentifier/node()"/>
                </altIdentifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- function to normalize language -->
    <xsl:function name="jc:normalizeLang" as="item()">
        <xsl:param name="lang" as="item()"/>
        <xsl:variable name="languages">
            <!-- table of languages to normalize -->
            <row>
                <cell>Egyd</cell>
                <cell>egy-Egyd</cell>
            </row>
            <row>
                <cell>Egyh</cell>
                <cell>egy-Egyh</cell>
            </row>
            <row>
                <cell>English</cell>
                <cell>en</cell>
            </row>
            <row>
                <cell>French</cell>
                <cell>fr</cell>
            </row>
            <row>
                <cell>Hebrew</cell>
                <cell>he</cell>
            </row>
            <row>
                <cell>ara</cell>
                <cell>ar</cell>
            </row>
            <row>
                <cell>ara-Latn-x-lc</cell>
                <cell>ar-Latn-x-lc</cell>
            </row>
            <row>
                <cell>ara-Latn-x-lx</cell>
                <cell>ar-Latn-x-lx</cell>
            </row>
            <row>
                <cell>arb</cell>
                <cell>ar</cell>
            </row>
            <row>
                <cell>ben</cell>
                <cell>bn</cell>
            </row>
            <row>
                <cell>bo-Latn-x-EWTS</cell>
                <cell/>
            </row>
            <row>
                <cell>eng</cell>
                <cell>en</cell>
            </row>
            <row>
                <cell>eng-Latn-x-lc</cell>
                <cell>en-Latn-x-lc</cell>
            </row>
            <row>
                <cell>fre</cell>
                <cell>fr</cell>
            </row>
            <row>
                <cell>fre-Latn-x-lc</cell>
                <cell>fr-Latn-x-lc</cell>
            </row>
            <row>
                <cell>geo</cell>
                <cell>ka</cell>
            </row>
            <row>
                <cell>geo-Latn-x-lc</cell>
                <cell>ka-Latn-x-lc</cell>
            </row>
            <row>
                <cell>ger</cell>
                <cell>de</cell>
            </row>
            <row>
                <cell>heb</cell>
                <cell>he</cell>
            </row>
            <row>
                <cell>heb-Latn-x-lc</cell>
                <cell>he-Latn-x-lc</cell>
            </row>
            <row>
                <cell>hin</cell>
                <cell>hi</cell>
            </row>
            <row>
                <cell>hin-Latn-x-lc</cell>
                <cell>hi-Latn-x-lc</cell>
            </row>
            <row>
                <cell>ita</cell>
                <cell>it</cell>
            </row>
            <row>
                <cell>jav</cell>
                <cell>jv</cell>
            </row>
            <row>
                <cell>kur</cell>
                <cell>ku</cell>
            </row>
            <row>
                <cell>lat</cell>
                <cell>la</cell>
            </row>
            <row>
                <cell>lst</cell>
                <cell>la</cell>
            </row>
            <row>
                <cell>may</cell>
                <cell>ms</cell>
            </row>
            <row>
                <cell>mon</cell>
                <cell>mn</cell>
            </row>
            <row>
                <cell>per</cell>
                <cell>fa</cell>
            </row>
            <row>
                <cell>per-Latn-x-lc</cell>
                <cell>fa-Latn-x-lc</cell>
            </row>
            <row>
                <cell>per-Latn-xlc</cell>
                <cell>fa-Latn-xlc</cell>
            </row>
            <row>
                <cell>pus</cell>
                <cell>ps</cell>
            </row>
            <row>
                <cell>rus</cell>
                <cell>ru</cell>
            </row>
            <row>
                <cell>rus-Latn-x-lc</cell>
                <cell>ru-Latn-x-lc</cell>
            </row>
            <row>
                <cell>san</cell>
                <cell>sa</cell>
            </row>
            <row>
                <cell>san-Latn-x-lc</cell>
                <cell>sa-Latn-x-lc</cell>
            </row>
            <row>
                <cell>shan-Latn-x-lc</cell>
                <cell>shn-Latn-x-lc</cell>
            </row>
            <row>
                <cell>shn-Latn-x-lc</cell>
                <cell/>
            </row>
            <row>
                <cell>spa</cell>
                <cell>es</cell>
            </row>
            <row>
                <cell>t-Latn-x-lc</cell>
                <cell>tr-Latn-x-lc</cell>
            </row>
            <row>
                <cell>tur-Latn-x-lc</cell>
                <cell>tr-Latn-x-lc</cell>
            </row>
            <row>
                <cell>urd</cell>
                <cell>ur</cell>
            </row>
            <row>
                <cell>urd-Latn-x-lc</cell>
                <cell>ur-Latn-x-lc</cell>
            </row>
            <row>
                <cell>x-other</cell>
                <cell>und</cell>
            </row>
            <row>
                <cell>yid</cell>
                <cell>yi</cell>
            </row>
        </xsl:variable>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="contains(normalize-space($lang), ' ')">
                    <xsl:for-each select="tokenize(normalize-space($lang), ' ')">
                        <xsl:variable name="current" select="."/>
                        <xsl:choose>
                            <xsl:when test="$current=$languages//row/cell[1]">
                                <xsl:value-of select="$languages//row[cell[1]=$current]/cell[2]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$current"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$lang=$languages//row/cell[1]">
                            <xsl:value-of select="$languages//row[cell[1]=$lang]/cell[2]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$lang"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($value)"/>
    </xsl:function>



    <!-- to copy return true/false  if something is empty-->
    <xsl:function name="jc:checkEmpty" as="text()">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="output">
            <xsl:choose>
                <xsl:when
                        test="($node//text()[string-length(normalize-space(.)) gt 1]) or ($node//@*[string-length(normalize-space(.)) gt 1])"
                >false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="normalize-space($output)"/>
    </xsl:function>


    <!-- man... imagine what I'd do if I had had time allocated to actually _improve_ it
      rather than just convert it and make it syntatically valid. Manuscript cataloguers are weird. -->
</xsl:stylesheet>