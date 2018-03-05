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
    
    <xsl:function name="bod:hijri2greg" as="xs:integer*">
        <xsl:param name="ah" as="xs:integer"/>
        <!-- NOTE: Only works for 1AH and later years, i.e. post-621AD, but that is OK because there are no negative values in @when|@notBefore|@from attributes in Fihrist -->
        <xsl:variable name="ce" as="xs:float" select="($ah * 0.970229) + 621.5643"/>
        <xsl:copy-of select="(xs:integer(floor($ce)), xs:integer(ceiling($ce)))"/>
    </xsl:function>


    <xsl:template match="/">
        
        <!-- First pass modifies the origDate elements -->
        <xsl:variable name="firstpass">
            <xsl:apply-templates/>
        </xsl:variable>
        
        <!-- Second pass tidies up, and logs changes in revisionDesc -->
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

    <xsl:template match="tei:origin/tei:p[not(@*)]"><!-- Strip out plain p tags in origin --><xsl:apply-templates/></xsl:template>
    
    <xsl:template match="tei:origDate">
        <!-- Create a copy of the origDate so typos in calendar attributes can be fixed first -->
        <xsl:variable name="fixAttributes">
            <xsl:copy>
                <xsl:for-each select="@*">
                    <xsl:choose>
                        <xsl:when test="name() = 'calendar' and . = '#Hijri-qaari'">
                            <xsl:attribute name="calendar" select="'#Hijri-qamari'"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'calendar' and . = '#Hijri-qamar'">
                            <xsl:attribute name="calendar" select="'#Hijri-qamari'"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'calendar' and . = '#Hijri-Qamari'">
                            <xsl:attribute name="calendar" select="'#Hijri-qamari'"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'calendar' and . = '#Higiri-Qamari'">
                            <xsl:attribute name="calendar" select="'#Hijri-qamari'"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'calendar' and . = '#Gregoorian'">
                            <xsl:attribute name="calendar" select="'#Gregorian'"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'calendar' and . = '#gregorian'">
                            <xsl:attribute name="calendar" select="'#Gregorian'"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'calendar' and . = '#Gregoriani'">
                            <xsl:attribute name="calendar" select="'#Gregorian'"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'atLeast'">
                            <xsl:attribute name="notBefore" select="."/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'atMost'">
                            <xsl:attribute name="notAfter" select="."/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'min'">
                            <xsl:attribute name="from" select="."/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:when test="name() = 'max'">
                            <xsl:attribute name="to" select="."/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:variable>
        <!-- Process the origDate a second time, looking at the actual dates -->
        <xsl:for-each select="$fixAttributes/tei:origDate">
            <xsl:variable name="textval" select="normalize-space(string-join(.//text(), ' '))"/>
            <xsl:choose>
                <xsl:when test="@calendar='#Hijri-qamari' and (@when or @notBefore or @notAfter or @from or @to)">
                    <!-- Check for Islamic dates with normalized date attributes that match what's in the value of the origDate
					and converted these to Gregorian normalized date attributes -->
                    <xsl:copy>
                        <xsl:choose>
                            <xsl:when test="@when and contains($textval, replace(@when, '^0', ''))">
                                <!-- The text value of this origDate contains a match for the @when, so very likely the Islamic
								 year has been erroneously record in the @when instead of its Gregorian equivalent. So calculate
								 what it should be and replace the @when (always a two-year range.) -->
                                <xsl:attribute name="notBefore">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@when)))[1]"/>
                                </xsl:attribute>
                                <xsl:attribute name="notAfter">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@when)))[2]"/>
                                </xsl:attribute>
                                <xsl:copy-of select="@*[not(name()='when')]"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="@notBefore and @notAfter and (contains($textval, replace(@notBefore, '^0', '')) or contains($textval, replace(@notAfter, '^0', '')))">
                                <!-- The text values of this origDate contains a match for either the @notBefore or @notAfter, so very 
								 likely the Islamic year has been erroneously record in the @when instead of its Gregorian equivalent. 
								 So calculate what it should be and change the values of @notBefore and @notAfter -->
                                <xsl:attribute name="notBefore">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notBefore)))[1]"/>
                                </xsl:attribute>
                                <xsl:attribute name="notAfter">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notAfter)))[2]"/>
                                </xsl:attribute>
                                <xsl:copy-of select="@*[not(name()='notBefore' or name()='notAfter')]"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="@notBefore and not(@notAfter) and contains($textval, replace(@notBefore, '^0', ''))">
                                <!-- Same as above except it is an open-ended date range -->
                                <xsl:attribute name="notBefore">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notBefore)))[1]"/>
                                </xsl:attribute>
                                <xsl:copy-of select="@*[not(name()='notBefore')]"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="@notAfter and not(@notBefore) and contains($textval, replace(@notAfter, '^0', ''))">
                                <!-- Same as above except it is an open-started date range -->
                                <xsl:attribute name="notAfter">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notAfter)))[2]"/>
                                </xsl:attribute>
                                <xsl:copy-of select="@*[not(name()='notAfter')]"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="@from and @to and contains($textval, replace(@from, '^0', '')) and contains($textval, replace(@to, '^0', ''))">
                                <!-- Same as above except @from and @to have been used instead of @notBefore and @notAfter -->
                                <xsl:attribute name="from">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@from)))[1]"/>
                                </xsl:attribute>
                                <xsl:attribute name="to">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@to)))[2]"/>
                                </xsl:attribute>
                                <xsl:copy-of select="@*[not(name()='from' or name()='to')]"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="@from and not(@to) and contains($textval, replace(@from, '^0', ''))">
                                <!-- Same as above except it is an open-ended date range -->
                                <xsl:attribute name="from">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@from)))[1]"/>
                                </xsl:attribute>
                                <xsl:copy-of select="@*[not(name()='from')]"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="@to and not(@from) and contains($textval, replace(@to, '^0', ''))">
                                <!-- Same as above except it is an open-started date range -->
                                <xsl:attribute name="to">
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notAfter)))[2]"/>
                                </xsl:attribute>
                                <xsl:copy-of select="@*[not(name()='to')]"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:when test="matches($textval, '\d\s*(st|nd|rd|th)\s*cent', 'i')">
                                <!-- The text value of this origDate contains a century, or centuries, so copy as-is but 
								 leave a comment suggesting it be checked -->
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates/>
                                <xsl:comment> Please review date attributes, see https://git.io/fihrist-dates </xsl:comment>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- This origDate is probably correctly translating an Islamic date in the text into Gregorian attributes, so copy as-is... -->
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates/>
                                <!-- ...but leave a comment if the text does not look like it is describing a date or time period -->
                                <xsl:if test="not(matches($textval, '(\d|cent)', 'i'))">
                                    <xsl:comment> Please review date text, see https://git.io/fihrist-dates </xsl:comment>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="@when or @notBefore or @notAfter or @from or @to">
                    <!-- Otherwise if it has any normalized date attributes, copy it as-is... -->
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                        <!-- ...but leave a comment if the text does not look like it is describing a date or time period -->
                        <xsl:if test="not(matches($textval, '(\d|cent)', 'i'))">
                            <xsl:comment> Please review date text, see https://git.io/fihrist-dates </xsl:comment>
                        </xsl:if>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="@calendar = '#Gregorian' and count(*) eq 0 and matches($textval, '\d\s*(st|nd|rd|th)\s*cent', 'i')">
                    <!-- For simple unnormalized Gregorian dates, create normalized date attributes when the text value mentions a century. -->
                    <xsl:choose>
                        <xsl:when test="contains($textval, '/') or contains($textval, ' or ')">
                            <!-- Cannot cope with dates spanning multiple centuries, such as "16th or 17th cent." or 
							 "Late 18th/early 19th century", so just copy these as-is and leave a note to review -->
                            <xsl:copy>
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates/>
                                <xsl:comment> Please review date attributes, see https://git.io/fihrist-dates </xsl:comment>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy>
                                <xsl:attribute name="notBefore">
                                    <xsl:analyze-string select="$textval" regex="(\d?\d)\s*(st|nd|rd|th)\s*cent" flags="i">
                                        <xsl:matching-substring>
                                            <xsl:choose>
                                                <xsl:when test="matches($textval, 'late', 'i')">
                                                    <xsl:value-of select="concat(number(regex-group(1)) - 1, '50')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(number(regex-group(1)) - 1, '00')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:attribute>
                                <xsl:attribute name="notAfter">
                                    <xsl:analyze-string select="$textval" regex="(\d?\d)\s*(st|nd|rd|th)\s*cent" flags="i">
                                        <xsl:matching-substring>
                                            <xsl:choose>
                                                <xsl:when test="matches($textval, 'early', 'i')">
                                                    <xsl:value-of select="concat(number(regex-group(1)) - 1, '50')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(regex-group(1), '00')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:attribute>
                                <xsl:copy-of select="@*"/>
                                <xsl:attribute name="change" select="'#fix-dates'"/>
                                <xsl:apply-templates/>
                            </xsl:copy>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="@calendar = '#Gregorian' and count(*) eq 0 and matches($textval, '\d?\d\d\d')">
                    <!-- For simple unnormalized Gregorian dates, create normalized date attribute when the text value contains a 
					 three-or-four-digit substring -->
                    <xsl:copy>
                        <xsl:choose>
                            <xsl:when test="matches($textval, 'before \d\d\d', 'i')">
                                <xsl:attribute name="notAfter">
                                    <xsl:analyze-string select="$textval" regex="(\d?\d\d\d)">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="matches($textval, 'after \d\d\d', 'i')">
                                <xsl:attribute name="notBefore">
                                    <xsl:analyze-string select="$textval" regex="(\d?\d\d\d)">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="when">
                                    <xsl:analyze-string select="$textval" regex="(\d?\d\d\d)">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="change" select="'#fix-dates'"/>
                        <xsl:apply-templates/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="@calendar = '#Hijri-qamari' and count(*) eq 0 and matches($textval, '[0-9]?[0-9][0-9][0-9]')">
                    <!-- For simple unnormalized Islamic dates, create normalized date attributes when the text value contains a 
					 three-or-four-digit substring. Using [0-9] instead of \d above because Arabic digits cannot be cast into 
                     integers by the below (probably possible, but there's only one example currently in the Fihrist collections -->
                    <xsl:copy>
                        <xsl:attribute name="notBefore">
                            <xsl:analyze-string select="$textval" regex="(\d?\d\d\d)">
                                <xsl:matching-substring>
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(regex-group(1))))[1]"/>   <!-- TODO: Change function to take string and cast to integer there, so it can handle NaN -->
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:attribute>
                        <xsl:attribute name="notAfter">
                            <xsl:analyze-string select="$textval" regex="(\d?\d\d\d)">
                                <xsl:matching-substring>
                                    <xsl:value-of select="bod:hijri2greg(xs:integer(number(regex-group(1))))[2]"/>   <!-- TODO: Change function to take string and cast to integer there, so it can handle NaN -->
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:attribute>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="change" select="'#fix-dates'"/>
                        <xsl:apply-templates/>
                    </xsl:copy>
                </xsl:when>
                <xsl:when test="(@calendar = '#Gregorian' and $textval = 'Gregorian') or (@calendar = '#Hijri-qamari' and $textval = 'Hijri-qamari') and count(*) eq 0">
                    <!-- Completely strip out meaningless origDate elements added by previous batch conversion -->
                    <desc change="#fix-dates"/>
                </xsl:when>
                <xsl:when test="not(matches($textval, '(\d|cent)', 'i'))">
                    <!-- Remove origDate tags around statements that the date is not known -->
                    <desc>
                        <xsl:attribute name="change" select="'#fix-dates'"/>
                        <xsl:apply-templates/>
                        <xsl:if test="$textval eq 'Unknown' or $textval eq 'unknown'">
                            <xsl:text> date</xsl:text>
                        </xsl:if>
                    </desc>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Anything else, copy as-is -->
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- The following templates perform the second pass, to add a change elements to the revisionDesc -->
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="updatechangelog">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*" mode="updatechangelog"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="updatechangelog"/></xsl:copy></xsl:template>

    <xsl:template match="tei:origin[.//@change = '#fix-dates']" mode="updatechangelog">
        <!-- Add a change attribute to the origin element, if the origDates within have been changed -->
        <xsl:variable name="origincopy">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:attribute name="change" select="'#fix-dates'"/>
                <xsl:apply-templates mode="updatechangelog"/>
            </xsl:copy>
        </xsl:variable>
        <!-- Tidy up, deduplicating multiple "no date" or "n.d." and removing excess whitespace -->
        <xsl:choose>
            <xsl:when test="$origincopy/tei:origin/child::*">
                <xsl:copy-of select="$origincopy"/>
            </xsl:when>
            <xsl:otherwise>
                <origin>
                    <xsl:copy-of select="$origincopy/tei:origin/@*"/>
                    <xsl:value-of select="normalize-space(string-join($origincopy/tei:origin/text(), ''))"/>
                </origin>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:origin//tei:desc[@change = '#fix-dates']"  mode="updatechangelog">
        <!-- Remove desc elements added above, which were just so changes could be logged correctly -->
        <xsl:if test="not(text() = preceding-sibling::tei:desc/text())">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:origin//tei:origDate[@change = '#fix-dates']"  mode="updatechangelog">
        <!-- Remove the change attribute from the origDate because those are going on the parent origin -->
        <xsl:copy>
            <xsl:copy-of select="@*[not(name() = 'change' and . = '#fix-dates')]"/>
            <xsl:apply-templates mode="updatechangelog"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:revisionDesc" mode="updatechangelog">
        <!-- Prepend a new change element, if the document has actually been changed (addition of XML comments not counted) -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="changes" select="//*[@change = '#fix-dates']"/>
            <xsl:if test="exists($changes)">
                <xsl:value-of select="$newline"/>
                <xsl:text>         </xsl:text>
                <change when="{ format-date(current-date(), '[Y0001]-[M01]-[D01]') }" xml:id="fix-dates">
                    <xsl:value-of select="$newline"/>
                    <xsl:text>            </xsl:text>
                    <persName>
                        <xsl:text>Andrew Morrison</xsl:text>
                    </persName>
                    <xsl:text> </xsl:text>
                    <xsl:if test="$changes[self::tei:origDate]">
                        <xsl:text>Added or modified attributes in origDate elements </xsl:text>
                    </xsl:if>
                    <xsl:if test="$changes[self::tei:desc]">
                        <xsl:choose>
                            <xsl:when test="$changes[self::tei:origDate]">
                                <xsl:text>and r</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>R</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>emoved origDate tags around something which is not a date </xsl:text>
                    </xsl:if>
                    <xsl:text>using </xsl:text>
                    <ref target="https://github.com/bodleian/fihrist-mss/tree/master/processing/conversion_scripts/fix-dates.xsl">fix-dates.xsl</ref>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>         </xsl:text>
                </change>
            </xsl:if>
            <xsl:apply-templates mode="updatechangelog"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>