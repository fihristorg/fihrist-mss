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
    
    

    <!-- The stylesheet is a library. It doesn't validate and won't produce HTML on its own. It is called by 
         convert2HTML.xsl and previewManuscript.xsl. Any templates added below will override the templates 
         in msdesc2html.xsl in the consolidated-tei-schema repository, allowing customization of manuscript 
         display for each catalogue. -->



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
    <xsl:template match="name[@key]/persName | author[@key]/persName | editor[@key]/persName">
        <xsl:apply-templates/>
    </xsl:template>



    <!-- The next three templates override the default by putting authors, editors and titles on separate lines, because in Fihirst there are often multiple
         titles in different languages, and versions of the author name in different languages, which gets confusing all on one line -->
    <xsl:template match="msItem/author">
        <xsl:variable name="rolelabel" as="xs:string" select="if(@role) then bod:personRoleLookup(concat('aut ', @role)) else 'Author'"/>
        <div class="tei-author">
            <span class="tei-label">
                <xsl:value-of select="$rolelabel"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:choose>
                <xsl:when test="@key and not(@key='')">
                    <a class="author">
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
            <xsl:choose>
                <xsl:when test="@key and not(@key='')">
                    <a>
                        <xsl:if test="not(@type = 'desc')">
                            <xsl:attribute name="class" select="'italic'"/>
                        </xsl:if>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <xsl:copy-of select="bod:direction(.)"/>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span>
                        <xsl:if test="not(@type = 'desc')">
                            <xsl:attribute name="class" select="'italic'"/>
                        </xsl:if>
                        <xsl:copy-of select="bod:direction(.)"/>
                        <xsl:apply-templates/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="msItem/editor">
        <xsl:variable name="rolelabel" as="xs:string" select="if(@role) then bod:personRoleLookup(@role) else 'Editor'"/>
        <div class="tei-editor">
            <span class="tei-label">
                <xsl:value-of select="$rolelabel"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:choose>
                <xsl:when test="@key and not(@key='')">
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
                <xsl:when test="@n or ancestor::msItem[@xml:id and title] or following-sibling::msItem or preceding-sibling::msItem or ancestor::msPart">
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
            <xsl:choose>
                <xsl:when test="not(listBibl/head)">
            <!-- Return control back to msdesc2html.xsl -->
            <xsl:apply-templates select="listBibl/bibl"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="listBibl">
                        <xsl:if test="head">
                            <h4>
                                <xsl:apply-templates select="head"/>
                            </h4>
                        </xsl:if>
                        <ul>
                            <xsl:for-each select="bibl">
                                <li>
                                    <!-- Return control back to msdesc2html.xsl -->
                                    <xsl:apply-templates select="."/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:if>
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
                    <xsl:for-each select="distinct-values($profiledesc//term/@key[not(. = '')])">
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
                    <xsl:for-each select="distinct-values(for $term in $profiledesc//term[not(@key) or @key=''] return normalize-space(string-join($term//text(), ' ')))[string-length() gt 0]">
                        <li>
                            <xsl:value-of select="."/>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>



    <!-- Prevent facs attributes from being displayed. Move to msdesc2html.xsl? -->
    <xsl:template match="@facs"/>
        
    
</xsl:stylesheet>
