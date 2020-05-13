<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    version="1.0">

    <!-- Using XSLT 1.0 to allow viewing in web browsers that support client-side transformation: Firefox and Safari only
         when the file is on local filesystem, Chrome on a web server that responds with XML MIME type (which is not the case
         on raw.githubusercontent.com that serves everything as text/plain), possibly IE/Edge with some more work. -->
    
    <xsl:variable name="website" select="'https://www.fihrist.org.uk'"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Authority file browser</title>
                <style type="text/css">
                    body {
                        font-family: Helvetica, Arial, sans-serif;
                        background-color: #CCCCCC;
                        padding-top: 5px;
                        padding-left: 10px;
                        padding-right: 10px;
                    }
                    td {
                        vertical-align: top ! important;
                    }
                    th {
                        text-align: left ! important;
                    }
                    td.ids {
                        word-break: keep-all;
                    }</style>
                <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.16/css/jquery.dataTables.min.css"/>
                <script type="text/javascript" language="javascript" src="http://code.jquery.com/jquery-1.12.4.js"/>
                <script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.16/js/jquery.dataTables.min.js"/>
                <script type="text/javascript" class="init">
                    $(document).ready(
                        function() {
                            $('#onetable').DataTable(
                                {
                                    scrollY: '80vh',
                                    "lengthMenu": [[100, -1], [100, "All"]],
                                    "columns": [
                                        { "searchable": true },
                                        { "searchable": true },
                                        { "searchable": false }
                                    ]
                                }
                            );
                        }   
                    );
                </script>
                <base target="_blank"/>
            </head>
            <body>
                <xsl:apply-templates select="/tei:TEI/tei:text/tei:body"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="tei:body">
        <table id="onetable" class="display">
            <thead>
                <tr>
                    <th width="15%">ID</th>
                    <th width="70%">Names</th>
                    <xsl:choose>
                        <xsl:when test="tei:listBibl or xi:include[contains(@href, 'work')]">
                            <th width="15%">Authors</th>
                        </xsl:when>
                        <xsl:otherwise>
                            <th width="15%">Sources</th>
                        </xsl:otherwise>
                    </xsl:choose>
                </tr>
            </thead>
            <tbody>

                <!-- Next line works with or without XInclude support enabled in the XSLT processor -->
                <xsl:for-each select=".//*[@xml:id] | document(xi:include/@href)//*[@xml:id]">
                    <xsl:sort select="@xml:id"/>
                    <tr>
                        <td class="ids">
                            <a href="{ $website }/catalog/{ @xml:id }">
                                <xsl:value-of select="@xml:id"/>
                            </a>
                        </td>
                        <td>
                            <!-- Preferred form of the entry (e.g. person's name, work title, etc) -->
                            <xsl:value-of select="normalize-space(*[@type = 'display' or @type = 'uniform'])"/>

                            <!-- List of alternative forms/spellings, if any, which will be indexed but not displayed in the search results on the web site -->
                            <xsl:if test="*[@type = 'variant']">
                                <ul>
                                    <xsl:for-each select="*[@type = 'variant']">
                                        <li>
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:if>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="self::tei:bibl">
                                    <ul>
                                        <xsl:for-each select="tei:author">
                                            <li>
                                                <xsl:choose>
                                                    <xsl:when test="@key">
                                                        <a href="{ $website }/catalog/{ @key }">
                                                            <xsl:value-of select="string(.)"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="string(.)"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:when>
                                <xsl:when test=".//tei:list[@type = 'links']">
                                    <ul>
                                        <xsl:for-each select=".//tei:list[@type = 'links']//tei:ref">
                                            <li>
                                                <a href="{@target}">
                                                    <xsl:value-of select="tei:title"/>
                                                </a>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:when>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

</xsl:stylesheet>
