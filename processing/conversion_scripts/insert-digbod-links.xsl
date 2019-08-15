<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    exclude-result-prefixes="xs bod saxon tei"
    version="2.0">
    
    <xsl:variable name="newline" select="'&#10;'"/>
    <xsl:variable name="mappings" as="xs:string*" select="tokenize(unparsed-text('/tmp/matched_fihrist_in_digbod.txt', 'utf-8'), '\r?\n')"/>
    <xsl:variable name="mappedshelfmarks" as="xs:string*" select="for $m in $mappings return tokenize($m, '\t')[1]"/>
    <xsl:variable name="recordshelfmark" as="xs:string" select="normalize-space((tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/string())"/>

    <xsl:template match="/">
        <xsl:if test="$recordshelfmark = $mappedshelfmarks">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:additional[not(tei:surrogates)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="surrogates">
                <xsl:for-each select="$mappings[tokenize(., '\t')[1] = $recordshelfmark]">
                    <xsl:variable name="uuid" as="xs:string" select="tokenize(., '\t')[3]"/>
                    <xsl:variable name="completeness" as="xs:string" select="tokenize(., '\t')[4]"/>
                    <xsl:variable name="numsurfaces" as="xs:string" select="tokenize(., '\t')[5]"/>            
                    <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="bibl">
                        <xsl:attribute name="type">
                            <xsl:text>digital-facsimile</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="subtype">
                            <xsl:choose>
                                <xsl:when test="$completeness eq 'complete'">
                                    <xsl:text>full</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>partial</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="ref">
                            <xsl:attribute name="target">
                                <xsl:text>https://digital.bodleian.ox.ac.uk/inquire/p/</xsl:text>
                                <xsl:value-of select="$uuid"/>
                            </xsl:attribute>
                            <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="title">
                                <xsl:text>Digital Bodleian</xsl:text>
                            </xsl:element>
                        </xsl:element>
                        <xsl:text> </xsl:text>
                        <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="note">
                            <xsl:text>(</xsl:text>
                            <xsl:choose>
                                <xsl:when test="$completeness eq 'complete'">
                                    <xsl:text>full digital facsimile</xsl:text>
                                </xsl:when>
                                <xsl:when test="$numsurfaces eq '1'">
                                    <xsl:text>single sample image</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$numsurfaces"/>
                                    <xsl:text> selected images only</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>)</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:copy>
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
    
    
</xsl:stylesheet>