<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:jc="http://james.blushingbunny.net/ns.html"
   version="2.0" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0">
   <xsl:output encoding="UTF-8" indent="yes"/>
   <xsl:template match="/" name="main">
      <!-- example input -->
      <xsl:variable name="amounts">
         <list xmlns="http://www.tei-c.org/ns/1.0">
            <item>vijli xxijs viijd ob</item>
            <item>vijli viijd ob</item>
            <item>vijli viijd</item>
            <item>vijli xxijs ob</item>
            <item>vijli xxijs</item>
            <item>vijli xxijs viijd </item>
            <item>xxijs viijd ob</item>
            <item>ob</item>
            <item>xxijs viijd</item>
            <item>xxijs</item>
            <item>viijd</item>
            <item>liijs iiijd</item>
            <!--  -->
            <item>liijli</item>
         </list>
      </xsl:variable>
      <!-- sample output -->
      <list>
         <xsl:for-each select="$amounts/list/item/text()">
            <xsl:copy-of select="jc:OldMoneyToTEI(.)"/>
         </xsl:for-each>
      </list>
   </xsl:template>
   
   <!-- Function for outputing a tei:num with internal tei:num for each bit of money  -->
   <xsl:function name="jc:OldMoneyToTEI" as="item()*">
      <!-- Expects a (potentially mixed-case) string with no internal markup like: vijli xxijs viijd ob -->
      <xsl:param name="moneyString" as="xs:string"/>
      <xsl:variable name="item">
         <xsl:for-each select="tokenize(normalize-space($moneyString), ' ')">
            <xsl:choose>
               <xsl:when test="ends-with(upper-case(.), 'LI')">
                  <xsl:if test="position() gt 1">
                     <xsl:text> </xsl:text>
                  </xsl:if>
                  <num type="pounds"
                     value="{jc:RomanToInteger(replace(upper-case(.), 'LI$', ''))*240}">
                     <xsl:value-of select="replace(., '[Ll][Ii]$', '')"/>
                     <hi rend="superscript">li</hi>
                  </num>
               </xsl:when>
               <xsl:when test="ends-with(upper-case(.), 'S')">
                  <xsl:if test="position() gt 1">
                     <xsl:text> </xsl:text>
                  </xsl:if>
                  <num type="shillings"
                     value="{jc:RomanToInteger(replace(upper-case(.), 'S$', ''))*12}">
                     <xsl:value-of select="replace(., '[sS]$', '')"/>
                     <hi rend="superscript">s</hi>
                  </num>
               </xsl:when>
               <xsl:when test="ends-with(upper-case(.), 'D')">
                  <xsl:if test="position() gt 1">
                     <xsl:text> </xsl:text>
                  </xsl:if>
                  <num type="pence" value="{jc:RomanToInteger(replace(upper-case(.), 'D$',''))}">
                     <xsl:value-of select="replace(., '[dD]$', '')"/>
                     <hi rend="superscript">d</hi>
                  </num>
               </xsl:when>
               <xsl:when test="upper-case(.)='OB'">
                  <xsl:if test="position() gt 1">
                     <xsl:text> </xsl:text>
                  </xsl:if>
                  <num type="halfpence" value="0.5">
                     <hi rend="superscript">ob</hi>
                  </num>
               </xsl:when>
               <xsl:otherwise>ERROR: <xsl:value-of select="."/></xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
      </xsl:variable>
      <num type="totalMoney" value="{sum($item//num/@value)}">
         <xsl:copy-of select="$item"/>
      </num>
   </xsl:function>
   
   
   <!-- change roman numerals to integers, including normalisation of I vs J -->
   <xsl:function name="jc:RomanToInteger" as="xs:integer">
      <xsl:param name="r" as="xs:string"/>
      <xsl:variable name="r2" select="translate(upper-case($r), 'J', 'I')"/>
      <xsl:choose>
         <xsl:when test="ends-with($r2,'XC')">
            <xsl:sequence select="90 + jc:RomanToInteger(substring($r2,1,string-length($r2)-2))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'L')">
            <xsl:sequence select="50 + jc:RomanToInteger(substring($r2,1,string-length($r2)-1))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'C')">
            <xsl:sequence select="100 + jc:RomanToInteger(substring($r2,1,string-length($r2)-1))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'D')">
            <xsl:sequence select="500 + jc:RomanToInteger(substring($r2,1,string-length($r2)-1))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'M')">
            <xsl:sequence select="1000 + jc:RomanToInteger(substring($r2,1,string-length($r2)-1))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'IV')">
            <xsl:sequence select="4 + jc:RomanToInteger(substring($r2,1,string-length($r2)-2))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'IX')">
            <xsl:sequence select="9 + jc:RomanToInteger(substring($r2,1,string-length($r2)-2))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'IIX')">
            <xsl:sequence select="8 + jc:RomanToInteger(substring($r2,1,string-length($r2)-2))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'I')">
            <xsl:sequence select="1 + jc:RomanToInteger(substring($r2,1,string-length($r2)-1))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'V')">
            <xsl:sequence select="5 + jc:RomanToInteger(substring($r2,1,string-length($r2)-1))"/>
         </xsl:when>
         <xsl:when test="ends-with($r2,'X')">
            <xsl:sequence select="10 + jc:RomanToInteger(substring($r2,1,string-length($r2)-1))"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="0"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
</xsl:stylesheet>
