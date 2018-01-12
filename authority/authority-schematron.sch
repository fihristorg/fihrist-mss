<?xml version="1.0" encoding="UTF-8"?>


<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
 <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/> 
    
    <!-- currently, these are basic rules relating to correct entry of names and ids. Later they may be expanded to cover other areas. -->

    <pattern>
        <rule context="tei:person">
            <assert test="count(tei:persName[@type='display']) = 1" role="warn">One persName element should have @type=display</assert>
        </rule>
        <rule context="tei:org">
            <assert test="count(tei:orgName[@type='display']) = 1" role="warn">One orgName element should have @type=display</assert>
        </rule>
        <rule context="tei:place">
            <assert test="count(tei:placeName[@type='index']) = 1" role="warn">One placeName element should have @type=index</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="tei:text/tei:body/tei:listBibl/tei:bibl">
            <assert test="matches(@xml:id, 'work_\d+')">The bibl element must have an xml:id attribute matching the pattern 'work_[digits]'</assert>
            <assert test="count(tei:title[@type='uniform']) = 1">One title element only must have @type=uniform</assert>
            <assert test="tei:textLang[@mainLang]">Works should have language(s) specified in a textLang element which must have an attribute @mainLang</assert>
            
        </rule>
        
    </pattern>
    
    <pattern>
        <rule context="tei:text/tei:body/tei:listBibl/tei:bibl[not(tei:author)]">
            <assert test="tei:note[@type='subject']">Works without an author should have one or more subject headings</assert>
        </rule>
    </pattern>

    <!-- Import all the entries so that when editing an individual file checks can be made across all others -->
    <let name="allpeople" value="doc('persons_master.xml')//tei:person"/>

    <pattern>
        <rule context="tei:person">
            <let name="thisid" value="@xml:id"/>
            <report test="count($allpeople[@xml:id eq $thisid]) gt 1" role="error">
                The xml:id of <value-of select="$thisid"/> has been used elsewhere
            </report>
        </rule>
    </pattern>
    
    <!-- TODO: Similar code needed for other types of authority files -->
    
</schema>