<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:jc="http://james.blushingbunny.net/ns.html" exclude-result-prefixes="tei jc" version="2.0">

  <!-- 
  Created by James Cummings james@blushingbunny.net 
  2017-07 or so
  for up-conversion of existing TEI  Fihrist Catalogue
  -->

<!-- loading in common-mss.xsl for general stuff catalogue specific stuff below
     but hope is that most things will be common -->

<!--the original common-mss.xsl is at https://github.com/jamescummings/Bodleian-msDesc-ODD/blob/master/common-mss.xsl -->

<xsl:import href="./common-mss.xsl"/>

  <!-- variable for overall collection -->
  <xsl:variable name="cat" select="'Fihrist'"/>
  <xsl:variable name="catdir" select="'fihrist'"/>

  

</xsl:stylesheet>
