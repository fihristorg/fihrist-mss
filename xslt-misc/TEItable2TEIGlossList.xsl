<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd tei jc"
    xmlns:jc="http://james.blushingbunny.net/ns.html"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 2015</xd:p>
            <xd:p><xd:b>Author:</xd:b> jamesc</xd:p>
            <xd:p>Simple stylesheet to take an xslx to TEI converted table and convert it to
                  a TEI file with a gloss list. Mostly used to output surveys from Google Drive Forms.</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="/">
        
        
        
        
        <xsl:variable name="row1" select="//body/table/row[1]"/>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <xsl:copy-of select="//teiHeader/*"/>
             </teiHeader>
            <text>
                <body>
        <xsl:for-each select="//body/table/row[position() ne 1]">
            <div xml:id="{concat('row-', position())}">
                <head><xsl:value-of select="cell[2]"/></head>
                
                <list type="gloss">
                <xsl:for-each select="cell">
                    <xsl:variable name="num" ><xsl:value-of select="position()"/></xsl:variable>
                    <label><xsl:value-of select="$row1/cell[number($num)]"/></label>
                    <item><xsl:apply-templates/></item>   
               </xsl:for-each>
                </list> 
            </div>
                
        </xsl:for-each>
                </body>
            </text>
        </TEI>
        
        
    </xsl:template>
    
    
</xsl:stylesheet>
