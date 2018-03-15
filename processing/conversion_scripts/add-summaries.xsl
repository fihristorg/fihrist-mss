<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    exclude-result-prefixes="xs bod saxon tei"
    version="2.0">
    
    <xsl:function name="bod:shortenToNearestWord" as="xs:string">
        <xsl:param name="stringval" as="xs:string"/>
        <xsl:param name="tolength" as="xs:integer"/>
        <xsl:variable name="cutoffat" as="xs:integer" select="$tolength - 1"/>
        <xsl:choose>
            <xsl:when test="string-length($stringval) le $tolength">
                <!-- Already short enough, so return unmodified -->
                <xsl:value-of select="$stringval"/>
            </xsl:when>
            <xsl:when test="substring($stringval, $cutoffat, 1) = (' ', '&#9;', '&#10;')">
                <!-- The cut-off is at the location of some whitespace, so won't be cutting off any words -->
                <xsl:value-of select="concat(normalize-space(substring($stringval, 1, $cutoffat)), '…')"/>
            </xsl:when>
            <xsl:when test="substring($stringval, $tolength, 1) = (' ', '&#9;', '&#10;')">
                <!-- The cut-off is at the end of a word, so won't be cutting off any words -->
                <xsl:value-of select="concat(substring($stringval, 1, $cutoffat), '…')"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- The cut-off is in the middle of a word, so return everything up to the preceding word -->
                <xsl:value-of select="concat(replace(substring($stringval, 1, $cutoffat), '\s\S*$', ''), '…')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:variable name="newline" select="'&#10;'"/>
    
    <!-- Load the works authority file and match up the msItems in the input TEI document to entries in that -->
    <xsl:variable name="allworks" select="document('../../authority/works.xml')" as="document-node()"/>
    <xsl:variable name="allworkids" select="distinct-values($allworks//tei:listBibl/tei:bibl[@xml:id]/tei:ref/@target)" as="xs:string*"/>
    <xsl:variable name="workshere" select="//tei:msItem[@xml:id = $allworkids]"/>
    <xsl:variable name="workidshere" select="$workshere/@xml:id" as="xs:string*"/>
    <xsl:variable name="distinctworkkeyshere" select="distinct-values($allworks//tei:listBibl/tei:bibl[tei:ref/@target = $workidshere]/@xml:id)" as="xs:string*"/>
    <xsl:variable name="numworks" select="count($workshere)" as="xs:integer"/>
    <xsl:variable name="numdistinctworks" select="count($distinctworkkeyshere)" as="xs:integer"/>

    <!-- Load the persons authority file and match up the authors in the input TEI document to entries in that -->
    <xsl:variable name="allpeople" select="doc('../../authority/persons.xml')" as="document-node()"/>
    <xsl:variable name="allpersonkeys" select="$allpeople//tei:listPerson/tei:person/@xml:id" as="xs:string*"/>
    <xsl:variable name="authorshere" select="//tei:msItem/(tei:author|tei:author//tei:persName|tei:author/tei:name)[@key = $allpersonkeys]"/>
    <xsl:variable name="distinctauthorkeyshere" select="distinct-values($authorshere/@key)" as="xs:string*"/>
    <xsl:variable name="numdistinctauthors" select="count($distinctauthorkeyshere)" as="xs:integer"/>
    
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
    
    <xsl:template match="tei:msContents[not(tei:summary) or (not(tei:summary/*) and not(tei:summary/text()))]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="$newline"/>
            <xsl:text>                  </xsl:text>
            <summary change="#add-summary">
                <xsl:variable name="summarytext" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="every $workkey in $distinctworkkeyshere satisfies $workkey eq 'work_112'">
                            <!-- Special case for the Koran -->
                            <xsl:value-of select="$numworks"/>
                            <xsl:choose>
                                <xsl:when test="$numworks gt 1">
                                    <xsl:text> copies</xsl:text>
                                    <xsl:if test=".//text()[contains(., 'ragment')]">
                                        <xsl:text> or fragments</xsl:text>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text> copy</xsl:text>
                                    <xsl:if test=".//text()[contains(., 'ragment')]">
                                        <xsl:text> or fragment</xsl:text>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> of al-Qurʼān</xsl:text>
                        </xsl:when>
                        <xsl:when test="every $workkey in $distinctworkkeyshere satisfies $workkey = ('work_519', 'work_556')">
                            <!-- Special case: Collections of poetry -->
                            <xsl:value-of select="normalize-space(string-join($workshere[1]/tei:title[1]//text(), ''))"/>
                        </xsl:when>
                        <xsl:when test="$numdistinctworks gt 1">
                            <xsl:value-of select="$numworks"/>
                            <xsl:text> works</xsl:text>
                        </xsl:when>
                        <xsl:when test="$numdistinctworks eq 1">
                            <xsl:variable name="worktitle" select="replace(normalize-space(string-join($workshere[1]/tei:title[1]//text(), '')), '\.$', '')" as="xs:string"/>
                            <xsl:choose>
                                <xsl:when test="string-length($worktitle) ge 128">
                                    <!-- Long titles probably mean it is more of a description than a title, so just output first 128 chars of that -->
                                    <xsl:copy-of select="bod:shortenToNearestWord($worktitle, 128)"/>
                                </xsl:when>
                                <xsl:when test="matches($worktitle, '^(\d|One|Two|Three|Four|Five|Six|Seven|Eight|Nine|Ten|Eleven|Twelve|Thirt|Fift|Twent|Forty)')">
                                    <!-- Titles that start with numbers are usually descriptions -->
                                    <xsl:value-of select="$worktitle"/>
                                </xsl:when>
                                <xsl:when test="$numworks gt 1">
                                    <xsl:value-of select="$numworks"/>
                                    <xsl:text> copies of </xsl:text>
                                    <xsl:value-of select="$worktitle"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>1 copy of </xsl:text>
                                    <xsl:value-of select="$worktitle"/>
                                </xsl:otherwise>                                
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>No works</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="every $authorkey in $distinctauthorkeyshere satisfies $authorkey = ('person_f40', 'person_f41', 'person_f407', 'person_f403', 'person_f402', 'person_f404', 'person_f405', 'person_f406', 'person_f4580', 'person_f4579', 'person_f5625', 'person_f477', 'person_f5627', 'person_f4594', 'person_f4593', 'person_f4279', 'person_f4278')">
                            <!-- Special case: anonymous authors -->
                            <xsl:choose>
                                <xsl:when test="$numdistinctworks gt 1">
                                    <xsl:text> by anonymous authors</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Just display title -->
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$numdistinctworks eq 1 and matches(normalize-space(string-join($workshere[1]/tei:title[1]//text(), '')), '^D.[vw].n(-i| of)')">
                            <!-- Special case: when the work title begins with some variant of "Dīvān-i" or "Dīwān of" do not append the
                                 author name, because that would be roughly equivalent to "Shakespeare's Sonnets by William Shakespeare"-->
                        </xsl:when>
                        <!-- Do not output authors for certain works? -->
                        <xsl:when test="$numdistinctauthors gt 1">
                            <xsl:text> by </xsl:text>
                            <xsl:value-of select="$numdistinctauthors"/>
                            <xsl:text> authors</xsl:text>
                        </xsl:when>
                        <xsl:when test="$numdistinctauthors eq 1">
                            <xsl:text> by </xsl:text>
                            <xsl:choose>
                                <xsl:when test="$authorshere[1]//(tei:persName|tei:name)">
                                    <xsl:value-of select="string-join(($authorshere[1]//(tei:persName|tei:name))[1]//text()[not(parent::foreign)], '')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="string-join($authorshere[1]//text()[not(parent::foreign)], '')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="$newline"/>
                <xsl:text>                     </xsl:text>
                <xsl:value-of select="normalize-space(string-join($summarytext, ''))"/>
                <xsl:value-of select="$newline"/>
                <xsl:text>                  </xsl:text>
            </summary>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:msContents/tei:summary[not(*) and not(text())]"><!-- Delete empty summary elements --></xsl:template>
    
    
    <!-- The following templates perform the second pass, to add a change elements to the revisionDesc -->
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="updatechangelog">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*" mode="updatechangelog"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="updatechangelog"/></xsl:copy></xsl:template>

    <xsl:template match="tei:revisionDesc" mode="updatechangelog">
        <!-- Prepend a new change element, if the document has actually been changed (addition of XML comments not counted) -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="changes" select="//*[@change = '#add-summary']"/>
            <xsl:if test="exists($changes)">
                <xsl:value-of select="$newline"/>
                <xsl:text>         </xsl:text>
                <change when="{ format-date(current-date(), '[Y0001]-[M01]-[D01]') }" xml:id="add-summary">
                    <xsl:value-of select="$newline"/>
                    <xsl:text>            </xsl:text>
                    <persName>
                        <xsl:text>Andrew Morrison</xsl:text>
                    </persName>
                    <xsl:text> </xsl:text>
                    <xsl:text>Added summary</xsl:text>
                    <xsl:text> using </xsl:text>
                    <ref target="https://github.com/bodleian/fihrist-mss/tree/master/processing/conversion_scripts/add-summaries.xsl">add-summaries.xsl</ref>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>         </xsl:text>
                </change>
            </xsl:if>
            <xsl:apply-templates mode="updatechangelog"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>