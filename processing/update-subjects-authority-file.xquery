declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

(: Read authority files :)
declare variable $base := doc("../authority/subjects_base.xml")/tei:TEI/tei:text/tei:body/tei:list/tei:item[@xml:id];
declare variable $additions := doc("../authority/subjects_additions.xml")/tei:TEI/tei:text/tei:body/tei:list/tei:item[@xml:id];
declare variable $currentsubjects := ($base, $additions);
declare variable $collection := collection('../collections/?select=*.xml;recurse=yes');
declare variable $currentkeys := $currentsubjects//@xml:id/data();
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
            <list>
{
    let $newlcsh := (      
        for $s in $collection//(tei:term|tei:placeName|tei:settlement|tei:region|tei:country)[matches(@key, 'subject_(sh|n)\d+') and not(@key = $currentkeys)]
            return 
            <item xml:id="{ $s/@key }">
                <term type="display">{ normalize-space(string-join($s//text(), ' ')) }</term>
                {
                comment{concat(' ../collections/', local:percentEncode(substring-after(base-uri($s), 'collections/')), ' ')}
                }
            </item>       
    )
    
    let $dedupednewlcsh := (
        for $k in distinct-values($newlcsh/@xml:id/data())
            return
            <item xml:id="{ $k }">
                {
                for $n at $pos in distinct-values($newlcsh[@xml:id = $k]/term/text())
                    return 
                    if ($pos eq 1) then
                        <term type="display">{ $n }</term>
                    else
                        <term type="variant">{ $n }</term>
                    
                }
                <note type="links">
                    <list type="links">
                        <item>
                            <ref>
                                {
                                if (starts-with($k, 'subject_sh')) then
                                    attribute target { concat('https://id.loc.gov/authorities/subjects/', substring-after($k, 'subject_'), '.html') }
                                else
                                    attribute target { concat('https://id.loc.gov/authorities/names/', substring-after($k, 'subject_'), '.html') }
                                }
                                <title>LC</title>
                            </ref>
                        </item>
                    </list>
                </note>
                {
                for $c in distinct-values($newlcsh[@xml:id = $k]/comment())
                    order by $c
                    return comment{ $c }
                }
            </item>
    )
    
    let $lcshfrompreviousrun := $additions[matches(@xml:id, 'subject_(sh|n)\d+')]

    (: Output the new _additions authority file :)
    return (
        $linebreak,
        <item>{ comment{' Dummy subject, just so this file validates, do not delete '} }<term type="display"/></item>,
        $linebreak,
        $linebreak,
        comment{' TODO: Review the following entries, update their key attributes in the TEI files, then cut and paste them into subjects_base.xml '},
        $linebreak,
        for $e in ($dedupednewlcsh, $lcshfrompreviousrun) order by $e/term[@type='display']/text() return ($e, $linebreak),
        $linebreak,
        $linebreak
    )
}
            </list>
        </body>
    </text>
</TEI>




        
