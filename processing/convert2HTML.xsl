<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei html xs bod"
    version="2.0">
    
    <xsl:import href="https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2html.xsl"/>

    <!-- Only set this variable if you want full URLs hardcoded into the HTML
         on the web site (previewManuscript.xsl overrides this to do so when previewing.) -->
    <xsl:variable name="website-url" as="xs:string" select="''"/>



    <!-- Any templates added below will override the templates in the shared
         imported stylesheet, allowing customization of manuscript display for each catalogue. -->



    <!-- When two dates in different calendars are given, add some text to explain the difference. -->
    <xsl:template match="origin//origDate[@calendar and preceding-sibling::origDate[not(@calendar = current()/@calendar)]]">
        <span class="{name()}">
            <xsl:text>(</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> in the </xsl:text>
            <xsl:value-of select="replace(@calendar, '#', '')"/>
            <xsl:text> calendar)</xsl:text>
        </span>
    </xsl:template>
    
    

    <!-- In Fihrist, persNames are quite often nested inside name or author elements, which have their own @key. It is that @key which 
         has been chosen when building authority files, and will be in the index. Not the @key of the persName. So, override the default 
         and do NOT output these persNames as links. -->
    <xsl:template match="name[@key]/persName | author[@key]/persName">
        <xsl:apply-templates/>
    </xsl:template>



    <!-- The next two templates override the default by putting authors and titles on separate lines, because in Fihirst there are often multiple
         titles in different languages, and versions of the author name in different languages, which gets confusing all on one line -->
    <xsl:template match="msItem/author">
        <div class="{name()}">
            <span class="tei-label">
                <xsl:copy-of select="bod:standardText('Author:')"/>
                <xsl:text> </xsl:text>
            </span>
            <xsl:choose>
                <xsl:when test="@key">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="msItem/title">
        <div class="tei-title">
            <span class="tei-label">
                <xsl:copy-of select="bod:standardText('Title:')"/>
                <xsl:text> </xsl:text>
            </span>
            <span class="italic">
                <xsl:apply-templates/>
            </span>
        </div>
    </xsl:template>


    <!-- Do not output organization names as links, because Fihrist doesn't have an index for those -->
    <xsl:template match="name[@type = 'org'] | orgName">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>




</xsl:stylesheet>
