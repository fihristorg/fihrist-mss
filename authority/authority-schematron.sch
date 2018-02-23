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
        <rule context="tei:text/tei:body/tei:listBibl/tei:bibl[@xml:id]">
            <assert test="matches(@xml:id, 'work_\d+')">The bibl element must have an xml:id attribute matching the pattern 'work_[digits]'</assert>
            <assert test="count(tei:title[@type='uniform']) = 1">One title element only must have @type=uniform</assert>
            <!--<assert test="tei:textLang[@mainLang]">Works should have language(s) specified in a textLang element which must have an attribute @mainLang</assert>-->
            
        </rule>
        
    </pattern>
    
<!--
    <pattern>
        <rule context="tei:text/tei:body/tei:listBibl/tei:bibl[not(tei:author)]">
            <assert test="tei:note[@type='subject']">Works without an author should have one or more subject headings</assert>
        </rule>
    </pattern>
-->

    <!-- Import all the entries for the current type of authority file being checked, so that when editing an individual file checks can be made across all others -->
    <let name="allworks" value="if (contains(base-uri(.), 'works_')) then doc('works.xml')/tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl else ()"/>
    <let name="allpeople" value="if (contains(base-uri(.), 'persons_')) then doc('persons.xml')/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person else ()"/>
    <let name="allsubjects" value="if (contains(base-uri(.), 'subjects_')) then doc('subjects.xml')/tei:TEI/tei:text/tei:body/tei:list/tei:item else ()"/>

    <!-- Check for duplicate xml:ids. Those would be invalid automatically if in the same file, but these additionally test for duplicates across multiple files -->
    <pattern>
        <rule context="/tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl">
            <let name="thisid" value="@xml:id"/>
            <report test="count($allworks[@xml:id eq $thisid]) gt 1" role="error">
                The xml:id of <value-of select="$thisid"/> has been used elsewhere
            </report>
        </rule>
        <rule context="/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person">
            <let name="thisid" value="@xml:id"/>
            <report test="count($allpeople[@xml:id eq $thisid]) gt 1" role="error">
                The xml:id of <value-of select="$thisid"/> has been used elsewhere
            </report>
        </rule>
        <rule context="/tei:TEI/tei:text/tei:body/tei:list/tei:item">
            <let name="thisid" value="@xml:id"/>
            <report test="count($allsubjects[@xml:id eq $thisid]) gt 1" role="error">
                The xml:id of <value-of select="$thisid"/> has been used elsewhere
            </report>
        </rule>
    </pattern>

    
</schema>