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



    <!-- Append the calendar if it does not appear to have been mentioned in the origDate text -->
    <xsl:template match="origDate[@calendar]">
        <span class="{name()}">
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="@calendar = '#Hijri-qamari' and not(matches(string-join(.//text(), ''), '[\d\s](H|AH|A\.H|Hijri)'))">
                    <xsl:text> AH</xsl:text>
                </xsl:when>
                <xsl:when test="@calendar = '#Gregorian' and not(matches(string-join(.//text(), ''), '[\d\s](CE|AD|C\.E|A\.D|Gregorian)'))">
                    <xsl:text> CE</xsl:text>
                </xsl:when>
            </xsl:choose>
        </span>
        <xsl:variable name="nextelem" select="following-sibling::*[1]"/>
        <xsl:if test="following-sibling::*[self::origDate] and not(following-sibling::node()[1][self::text()][string-length(normalize-space(.)) gt 0])">
            <!-- Insert a semi-colon between adjacent dates without text between them -->
            <xsl:text>; </xsl:text>
        </xsl:if>
    </xsl:template>
    
    

    <!-- In Fihrist, persNames are quite often nested inside name or author elements, which have their own @key. It is that @key which 
         has been chosen when building authority files, and will be in the index. Not the @key of the persName. So, override the default 
         and do NOT output these persNames as links. -->
    <xsl:template match="name[@key]/persName | author[@key]/persName">
        <xsl:apply-templates/>
    </xsl:template>



    <!-- The next three templates override the default by putting authors, editors and titles on separate lines, because in Fihirst there are often multiple
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
    
    <xsl:template match="msItem/editor">
        <xsl:variable name="rolelabel" select="(@role, 'editor')[1]"/>
        <div class="tei-editor{ if ($rolelabel ne 'editor') then concat(' tei-', lower-case($rolelabel)) else ''}">
            <span class="tei-label">
                <xsl:choose>
                    <xsl:when test="$rolelabel ne 'editor'">
                        <xsl:value-of select="upper-case(substring($rolelabel, 1, 1))"/>
                        <xsl:copy-of select="lower-case(substring($rolelabel, 2))"/>
                     <xsl:text>: </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="bod:standardText('Editor:')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
            </span>
            <xsl:apply-templates/>
        </div>
    </xsl:template>



    <!-- Do not output organization names as links, because Fihrist doesn't have an index for those -->
    <xsl:template match="name[@type = 'org'] | orgName">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>



    <!-- Move bibliographic references (which can include a links to the digitial surrogates but those are not tagged any differently) 
         so they appear under a separate subheading. First override their display in document order... -->
    <xsl:template match="msItem/listBibl"></xsl:template>
    
    <!-- ...then implement a named-template that will be called at the appropriate point in msdesc2html.xsl to display after the rest 
         of the item description but before nested msItems, if any. The context for this template is the msItem. -->
    <xsl:template name="MsItemFooter">
        <xsl:if test="listBibl/bibl">
            <xsl:choose>
                <xsl:when test="@n or ancestor::msItem[@xml:id and title] or following-sibling::msItem or preceding-sibling::msItem">
                    <h4>
                        <xsl:copy-of select="bod:standardText('References')"/>
                    </h4>
                </xsl:when>
                <xsl:otherwise>
                    <h3>
                        <xsl:copy-of select="bod:standardText('References')"/>
                    </h3>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Return control back to msdesc2html.xsl -->
            <xsl:apply-templates select="listBibl/bibl"/>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- The following templates should be moved into msdesc2html.xsl when I've tested their effect on other catalogues -->
    <xsl:template match="list">
        <ul class="mslist">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    <xsl:template match="item">
        <li class="mslistitem">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
    <xsl:template match="label">
        <span class="mslabel"><!-- Cannot use class of "label" as clashes with something else in the CSS -->
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    

    
    <!-- These really should be fixed in the source TEI - pointless single-item lists in the source 
         history - but this is a quick fix to stop them looking ugly on the web site -->
    <xsl:template match="recordHist/source/list[count(item) eq 1] | recordHist/source/list[count(item) eq 1]/item">
        <xsl:apply-templates/>
    </xsl:template>


    
    <!-- This implements a named-template that will be called at the appropriate point in msdesc2html.xsl to display
         at the very end of the HTML generated by the XSL (which on the web site means just before the "Comments" subheading). -->
    <xsl:template name="Footer">
        <xsl:variable name="profiledesc" as="element()*" select="/TEI//profileDesc"/>
        <xsl:if test="count($profiledesc//term) gt 0">
            <div class="subjects">
                <h3>
                    <xsl:copy-of select="bod:standardText('Subjects')"/>
                </h3>
                <ul>
                    <!-- First the terms with keys, which can be turned into links to their entry in the subjects index -->
                    <xsl:for-each select="distinct-values($profiledesc//term/@key)">
                        <xsl:variable name="key" as="xs:string" select="."/>
                        <xsl:variable name="termswiththiskey" as="xs:string*" select="distinct-values(for $term in $profiledesc//term[@key = $key] return normalize-space(string-join($term//text(), ' ')))[string-length() gt 0]"/>
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$website-url"/>
                                    <xsl:text>/catalog/</xsl:text>
                                    <xsl:value-of select="$key"/>
                                </xsl:attribute>
                                <xsl:for-each select="$termswiththiskey">
                                    <!-- Merge variant forms of the same subject (e.g. Word history and Universal History) into one link -->
                                    <xsl:value-of select="."/>
                                    <xsl:if test="position() ne last()">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </a>
                        </li>
                    </xsl:for-each>
                    
                    <!-- Next the terms without keys, which can only be displayed as text -->
                    <xsl:for-each select="distinct-values(for $term in $profiledesc//term[not(@key)] return normalize-space(string-join($term//text(), ' ')))[string-length() gt 0]">
                        <li>
                            <xsl:value-of select="."/>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>
    
    
    
</xsl:stylesheet>
