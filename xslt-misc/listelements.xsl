<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd" version="2.0">
    <!-- Minimal Documentation -->
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 13, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> jamesc</xd:p>
            <xd:p>Stylesheet to output all element names, attributes and attribute values with a
                count of usage.</xd:p>
            <xd:p>Parameters: files (takes filename wildcard, defaults to '*.xml') and recurse
                (defaults to 'no')</xd:p>
            <xd:p>Usage: saxon -it:main -o:outputFilename.html -xsl:listelements.xsl files=*.xml
                recurse=yes</xd:p>
            <xd:p>Usage: saxon -it:main -o:outputFilename.html -xsl:listelements.xsl
                recurse=yes</xd:p>
            <xd:p>Usage: saxon -it:main -o:outputFilename.html -xsl:listelements.xsl files=*.xml </xd:p>
            <xd:p>Usage: saxon -it:main -o:outputFilename.html -xsl:listelements.xsl files=foo.xml
            </xd:p>
        </xd:desc>
    </xd:doc>
    <!-- output not indented for whitespace concerns -->
    <xsl:output method="xml" indent="no"/>
    <!-- files and recurse parameters defaulting to '*.xml' and 'no' respectively -->
    <xsl:param name="files" select="'*.xml'"/>
    <xsl:param name="recurse" select="'no'"/>
    <!-- The main template, everything happens here. -->
    <xsl:template name="main">
        <!-- create path from params -->
        <xsl:variable name="path">
            <xsl:value-of
                select="concat('./?select=', $files,';on-error=warning;recurse=',$recurse)"/>
        </xsl:variable>
        <!-- the main collection of all the documents we are dealing with -->
        <xsl:variable name="doc" select="collection($path)"/>
        <!-- Lazy way, let's create a list and then interrogate it, could do this just in the distinct-values  -->
        <xsl:variable name="elementList">
            <xsl:for-each select="$doc//*">
                <li>
                    <xsl:value-of select="concat(local-name(), '#', namespace-uri())"/>
                </li>
            </xsl:for-each>
        </xsl:variable>
        <!-- where most of the work is done -->
        <xsl:variable name="distinctList">
            <!-- output as ul -->
            <ul>
                <!-- for each of the distinct element names (inc namespace) in the list we made above -->
                <xsl:for-each select="distinct-values($elementList/li)">
                    <xsl:sort/>
                    <!-- Put current element in a variable -->
                    <xsl:variable name="currElem" select="."/>
                    <!-- count instances of the element -->
                    <xsl:variable name="currElemCount">
                        <xsl:value-of
                            select="count($doc//*[concat(local-name(), '#', namespace-uri())=$currElem])"
                        />
                    </xsl:variable>
                    <!-- an li per distinct element -->
                    <li>
                        <span class="elemName">
                            <xsl:value-of select="substring-before($currElem, '#')"/>
                        </span>
                        <span class="count"> (<xsl:value-of select="$currElemCount"/>) </span>
                        <!-- if there is a namespace -->
                        <xsl:if test="not(substring-after($currElem, '#')='')">
                            <span class="attrName"> xmlns</span>
                            <span class="punc">="</span>
                            <span class="attrVal">
                                <xsl:value-of select="substring-after($currElem, '#')"/>
                            </span>
                            <span class="punc">"</span>
                        </xsl:if>
                        <!-- if it has attributes -->
                        <xsl:if
                            test="$doc//*[concat(local-name(), '#', namespace-uri())=$currElem]/@*">
                            <!-- make a nested list -->
                            <ul>
                                <xsl:for-each
                                    select="distinct-values($doc//*[concat(local-name(), '#', namespace-uri())=$currElem]/@*/name())">
                                    <xsl:sort/>
                                    <!-- put current attribute in a variable -->
                                    <xsl:variable name="currAttr" select="."/>
                                    <!-- count the uses of this attribute, but only on this element otherwise it isn't really the same attribute -->
                                    <xsl:variable name="currAttrCount">
                                        <xsl:value-of
                                            select="count($doc//*[concat(local-name(), '#', namespace-uri())=$currElem]/@*[name()=$currAttr])"
                                        />
                                    </xsl:variable>
                                    <!-- an li per distinct attribute name -->
                                    <li>
                                        <span class="attrName">
                                            <xsl:value-of select="$currAttr"/>
                                        </span>
                                        <span class="count"> (<xsl:value-of select="$currAttrCount"
                                            />) </span>
                                        <span class="punc">="</span>
                                        <!-- for each distinct use of the tokenized attributes -->
                                        <xsl:for-each
                                            select="distinct-values($doc//*[concat(local-name(), '#', namespace-uri())=$currElem]/@*[name()=$currAttr]/tokenize(., '\s'))">
                                            <xsl:sort/>
                                            <!-- put current attribute value in a variable -->
                                            <xsl:variable name="currentAttrVal" select="."/>
                                            <!-- count the current attribute value's use in the corpus as a whole -->
                                            <xsl:variable name="currAttrValCount"
                                                select="count($doc//*[concat(local-name(), '#', namespace-uri())=$currElem]/@*[name()=$currAttr]/tokenize(., '\s')[. = $currentAttrVal])"/>
                                            <span class="attrVal">
                                                <xsl:value-of select="$currentAttrVal"/>
                                            </span>
                                            <span class="count"> (<xsl:value-of
                                                  select="$currAttrValCount"/>) </span>
                                            <!-- separate with a pipe symbol -->
                                            <xsl:if test="not(position()=last())">
                                                <span class="sep">
                                                  <xsl:text> | </xsl:text>
                                                </span>
                                            </xsl:if>
                                        </xsl:for-each>
                                        <span class="punc">"</span>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:variable>
        <!-- Now start the real output, all that was just in a variable!  -->
        <html>
            <head>
                <title>Element/Attribute/Value list</title>
                <!-- CSS style block -->
                <style type="text/css">
                    .elemName{
                        color:#33A;
                    }
                    .attrName{
                        color:#C93;
                    }
                    .attrVal{
                        color:#944;
                    }
                    .punc{
                        color:#009;
                    }
                    .count{
                        font-size:60%;
                        color:#BBB;
                    }
                    .sep{
                        color:#BBB;
                    }</style>
            </head>
            <body>
                <h1>Element/Attribute/Value list</h1>
                <!-- basic stats -->
                <p>Element/Attribute/Value list generated: <xsl:value-of select="current-dateTime()"
                    /> for <xsl:value-of select="count($doc/*)"/> files, <xsl:value-of
                        select="count($doc//@*)"/> attributes, and <xsl:value-of
                        select="count($doc//@*/tokenize(., '\s'))"/> attribute values.</p>
                <!-- Just copy the distinctList variable from above and put it here.  -->
                <xsl:copy-of select="$distinctList"/>
            </body>
        </html>
    </xsl:template>
    <!-- that's all she wrote -->
</xsl:stylesheet>
