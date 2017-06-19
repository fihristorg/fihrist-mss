<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs tei"
    version="2.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
     xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    >
    
    <xsl:output indent="yes"/>
    
    <!-- 
    up-convert script for Wycliffite Bibles project
    Dr James Cummings
    First created: 2017-06-19
    License: CC+by
    
    -->
    
    
    <!-- Typical copy-all template -->
    <xsl:template match="@*|node()" priority="-1" mode="#all">
        <xsl:copy><xsl:apply-templates select="@*|node()" mode="#current"/></xsl:copy>
    </xsl:template>
    
    
    
    <!-- starting template -->
    <xsl:template match="/" mode="#default">
        <!-- first process everything in a variable in mode 'addWords' to add the w elements -->
        <xsl:variable name="pass0"> 
            <xsl:apply-templates select="*" mode="addWords" />
        </xsl:variable>
        <!-- Then process it to put it out -->
        <xsl:apply-templates select="$pass0/*"/>
   </xsl:template>
    
    <!-- Get rid of some things we don't need -->
    <xsl:template match="@rend[.='Normal'] |@xml:space |encodingDesc"/>
    
    <!-- add w elements to text inside body paragraphs and headings but not notes -->
    <xsl:template match="body//p//text()[not(ancestor::note)] | body//head//text()[not(ancestor::note)]" mode="addWords" priority="100"> 
        <xsl:analyze-string regex="(\w+|;+)" select=".">
            <xsl:matching-substring><w><xsl:value-of select="."/></w></xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- Now that we have w elements (on the next pass) add @xml:ids to them -->
  <xsl:template match="w" >
      <w xml:id="{concat('w', count(preceding::w)+1)}"><xsl:apply-templates/></w>
  </xsl:template>
    
    <!-- make divisions into chapters with an ID -->
        <xsl:template match="body/div">
            <div type="chapter" xml:id="{concat('WB_',ancestor::TEI/teiHeader/fileDesc/publicationStmt/idno[@type='book'],'-chapter',count(preceding::div)+1)}">
                <xsl:apply-templates/>
            </div>
        </xsl:template>
    
    <!-- make paragraphs into ab elements with and ID -->
        <xsl:template match="body/div/p">
            <ab  type="verse" xml:id="{concat('WB_',ancestor::TEI/teiHeader/fileDesc/publicationStmt/idno[@type='book'],'-chapter', count(preceding::div)+1, '-verse', w[1])}">
              <xsl:apply-templates/>
            </ab>
         </xsl:template>
    
    <!-- Update the revisionDesc -->
    <xsl:template match="revisionDesc/listChange"><xsl:copy>
            <change>
                <name>Dr James Cummings</name>
                 Converted file from DOCX to TEI with improvements
                 on <date><xsl:value-of select="current-dateTime()"/></date>
            </change>
            <xsl:apply-templates/>
        </xsl:copy></xsl:template>
    
    
</xsl:stylesheet>