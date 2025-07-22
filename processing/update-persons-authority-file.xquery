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
    let $normalized1 := normalize-space(replace(normalize-unicode($name, 'NFKD'), '(^|\s)(the |al-|el-)', ' ', 'i'))
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
    string-join(tokenize(string-join(for $s in tokenize($str, '%') return encode-for-uri($s), '%'), '-'), '%2D')
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
        for $p in $collection/tei:TEI[@xml:id]//(tei:author|tei:editor|tei:persName[not(ancestor::tei:author/@key or ancestor::tei:editor/@key)]|tei:name[tei:persName])[matches(@key, 'person_\d+') or matches(@key/lower-case(data()), 'viaf_\d+')]
            let $keys := (distinct-values(
                for $key in tokenize($p/@key, '\s+')
                    return
                    if (starts-with($key, 'person_')) then
                        $key
                    else if (starts-with(lower-case($key), 'viaf_')) then
                        (: The BL's IAMS system uses "viaf_123" or "Viaf_123" instead of "person_123" for VIAF-based person IDs :)
                        concat('person_', substring-after($key, '_'))
                    else
                        ()
                ))[not(. = $currentkeys)][matches(., '^person_\d+$')]
            let $names := 
                if ($p/tei:persName) then
                    for $n in $p/tei:persName
                        return
                        normalize-space(string-join($n//text(), ' '))
                else
                    normalize-space(string-join($p//text(), ' '))
            return
            if (count($keys) gt 0) then
                <person xml:id="{ $keys[1] }">
                    {
                    for $n at $pos in distinct-values($names)
                        return 
                        if ($pos eq 1) then
                            <persName type="display">{ $n }</persName>
                        else
                            <persName type="variant">{ $n }</persName>
                        
                    }
                    {
                    comment{concat(' ../collections/', local:percentEncode(substring-after(base-uri($p), 'collections/')), '#', local:percentEncode($p/ancestor::*[@xml:id][1]/@xml:id), ' ')}
                    }
                </person>
            else
                ()
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
        for $p in $collection/tei:TEI[@xml:id]//(tei:author|tei:editor|tei:persName[not(ancestor::tei:author/@key or ancestor::tei:editor/@key)]|tei:name[tei:persName])[@key and (@key = '' or not(some $k in tokenize(@key, '\s+') satisfies (starts-with($k, 'person_') or starts-with(lower-case($k), 'viaf_')))) and string-length(normalize-space(string())) gt 1]
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
                comment{concat(' ../collections/', local:percentEncode(substring-after(base-uri($p), 'collections/')), '#', local:percentEncode($p/ancestor::*[@xml:id][1]/@xml:id), ' ')}
                }
            </person>
    )
    
    let $localpeoplefrompreviousrun := (
        for $p in $additions[starts-with(@xml:id, 'person_f')]
            return
            <person>
                { $p/@* }
                { $p/* }
                { for $n in $p/persName[text()] return <norm>{ local:normalize4Crossrefing($n/text()) }</norm> }
                { $p/comment() }                
            </person>
    )
    
    let $peopleinbase := (
        for $p in $base
            return
            <person>
                { $p/@* }
                { $p/* }
                { for $n in $p/persName[text()] return <norm>{ local:normalize4Crossrefing($n/text()) }</norm> }
                { $p/comment() }                
            </person>
    )
    
    let $dedupednewlocalpeople := (
        for $n at $pos in $newlocalpeople
            return
            if (some $v in $n/norm/text() satisfies $v = $localpeoplefrompreviousrun/norm/text()) then
                (: This is a duplicate of an entry created by a previous running of this script, so skip it :)
                ()
            else if (some $v in $n/norm/text() satisfies $v = $newlocalpeople[position() lt $pos]/norm/text()) then
                (: This is a duplicate of another new entry already processed in this for-loop, so skip it :)
                ()
            else
                let $possibleduplicatesinbase := $peopleinbase[some $v in ./norm/text() satisfies $v = $n/norm/text()]
                let $possibleduplicatesinbasecomments := for $pd in $possibleduplicatesinbase return comment{concat(' POSSIBLE DUPLICATE OF: persons_base.xml#', $pd/@xml:id/data(), ' ')}
                let $duplicates := $newlocalpeople[position() gt $pos and (some $v in ./norm/text() satisfies $v = $n/norm/text())]
                return
                if (count($duplicates) gt 0) then
                    (: This has duplicates, so merge them into this entry :)
                    <person>
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
                        { $possibleduplicatesinbasecomments }
                    </person>
                else
                    <person>
                        { $n/* }
                        { $n/comment() }
                        { $possibleduplicatesinbasecomments }
                    </person>
    )
    
    let $localpeoplefrompreviousrunwithnewvariants := (
        for $n in $localpeoplefrompreviousrun
            let $duplicates := $newlocalpeople[some $v in ./norm/text() satisfies $v = $n/norm/text()]
            return
            if (count($duplicates) gt 0) then
                <person>
                    { $n/@xml:id }
                    {
                    for $f at $pos in distinct-values(($n/persName/text(), $duplicates/persName/text()))
                        return
                        (
                        if ($pos eq 1) then
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
            else
                $n
    )
    
    let $dedupedlocalpeoplewithids := (
        for $n at $pos in $dedupednewlocalpeople
            return
            <person xml:id="{ concat('person_f', ($highestcurrentkey + $pos)) }">
                { $n/*[not(self::norm)] }
                { $n/comment() }
            </person>
        ,
        for $n in $localpeoplefrompreviousrunwithnewvariants
            return
            <person xml:id="{ $n/@xml:id }">
                { $n/*[not(self::norm)] }
                { $n/comment() }
            </person>
    )

    (: Output the new _additions authority file :)
    return (
        $linebreak,
        <person>{ comment{' Dummy person, just so this file validates, do not delete '} }<persName type="display"/></person>,
        $linebreak,
        $linebreak,
        comment{' TODO: Review the following entries, update their key attributes in the TEI files, then cut and paste them into persons_base.xml '},
        $linebreak,
        for $e in ($dedupednewviafpeople, $viafpeoplefrompreviousrun, $dedupedlocalpeoplewithids) order by $e/persName[@type='display']/text() return ($e, $linebreak),
        $linebreak,
        $linebreak
    )
}
            </listPerson>
        </body>
    </text>
</TEI>




        
