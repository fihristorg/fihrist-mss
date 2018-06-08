<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="newline" select="'&#10;'"/> 
    <xsl:variable name="idsmapping" as="xs:string*" select="tokenize(unparsed-text('nonviaf2viaf.txt', 'utf-8'), '\r?\n')"/>
    
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
    
    <xsl:template match="tei:person">
        <xsl:variable name="newid" as="xs:string*" select="
            for $line in $idsmapping
                return
                if (current()/@xml:id = tokenize($line, '\t')[1]) then 
                    tokenize($line, '\t')[2]
                else
                    ()
            "/>
        <xsl:choose>
            <xsl:when test="count($newid) eq 1">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(name()='xml:id')]"/>
                    <xsl:attribute name="xml:id" select="$newid"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>