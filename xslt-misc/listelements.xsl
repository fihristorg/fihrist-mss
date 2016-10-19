<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd" version="2.0">
    <!-- Minimal Documentation -->
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Feb 13, 2012 but modified many times thereafter</xd:p>
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
                    <!-- bare version of element name -->
                    <xsl:variable name="elemName"><xsl:value-of select="substring-before($currElem, '#')"/></xsl:variable>  
                    <!-- count instances of the element -->
                    <xsl:variable name="currElemCount">
                        <xsl:value-of
                          select="count($doc//*[concat(local-name(), '#', namespace-uri())=$currElem])"
                        />
                    </xsl:variable>
                  <!-- Find all the parents of the current Element instances and make a distinct-values list of them -->
                  <xsl:variable name="currElemInstancesParents">
                    <xsl:for-each select="distinct-values($doc//*[concat(local-name(), '#', namespace-uri())=$currElem]/parent::node()/name())">
                      <xsl:sort/>
                      <a href="{concat('#', $elemName)}"><xsl:value-of select="."/></a><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if><xsl:text> </xsl:text>
                    </xsl:for-each>
                  </xsl:variable>
                  
                  
                 <!-- an li per distinct element -->
                    <li id="{$elemName}">
                      <span class="elemName"><xsl:value-of select="$elemName"/></span>
                        <span class="count"> (<xsl:value-of select="$currElemCount"/>) </span>
                        <!-- if there is a namespace -->
                        <xsl:if test="not(substring-after($currElem, '#')='')">
                            <span class="xmlns"><span class="attrName"> xmlns</span>
                            <span class="punc">="</span>
                            <span class="attrVal">
                                <xsl:value-of select="substring-after($currElem, '#')"/>
                            </span>
                            <span class="punc">"</span>
                            </span>
                        </xsl:if>
                      
                         <span class="parents"> Parents: <xsl:copy-of select="$currElemInstancesParents"/></span>
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
                                        <span class="count"> (<xsl:value-of select="$currAttrCount"/>) </span>
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
                                            <!-- separate with a pipe symbol with spaces on each side -->
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
                        font-weight:bold;
                    }
                    .attrName{
                        color:#C93;
                    }
                    .attrVal{
                        color:#944;
                        font-size:90%
                    }
                    .punc{
                        color:#009;
                    }
                    .count{
                        font-size:60%;
                        color:#444;
                    }
                    .sep{
                        color:#BBB;
                    }
                    .xmlns{font-size:70%;opacity:0.5; filter:alpha(opacity=50)}
                 p.footer {font-size 90%; text-align:center; margin-left:auto;margin-right:auto;}
                 .bold {font-weight:bold;}
                 .parents a {text-decoration:none;}
                </style>
            </head>
            <body>
              <xsl:comment>Created by listelements.xsl script from https://github.com/jamescummings/conluvies/ </xsl:comment>
                <h1>Element/Attribute/Value list</h1>
                <!-- basic stats -->
                <p>
                  Element/Attribute/Value list generated by James Cummings at <xsl:value-of select="current-dateTime()"
                    /> for:
                  <ul>
                    <li><span class="bold">Number of XML Files: </span> <xsl:value-of select="count($doc/*)"/></li>
                    <li><span class="bold">Number of XML Elements: </span> <xsl:value-of select="count($doc//*)"/></li>
                    <li><span class="bold">Number of Attributes: </span> <xsl:value-of select="count($doc//@*)"/></li>
                    <li><span class="bold">Number of Attribute Values: </span> <xsl:value-of
                      select="count($doc//@*/tokenize(., '\s'))"/>.</li>
                  </ul>
                 
                </p>
                <!-- Just copy the distinctList variable from above and put it here.  -->
                <xsl:copy-of select="$distinctList"/>
              
              <hr/>
              <p class="footer">
                <a href="https://github.com/jamescummings/conluvies/blob/master/xslt-misc/listelements.xsl">Source XSLT</a> -- 
                <a href="https://github.com/jamescummings/conluvies/issues/new">Report Bugs</a>
              </p>
            </body>
        </html>
    </xsl:template>
  
    <!-- And that's it. -->
  
  
</xsl:stylesheet>
