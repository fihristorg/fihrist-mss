<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs tei"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="newline" select="'&#10;'"/>
    <xsl:variable name="rolesmapping" as="element()*">
        <map code="abr">abridger</map>
        <map code="acp">art copyist</map>
        <map code="act">actor</map>
        <map code="adi">art director</map>
        <map code="adp">adapter</map>
        <map code="aft">author of afterword, colophon, etc.</map>
        <map code="anl">analyst</map>
        <map code="anm">animator</map>
        <map code="ann">annotator</map>
        <map code="ant">bibliographic antecedent</map>
        <map code="ape">appellee</map>
        <map code="apl">appellant</map>
        <map code="app">applicant</map>
        <map code="aqt">author in quotations or text abstracts</map>
        <map code="arc">architect</map>
        <map code="ard">artistic director</map>
        <map code="arr">arranger</map>
        <map code="art">artist</map>
        <map code="asg">assignee</map>
        <map code="asn">associated name</map>
        <map code="ato">autographer</map>
        <map code="att">attributed name</map>
        <map code="auc">auctioneer</map>
        <map code="aud">author of dialog</map>
        <map code="aui">author of introduction, etc.</map>
        <map code="aus">screenwriter</map>
        <map code="aut">author</map>
        <map code="bdd">binding designer</map>
        <map code="bjd">bookjacket designer</map>
        <map code="bkd">book designer</map>
        <map code="bkp">book producer</map>
        <map code="blw">blurb writer</map>
        <map code="bnd">binder</map>
        <map code="bpd">bookplate designer</map>
        <map code="brd">broadcaster</map>
        <map code="brl">braille embosser</map>
        <map code="bsl">bookseller</map>
        <map code="cas">caster</map>
        <map code="ccp">conceptor</map>
        <map code="chr">choreographer</map>
        <map code="cli">client</map>
        <map code="cll">calligrapher</map>
        <map code="clr">colorist</map>
        <map code="clt">collotyper</map>
        <map code="cmm">commentator</map>
        <map code="cmp">composer</map>
        <map code="cmt">compositor</map>
        <map code="cnd">conductor</map>
        <map code="cng">cinematographer</map>
        <map code="cns">censor</map>
        <map code="coe">contestant-appellee</map>
        <map code="col">collector</map>
        <map code="com">compiler</map>
        <map code="con">conservator</map>
        <map code="cor">collection registrar</map>
        <map code="cos">contestant</map>
        <map code="cot">contestant-appellant</map>
        <map code="cou">court governed</map>
        <map code="cov">cover designer</map>
        <map code="cpc">copyright claimant</map>
        <map code="cpe">complainant-appellee</map>
        <map code="cph">copyright holder</map>
        <map code="cpl">complainant</map>
        <map code="cpt">complainant-appellant</map>
        <map code="cre">creator</map>
        <map code="crp">correspondent</map>
        <map code="crr">corrector</map>
        <map code="crt">court reporter</map>
        <map code="csl">consultant</map>
        <map code="csp">consultant to a project</map>
        <map code="cst">costume designer</map>
        <map code="ctb">contributor</map>
        <map code="cte">contestee-appellee</map>
        <map code="ctg">cartographer</map>
        <map code="ctr">contractor</map>
        <map code="cts">contestee</map>
        <map code="ctt">contestee-appellant</map>
        <map code="cur">curator</map>
        <map code="cwt">commentator for written text</map>
        <map code="dbp">distribution place</map>
        <map code="dfd">defendant</map>
        <map code="dfe">defendant-appellee</map>
        <map code="dft">defendant-appellant</map>
        <map code="dgg">degree granting institution</map>
        <map code="dgs">degree supervisor</map>
        <map code="dis">dissertant</map>
        <map code="dln">delineator</map>
        <map code="dnc">dancer</map>
        <map code="dnr">donor</map>
        <map code="dpc">depicted</map>
        <map code="dpt">depositor</map>
        <map code="drm">draftsman</map>
        <map code="drt">director</map>
        <map code="dsr">designer</map>
        <map code="dst">distributor</map>
        <map code="dtc">data contributor</map>
        <map code="dte">dedicatee</map>
        <map code="dtm">data manager</map>
        <map code="dto">dedicator</map>
        <map code="dub">dubious author</map>
        <map code="edc">editor of compilation</map>
        <map code="edm">editor of moving image work</map>
        <map code="edt">editor</map>
        <map code="egr">engraver</map>
        <map code="elg">electrician</map>
        <map code="elt">electrotyper</map>
        <map code="eng">engineer</map>
        <map code="enj">enacting jurisdiction</map>
        <map code="etr">etcher</map>
        <map code="evp">event place</map>
        <map code="exp">expert</map>
        <map code="fac">facsimilist</map>
        <map code="fds">film distributor</map>
        <map code="fld">field director</map>
        <map code="flm">film editor</map>
        <map code="fmd">film director</map>
        <map code="fmk">filmmaker</map>
        <map code="fmo">former owner</map>
        <map code="fmp">film producer</map>
        <map code="fnd">funder</map>
        <map code="fpy">first party</map>
        <map code="frg">forger</map>
        <map code="gis">geographic information specialist</map>
        <map code="his">host institution</map>
        <map code="hnr">honoree</map>
        <map code="hst">host</map>
        <map code="ill">illustrator</map>
        <map code="ilu">illuminator</map>
        <map code="ins">inscriber</map>
        <map code="inv">inventor</map>
        <map code="isb">issuing body</map>
        <map code="itr">instrumentalist</map>
        <map code="ive">interviewee</map>
        <map code="ivr">interviewer</map>
        <map code="jud">judge</map>
        <map code="jug">jurisdiction governed</map>
        <map code="lbr">laboratory</map>
        <map code="lbt">librettist</map>
        <map code="ldr">laboratory director</map>
        <map code="led">lead</map>
        <map code="lee">libelee-appellee</map>
        <map code="lel">libelee</map>
        <map code="len">lender</map>
        <map code="let">libelee-appellant</map>
        <map code="lgd">lighting designer</map>
        <map code="lie">libelant-appellee</map>
        <map code="lil">libelant</map>
        <map code="lit">libelant-appellant</map>
        <map code="lsa">landscape architect</map>
        <map code="lse">licensee</map>
        <map code="lso">licensor</map>
        <map code="ltg">lithographer</map>
        <map code="lyr">lyricist</map>
        <map code="mcp">music copyist</map>
        <map code="mdc">metadata contact</map>
        <map code="med">medium</map>
        <map code="mfp">manufacture place</map>
        <map code="mfr">manufacturer</map>
        <map code="mod">moderator</map>
        <map code="mon">monitor</map>
        <map code="mrb">marbler</map>
        <map code="mrk">markup editor</map>
        <map code="msd">musical director</map>
        <map code="mte">metal-engraver</map>
        <map code="mtk">minute taker</map>
        <map code="mus">musician</map>
        <map code="nrt">narrator</map>
        <map code="opn">opponent</map>
        <map code="org">originator</map>
        <map code="orm">organizer</map>
        <map code="osp">onscreen presenter</map>
        <map code="oth">other</map>
        <map code="own">owner</map>
        <map code="pan">panelist</map>
        <map code="pat">patron</map>
        <map code="pbd">publishing director</map>
        <map code="pbl">publisher</map>
        <map code="pdr">project director</map>
        <map code="pfr">proofreader</map>
        <map code="pht">photographer</map>
        <map code="plt">platemaker</map>
        <map code="pma">permitting agency</map>
        <map code="pmn">production manager</map>
        <map code="pop">printer of plates</map>
        <map code="ppm">papermaker</map>
        <map code="ppt">puppeteer</map>
        <map code="pra">praeses</map>
        <map code="prc">process contact</map>
        <map code="prd">production personnel</map>
        <map code="pre">presenter</map>
        <map code="prf">performer</map>
        <map code="prg">programmer</map>
        <map code="prm">printmaker</map>
        <map code="prn">production company</map>
        <map code="pro">producer</map>
        <map code="prp">production place</map>
        <map code="prs">production designer</map>
        <map code="prt">printer</map>
        <map code="prv">provider</map>
        <map code="pta">patent applicant</map>
        <map code="pte">plaintiff-appellee</map>
        <map code="ptf">plaintiff</map>
        <map code="pth">patent holder</map>
        <map code="ptt">plaintiff-appellant</map>
        <map code="pup">publication place</map>
        <map code="rbr">rubricator</map>
        <map code="rcd">recordist</map>
        <map code="rce">recording engineer</map>
        <map code="rcp">addressee</map>
        <map code="rdd">radio director</map>
        <map code="red">redaktor</map>
        <map code="ren">renderer</map>
        <map code="res">researcher</map>
        <map code="rev">reviewer</map>
        <map code="rpc">radio producer</map>
        <map code="rps">repository</map>
        <map code="rpt">reporter</map>
        <map code="rpy">responsible party</map>
        <map code="rse">respondent-appellee</map>
        <map code="rsg">restager</map>
        <map code="rsp">respondent</map>
        <map code="rsr">restorationist</map>
        <map code="rst">respondent-appellant</map>
        <map code="rth">research team head</map>
        <map code="rtm">research team member</map>
        <map code="sad">scientific advisor</map>
        <map code="sce">scenarist</map>
        <map code="scl">sculptor</map>
        <map code="scr">scribe</map>
        <map code="sds">sound designer</map>
        <map code="sec">secretary</map>
        <map code="sgd">stage director</map>
        <map code="sgn">signer</map>
        <map code="sht">supporting host</map>
        <map code="sll">seller</map>
        <map code="sng">singer</map>
        <map code="spk">speaker</map>
        <map code="spn">sponsor</map>
        <map code="spy">second party</map>
        <map code="srv">surveyor</map>
        <map code="std">set designer</map>
        <map code="stg">setting</map>
        <map code="stl">storyteller</map>
        <map code="stm">stage manager</map>
        <map code="stn">standards body</map>
        <map code="str">stereotyper</map>
        <map code="tcd">technical director</map>
        <map code="tch">teacher</map>
        <map code="ths">thesis advisor</map>
        <map code="tld">television director</map>
        <map code="tlp">television producer</map>
        <map code="trc">transcriber</map>
        <map code="trl">translator</map>
        <map code="tyd">type designer</map>
        <map code="tyg">typographer</map>
        <map code="uvp">university place</map>
        <map code="vac">voice actor</map>
        <map code="vdg">videographer</map>
        <map code="wac">writer of added commentary</map>
        <map code="wal">writer of added lyrics</map>
        <map code="wam">writer of accompanying material</map>
        <map code="wat">writer of added text</map>
        <map code="wdc">woodcutter</map>
        <map code="wde">wood engraver</map>
        <map code="win">writer of introduction</map>
        <map code="wit">witness</map>
        <map code="wpr">writer of preface</map>
        <map code="wst">writer of supplementary textual content</map>
        <!-- Variations in Fihrist already -->
        <map code="scr">copyist</map>
        <map code="cmm">comentator</map>
        <map code="com">compilator</map>
        <map code="com">copiler</map>
        <map code="cmm">commentor</map>
        <map code="trl">transtator</map>
        <!--
        <map code="">reviser</map>
        <map code="">continuator</map>
        -->
    </xsl:variable>
    
    <!-- First pass makes the changes, storing the resulting output document in a variable -->
    <xsl:variable name="firstpass">
        <xsl:apply-templates/>
    </xsl:variable>
    
    <!-- Root template -->
	
	<xsl:template match="/">

	    <!-- Second pass does nothing but log changes (if any) in revisionDesc -->
	    <xsl:apply-templates select="$firstpass" mode="updatechangelog"/>
	    
	</xsl:template>
    
    <!-- The following templates do the first pass -->
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>

    <xsl:template match="tei:editor|tei:persName">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="self::tei:editor or (self::tei:persName and not(parent::tei:editor or parent::tei:name))">
                    <xsl:copy-of select="@*[not(name()=('role'))]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@*[not(name()=('role','key'))]"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@role">
                <xsl:variable name="lcrole" select="lower-case(@role)"/>
                <xsl:variable name="lcroles" select="tokenize($lcrole, ' ')"/>
                <xsl:attribute name="role">
                    <xsl:choose>
                        <xsl:when test="some $r in ($lcrole, $lcroles) satisfies $r = $rolesmapping//@code">
                            <xsl:variable name="newcodes" as="xs:string*">
                                <xsl:for-each select="$rolesmapping//@code[. = ($lcrole, $lcroles)]">
                                    <xsl:value-of select="."/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:value-of select="string-join(distinct-values($newcodes), ' ')"/>
                        </xsl:when>
                        <xsl:when test="some $r in ($lcrole, $lcroles) satisfies $r = $rolesmapping//text()">
                            <xsl:variable name="newcodes" as="xs:string*">
                                <xsl:for-each select="$rolesmapping//text()[. = ($lcrole, $lcroles)]">
                                    <xsl:value-of select="parent::*/@code"/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:value-of select="string-join(distinct-values($newcodes), ' ')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message>Cannot match role of '<xsl:value-of select="$lcrole"/>' in <xsl:value-of select="substring-after(base-uri(.), 'collections/')"/> to any MARC relators</xsl:message>
                            <xsl:value-of select="@role"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="self::tei:editor and not(@key) and tei:persName[@key]">
                <xsl:variable name="childpersnamekeys" select="tei:persName/@key"/>
                <xsl:attribute name="key" select="$childpersnamekeys[1]"/>
                <xsl:for-each select="$childpersnamekeys[position() gt 1]">
                    <xsl:message>Person key <xsl:value-of select="."/> is a duplicate of <xsl:value-of select="$childpersnamekeys[1]"/> in <xsl:value-of select="substring-after(base-uri(.), 'collections/')"/></xsl:message>
                </xsl:for-each>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:name">
        <xsl:choose>
            <xsl:when test="count(tei:persName) eq 1 and count(child::*) eq 1">
                <persName>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="tei:persName/@*"/>
                    <xsl:apply-templates select="tei:persName/(*|text()|comment())"/>
                </persName>
            </xsl:when>
            <xsl:when test="not(@key) and count(tei:persName) gt 1 and tei:persName[@key]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:variable name="childpersnamekeys" select="tei:persName/@key"/>
                    <xsl:attribute name="key" select="$childpersnamekeys[1]"/>
                    <xsl:for-each select="$childpersnamekeys[position() gt 1]">
                        <xsl:message>Person key <xsl:value-of select="."/> is a duplicate of <xsl:value-of select="$childpersnamekeys[1]"/> in <xsl:value-of select="substring-after(base-uri(.), 'collections/')"/></xsl:message>
                    </xsl:for-each>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    	
    <!-- The following templates perform the second pass, to add a change element to the revisionDesc -->
    
    <xsl:template match="text()|comment()|processing-instruction()" mode="updatechangelog">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*" mode="updatechangelog"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates mode="updatechangelog"/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:revisionDesc" mode="updatechangelog">
        <!-- Prepend a new change element, if the document has actually been changed (addition of XML comments not counted) -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="$firstpass//tei:editor/@role or count($firstpass//tei:persName[@key]) ne count(//tei:persName[@key]) or count($firstpass//tei:name) ne count(//tei:name)">
                <xsl:value-of select="$newline"/>
                <xsl:text>         </xsl:text>
                <change when="{ format-date(current-date(), '[Y0001]-[M01]-[D01]') }">
                    <!-- Do not use add xml:id for this change because it is only adding attributes -->
                    <xsl:value-of select="$newline"/>
                    <xsl:text>            </xsl:text>
                    <persName>
                        <xsl:text>Andrew Morrison</xsl:text>
                    </persName>
                    <xsl:text> </xsl:text>
                    <xsl:text>Normalized roles using </xsl:text>
                    <ref target="https://github.com/bodleian/fihrist-mss/tree/master/processing/conversion_scripts/normalize-roles.xsl">normalize-roles.xsl</ref>
                    <xsl:value-of select="$newline"/>
                    <xsl:text>         </xsl:text>
                </change>
            </xsl:if>
            <xsl:apply-templates mode="updatechangelog"/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>