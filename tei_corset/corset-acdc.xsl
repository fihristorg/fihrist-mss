<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:corset="http://www.tei-c.org/ns/corset/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:jc="http://james.blushingbunny.net/ns.html"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
   xpath-default-namespace="http://www.tei-c.org/ns/corset/1.0"
   >
<xsl:output encoding="UTF-8" indent="yes"/>
   
   
<!-- copy everything-->
   <xsl:template match="@*|node()|comment()|processing-instruction()|text()" priority="-1" xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:copy xmlns="http://www.tei-c.org/ns/1.0"><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></xsl:copy>
   </xsl:template>
   
   <xsl:template match="@t"><xsl:attribute name="type"><xsl:value-of select="."/></xsl:attribute></xsl:template>
  <xsl:template match="@w"><xsl:attribute name="when"><xsl:value-of select="."/></xsl:attribute></xsl:template>
   <xsl:template match="@fm"><xsl:attribute name="from"><xsl:value-of select="."/></xsl:attribute></xsl:template>
   <xsl:template match="@p"><xsl:attribute name="place"><xsl:value-of select="."/></xsl:attribute></xsl:template>
   <xsl:template match="@id"><xsl:attribute name="xml:id"><xsl:value-of select="."/></xsl:attribute></xsl:template>
   <xsl:template match="@lg"><xsl:attribute name="xml:lang"><xsl:value-of select="."/></xsl:attribute></xsl:template>
   <xsl:template match="@targ"><xsl:attribute name="target"><xsl:value-of select="."/></xsl:attribute></xsl:template>
   <xsl:template match="ab"  xmlns="http://www.tei-c.org/ns/1.0"><ab><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></ab></xsl:template>
   <xsl:template match="abbr"  xmlns="http://www.tei-c.org/ns/1.0"><abbr><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></abbr></xsl:template>
   <xsl:template match="add"  xmlns="http://www.tei-c.org/ns/1.0"><add><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></add></xsl:template>
   <xsl:template match="cb"  xmlns="http://www.tei-c.org/ns/1.0"><cb><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></cb></xsl:template>
   <xsl:template match="label"  xmlns="http://www.tei-c.org/ns/1.0"><label><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></label></xsl:template>
   <xsl:template match="lb"  xmlns="http://www.tei-c.org/ns/1.0"><lb><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></lb></xsl:template>
   <xsl:template match="q"  xmlns="http://www.tei-c.org/ns/1.0"><q><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></q></xsl:template>
   <xsl:template match="ptr"  xmlns="http://www.tei-c.org/ns/1.0"><ptr><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></ptr></xsl:template>
   <xsl:template match="body"  xmlns="http://www.tei-c.org/ns/1.0"><text><body><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></body></text></xsl:template>
<!--   <xsl:template match="dt"  xmlns="http://www.tei-c.org/ns/1.0"><date><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></date></xsl:template>-->
<!--   <xsl:template match="d"  xmlns="http://www.tei-c.org/ns/1.0"><div><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></div></xsl:template>-->
   <xsl:template match="fn"  xmlns="http://www.tei-c.org/ns/1.0"><forename><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></forename></xsl:template>
   <xsl:template match="for"  xmlns="http://www.tei-c.org/ns/1.0"><foreign><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></foreign></xsl:template>
      <xsl:template match="fw"  xmlns="http://www.tei-c.org/ns/1.0"><fw><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></fw></xsl:template>
      <!--<xsl:template match="gp"  xmlns="http://www.tei-c.org/ns/1.0"><gap><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></gap></xsl:template>-->
<xsl:template match="gr"  xmlns="http://www.tei-c.org/ns/1.0"><graphic><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></graphic></xsl:template>
<xsl:template match="hd"  xmlns="http://www.tei-c.org/ns/1.0"><head><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></head></xsl:template>
<xsl:template match="h"  xmlns="http://www.tei-c.org/ns/1.0"><hi><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></hi></xsl:template>
 <xsl:template match="it"  xmlns="http://www.tei-c.org/ns/1.0"><item><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></item></xsl:template>
   <xsl:template match="ls"  xmlns="http://www.tei-c.org/ns/1.0"><list><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></list></xsl:template>
   <!--<xsl:template match="n"  xmlns="http://www.tei-c.org/ns/1.0"><name><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></name></xsl:template>-->
   <xsl:template match="nt"  xmlns="http://www.tei-c.org/ns/1.0"><note><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></note></xsl:template>
   <xsl:template match="nm"  xmlns="http://www.tei-c.org/ns/1.0"><num><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></num></xsl:template>
   <xsl:template match="p"  xmlns="http://www.tei-c.org/ns/1.0"><p><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></p></xsl:template>
   <xsl:template match="pb"  xmlns="http://www.tei-c.org/ns/1.0"><pb n="{@n}"/></xsl:template>
   <xsl:template match="rf"  xmlns="http://www.tei-c.org/ns/1.0"><ref><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></ref></xsl:template>
   <xsl:template match="seg"  xmlns="http://www.tei-c.org/ns/1.0"><seg><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></seg></xsl:template>
   <!--<xsl:template match="spc"  xmlns="http://www.tei-c.org/ns/1.0"><xsl:choose><xsl:when test="text()"><space><desc><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></desc></space></xsl:when><xsl:otherwise><space><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></space></xsl:otherwise></xsl:choose></xsl:template>-->
   <xsl:template match="sn"  xmlns="http://www.tei-c.org/ns/1.0"><surname><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></surname></xsl:template>
   <xsl:template match="tbl"  xmlns="http://www.tei-c.org/ns/1.0"><table><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></table></xsl:template>
   <xsl:template match="cell"  xmlns="http://www.tei-c.org/ns/1.0"><cell><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></cell></xsl:template>
   <xsl:template match="row"  xmlns="http://www.tei-c.org/ns/1.0"><row><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></row></xsl:template>
   <xsl:template match="file"  xmlns="http://www.tei-c.org/ns/1.0"><TEI><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></TEI></xsl:template>
   
<xsl:template match="t"  xmlns="http://www.tei-c.org/ns/1.0"><title><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></title></xsl:template>
   <xsl:template match="un"  xmlns="http://www.tei-c.org/ns/1.0"><unclear><xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/></unclear></xsl:template>

<xsl:template match="header"  xmlns="http://www.tei-c.org/ns/1.0">
   <teiHeader>
   <fileDesc>
      <titleStmt>
        <xsl:apply-templates select="t"/>
      </titleStmt>
      <publicationStmt>
        <xsl:apply-templates select="ab[@t='notes']"/>
      </publicationStmt>
      <sourceDesc>
        <xsl:apply-templates select="ab[@t='source']"/>
      </sourceDesc>
    </fileDesc>
  
   
   </teiHeader></xsl:template>


<!-- Revert rend back to human readable -->

  <xsl:template match="@r">
    <xsl:variable name="valList">
      <valList mode="replace" type="closed"   xmlns="http://www.tei-c.org/ns/corset/1.0">
        <valItem ident="ab">
          <desc>rendered above the line</desc>
          <altIdent>above</altIdent>
        </valItem>
        <valItem ident="al">
          <desc>rendered aligned to the left</desc>
          <altIdent>aligned-left</altIdent>
        </valItem>
        <valItem ident="ar">
          <desc>rendered aligned to the right</desc>
          <altIdent>aligned-right</altIdent>
        </valItem>
        <valItem ident="b">
          <desc>rendered in bold</desc>
          <altIdent>bold</altIdent>
        </valItem>
        <valItem ident="bel">
          <desc>rendered below the line</desc>
          <altIdent>below</altIdent>
        </valItem>
        <valItem ident="bl">
          <desc>rendered in blackletter font</desc>
          <altIdent>blackletter</altIdent>
        </valItem>
        <valItem ident="brl">
          <desc>rendering is bracketed to the left</desc>
          <altIdent>bracketed-left</altIdent>
        </valItem>
        <valItem ident="brr">
          <desc>rendering is bracketed to the right</desc>
          <altIdent>bracketed-right</altIdent>
        </valItem>
        <valItem ident="c">
          <desc>rendered centred</desc>
          <altIdent>centred</altIdent>
        </valItem>
        <valItem ident="dc">
          <desc>rendered as drop-cap or illuminated initial</desc>
          <altIdent>dropcap</altIdent>
        </valItem>
        <valItem ident="f">
          <desc>rendered in a different font</desc>
          <altIdent>font-change</altIdent>
        </valItem>
        <valItem ident="i">
          <desc>rendered in italics</desc>
          <altIdent>italics</altIdent>
        </valItem>
        <valItem ident="l">
          <desc>rendered on the left</desc>
          <altIdent>left</altIdent>
        </valItem>
        <valItem ident="lrg">
          <desc>rendering is of large size</desc>
          <altIdent>large</altIdent>
        </valItem>
        <valItem ident="med">
          <desc>rendering is of medium size</desc>
          <altIdent>medium</altIdent>
        </valItem>
        <valItem ident="n">
          <desc>rendering returns to 'normal'</desc>
          <altIdent>normal</altIdent>
        </valItem>
        <valItem ident="o">
          <desc>other rendering</desc>
          <altIdent>other</altIdent>
        </valItem>
        <valItem ident="r">
          <desc>rendered on the right</desc>
          <altIdent>right</altIdent>
        </valItem>
        <valItem ident="rm">
          <desc>rendered in a roman numerals</desc>
          <altIdent>roman-numerals</altIdent>
        </valItem>
        <valItem ident="s">
          <desc>rendered in superscript</desc>
          <altIdent>superscript</altIdent>
        </valItem>
        <valItem ident="sc">
          <desc>rendered in small caps</desc>
          <altIdent>smallcaps</altIdent>
        </valItem>
        <valItem ident="sig">
          <desc>rendered as a signature</desc>
          <altIdent>signature</altIdent>
        </valItem>
        <valItem ident="sml">
          <desc>rendered as smaller</desc>
          <altIdent>small</altIdent>
        </valItem>
        <valItem ident="st">
          <desc>rendered struck-through</desc>
          <altIdent>struck-through</altIdent>
        </valItem>
        <valItem ident="u">
          <desc>rendered in underline</desc>
          <altIdent>underlined</altIdent>
        </valItem>
        <valItem ident="xlrg">
          <desc>rendering is of extra-large size</desc>
          <altIdent>extra-large</altIdent>
        </valItem>
        <valItem ident="xxlrg">
          <desc>rendering is of extra-large size</desc>
          <altIdent>extra-extra-large</altIdent>
        </valItem>
      </valList>
     </xsl:variable>
    <xsl:attribute name="rend">
    <xsl:for-each select="tokenize(., ' ')">
      <xsl:variable name="token" select="."/>
      <xsl:if test="position() gt 1"><xsl:text> </xsl:text></xsl:if>
      <xsl:choose>
        <xsl:when test="$valList/valList/valItem[@ident=$token]"><xsl:value-of select="$valList/valList/valItem[@ident=$token]/altIdent"/></xsl:when>
          <xsl:when test="normalize-space(.) = ''"></xsl:when>
        <xsl:otherwise>ERROR</xsl:otherwise>
      </xsl:choose>
      
    </xsl:for-each>
  </xsl:attribute>
  </xsl:template>
  
  
  <xsl:template match="spc"  xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:choose><xsl:when test="normalize-space(text())='[no sum stated]'">
          <space><desc>no sum stated</desc></space>
      </xsl:when>
          <xsl:when test="text()">
              <space><desc><xsl:value-of select="translate(text(), '][', '')"/></desc></space>
          </xsl:when>
          <xsl:otherwise>
              <space/>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  
  <!-- process dates -->
<xsl:template match="dt"  xmlns="http://www.tei-c.org/ns/1.0">
  <xsl:copy-of select="jc:guessDate(.)"/>
  </xsl:template>


<!-- process gaps -->
<xsl:template match="gp"  xmlns="http://www.tei-c.org/ns/1.0">
<xsl:choose>
    <xsl:when test="not(text()) and @n">
        <gap resp="#arber"><desc><xsl:value-of select="@n"/> entries omitted</desc></gap></xsl:when>
<xsl:otherwise>
     <gap resp="#arber"><desc><xsl:value-of select="."/></desc></gap>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- deal with divs -->
   <xsl:template match="d"  xmlns="http://www.tei-c.org/ns/1.0">
       <div>
           <xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/>
       </div>
   </xsl:template>

<!-- entries -->
   <xsl:template match="d[@t='e']"  xmlns="http://www.tei-c.org/ns/1.0">
       <div type="entry">
       <xsl:apply-templates select="@*[not(name()='t')]|node()|comment()|processing-instruction()|text()"/>
       </div>
   </xsl:template>


<!-- entries with entries become entryGrp-->
<xsl:template match="d[@t='e'][.//d/@t='e']"  xmlns="http://www.tei-c.org/ns/1.0" priority="1">
       <div type="entryGrp">
           <xsl:apply-templates select="@*[not(name()='t')]|node()|comment()|processing-instruction()|text()"/>
       </div>
   </xsl:template>


    <!-- hi inside entries becomes titles -->
    <xsl:template match="d[@t='e']//h[contains(@r,'i')][not(ancestor::dt)][not(ancestor::nm)][not(ancestor::hd)][not(ancestor::n)]"  xmlns="http://www.tei-c.org/ns/1.0" priority="1"><xsl:variable name="exactMatch">
        <list xmlns="http://www.tei-c.org/ns/corset/1.0">
            <!-- page references -->
            <item n="p"/>
            <item n="pp"/>
            <item n="see p"/>
            <item n="see pp"/>
            <!-- i.e. -->
            <item n="i.e."/>
            <item n="i.e"/>
            <item n="i. e."/>
            <item n="i. e"/>
            <!-- ed -->
            <item n="ed"/>
            <item n="ed."/>
            <!-- Calendar -->
            <item n="aprilis"/>
            <item n="aprillis"/>
            <item n="august"/>
            <item n="augusti"/>
            <item n="januarij"/>
            <item n="februarij"/>
            <item n="marcij"/>
            <item n="martij"/>
            <item n="maij"/>
            <item n="junij"/>
            <item n="julij"/>
            <item n="july"/>
            <item n="septembris"/>
            <item n="octobris"/>
            <item n="novembris"/>
            <item n="nouembris"/>
            <item n="decembris"/>
            <!-- misc -->
            <item n="blank"/>
            <item n="alias"/>
            <item n="anno"/>
            <item n="false"/>
            <item n="20 marcij"/>
            <item n="add ms"/>
            <item n="add. ms"/>
            <item n="by me"/>
            <item n="per me"/>
            <item n="datum"/>
            <item n="in primis"/>
            <item n="inprimis"/>
            <item n="signum per"/>
            <item n="vis"/>
            <item n="vide"/>
            <item n="videlicet"/>
            <item n="by sale of"/>
            <item n="eodem die"/>
            <item n="in toto"/>
            <item n="no money payment"/>
            <item n="no payment recorded"/>
            <item n="per"/>
            <item n="per annum"/>
            <item n="per copy per"/>
            <item n="per licem"/>
            <item n="vltimo marcij"/>
            <item n="idem"/>
            <item n="item"/>
            <item n="vide in hoc libro postea"/>
            <item n="vide proximam paginam"/>
            <item n="vide vt supra"/>
            <item n="vltimo"/>
            
            <item n="ultimo"/>
            <item n="n. s"/>
            <item n="also p"/>
            <item n="&amp;c"/>
            <item n="&amp;c."/>
         </list>
    </xsl:variable><xsl:choose>
        <xsl:when test="normalize-space(lower-case(.)) = $exactMatch//item/@n"><hi><xsl:apply-templates select="@*[not(name()='t')]|node()|comment()|processing-instruction()|text()"/></hi></xsl:when>
        <xsl:otherwise><title><xsl:apply-templates select="@*[not(name()='t')]|node()|comment()|processing-instruction()|text()"/></title></xsl:otherwise>
        </xsl:choose></xsl:template>
    


<!-- Try and deal with arber's [ ... ] notes -->

<xsl:template match="text()"  xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:variable name="note-inline">\[(\s*[a-zA-Z0-9]*\s*)\]</xsl:variable>
    <xsl:variable name="note-start">\[</xsl:variable>
    <xsl:variable name="note-end">\]</xsl:variable>
<xsl:choose>
    <xsl:when test="matches(., $note-inline)">
        <xsl:analyze-string select="." regex="{$note-inline}">
            <xsl:matching-substring> <note resp="#arber"><xsl:value-of select="regex-group(1)"/></note> </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:when>
    <xsl:when test="matches(., $note-start)">
        <xsl:analyze-string select="." regex="{$note-start}">
            <xsl:matching-substring> <anchor type="noteStart"/> </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:when>
    <xsl:when test="matches(., $note-end)">
        <xsl:analyze-string select="." regex="{$note-end}">
            <xsl:matching-substring> <anchor type="noteEnd"/> </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
</xsl:choose>
</xsl:template>




<!-- names -->

<xsl:template match="n[not(@t) or @t='per']"  xmlns="http://www.tei-c.org/ns/1.0">
    <persName>
        <xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/>
    </persName>
</xsl:template>

<xsl:template match="n[@t='pla']"  xmlns="http://www.tei-c.org/ns/1.0">
    <placeName>
        <xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/>
    </placeName>
</xsl:template>

<xsl:template match="n"  xmlns="http://www.tei-c.org/ns/1.0" priority="-1">
    <name>
        <xsl:apply-templates select="@*|node()|comment()|processing-instruction()|text()"/>
    </name>
</xsl:template>






  
<!-- process numbers  that are inside entries and roman-->
  
  <xsl:template match="d[@t='e']//nm[contains(@r, 'rm')][contains(@r, 'ar')]"  xmlns="http://www.tei-c.org/ns/1.0" priority="1">
    <seg type="fee"><xsl:apply-templates select="@*"/><xsl:comment>processing: <xsl:value-of select="."/></xsl:comment><xsl:copy-of select="jc:OldMoneyToTEI(.)"/></seg>
  </xsl:template>

<!--
  <xsl:template match="nm[contains(@r, 'rm')][contains(@r, 'ar')]"  xmlns="http://www.tei-c.org/ns/1.0">
    <seg type="payment"><xsl:apply-templates select="@*"/><xsl:comment>processing: <xsl:value-of select="."/></xsl:comment><xsl:copy-of select="jc:OldMoneyToTEI(.)"/></seg>
  </xsl:template>-->



  <!-- Function for outputing a tei:num with internal tei:num for each bit of money  -->
  <xsl:function name="jc:OldMoneyToTEI" as="item()*">
    <!-- Expects a (potentially mixed-case) string with no internal markup like: vijli xxijs viijd ob -->
    <xsl:param name="moneyString" as="xs:string"/>
      <xsl:variable name="money" select="replace($moneyString, '([./,;:#-R\+\*])',' $1 ')"/>
    <xsl:variable name="item">
      <xsl:for-each select="tokenize(normalize-space($money), '\s+')">
        <xsl:choose>
               <xsl:when test="replace(., '\s', '')='/'"><xsl:text> / </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')=']'"><xsl:text> ] </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')='['"><xsl:text> ] </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')='.'"><xsl:text> . </xsl:text></xsl:when>
             <xsl:when test="replace(., '\s', '')=';'"><xsl:text> ; </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')=':'"><xsl:text> : </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')='-'"><xsl:text> - </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')='+'"><xsl:text> + </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')=','"><xsl:text> , </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')='*'"><xsl:text> * </xsl:text></xsl:when>
            <xsl:when test="replace(., '\s', '')=''"><xsl:text> </xsl:text></xsl:when>
            <xsl:when test="matches(lower-case(.), 'and|a|copie|copy|r|solutum|n|h|ff')"><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:when>
          <xsl:when test="ends-with(upper-case(.), 'LI')">
            <xsl:if test="position() gt 1">
              <xsl:text> </xsl:text>
            </xsl:if>
            <num type="poundsAsPence"
              value="{jc:RomanToInteger(replace(upper-case(.), 'LI$', ''))*240}" >
              <xsl:value-of select="replace(., '[Ll][Ii]$', '')"/>
              <hi rend="superscript">li</hi>
            </num>
          </xsl:when>
          <xsl:when test="ends-with(upper-case(.), 'S')">
            <xsl:if test="position() gt 1">
              <xsl:text> </xsl:text>
            </xsl:if>
            <num type="shillingsAsPence"
              value="{jc:RomanToInteger(replace(upper-case(.), 'S$', ''))*12}">
              <xsl:value-of select="replace(., '[sS]$', '')"/>
              <hi rend="superscript">s</hi>
            </num>
          </xsl:when>
          <xsl:when test="ends-with(upper-case(.), 'D')">
            <xsl:if test="position() gt 1">
              <xsl:text> </xsl:text>
            </xsl:if>
            <num type="pence" value="{jc:RomanToInteger(replace(upper-case(.), 'D$',''))}" >
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
         <xsl:otherwise><xsl:comment>ERROR matching money</xsl:comment> <xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <num type="totalPence" value="{sum($item/tei:num/@value)}">
        <xsl:comment>orig: <xsl:value-of select="$moneyString"/></xsl:comment>
      <xsl:copy-of select="$item"/>
    </num>
  </xsl:function>
  
  
  <!-- change roman numerals to integers, including normalisation of I vs J -->
  <xsl:function name="jc:RomanToInteger" as="xs:integer">
    <xsl:param name="r" as="xs:string"/>
    <xsl:variable name="r2" select="translate(upper-case($r), 'J][', 'I')"/>
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
    

<!-- tidy dates -->
    
    <xsl:template mode="dateTidy" match="h[@r='s']"/>
        
    

<!-- Guess date function -->
<xsl:function name="jc:guessDate" as="item()*">
        <xsl:param name="dateNode" as="element()"/>
        <xsl:variable name="input">
            <xsl:copy-of select="$dateNode"/>
        </xsl:variable>
         <xsl:variable name="d">
             <xsl:variable name="in"><xsl:apply-templates select="$input/node()" mode="dateTidy"/></xsl:variable>
            <xsl:variable name="start"><xsl:value-of select="replace(lower-case(normalize-space(translate(translate($in, '.][', ''), '–', '-'))), '(([0-9])(st|nd|rd|th))', '$2')"/></xsl:variable>
             <xsl:variable name="die"><xsl:value-of select="replace($start, '(\s*die\s*|\sof\s)', ' ')"/></xsl:variable>
             <xsl:variable name="jan"><xsl:value-of select="replace($die, 'janu[a-z]*', 'jan')"/></xsl:variable>
             <xsl:variable name="feb"><xsl:value-of select="replace($jan, '[f]*feb[a-z]*', 'feb')"/></xsl:variable>
             <xsl:variable name="mar"><xsl:value-of select="replace($feb, 'mar[a-z]*', 'mar')"/></xsl:variable>
             <xsl:variable name="apr"><xsl:value-of select="replace($mar, 'apr[a-z]*', 'apr')"/></xsl:variable>
             <xsl:variable name="may"><xsl:value-of select="replace($apr, 'mai[a-z]*', 'may')"/></xsl:variable>
             <xsl:variable name="jun"><xsl:value-of select="replace($may, 'jun[a-z]*', 'jun')"/></xsl:variable>
             <xsl:variable name="jul"><xsl:value-of select="replace($jun, 'jul[a-z]*', 'jul')"/></xsl:variable>
             <xsl:variable name="aug"><xsl:value-of select="replace($jul, 'aug[a-z]*', 'aug')"/></xsl:variable>
             <xsl:variable name="sep"><xsl:value-of select="replace($aug, 'sep[a-z]*', 'sep')"/></xsl:variable>
             <xsl:variable name="oct"><xsl:value-of select="replace($sep, 'oct[a-z]*', 'oct')"/></xsl:variable>
             <xsl:variable name="nov"><xsl:value-of select="replace($oct, 'no[vu][a-z]*', 'nov')"/></xsl:variable>
             <xsl:variable name="dec"><xsl:value-of select="replace($nov, 'dece[a-z]*', 'dece')"/></xsl:variable>
             <xsl:variable name="rom"><xsl:value-of select="jc:swapRoman(string($dec))"/></xsl:variable><xsl:value-of select="$rom"/></xsl:variable>
<xsl:variable name="fullrange">[a-z]*\s*([0-9]{1,2})\s*[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})(\s*[(\-|to)]+\s*)([0-9]{1,2})\s*[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})\s*[a-z]*</xsl:variable>
<xsl:variable name="rangeInYear">[a-z]*\s*([0-9]{1,2})\s*[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)(\s*[(\-|to)]+\s*)([0-9]{1,2})\s*[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})\s*[a-z]*</xsl:variable>    
<xsl:variable name="rangeInMonth">[a-z]*\s*([0-9]{1,2})(\s*[(\-|to)]+\s*)([0-9]{1,2})\s*[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})\s*[a-z]*</xsl:variable>
<xsl:variable name="monthYearRange">[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})(\s*[(\-|to)]+\s*)(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})\s*[a-z]*</xsl:variable>
<xsl:variable name="monthMonthYearRange">[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)(\s*[(\-|to)]+\s*)(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})\s*[a-z]*</xsl:variable>
    <xsl:variable name="dayMonthYear">[a-z]*\s*([0-9]{1,2})\s*[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*([0-9]{4})\s*[a-z]*</xsl:variable>
<xsl:variable name="dayMonth">[a-z]*\s*([0-9]{1,2})\s*[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece)\s*[a-z]*</xsl:variable>
<xsl:variable name="monthYear">[a-z]*\s*(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dece) ([0-9]{4})\s*[a-z]*</xsl:variable>
<xsl:variable name="year">[a-z]*\s*([0-9]{4})\s*[a-z]*</xsl:variable>
 <xsl:choose>
     <!-- existing attributes -->    
     <xsl:when test="$dateNode/@when or $dateNode/@from or $dateNode/@to">
                <xsl:comment>Date not guessed, attributes exist </xsl:comment>
                <date><xsl:apply-templates select="$dateNode/@*|$dateNode/node()"/></date>
     </xsl:when>
     <!-- full range -->
            <xsl:when test="matches($d, $fullrange)">
                <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$fullrange}">
                        <xsl:matching-substring>
                            <xsl:attribute name="from">
                                <xsl:value-of
                                    select="concat(regex-group(3), jc:getMonth(regex-group(2)), translate(normalize-space(jc:getDay(regex-group(1))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="to">
                                <xsl:value-of
                                    select="concat(regex-group(7), jc:getMonth(regex-group(6)), translate(normalize-space(jc:getDay(regex-group(5))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates select="$dateNode/node()"/></date>
            </xsl:when>
     <!-- range in year -->
            <xsl:when test="matches($d, $rangeInYear)">
                <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$rangeInYear}">
                        <xsl:matching-substring>
                            <xsl:attribute name="from">
                                <xsl:value-of
                                    select="concat(regex-group(6), jc:getMonth(regex-group(2)), translate(normalize-space(jc:getDay(regex-group(1))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="to">
                                <xsl:value-of
                                    select="concat(regex-group(6), jc:getMonth(regex-group(5)), translate(normalize-space(jc:getDay(regex-group(4))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates select="$dateNode/node()"/></date>
            </xsl:when>
     <!-- range in month -->
    <xsl:when test="matches($d, $rangeInMonth)">
                <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$rangeInMonth}">
                        <xsl:matching-substring>
                            <xsl:attribute name="from">
                                <xsl:value-of
                                    select="concat(regex-group(5), jc:getMonth(regex-group(4)), translate(normalize-space(jc:getDay(regex-group(1))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="to">
                                <xsl:value-of
                                    select="concat(regex-group(5), jc:getMonth(regex-group(4)), translate(normalize-space(jc:getDay(regex-group(3))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates select="$dateNode/node()"/></date>
                </xsl:when>

<!-- monthYear Range -->
            <xsl:when test="matches($d, $monthYearRange)">
                <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$monthYearRange}">
                        <xsl:matching-substring>
                            <xsl:attribute name="from">
                                <xsl:value-of
                                    select="concat(regex-group(2), jc:getMonth(regex-group(1)))"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="to">
                                <xsl:value-of
                                    select="concat(regex-group(5), jc:getMonth(regex-group(4)))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates select="$dateNode/node()"/></date>
            </xsl:when>

<!-- monthMonthYear Range -->
            <xsl:when test="matches($d, $monthMonthYearRange)">
                <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$monthMonthYearRange}">
                        <xsl:matching-substring>
                            <xsl:attribute name="from">
                                <xsl:value-of
                                    select="concat(regex-group(4), jc:getMonth(regex-group(1)))"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="to">
                                <xsl:value-of
                                    select="concat(regex-group(4), jc:getMonth(regex-group(3)))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                    <xsl:apply-templates select="$dateNode/node()"/></date>
            </xsl:when>


     <!-- day, month, year -->
            <xsl:when test="matches($d, $dayMonthYear)">
            <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$dayMonthYear}">
                        <xsl:matching-substring>
                            <xsl:attribute name="when">
                                <xsl:value-of
                                    select="concat(regex-group(3), jc:getMonth(regex-group(2)), translate(normalize-space(jc:getDay(regex-group(1))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                <xsl:apply-templates select="$dateNode/node()"/></date>
                </xsl:when>
     <!-- day month -->
            <xsl:when test="matches($d, $dayMonth)">
                <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$dayMonth}">
                        <xsl:matching-substring>
                            <xsl:attribute name="when">
                                <xsl:value-of
                                    select="concat('-', jc:getMonth(regex-group(2)), translate(normalize-space(jc:getDay(regex-group(1))), '&#xa0;', ''))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                <xsl:apply-templates select="$dateNode/node()"/></date>
            </xsl:when>
     <!-- month year -->
     <xsl:when test="matches($d, $monthYear)">        
         <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$monthYear}">
                        <xsl:matching-substring>
                            <xsl:attribute name="when">
                                <xsl:value-of
                                    select="concat(regex-group(2), jc:getMonth(regex-group(1)))"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
             <xsl:apply-templates select="$dateNode/node()"/></date>
        </xsl:when>
     <!-- year -->  
     <xsl:when test="matches($d, $year)"> 
         <date>
                    <xsl:copy-of select="$dateNode/@*"/>
                    <xsl:analyze-string select="$d" regex="{$year}">
                        <xsl:matching-substring>
                            <xsl:attribute name="when">
                                <xsl:value-of
                                    select="regex-group(1)"
                                />
                            </xsl:attribute>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
             <xsl:apply-templates select="$dateNode/node()"/></date></xsl:when>
     <!-- Otherwise put out date with a type of 'notMatched' -->
        <xsl:otherwise><date type="notMatched"><xsl:comment>processing: <xsl:value-of select="$d"/></xsl:comment><xsl:apply-templates select="$dateNode/node()"/></date></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

<!-- Could just use format-number() instead but convenience function -->
    <xsl:function name="jc:getDay"  as="xs:string">
        <xsl:param name="day" />
        <xsl:variable name="num"><xsl:number value="number($day)" format="01"/></xsl:variable>
        <xsl:choose>
            <xsl:when test="number($num) lt 32"><xsl:value-of select="concat('-',$num)"/></xsl:when>
            <xsl:otherwise>&#xa0;</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

<!-- Give back the number from index of month names -->
    <xsl:function as="xs:string" name="jc:getMonth">
        <xsl:param name="monthName"/>
        <xsl:variable name="monthNames"
            select="('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dece')"/>
       <xsl:variable name="num"><xsl:sequence
            select="format-number(if (index-of($monthNames,$monthName) castable as xs:integer)
            then index-of($monthNames,$monthName)
            else 0,'00')"
        /></xsl:variable>
        <xsl:choose>
            <xsl:when test="number($num) lt 13"><xsl:value-of select="concat('-',$num)"/></xsl:when>
            <xsl:otherwise>--</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

<!-- Give back the number from index of month names -->
    <xsl:function as="xs:string" name="jc:swapRoman">
        <xsl:param name="string"/>
        <xsl:variable name="processed"><xsl:analyze-string select="$string" regex="{'([xvijlc]{2,}|[x]+|\s[v]+|^v)'}">
            <xsl:matching-substring><xsl:value-of select="jc:RomanToInteger(.)"/></xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="$processed"/>
     </xsl:function>




</xsl:stylesheet>
