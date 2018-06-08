<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs tei"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="newline" select="'&#10;'"/>   
	<xsl:variable name="works" select="document('../../authority/works_base.xml')//tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl"/>
    <xsl:variable name="keysmapping" as="xs:string*" select="
        for $line in tokenize(unparsed-text('nonviaf2viaf.txt', 'utf-8'), '\r?\n')
            return
            if (//@key = tokenize($line, '\t')[1]) then 
                $line
            else
                ()
    "/>
    
    <!-- Root template -->
	
	<xsl:template match="/">
	    
	    <!-- First pass adds key attributes -->
	    <xsl:variable name="firstpass">
	        <xsl:apply-templates/>
	    </xsl:variable>
	    
	    <!-- Second pass logs changes in revisionDesc -->
	    <xsl:apply-templates select="$firstpass" mode="updatechangelog"/>
	    
	</xsl:template>
    
    <!-- The following templates do the first pass -->
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>

	<xsl:template match="tei:msItem[@xml:id]/tei:title">
	    <xsl:variable name="msitemid" select="parent::tei:msItem/@xml:id"/>
	    <xsl:variable name="keys" select="$works[tei:ref/@target = $msitemid]/@xml:id"/>
		<xsl:copy>
            <xsl:copy-of select="@*[not(name()='key')]"/>
	        <xsl:if test="exists($keys)">
	            <!-- Add key attribute from the works authority file -->
                <xsl:attribute name="key" select="string-join($keys, ' ')"/>
	        </xsl:if>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
    
    <xsl:template match="tei:persName[@key and parent::*/@key and starts-with(@key, 'person_')]">
        <xsl:copy>
            <!-- Strip out key attributes for names within names/authors because it is the parent element's key
                 which has been used in the persons authority file -->
            <xsl:copy-of select="@*[not(name()='key')]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[@key and not(parent::*/@key) and starts-with(@key, 'person_')]">
        <xsl:variable name="keymap" as="xs:string*" select="$keysmapping[tokenize(., '\t')[1] = current()/@key]"/>
        <xsl:choose>
            <xsl:when test="count($keymap) gt 0">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(name()='key')]"/>
                    <xsl:attribute name="key">
                        <!-- Replace old key value with one based on VIAF number -->
                        <xsl:value-of select="tokenize($keymap[1], '\t')[2]"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- No replacement provided, so leave as-is -->
                <xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    	
    <!-- The following templates perform the second pass, to add a change element to the revisionDesc -->
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="updatechangelog">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*" mode="updatechangelog"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="updatechangelog"/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:revisionDesc" mode="updatechangelog">
        <!-- Prepend a new change element, if the document has actually been changed (addition of XML comments not counted) -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="//tei:title[@key] or count($keysmapping) gt 0">
                <xsl:value-of select="$newline"/>
                <xsl:text>         </xsl:text>
                <change when="{ format-date(current-date(), '[Y0001]-[M01]-[D01]') }">
                    <!-- Do not use add xml:id for this change because it is only adding attributes -->
                    <xsl:value-of select="$newline"/>
                    <xsl:text>            </xsl:text>
                    <persName>
                        <xsl:text>Andrew Morrison</xsl:text>
                    </persName>
                    <xsl:text> </xsl:text>
                    <xsl:text>Updated key attributes using </xsl:text>
                    <ref target="https://github.com/bodleian/fihrist-mss/tree/master/processing/conversion_scripts/update-keys.xsl">update-keys.xsl</ref>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>         </xsl:text>
                </change>
            </xsl:if>
            <xsl:apply-templates mode="updatechangelog"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>