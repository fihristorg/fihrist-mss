<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="/"
    exclude-result-prefixes="xs tei local"
    version="2.0">
    
    <!-- This adds the following to works authority files: 
            - authors
            - editors (with their roles, e.g. trl for translators)
            - text languages
    -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="allrecs" as="element(tei:TEI)*" select="collection('../../collections/?select=*.xml;recurse=yes')/tei:TEI"/>
    <xsl:variable name="persons" as="element(tei:person)*" select="document('../../authority/persons_base.xml')/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id]"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model') and not(following::processing-instruction('xml-model'))"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|processing-instruction()|comment()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:body/tei:listBibl/tei:bibl[@xml:id]">
        <xsl:variable name="key" as="xs:string" select="@xml:id"/>
        <xsl:variable name="instances" as="element()*" select="$allrecs//*[@key = $key]"/>
        <xsl:variable name="authors" as="element()*" select="$instances/parent::tei:msItem/tei:author"/>
        <xsl:variable name="authorkeys" as="xs:string*" select="distinct-values((tokenize(string-join($authors/@key, ' '), ' '), tokenize(string-join($authors/tei:persName/@key, ' '), ' ')))"/>
        <xsl:variable name="editors" as="element()*" select="$instances/parent::tei:msItem/tei:editor"/>
        <xsl:variable name="editorkeys" as="xs:string*" select="distinct-values((tokenize(string-join($editors/@key, ' '), ' '), tokenize(string-join($editors/tei:persName/@key, ' '), ' ')))"/>
        <xsl:variable name="editorroles" as="xs:string*" select="distinct-values(tokenize(string-join($editors/@role, ' '), ' '))"/>
        <xsl:variable name="textlangs" as="element()*" select="$instances/parent::tei:msItem/tei:textLang"/>
        <xsl:variable name="langcodes" as="xs:string*" select="distinct-values(tokenize(normalize-space(string-join(($textlangs/@mainLang, $textlangs/@otherLangs), ' ')), ' '))"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="child::*|processing-instruction()"/>
            <xsl:choose>
                <xsl:when test="count($langcodes) eq 0"/>
                <xsl:when test="count($textlangs) eq 1">
                    <xsl:element name="textLang" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="$textlangs[1]/@*"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="count($langcodes) eq 1">
                    <xsl:element name="textLang" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="mainLang" select="$langcodes[1]"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="count(distinct-values($textlangs/@mainLang)) eq 1">
                    <xsl:variable name="mainlang" as="xs:string" select="$textlangs[1]/@mainLang"/>
                    <xsl:element name="textLang" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="mainLang" select="$mainlang"/>
                        <xsl:attribute name="otherLangs" select="string-join($langcodes[not(. = $mainlang)], ' ')"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="textLang" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="mainLang" select="'mul'"/>
                        <xsl:attribute name="otherLangs" select="string-join($langcodes, ' ')"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="$authorkeys">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:element name="author" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="key" select="$key"/>
                    <xsl:value-of select="normalize-space($persons[@xml:id = $key]/tei:persName[@type='display'][1]/string())"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:for-each select="$editorkeys">
                <xsl:variable name="key" as="xs:string" select="."/>
                <xsl:element name="editor" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="key" select="$key"/>
                    <xsl:if test="count($editorroles) gt 0">
                        <xsl:attribute name="role" select="string-join($editorroles, ' ')"/>
                    </xsl:if>
                    <xsl:value-of select="normalize-space($persons[@xml:id = $key]/tei:persName[@type='display'][1]/string())"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:apply-templates select="comment()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>