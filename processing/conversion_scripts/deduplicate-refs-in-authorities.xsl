<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="newline" select="'&#10;'"/> 
    
    <!-- First pass dedupes refs, and adds them where missing, storing the resulting output document in a variable -->
    <xsl:variable name="firstpass">
        <xsl:apply-templates/>
    </xsl:variable>
    
    <!-- Root template -->
    
    <xsl:template match="/">
        
        <!-- Second pass removes empty notes where all refs have been removed by first pass -->
        <xsl:apply-templates select="$firstpass" mode="secondpass"/>
        
    </xsl:template>
    
    <!-- The following templates do the first pass -->
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="not(following::processing-instruction('xml-model'))"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:note[@type='links']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="$newline"/>
            <xsl:text>                        </xsl:text>
            <list type="links">
                <xsl:for-each select=".//tei:ref">
                    <xsl:variable name="extid" select="replace(@target, '\D', '')"/>
                    <xsl:if test="not(preceding::tei:ref[matches(@target, concat($extid, '(/|$)'))])">
                        <xsl:value-of select="$newline"/>
                        <xsl:text>                            </xsl:text>
                        <item>
                            <xsl:value-of select="$newline"/>
                            <xsl:text>                                </xsl:text>
                            <ref target="{ @target }">
                                <xsl:value-of select="$newline"/>
                                <xsl:text>                                    </xsl:text>
                                <title>
                                    <xsl:value-of select="tei:title/text()"/>
                                </title>
                                <xsl:value-of select="$newline"/>
                                <xsl:text>                                </xsl:text>
                            </ref>
                            <xsl:value-of select="$newline"/>
                            <xsl:text>                            </xsl:text>
                        </item>
                        <xsl:value-of select="$newline"/>
                        <xsl:text>                        </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </list>
            <xsl:value-of select="$newline"/>
            <xsl:text>                    </xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:person[matches(@xml:id, 'person_\d+$') and not(.//tei:ref)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="*">
                <xsl:value-of select="$newline"/>
                <xsl:text>                    </xsl:text>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:value-of select="$newline"/>
            <xsl:text>                    </xsl:text>
            <note type="links">
                <xsl:value-of select="$newline"/>
                <xsl:text>                        </xsl:text>
                <list type="links">
                    <xsl:value-of select="$newline"/>
                    <xsl:text>                            </xsl:text>
                    <item>
                        <xsl:value-of select="$newline"/>
                        <xsl:text>                                </xsl:text>
                        <ref target="https://viaf.org/viaf/{ substring-after(@xml:id, 'person_') }">
                            <xsl:value-of select="$newline"/>
                            <xsl:text>                                    </xsl:text>
                            <title>
                                <xsl:text>VIAF</xsl:text>
                            </title>
                            <xsl:value-of select="$newline"/>
                            <xsl:text>                                </xsl:text>
                        </ref>
                        <xsl:value-of select="$newline"/>
                        <xsl:text>                            </xsl:text>
                    </item>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>                        </xsl:text>
                </list>
                <xsl:value-of select="$newline"/>
                <xsl:text>                    </xsl:text>
            </note>
            <xsl:for-each select="comment()">
                <xsl:value-of select="$newline"/>
                <xsl:text>                    </xsl:text>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:value-of select="$newline"/>
            <xsl:text>                </xsl:text>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:item[matches(@xml:id, 'subject_(sh|n)\d+$') and not(.//tei:ref)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="*">
                <xsl:value-of select="$newline"/>
                <xsl:text>                    </xsl:text>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:value-of select="$newline"/>
            <xsl:text>                    </xsl:text>
            <note type="links">
                <xsl:value-of select="$newline"/>
                <xsl:text>                        </xsl:text>
                <list type="links">
                    <xsl:value-of select="$newline"/>
                    <xsl:text>                            </xsl:text>
                    <item>
                        <xsl:value-of select="$newline"/>
                        <xsl:text>                                </xsl:text>
                        <ref target="https://lccn.loc.gov/{ substring-after(@xml:id, 'subject_') }">
                            <xsl:value-of select="$newline"/>
                            <xsl:text>                                    </xsl:text>
                            <title>
                                <xsl:text>LC</xsl:text>
                            </title>
                            <xsl:value-of select="$newline"/>
                            <xsl:text>                                </xsl:text>
                        </ref>
                        <xsl:value-of select="$newline"/>
                        <xsl:text>                            </xsl:text>
                    </item>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>                        </xsl:text>
                </list>
                <xsl:value-of select="$newline"/>
                <xsl:text>                    </xsl:text>
            </note>
            <xsl:for-each select="comment()">
                <xsl:value-of select="$newline"/>
                <xsl:text>                    </xsl:text>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:value-of select="$newline"/>
            <xsl:text>                </xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <!-- The following templates perform the second pass -->
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="secondpass">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*" mode="secondpass"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="secondpass"/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:note[@type='links' and not(.//tei:ref)]" mode="secondpass"></xsl:template>
    
</xsl:stylesheet>