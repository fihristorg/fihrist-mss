<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    exclude-result-prefixes="xs bod saxon tei"
    version="2.0">
    
    <xsl:variable name="ellipsis" select="'…'"/>
    <xsl:variable name="newline" select="'&#10;'"/>
    
   
   
    <xsl:template match="/">
        
        <!-- First pass adds summaries -->
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
    
    <xsl:template match="tei:msDesc/tei:msContents/tei:summary[@change='#add-summary' and contains(text(), $ellipsis) and ancestor::tei:TEI//tei:profileDesc//tei:term]">
        <!-- These long constructed summaries just truncate the title, which is not very helpful, so convert to a list of subject terms -->
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='change')]"/>
            <xsl:attribute name="change" select="'#add-summary2'"/>
            <xsl:value-of select="$newline"/>
            <xsl:text>                     </xsl:text>
            <xsl:text>1 work on the </xsl:text>
            <xsl:variable name="subjects" select="distinct-values(for $term in ancestor::tei:TEI//tei:profileDesc//tei:term return normalize-space(replace(string-join($term//text(), ' '), '(--|\(|,).*', '')))"/>
            <xsl:choose>
                <xsl:when test="count($subjects) gt 1">
                    <xsl:text>subjects of </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>subject of </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="$subjects">
                <xsl:value-of select="."/>
                <xsl:choose>
                    <xsl:when test="position() eq last() - 1 and last() gt 2">
                        <xsl:text>, and </xsl:text>
                    </xsl:when>
                    <xsl:when test="position() eq 1 and last() eq 2">
                        <xsl:text> and </xsl:text>
                    </xsl:when>
                    <xsl:when test="position() ne last() and last() gt 2">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:value-of select="$newline"/>
            <xsl:text>                  </xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:msDesc/tei:msContents/tei:summary[@change='#add-summary' and matches(text(), '\d works') and not(contains(text(), $ellipsis)) and ancestor::tei:TEI//tei:profileDesc//tei:term]">
        <!-- These previously constructed summaries are not very helpful, so append subject terms -->
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='change')]"/>
            <xsl:attribute name="change" select="'#add-summary2'"/>
            <xsl:value-of select="$newline"/>
            <xsl:text>                     </xsl:text>
            <xsl:variable name="oldsummary" select="normalize-space(string-join(text(), ' '))"/>
            <xsl:choose>
                <xsl:when test="ends-with($oldsummary, '.')">
                    <xsl:value-of select="substring($oldsummary, 1, string-length($oldsummary) - 1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$oldsummary"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text> on the </xsl:text>
            <xsl:variable name="subjects" select="distinct-values(for $term in //tei:profileDesc//tei:term return normalize-space(replace(string-join($term//text(), ' '), '(--|\(|,).*', '')))"/>
            <xsl:choose>
                <xsl:when test="count($subjects) gt 1">
                    <xsl:text>subjects of </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>subject of </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="$subjects">
                <xsl:value-of select="."/>
                <xsl:choose>
                    <xsl:when test="position() eq last() - 1 and last() gt 2">
                        <xsl:text>, and </xsl:text>
                    </xsl:when>
                    <xsl:when test="position() eq 1 and last() eq 2">
                        <xsl:text> and </xsl:text>
                    </xsl:when>
                    <xsl:when test="position() ne last() and last() gt 2">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:value-of select="$newline"/>
            <xsl:text>                  </xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:msPart/tei:msContents/tei:summary[@change='#add-summary']"><!-- Remove summaries previously erroneously added to parts --></xsl:template>


    
    <!-- The following templates perform the second pass, to add a change elements to the revisionDesc -->
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="updatechangelog">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*" mode="updatechangelog"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="updatechangelog"/></xsl:copy></xsl:template>

    <xsl:template match="tei:revisionDesc" mode="updatechangelog">
        <!-- Prepend a new change element, if the document has actually been changed (addition of XML comments not counted) -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="changes" select="//*[@change = '#add-summary2']"/>
            <xsl:if test="exists($changes)">
                <xsl:value-of select="$newline"/>
                <xsl:text>         </xsl:text>
                <change when="{ format-date(current-date(), '[Y0001]-[M01]-[D01]') }" xml:id="add-summary2">
                    <xsl:value-of select="$newline"/>
                    <xsl:text>            </xsl:text>
                    <persName>
                        <xsl:text>Andrew Morrison</xsl:text>
                    </persName>
                    <xsl:text> </xsl:text>
                    <xsl:text>Adjusted summary</xsl:text>
                    <xsl:text> using </xsl:text>
                    <ref target="https://github.com/bodleian/fihrist-mss/tree/master/processing/conversion_scripts/add-summaries2.xsl">add-summaries2.xsl</ref>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>         </xsl:text>
                </change>
            </xsl:if>
            <xsl:apply-templates mode="updatechangelog"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:change[@xml:id = 'add-summary']">
        <xsl:choose>
            <xsl:when test="not(//@change[starts-with(., '#add-summary')])">
                <!-- Removed these when the previous change has been reversed (for multi-part manuscripts) -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="updatechangelog"/></xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>