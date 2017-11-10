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
                        <title>Fihrist term index</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Fihrist</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Index of subject terms from the Fihrist dataset</p>
                    </sourceDesc>
                </fileDesc>
                <profileDesc>
                    <textClass>
                        <keywords scheme="#LCSH">
                            <xsl:for-each-group select="TEI/teiHeader/profileDesc/textClass/keywords/term"
                                group-by="concat (term, @xml:id)">
                                <!--<xsl:sort select="concat (term, @xml:id)"/>-->
                                <xsl:sort select="."/>
                                <xsl:copy-of select="."/>

                            </xsl:for-each-group>
                        </keywords>
                    </textClass>
                </profileDesc>
            </teiHeader>
            <text>
                <body>
                    <div/>
                </body>
            </text>
        </TEI>

    </xsl:template>

</xsl:stylesheet>
