<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:jc="http://james.blushingbunny.net/ns.html" exclude-result-prefixes="tei jc xsi"
    version="2.0" xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

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

        <xsl:result-document method="xml" href="names_index.xml">

            <!--<xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
            <xsl:text>&#xA;</xsl:text>
            <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            <xsl:text>&#xA;</xsl:text>
            <xsl:processing-instruction name="xml-model">href="collections/authority-schematron.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            <xsl:text>&#xA;</xsl:text>-->

            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <teiHeader>
                    <fileDesc>
                        <titleStmt>
                            <title>Fihrist person index</title>
                        </titleStmt>
                        <publicationStmt>
                            <p>Fihrist</p>
                        </publicationStmt>
                        <sourceDesc>
                            <p>Index of people and ids from the Fihrist dataset</p>
                        </sourceDesc>
                    </fileDesc>
                </teiHeader>
                <text>
                    <body>
                        <listPerson>

                            <xsl:for-each select="$doc">
                                
                                <xsl:variable name="filename">
                                    <xsl:value-of select="tokenize(base-uri(), '/')[last()]"/>
                                </xsl:variable>
                                

                                <!-- This is just a debugging message so I see the filenames whizz by on the screen
              and I know what the last file was when something breaks  -->
                                <xsl:message select="$filename"/>

                                
                                <xsl:for-each select="//*:msDesc//*:persName[not(ancestor::author)]">

                                    
                                    <person>
                                        <xsl:attribute name="xml:id" select="@key"/>
                                        <persName type="display">
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </persName>
                                    </person>

                                    
                                    

                                </xsl:for-each>

                                <xsl:for-each select="//*:msDesc//*:author">
                                    
                                    
                                    

                                    <xsl:variable name="persName">
                                        
                                                <xsl:choose>
                                                  <xsl:when test="normalize-space(*:persName[1])">
                                                  <xsl:value-of
                                                  select="normalize-space(*:persName[1])"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="normalize-space(.)"/>
                                                  </xsl:otherwise>

                                                </xsl:choose>
                                    </xsl:variable>

                                    <person>
                                        <xsl:attribute name="xml:id" select="@key"/>
                                        <persName type="display">
                                            <xsl:value-of select="normalize-space($persName)"/>
                                        </persName>
                                    </person>

                                </xsl:for-each>


                            </xsl:for-each>

                        </listPerson>
                    </body>
                </text>
            </TEI>

        </xsl:result-document>
    </xsl:template>


</xsl:stylesheet>
