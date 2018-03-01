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
        <!-- NOTE: Only works for 1AH and later years, i.e. post-621AD, but that should be fine in a catalogue of Islamic manuscripts -->
        <xsl:variable name="ce" as="xs:float" select="($ah * 0.970229) + 621.5643"/>
        <xsl:copy-of select="(xs:integer(floor($ce)), xs:integer(ceiling($ce)))"/>
    </xsl:function>


    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
	<xsl:template match="text()|comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>

    <xsl:template match="tei:origDate">
        <xsl:choose>
            <xsl:when test="@calendar='#Hijri-qamari' and (@when or @notBefore or @notAfter or @from or @to)">
                <!-- Check for Islamic dates with normalized date attributes that match what's in the value of the origDate
					and converted these to Gregorian normalized date attributes -->
                <xsl:copy>
                    <xsl:choose>
                        <xsl:when test="@when and contains(text(), replace(@when, '^0', ''))">
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
                        <xsl:when test="@notBefore and @notAfter and (contains(text(), replace(@notBefore, '^0', '')) or contains(text(), replace(@notAfter, '^0', '')))">
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
                        <xsl:when test="@notBefore and not(@notAfter) and contains(text(), replace(@notBefore, '^0', ''))">
                            <!-- Same as above except it is an open-ended date range -->
                            <xsl:attribute name="notBefore">
                                <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notBefore)))[1]"/>
                            </xsl:attribute>
                            <xsl:copy-of select="@*[not(name()='notBefore')]"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:when test="@notAfter and not(@notBefore) and contains(text(), replace(@notAfter, '^0', ''))">
                            <!-- Same as above except it is an open-started date range -->
                            <xsl:attribute name="notAfter">
                                <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notAfter)))[2]"/>
                            </xsl:attribute>
                            <xsl:copy-of select="@*[not(name()='notAfter')]"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:when test="@from and @to and contains(text(), replace(@from, '^0', '')) and contains(text(), replace(@to, '^0', ''))">
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
                        <xsl:when test="@from and not(@to) and contains(text(), replace(@from, '^0', ''))">
                            <!-- Same as above except it is an open-ended date range -->
                            <xsl:attribute name="from">
                                <xsl:value-of select="bod:hijri2greg(xs:integer(number(@from)))[1]"/>
                            </xsl:attribute>
                            <xsl:copy-of select="@*[not(name()='from')]"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:when test="@to and not(@from) and contains(text(), replace(@to, '^0', ''))">
                            <!-- Same as above except it is an open-started date range -->
                            <xsl:attribute name="to">
                                <xsl:value-of select="bod:hijri2greg(xs:integer(number(@notAfter)))[2]"/>
                            </xsl:attribute>
                            <xsl:copy-of select="@*[not(name()='to')]"/>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:when test="matches(text(), '\d\s*(st|nd|rd|th)\s*cent', 'i')">
                            <!-- The text value of this origDate contains a century, or centuries, so copy as-is but 
								 leave a comment suggesting it be checked -->
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/><xsl:comment> Please review date attributes, see https://git.io/fihrist-dates </xsl:comment>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- This origDate is probably OK, so copy as-is -->
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@when or @notBefore or @notAfter or @from or @to">
                <!-- Otherwise if it has any normalized date attributes, copy it as-is (except fix some known typos in the calendar attribute) -->
                <xsl:copy>
                    <xsl:choose>
                        <xsl:when test="@calendar = '#Gregoorian'"><xsl:attribute name="calendar">#Gregorian</xsl:attribute></xsl:when>
                        <xsl:when test="@calendar"><xsl:attribute name="calendar" select="normalize-space(@calendar)"/></xsl:when>
                    </xsl:choose>
                    <xsl:copy-of select="@*[not(name()='calendar')]"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@atLeast or @atMost or @min or @max">
                <!-- Rare use of non-standard (for dates) attributes. Copy as-is and leave a note -->
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/><xsl:comment> Please review date attributes, see https://git.io/fihrist-dates </xsl:comment>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@calendar = '#Gregorian' and count(*) eq 0 and matches(text(), '\d\s*(st|nd|rd|th)\s*cent', 'i')">
                <!-- For simple unnormalized Gregorian dates, create normalized date attributes when the text value mentions a century. -->
                <xsl:choose>
                    <xsl:when test="contains(text(), '/') or contains(text(), ' or ')">
                        <!-- Cannot cope with dates spanning multiple centuries, such as "16th or 17th cent." or 
							 "Late 18th/early 19th century", so just copy these as-is and leave a note to review -->
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/><xsl:comment> Please review date attributes, see https://git.io/fihrist-dates </xsl:comment>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="stringval" select="text()"/>
                        <xsl:copy>
                            <xsl:attribute name="notBefore">
                                <xsl:analyze-string select="$stringval" regex="(\d?\d)\s*(st|nd|rd|th)\s*cent" flags="i">
                                    <xsl:matching-substring>
                                        <xsl:choose>
                                            <xsl:when test="matches($stringval, 'late', 'i')">
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
                                <xsl:analyze-string select="$stringval" regex="(\d?\d)\s*(st|nd|rd|th)\s*cent" flags="i">
                                    <xsl:matching-substring>
                                        <xsl:choose>
                                            <xsl:when test="matches($stringval, 'early', 'i')">
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
            <xsl:when test="@calendar = '#Gregorian' and count(*) eq 0 and matches(text(), '\d?\d\d\d')">
                <!-- For simple unnormalized Gregorian dates, create normalized date attribute when the text value contains a 
					 three-or-four-digit substring -->
                <xsl:copy>
                    <xsl:choose>
                        <xsl:when test="matches(text(), 'before \d\d\d', 'i')">
                            <xsl:attribute name="notAfter">
                                <xsl:analyze-string select="text()" regex="(\d?\d\d\d)">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(1)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="matches(text(), 'after \d\d\d', 'i')">
                            <xsl:attribute name="notBefore">
                                <xsl:analyze-string select="text()" regex="(\d?\d\d\d)">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(1)"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="when">
                                <xsl:analyze-string select="text()" regex="(\d?\d\d\d)">
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
            <xsl:when test="@calendar = '#Hijri-qamari' and count(*) eq 0 and matches(text(), '[0-9]?[0-9][0-9][0-9]')">
                <!-- For simple unnormalized Islamic dates, create normalized date attributes when the text value contains a 
					 three-or-four-digit substring. Using [0-9] instead of \d above because Arabic digits cannot be cast into 
                     integers by the below (probably possible, but there's only one example currently in the Fihrist collections -->
                <xsl:copy>
                    <xsl:attribute name="notBefore">
                        <xsl:analyze-string select="text()" regex="(\d?\d\d\d)">
                            <xsl:matching-substring>
                                <xsl:value-of select="bod:hijri2greg(xs:integer(number(regex-group(1))))[1]"/>   <!-- TODO: Change function to take string and cast to integer there, so it can handle NaN -->
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:attribute>
                    <xsl:attribute name="notAfter">
                        <xsl:analyze-string select="text()" regex="(\d?\d\d\d)">
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
            <xsl:when test="(@calendar = '#Gregorian' and text() = 'Gregorian') or (@calendar = '#Hijri-qamari' and text() = 'Hijri-qamari') and count(*) eq 0">
                <!-- Completely strip out meaningless origDate elements added by previous batch conversion -->
            </xsl:when>
            <xsl:when test="not(matches(string-join(.//text(), ' '), '(\d|cent)', 'i'))">
                <!-- Convert origDate elements containing messages about the work being undateable into plain text or a paragraph -->
                <xsl:choose>
                    <xsl:when test="parent::tei:origin">
                        <p>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                            <xsl:apply-templates/>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:attribute name="change" select="'#fix-dates'"/>
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Anything else, copy as-is -->
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>