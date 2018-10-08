<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="newline" select="'&#10;'"/> 
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:person[@xml:id = following::tei:person/@xml:id and not(@xml:id = preceding::tei:person/@xml:id)]">
        <xsl:variable name="duplicateid" select="@xml:id"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="$newline"/>
            <xsl:for-each select="tei:persName">
                <xsl:text>                    </xsl:text>
                <xsl:copy-of select="."/>
                <xsl:value-of select="$newline"/>
            </xsl:for-each>
            <xsl:for-each select="following::tei:person[@xml:id = $duplicateid]/tei:persName">
                <xsl:if test="not(text() = current()/tei:person/text())">
                    <xsl:text>                    </xsl:text>
                    <persName type="variant">
                        <xsl:value-of select="text()"/>
                    </persName>
                    <xsl:value-of select="$newline"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="tei:note">
                <xsl:text>                    </xsl:text>
                <xsl:copy-of select="."/>
                <xsl:value-of select="$newline"/>
            </xsl:for-each>
            <xsl:for-each select="following::tei:person[@xml:id = $duplicateid]/tei:note">
                <xsl:text>                    </xsl:text>
                <xsl:copy-of select="."/>
                <xsl:value-of select="$newline"/>
            </xsl:for-each>
            <xsl:for-each select="comment()">
                <xsl:text>                    </xsl:text>
                <xsl:copy-of select="."/>
                <xsl:value-of select="$newline"/>
            </xsl:for-each>
            <xsl:for-each select="following::tei:person[@xml:id = $duplicateid]/comment()">
                <xsl:text>                    </xsl:text>
                <xsl:copy-of select="."/>
                <xsl:value-of select="$newline"/>
            </xsl:for-each>
            <xsl:text>                </xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:person[@xml:id = preceding::tei:person/@xml:id]"/>
    
</xsl:stylesheet>