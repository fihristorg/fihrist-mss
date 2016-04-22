<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  xmlns="http://www.tei-c.org/ns/1.0"
  version="2.0">
  <xsl:output indent="no"/>
  
  <!-- root HTML element to TEI + teiHeader-->
  <xsl:template match="/html">
    <TEI>
        <teiHeader>
          <fileDesc>
            <titleStmt>
              <title>Anglo-Latin Wordbook</title>
            </titleStmt>
            <publicationStmt>
              <p>The Anglo-Latin Wordbook was created by Abigail Ann Young. Original text copyright (C) Records of Early English Drama, 2007.</p>
            </publicationStmt>
            <sourceDesc>
              <p>Records of Early English Drama project</p>
            </sourceDesc>
          </fileDesc>
        </teiHeader>
        <text>
          <xsl:apply-templates select="body"/>
        </text>
    </TEI>
  </xsl:template>
  
  <!-- don't match heads -->
  <xsl:template match="head"/>
  
  <!-- body -->
  <xsl:template match="body">
    <body>
      <xsl:apply-templates/>
    </body>
  </xsl:template>
  
  
  <!-- a with href -->
  <xsl:template match="a[@href]"><ref target="{@href}"><xsl:apply-templates/></ref></xsl:template>
  
  <!-- a with id for letter -->
  <xsl:template match="h2/a"><xsl:apply-templates/></xsl:template>
  
  <!-- a with id for anchor -->
  <xsl:template match="p//a[@id][not(text())][not(@href)]"><anchor xml:id="{@id}"/></xsl:template>
  
  
  <!-- bold to hi -->
  <xsl:template match="b"><hi rend="bold"><xsl:apply-templates/></hi></xsl:template>
  
  <!-- linebreaks -->
  <xsl:template match="br"><lb/></xsl:template>
  
  <!-- divisions -->
  <xsl:template match="div[@class='entry-content']">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="div[@id]">
    <div xml:id="{@id}"><xsl:apply-templates/></div>
  </xsl:template>
  
  <!-- headings -->
  <xsl:template match="h2"><head><xsl:apply-templates/></head></xsl:template>
    
  <!-- i to hi-->
  <xsl:template match="i"><hi rend="italics"><xsl:apply-templates/></hi></xsl:template>
  
  <!-- li -->
  <xsl:template match="li"><item><xsl:apply-templates/></item></xsl:template>
  
  <!-- ordered lists -->
  <xsl:template match="ol">
    <xsl:variable name="addRend">ordered<xsl:if test="@class"><xsl:text> </xsl:text><xsl:value-of select="@class"/></xsl:if></xsl:variable>
<list rend="{$addRend}">
  <xsl:apply-templates/>
</list>    
  </xsl:template>
  
  <!-- paragraphs -->
  <xsl:template match="p"><p><xsl:apply-templates/></p></xsl:template>
  
  <!-- SC -->
  <xsl:template match="span[@class='sc']"><hi rend="sc"><xsl:apply-templates/></hi></xsl:template>
  
  <!-- sup-->
  <xsl:template match="sup"><hi rend="sup"><xsl:apply-templates/></hi></xsl:template>
  
  
<!-- copy all -->
  <xsl:template match="@*|node()|comment()" priority="-1">
    <xsl:copy>
      <xsl:message>You missed <xsl:value-of select="local-name()"/>: <xsl:value-of select="concat(@*, .)"/></xsl:message>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  
</xsl:stylesheet>