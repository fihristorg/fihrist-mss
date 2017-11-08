<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:jc="http://james.blushingbunny.net/ns.html" exclude-result-prefixes="tei jc xsi"
    version="2.0" xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">

    <xsl:output method="text" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>

    <!-- Set up the collection of files to be converted -->
    <!-- files and recurse parameters defaulting to '*.xml' and 'no' respectively -->
    <xsl:param name="files" select="'*.xml'"/>
    <!-- <xsl:param name="recurse" select="yes" /> -->

    <!-- path hard-coded to location on my desktop cuz that was convenient -->
    <xsl:variable name="path">
        <xsl:value-of
            select="concat('../collections/?select=', $files,';on-error=warning;recurse=yes')"/>
    </xsl:variable>

    <!-- the main collection of all the documents we are dealing with -->
    <xsl:variable name="doc" select="collection($path)"/>



    <!-- Named template which we call that starts off the whole thing-->
    <xsl:template name="main">
        <!-- For each item in the collection -->

        <xsl:result-document method="xml" href="names_index.csv">



            <xsl:for-each select="$doc">
                <xsl:sort select="tokenize(base-uri(), '/')[last()-1]"/>
                <xsl:sort select="tokenize(base-uri(), '/')[last()]"/>
                <xsl:variable name="baseURI">
                    <xsl:value-of select="base-uri()"/>
                </xsl:variable>
                <xsl:variable name="filename">
                    <xsl:value-of select="tokenize(base-uri(), '/')[last()]"/>
                </xsl:variable>
                <xsl:variable name="folder">
                    <xsl:value-of select="tokenize(base-uri(), '/')[last()-1]"/>
                </xsl:variable>
                <xsl:variable name="fileNum">
                    <xsl:value-of select="position()"/>
                </xsl:variable>

                <!-- This is just a debugging message so I see the filnames whiz by on the screen
              and I know what the last file was when something breaks  -->
                <xsl:message select="$filename"/>

                <!--<xsl:value-of select="$filename"/><xsl:text>&#xa;</xsl:text>-->

                <xsl:for-each select="//*:msDesc//*:persName[not(ancestor::author)]">

                    <xsl:variable name="persNamevalues">
                        <values>
                            <value>
                                <xsl:value-of select="normalize-space(.)"/>
                            </value>
                            <value>
                                <xsl:value-of select="@key"/>
                            </value>
                            <value>
                                <xsl:value-of select="@ref"/>
                            </value>
                        </values>
                    </xsl:variable>

                    <xsl:value-of select="$persNamevalues/values/value" separator="|"/>
                    <xsl:text>&#xa;</xsl:text>

                </xsl:for-each>

                <xsl:for-each select="//*:msDesc//*:author">

                    <xsl:variable name="values">
                        <values>
                            <value>

                                <xsl:choose>
                                    <xsl:when test="normalize-space(*:persName[1])">
                                        <xsl:value-of select="normalize-space(*:persName[1])"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:otherwise>

                                </xsl:choose>

                            </value>
                            <value>
                                <xsl:value-of select="@key"/>
                            </value>
                            <value>
                                <xsl:value-of select="@ref"/>
                            </value>

                        </values>
                    </xsl:variable>

                    <xsl:value-of select="$values/values/value" separator="|"/>
                    <xsl:text>&#xa;</xsl:text>

                </xsl:for-each>


            </xsl:for-each>


        </xsl:result-document>
    </xsl:template>


</xsl:stylesheet>
