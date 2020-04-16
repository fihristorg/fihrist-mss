<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="/"
    exclude-result-prefixes="xs tei local"
    version="2.0">
    
    <!-- This does two things with authority files: 
            - Re-orders the entries alphabetically
            - Deletes all existing comments and replaces them with new ones listing which records reference each authority entry
         It does not update the names or titles from the records
         It should be run individually on each authority XML file, base or additions, not on the root files that use xi:include
    -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="allrecs" as="element(tei:TEI)*" select="collection('../../collections/?select=*.xml;recurse=yes')/tei:TEI"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model') and not(following::processing-instruction('xml-model'))"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="comment()"/>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
    
    <xsl:template match="/tei:TEI/tei:text/tei:body/tei:listPerson">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:person">
                <xsl:sort select="local:simplifyForSorting((tei:persName[@type='display'],tei:persName[1])[1]/string())"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/tei:TEI/tei:text/tei:body/tei:listBibl">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:bibl">
                <xsl:sort select="local:simplifyForSorting((tei:title[@type='uniform'],tei:title[1])[1]/string())"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/tei:TEI/tei:text/tei:body/tei:list">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:item">
                <xsl:sort select="local:simplifyForSorting((tei:term[@type='display'],tei:term[1])[1]/string())"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:body/tei:listPerson/tei:person[@xml:id] | tei:body/tei:listBibl/tei:bibl[@xml:id] | tei:body/tei:list/tei:item[@xml:id]">
        <xsl:variable name="key" as="xs:string" select="@xml:id"/>
        <xsl:variable name="instances" as="element()*" select="$allrecs//*[@key = $key]"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="child::*|processing-instruction()"/>
            <xsl:choose>
                <xsl:when test="count($instances) gt 0">
                    <xsl:variable name="paths" as="xs:string*">
                        <xsl:for-each select="$instances">
                            <xsl:variable name="nearestid" as="xs:string*" select="ancestor-or-self::*[@xml:id and not(self::tei:TEI)][1]/@xml:id"/>
                            <xsl:choose>
                                <xsl:when test="count($nearestid) eq 1">
                                    <xsl:value-of select="concat(local:percentEncode(substring-after(base-uri(.), 'collections/')), '#', local:percentEncode($nearestid[1]))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="local:percentEncode(substring-after(base-uri(.), 'collections/'))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:for-each select="distinct-values($paths)">
                        <xsl:sort select="."/>
                        <xsl:comment>
                            <xsl:text> ../collections/</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text> </xsl:text>
                        </xsl:comment>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:comment>
                        <xsl:text> THIS ENTRY IS NOT CURRENTLY REFERENCED BY ANY KEY ATTRIBUTES. </xsl:text>
                        <xsl:if test="count(comment()) gt 0">
                            <xsl:text>It was created for the following records but they may have changed since: </xsl:text>
                        </xsl:if>
                    </xsl:comment>
                    <xsl:value-of select="$newline"/>
                    <xsl:copy-of select="comment()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
        <xsl:value-of select="$newline"/>
        <xsl:value-of select="$newline"/>
    </xsl:template>
    
    <xsl:function name="local:simplifyForSorting" as="xs:string">
        <xsl:param name="str" as="xs:string"/>
        <xsl:variable name="nonwordregex" as="xs:string">([^\w\d\s'‘\-\.]|=)</xsl:variable>
        <xsl:value-of select="
            normalize-space(
                replace(
                    replace(
                        replace(
                            replace(
                                replace(
                                    replace(
                                        replace(
                                            replace(
                                                replace(
                                                    replace(
                                                        replace(
                                                            translate(
                                                                replace(
                                                                    lower-case($str)
                                                                , $nonwordregex ,'')
                                                                , 'ạĀāàáâḅÇçČḌḍḏèéëēĞğĠġǦǧḢḣḤḥḪḫẖĪīĭİıÎÏìíîïḲḳḴṇōóÖṛŕśṢṣŞşŠšṬṭṯúûüŪūżẒẓẔẕ', 'aaaaaabcccdddeeeegggggghhhhhhhiiiiiiiiiiikkknooorrssssssstttuuuuuzzzzz')
                                                        , '(^|\s)(the|a|an)\s', ' ')
                                                    , '(z̤|ẓ)', 'z')
                                                , 'ü', 'u')
                                            , 'ī', 'i')
                                        , 'ā', 'a')
                                    , 'ṭ', 't')
                                , 'ṣ', 's')
                            , 'æ', 'ae')
                        , 'œ', 'oe')
                    , 'diwan', 'divan')
                , 'divan(\-i|i | of )' ,'divan ')
            )
        "/>
    </xsl:function>
    
    <xsl:function name="local:percentEncode" as="xs:string">
        <xsl:param name="str" as="xs:string"/>
        <xsl:value-of select="
            string-join(
                tokenize(
                    string-join(
                        for $s in tokenize($str, '%') return encode-for-uri($s)
                    , '%')
                , '-')
            , '%2D')
        "/>
    </xsl:function>

</xsl:stylesheet>