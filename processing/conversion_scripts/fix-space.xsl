<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:saxon="http://saxon.sf.net/"
	exclude-result-prefixes="xs"
	version="2.0">
    
    <!-- DON'T FORGET TO SET XSLT TRANSFORMER TO IGNORE THE SCHEMA (TO AVOID ADDING DEFAULT ATTRIBUTES) -->

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="newline" select="'&#10;'"/>
	
	<xsl:template match="/">
		<xsl:value-of select="$newline"/>
		<xsl:processing-instruction name="xml-model"><xsl:text>href="https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text></xsl:processing-instruction><xsl:value-of select="$newline"/>
		<xsl:processing-instruction name="xml-model"><xsl:text>href="https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text></xsl:processing-instruction><xsl:value-of select="$newline"/>
		<xsl:apply-templates select="*[not(processing-instruction('xml-model'))]"/>
	</xsl:template>

	<xsl:template name="FixLeadingSpace">
	    <xsl:if test="not(self::ex or self::expan or self::supplied)">
    		<xsl:if test="preceding-sibling::*[1] &lt;&lt; preceding-sibling::text()[1] or (preceding-sibling::text() and not(preceding-sibling::*))">
    			<xsl:if test="string-length(normalize-space(preceding-sibling::text()[1])) gt 0 and not(matches(preceding-sibling::text()[1], '[ (]$'))">
    				<xsl:text> </xsl:text>
    			</xsl:if>
    		</xsl:if>
	    </xsl:if>
	</xsl:template>

	<xsl:template name="FixTrailingSpace">
	    <xsl:if test="not(self::ex or self::expan or self::supplied)">
    		<xsl:if test="following-sibling::*[1] &gt;&gt; following-sibling::text()[1] or (following-sibling::text() and not(following-sibling::*))">
    			<xsl:if test="string-length(normalize-space(following-sibling::text()[1])) gt 0 and not(matches(following-sibling::text()[1], '^[ ),;:\.''\?]'))">
    				<xsl:text> </xsl:text>
    			</xsl:if>
    		</xsl:if>
	    </xsl:if>
	</xsl:template>

	<xsl:template match="*">
		<xsl:call-template name="FixLeadingSpace"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
		<xsl:call-template name="FixTrailingSpace"/>
	</xsl:template>
    	
	<xsl:template match="@*|comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>

</xsl:stylesheet>