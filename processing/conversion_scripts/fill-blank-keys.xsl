<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs tei"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="newline" select="'&#10;'"/>
    
	<xsl:variable name="worksbase" select="document('../authority/works_base.xml')//tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl"/>
    <xsl:variable name="worksadds" select="document('../authority/works_additions.xml')//tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl"/>
    <xsl:variable name="personsviaf" select="document('../authority/persons.xml')//tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[tei:note/tei:list/tei:item/tei:ref[contains(@target, 'viaf.org')]]"/>
    <xsl:variable name="personslocal" select="document('../authority/persons.xml')//tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[not(tei:note/tei:list/tei:item/tei:ref[contains(@target, 'viaf.org')])]"/>
    <xsl:variable name="subjectsbase" select="document('../authority/subjects_base.xml')//tei:TEI/tei:text/tei:body/tei:list/tei:item"/>
    <xsl:variable name="subjectsadds" select="document('../authority/subjects_additions.xml')//tei:TEI/tei:text/tei:body/tei:list/tei:item"/>
    
    <!-- Call this named template to run on all the records in the collections folder -->
    <xsl:template name="main">
        <xsl:for-each select="collection('../collections/?select=*.xml;recurse=yes')">
            <xsl:variable name="oldversion" select="tei:TEI"/>
            <xsl:variable name="newversion"><xsl:apply-templates select="tei:TEI"/></xsl:variable>
                <xsl:if test="count($newversion//@key[string-length(.) gt 0]) gt count($oldversion//@key[string-length(.) gt 0])">
                    <!-- Keys have been added, so output new version. This avoids making 
                         insignificant XML formatting and whitespace changes that would 
                         have to be stored in the git repository. -->
                    <xsl:result-document href="{ base-uri(.) }" method="xml" encoding="UTF-8">
                        <xsl:apply-templates select="(processing-instruction()|comment())[following-sibling::tei:TEI]"/>
                        <xsl:copy-of select="$newversion"/>
                        <xsl:apply-templates select="(processing-instruction()|comment())[preceding-sibling::tei:TEI]"/>
                    </xsl:result-document>
                </xsl:if>
        </xsl:for-each>
    </xsl:template>
	
    <xsl:template match="/">
        <xsl:apply-templates select="tei:TEI"/>
        <xsl:value-of select="$newline"/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

	<xsl:template match="@key[. = '' and string-length(normalize-space(parent::*/string())) gt 0]">
	    <xsl:variable 
	        name="textvals" 
	        as="xs:string*" 
	        select="
	           for $t in (parent::tei:*/string(), parent::tei:*//text())[string-length(normalize-space(.)) gt 1]
	               return normalize-space($t)
	           "
	    />
	    <!-- Search for matching authority file entries. Prefer ones in the base authority file over
	         ones in the additions authority file, because the former have already been published. In
	         the persons authority files, prefer VIAF to local. -->
	    <xsl:variable name="matchingkeys" as="xs:string*">
	        <xsl:choose>
	            <xsl:when test="parent::tei:title">
	                <xsl:variable name="basematches" as="xs:string*" select="$worksbase[tei:title/string() = $textvals]/@xml:id"/>
	                <xsl:variable name="addsmatches" as="xs:string*" select="$worksadds[tei:title/string() = $textvals]/@xml:id"/>
	                <xsl:copy-of select="if(count($basematches) gt 0) then $basematches else $addsmatches"/>
	            </xsl:when>
	            <xsl:when test="parent::tei:author or parent::tei:editor or parent::tei:persName">                
	                <xsl:variable name="viafmatches" as="xs:string*" select="$personsviaf[tei:persName/string() = $textvals]/@xml:id"/>
	                <xsl:variable name="localmatches" as="xs:string*" select="$personslocal[tei:persName/string() = $textvals]/@xml:id"/>
	                <xsl:copy-of select="if(count($viafmatches) gt 0) then $viafmatches else $localmatches"/>
	            </xsl:when>
	            <xsl:when test="parent::tei:term or parent::tei:placeName or parent::tei:settlement or parent::tei:region or parent::tei:country or parent::tei:orgName">
	                <xsl:variable name="basematches" as="xs:string*" select="$subjectsbase[tei:term/string() = $textvals]/@xml:id"/>
	                <xsl:variable name="addsmatches" as="xs:string*" select="$subjectsadds[tei:term/string() = $textvals]/@xml:id"/>
	                <xsl:copy-of select="if(count($basematches) gt 0) then $basematches else $addsmatches"/>
	            </xsl:when>
	            <xsl:otherwise>
	                <xsl:message>Key attribute found in unexpected element: <xsl:value-of select="name(parent::*)"/></xsl:message>
	            </xsl:otherwise>
	        </xsl:choose>
	    </xsl:variable>
	    <xsl:choose>
	        <xsl:when test="count($matchingkeys) eq 1">
	            <!-- Found a single matching authority entry so output key attribute containing its ID -->
	            <xsl:attribute name="key">
	                <xsl:value-of select="$matchingkeys[1]"/>
	            </xsl:attribute>
	        </xsl:when>
	        <xsl:when test="count($matchingkeys) gt 1">
	            <!-- Too many matching authority entries. Leave the key attribute blank and log it. -->
	            <xsl:attribute name="key"/>
	            <xsl:message>
	                <xsl:text>Ambiguous match for "</xsl:text>
	                <xsl:value-of select="normalize-space(string-join($textvals, '&quot;,&quot;'))"/>
	                <xsl:text>" in </xsl:text>
	                <xsl:value-of select="string-join(tokenize(base-uri(.), '/')[position() ge last() - 1], '/')"/>
	                <xsl:text>: </xsl:text>
	                <xsl:value-of select="string-join($matchingkeys, ',')"/>
	            </xsl:message>
	        </xsl:when>
	        <xsl:otherwise>
	            <!-- Did not find any matching authority entries. Leave the key attribute blank and log it. -->
	            <xsl:attribute name="key"/>
	            <xsl:message>
	                <xsl:text>No match for "</xsl:text>
	                <xsl:value-of select="normalize-space(string-join($textvals, '&quot;,&quot;'))"/>
	                <xsl:text>" in </xsl:text>
	                <xsl:value-of select="string-join(tokenize(base-uri(.), '/')[position() ge last() - 1], '/')"/>
	            </xsl:message>
	        </xsl:otherwise>
	    </xsl:choose>
	</xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>