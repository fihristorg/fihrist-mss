<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei xsi" version="2.0"
    xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>



    <xsl:template match="/">
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
                        <xsl:for-each-group select="TEI/text/body/listPerson/person"
                            group-by="concat (persName, @xml:id)">
                            <xsl:sort select="concat (persName, @xml:id)"/>

                            <person>


                                <xsl:attribute name="xml:id" select="concat('person_f', position())"/>

                                <xsl:element name="persName">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </xsl:element>



                            </person>

                        </xsl:for-each-group>

                    </listPerson>
                </body>
            </text>
        </TEI>

    </xsl:template>

</xsl:stylesheet>
