declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

(: Read authority files :)
declare variable $base := doc("../authority/persons_base.xml")/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id];
declare variable $additions := doc("../authority/persons_additions.xml")/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id];
declare variable $currentpeople := ($base, $additions);
declare variable $collection := collection('../collections/?select=*.xml;recurse=yes');
declare variable $currentkeys := $currentpeople//@xml:id/data();
declare variable $highestcurrentkey := max(for $k in $currentkeys return if (starts-with($k, 'person_f')) then xs:integer(replace($k, '\D', '')) else () );
declare variable $linebreak := '&#10;&#10;';

declare function local:logging($level, $msg, $values)
{
    (: Trick XQuery into doing trace() to output message to STDERR but not insert it into the XML :)
    substring(trace('', concat(upper-case($level), '	', $msg, '	', string-join($values, '	'), '	')), 0, 0)
};

declare function local:normalize4Crossrefing($name as xs:string) as xs:string
{
    let $normalized1 := replace(normalize-unicode($name, 'NFKD'), '^(the|al-|el-) ', '', 'i')
    let $normalized2 := 
        translate(
            translate(
                replace(
                    replace(
                        replace(
                            lower-case($normalized1), 
                            '[^\p{L}\d]', ''
                        ),
                    'æ', 'ae'),
                'œ', 'oe'),
            'ạĀāàáâḅÇçČḌḍḏèéëēĞğĠġǦǧḢḣḤḥḪḫẖĪīĭİıÎÏìíîïḲḳḴṇōóÖṛŕśṢṣŞşŠšṬṭṯúûüŪūżẒẓẔẕ', 'aaaaaabcccdddeeeegggggghhhhhhhiiiiiiiiiiikkknooorrssssssstttuuuuuzzzzz'),
        'ʼ', '')
    let $normalized3 := replace(replace(replace(replace(replace($normalized2, "[ʻ’'ʻ‘ʺʹ]" ,""), 'ʻ̐', ''), 'ʹ̨', ''), 'ʻ̨', ''), '"', '')
    return $normalized3
};

declare function local:percentEncode($str as xs:string) as xs:string
{
    string-join(for $s in tokenize($str, '%') return encode-for-uri($s), '%')
};

processing-instruction xml-model {'href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"'},
processing-instruction xml-model {'href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'},
processing-instruction xml-model {'href="authority-schematron.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'},
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Title</title>
            </titleStmt>
            <publicationStmt>
                <p>Publication Information</p>
            </publicationStmt>
            <sourceDesc>
                <p>Information about the source</p>
            </sourceDesc>
        </fileDesc>
    </teiHeader>
    <text>
        <body>
            <listPerson>
{
    let $newviafpeople := (      
        for $p in $collection//(tei:author|tei:editor|tei:persName[not(ancestor::*/@key)]|tei:name[tei:persName])[matches(@key, 'person_\d+') and not(@key = $currentkeys)]
            let $names := 
                if ($p/tei:persName) then
                    for $n in $p/tei:persName
                        return
                        normalize-space(string-join($n//text(), ' '))
                else
                    normalize-space(string-join($p//text(), ' '))
            return 
            <person xml:id="{ $p/@key }">
                {
                for $n at $pos in distinct-values($names)
                    return 
                    if ($pos eq 1) then
                        <persName type="display">{ $n }</persName>
                    else
                        <persName type="variant">{ $n }</persName>
                    
                }
                {
                comment{concat(' ../collections/', local:percentEncode(substring-after(base-uri($p), 'collections/')), '#', $p/ancestor::*[@xml:id][1]/@xml:id, ' ')}
                }
            </person>       
    )
    
    let $dedupednewviafpeople := (
        for $k in distinct-values($newviafpeople/@xml:id/data())
            return
            <person xml:id="{ $k }">
                {
                for $n at $pos in distinct-values($newviafpeople[@xml:id = $k]/persName/text())
                    return 
                    if ($pos eq 1) then
                        <persName type="display">{ $n }</persName>
                    else
                        <persName type="variant">{ $n }</persName>
                    
                }
                <note type="links">
                    <list type="links">
                        <item>
                            <ref target="https://viaf.org/viaf/{ substring-after($k, 'person_') }/">
                                <title>VIAF</title>
                            </ref>
                        </item>
                    </list>
                </note>
                {
                for $c in distinct-values($newviafpeople[@xml:id = $k]/comment())
                    order by $c
                    return comment{ $c }
                }
            </person>
    )
    
    let $viafpeoplefrompreviousrun := $additions[matches(@xml:id, 'person_\d+')]
    
    let $newlocalpeople := (
        for $p in $collection//(tei:author|tei:editor|tei:persName[not(ancestor::*/@key)]|tei:name[tei:persName])[@key = '']
            let $names := 
                if ($p/tei:persName) then
                    for $n in $p/tei:persName
                        return
                        normalize-space(string-join($n//text(), ' '))
                else
                    normalize-space(string-join($p//text(), ' '))
            return 
            <person>
                {
                for $n at $pos in distinct-values($names)
                    return
                    (
                    <norm>{ local:normalize4Crossrefing($n) }</norm>,
                    if ($pos eq 1) then
                        <persName type="display">{ $n }</persName>
                    else
                        <persName type="variant">{ $n }</persName>
                    )
                }
                {
                comment{concat(' ../collections/', local:percentEncode(substring-after(base-uri($p), 'collections/')), '#', $p/ancestor::*[@xml:id][1]/@xml:id, ' ')}
                }
            </person>
    )
    
    let $localpeoplefrompreviousrun := (
        for $p in $additions[starts-with(@xml:id, 'person_f')]
            return
            <person>
                { $p/@* }
                { $p/* }
                { for $n in $p/persName return <norm>{ local:normalize4Crossrefing($n/text()) }</norm> }
                { $p/comment() }                
            </person>
    )
    
    let $alllocalpeople := ($localpeoplefrompreviousrun, $newlocalpeople)
    
    let $dedupednewlocalpeople := (
        for $n at $pos in $alllocalpeople  
            return 
            if (some $v in $n/norm/text() satisfies $v = $alllocalpeople[position() lt $pos]/norm/text()) then
                ()
            else
                let $duplicates := $alllocalpeople[position() gt $pos and (some $v in ./norm/text() satisfies $v = $n/norm/text())]
                return
                <person>
                    {
                    if ($n/@xml:id) then $n/@xml:id else if (exists($duplicates[@xml:id])) then $duplicates[@xml:id][1]/@xml:id else ()
                    }
                    {
                    for $f at $pos2 in distinct-values(($n/persName/text(), $duplicates/persName/text()))
                        return
                        (
                        if ($pos2 eq 1) then
                            <persName type="display">{ $f }</persName>
                        else
                            <persName type="variant">{ $f }</persName>
                        )
                    }
                    {
                    for $c in distinct-values(($n/comment(), $duplicates/comment()))
                        order by $c
                        return comment{ $c }
                    }
                </person>
    )
    
    let $dedupednewlocalpeoplewithids := (
        for $n at $pos in $dedupednewlocalpeople[not(exists(@xml:id))]
            return
            <person xml:id="{ concat('person_f', ($highestcurrentkey + $pos)) }">
                { $n/* }
                { $n/comment() }
            </person>
        ,
        $dedupednewlocalpeople[exists(@xml:id)]
    )

    (: Output the new _additions authority file :)
    return (
        $linebreak,
        <person>{ comment{' Dummy person, just so this file validates, do not delete '} }<persName type="display"/></person>,
        $linebreak,
        $linebreak,
        comment{' TODO: Review the following entries, update their key attributes in the TEI files, then cut and paste them into persons_base.xml '},
        $linebreak,
        for $e in ($dedupednewviafpeople, $viafpeoplefrompreviousrun, $dedupednewlocalpeoplewithids) order by $e/persName[@type='display']/text() return ($e, $linebreak),
        $linebreak,
        $linebreak
    )
}
            </listPerson>
        </body>
    </text>
</TEI>




        
