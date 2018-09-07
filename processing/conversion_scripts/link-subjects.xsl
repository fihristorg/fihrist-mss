<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    exclude-result-prefixes="xs bod saxon tei"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="/tei:TEI/tei:text/tei:body/tei:list/tei:item">
        <xsl:variable name="thiskey" as="xs:string" select="@xml:id"/>
        <xsl:variable name="terms" as="xs:string+" select="tei:term/string()"/>
        <xsl:variable name="parentterms" as="xs:string*" select="
            for $t in $terms
                return 
                if (contains($t, '--')) then for $x in 1 to count(tokenize($t, '\-\-')[position() ne last()]) return string-join(tokenize($t, '\-\-')[position() le $x], '--')
                else if (contains($t, ',')) then normalize-space(string-join(tokenize($t, ',')[position() ne last()], ','))
                else ()"/>
        <xsl:variable name="subkeys" as="xs:string*" select="/tei:TEI/tei:text/tei:body/tei:list/tei:item[not(@xml:id = $thiskey)][tei:term[some $t in $terms satisfies matches(string(), concat('^', translate($t, '[]', ''), '\s*(\-\-|,)'))]]/@xml:id"/>
        <xsl:variable name="parentkeys" as="xs:string*" select="/tei:TEI/tei:text/tei:body/tei:list/tei:item[not(@xml:id = $thiskey)][tei:term[some $pt in $parentterms satisfies string() = $pt]]/@xml:id"/>
        <xsl:variable name="sameaskeys" as="xs:string*" select="/tei:TEI/tei:text/tei:body/tei:list/tei:item[not(@xml:id = $thiskey)][tei:term[some $t in $terms satisfies string() = $t]]/@xml:id"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="count($sameaskeys) gt 0">
                <xsl:attribute name="sameAs">
                    <xsl:for-each select="distinct-values($sameaskeys)">
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:if test="position() ne last()"><xsl:text> </xsl:text></xsl:if>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="count(($parentkeys, $subkeys)[not(. = $sameaskeys)]) gt 0">
                <xsl:attribute name="corresp">
                    <xsl:for-each select="distinct-values(($parentkeys, $subkeys)[not(. = $sameaskeys)])">
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:if test="position() ne last()"><xsl:text> </xsl:text></xsl:if>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
<!--    <xsl:template match="/tei:TEI/tei:text/tei:body/tei:list/tei:item[starts-with(@xml:id, 'subject_n')]">
        <xsl:variable name="thiskey" as="xs:string" select="@xml:id"/>
        <xsl:variable name="terms" as="xs:string+" select="tei:term/string()"/>
        <xsl:variable name="sameaskeys" as="xs:string*" select="/tei:TEI/tei:text/tei:body/tei:list/tei:item[not(@xml:id = $thiskey)][tei:term[some $t in $terms satisfies string() = $t]]/@xml:id"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="count($sameaskeys) gt 0">
                <xsl:attribute name="sameAs">
                    <xsl:for-each select="distinct-values($sameaskeys)">
                        <xsl:text>#</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:if test="position() ne last()"><xsl:text> </xsl:text></xsl:if>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    -->
    
</xsl:stylesheet>