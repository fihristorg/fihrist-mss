<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jc="http://james.blushingbunny.net/ns.html" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="yes"/>
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>Quick stylesheet demonstrating tokenization and grouping of a rhyme scheme. run with
            "saxon -it:main"</desc>
    </doc>


    <!-- Our starting varialbe -->
    <xsl:variable name="rhyme">(a*)a*(a*)b(c*)c*(c*)bddee(f)fg(h)hg/</xsl:variable>


    <!-- Our main named templated -->
    <xsl:template name="main">
        <foo>
            <!-- Show the input -->
            <input>
                <xsl:copy-of select="$rhyme"/>
            </input>
            <!-- Tokenize the rhyme string -->
            <tokenized-rhymes>
                <xsl:copy-of select="jc:tokenizeRhymes($rhyme)"/>
            </tokenized-rhymes>
            <!-- Group the rhyme string -->
            <grouped-rhymes>
                <xsl:copy-of select="jc:groupRhymes($rhyme)"/>
            </grouped-rhymes>
            <!-- Get a specific rhyme -->
            <specific-rhyme>
                <xsl:copy-of select="jc:getCurrentRhyme($rhyme, 7)"/>
            </specific-rhyme>
            <!-- Get the rhymes from a specific line -->
            <specific-rhymes-from-line>
                <xsl:copy-of select="jc:getCurrentLineRhymes($rhyme, 4)"/>
            </specific-rhymes-from-line>
        </foo>
    </xsl:template>



    <!-- Tokenize the rhyme string -->
    <xsl:function name="jc:tokenizeRhymes" as="item()*">
        <xsl:param name="rhyme"/>
        <xsl:variable name="rhymes">
            <list>
                <xsl:analyze-string select="$rhyme" regex="\(*[a-zA-Z]\**\)*">
                    <xsl:matching-substring>
                        <item>
                            <xsl:value-of select="."/>
                        </item>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring/>
                </xsl:analyze-string>
            </list>
        </xsl:variable>
        <xsl:copy-of select="$rhymes"/>
    </xsl:function>


    <!-- Get the current rhyme -->
    <xsl:function name="jc:getCurrentRhyme" as="item()*">
        <xsl:param name="rhyme"/>
        <xsl:param name="currentRhyme" as="xs:integer"/>
        <xsl:variable name="rhymes" select="jc:tokenizeRhymes($rhyme)"/>
        <xsl:copy-of select="$rhymes/list/item[$currentRhyme]"/>
    </xsl:function>


    <!-- Group the rhymes together -->
    <xsl:function name="jc:groupRhymes" as="item()*">
        <xsl:param name="rhyme"/>
        <xsl:variable name="rhymes" select="jc:tokenizeRhymes($rhyme)"/>
        <xsl:variable name="groupedRhymes">
            <list>
                <xsl:for-each-group select="$rhymes/list/item"
                    group-ending-with="*[matches(., '^[a-zA-Z]\**$')]">
                    <item>
                        <list>
                            <xsl:for-each select="current-group()">
                                <item>
                                    <xsl:value-of select="."/>
                                </item>
                            </xsl:for-each>
                        </list>
                    </item>
                </xsl:for-each-group>
            </list>
        </xsl:variable>
        <xsl:copy-of select="$groupedRhymes"/>
    </xsl:function>

    <!-- Get the rhymes from the current line -->
    <xsl:function name="jc:getCurrentLineRhymes" as="item()*">
        <xsl:param name="rhyme"/>
        <xsl:param name="currentLine"/>
        <xsl:variable name="rhymes" select="jc:groupRhymes($rhyme)"/>
        <xsl:copy-of select="$rhymes/list/item[$currentLine]"/>
    </xsl:function>


</xsl:stylesheet>
