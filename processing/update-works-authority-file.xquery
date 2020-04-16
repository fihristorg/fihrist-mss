declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

(: Read authority files :)
declare variable $base := doc("../authority/works_base.xml")/tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl[@xml:id];
declare variable $additions := doc("../authority/works_additions.xml")/tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl[@xml:id];
declare variable $currentworks := ($base, $additions);
declare variable $collection := collection('../collections/?select=*.xml;recurse=yes');
declare variable $currentkeys := $currentworks//@xml:id/data();
declare variable $highestcurrentkey := max(for $k in $currentkeys return if (starts-with($k, 'work_')) then xs:integer(replace($k, '\D', '')) else () );
declare variable $linebreak := '&#10;&#10;';
declare variable $notitletitles := ('none', 'None', 'NONE', 'no title', 'No title', 'unknown', 'Unknown', 'Unknown.', 'unknown (front page damaged)', 'No titile', 'တိၼ်း ၵျဵဝ် ...');

declare function local:logging($level, $msg, $values)
{
    (: Trick XQuery into doing trace() to output message to STDERR but not insert it into the XML :)
    substring(trace('', concat(upper-case($level), '	', $msg, '	', string-join($values, '	'), '	')), 0, 0)
};

declare function local:normalize4Crossrefing($name as xs:string*) as xs:string
{
    let $normalized1 := replace(normalize-unicode($name, 'NFKD'), '^(the|a|an|al-|el-) ', '', 'i')
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
            <listBibl>
{
    let $newworks := (
        for $w in $collection/tei:TEI[@xml:id]//tei:msItem[tei:title[string-length(normalize-space(string())) gt 1]/@key = '' and not(tei:title/@key != '')]
            let $titles := 
                for $t in $w/tei:title
                    return
                    normalize-space(string-join($t//text(), ' '))
            return 
            <bibl>
                {
                for $t at $pos in distinct-values($titles)
                    return
                    (
                    <norm>{ local:normalize4Crossrefing($t) }</norm>,
                    if ($pos eq 1) then
                        <title type="uniform">{ $t }</title>
                    else
                        <title type="variant">{ $t }</title>
                    )
                }
                {
                comment{concat(' ../collections/', local:percentEncode(substring-after(base-uri($w), 'collections/')), '#', local:percentEncode($w/ancestor-or-self::*[@xml:id][1]/@xml:id), ' ')}
                }
            </bibl>
    )
    
    let $worksfrompreviousrun := (
        for $w in $additions[starts-with(@xml:id, 'work_')]
            return
            <bibl>
                { $w/@* }
                { $w/* }
                { for $t in $w/title return <norm>{ local:normalize4Crossrefing($t/text()) }</norm> }
                { $w/comment() }                
            </bibl>
    )
    
    let $worksinbase := (
        for $w in $base[starts-with(@xml:id, 'work_')]
            return
            <bibl>
                { $w/@* }
                { $w/* }
                { for $t in $w/title return <norm>{ local:normalize4Crossrefing($t/text()) }</norm> }
                { $w/comment() }                
            </bibl>
    )
    
    let $dedupednewworks := (
        for $w at $pos in $newworks
            return 
            if (some $v in $w/norm/text() satisfies $v = $worksfrompreviousrun/norm/text()) then
                (: This is a duplicate of an entry created by a previous running of this script, so skip it :)
                ()
            else if (some $v in $w/norm/text() satisfies $v = $worksinbase/norm/text()) then
                (: This is a duplicate of an entry in the base file, so skip it :)
                ()
            else if (some $v in $w/norm/text() satisfies $v = $newworks[position() lt $pos]/norm/text()) then
                (: This is a duplicate of another new entry already processed in this for-loop, so skip it :)
                ()
            else
                let $duplicates := $newworks[position() gt $pos and (some $v in ./norm/text() satisfies $v = $w/norm/text())]
                return
                if (count($duplicates) gt 0) then
                    (: This has duplicates, so merge them into this entry :)
                    <bibl>
                        {
                        for $t at $pos2 in distinct-values(($w/title/text(), $duplicates/title/text()))
                            return
                            (
                            if ($pos2 eq 1) then
                                <title type="uniform">{ $t }</title>
                            else
                                <title type="variant">{ $t }</title>
                            )
                        }
                        {
                        for $c in distinct-values(($w/comment(), $duplicates/comment()))
                            order by $c
                            return comment{ $c }
                        }
                    </bibl>
                else
                    $w
    )
    
    let $worksfrompreviousrunwithnewvariants := (
        for $w in $worksfrompreviousrun
            let $duplicates := $newworks[some $v in ./norm/text() satisfies $v = $w/norm/text()]
            return
            if (count($duplicates) gt 0) then
                <bibl>
                    { $w/@xml:id }
                    {
                    for $t at $pos in distinct-values(($w/title/text(), $duplicates/title/text()))
                        return
                        (
                        if ($pos eq 1) then
                            <title type="uniform">{ $t }</title>
                        else
                            <title type="variant">{ $t }</title>
                        )
                    }
                    {
                    for $c in distinct-values(($w/comment(), $duplicates/comment()))
                        order by $c
                        return comment{ $c }
                    }
                </bibl>
            else
                $w
    )
    
    let $dedupedworkswithids := (
        for $w at $pos in $dedupednewworks[not(exists(@xml:id))]
            return
            <bibl xml:id="{ concat('work_', ($highestcurrentkey + $pos)) }">
                { $w/*[not(self::norm)] }
                { $w/comment() }
            </bibl>
        ,
        for $w in $worksfrompreviousrunwithnewvariants
            return
            <bibl xml:id="{ $w/@xml:id }">
                { $w/*[not(self::norm)] }
                { $w/comment() }
            </bibl>
    )

    (: Output the new _additions authority file :)
    return (
        $linebreak,
        <bibl>{ comment{' Dummy work, just so this file validates, do not delete '} }<title type="display"/></bibl>,
        $linebreak,
        $linebreak,
        comment{' TODO: Review the following entries, update their key attributes in the TEI files, then cut and paste them into works_base.xml '},
        $linebreak,
        for $e in $dedupedworkswithids order by $e/title[@type='uniform']/text() return ($e, $linebreak),
        $linebreak,
        $linebreak
    )
}
            </listBibl>
        </body>
    </text>
</TEI>




        
