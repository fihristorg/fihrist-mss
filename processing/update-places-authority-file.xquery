declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

(: Read authority files :)
declare variable $base := doc("../authority/places_base.xml")/tei:TEI/tei:text/tei:body/tei:listPlace/tei:place[@xml:id];
declare variable $additions := doc("../authority/places_additions.xml")/tei:TEI/tei:text/tei:body/tei:listPlace/tei:place[@xml:id];
declare variable $currentplaces := ($base, $additions);
declare variable $collection := collection('../collections/?select=*.xml;recurse=yes');
declare variable $currentkeys := $currentplaces//@xml:id/data();
declare variable $highestcurrentkey := max(for $k in $currentkeys return if (starts-with($k, 'place_')) then xs:integer(replace($k, '\D', '')) else () );
declare variable $linebreak := '&#10;&#10;';



(:~ declare function local:logging($level, $msg, $values)
{
    (: Trick XQuery into doing trace() to output message to STDERR but not insert it into the XML :)
    substring(trace('', concat(upper-case($level), '	', $msg, '	', string-join($values, '	'), '	')), 0, 0)
}; ~:)

declare function local:normalize4Crossrefing($name as xs:string*) as xs:string
{
    let $normalized1 := normalize-space(replace(normalize-unicode($name, 'NFKD'), '(^|\s)(the |a |an |al-|el-)', ' ', 'i'))
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
            <listPlace>
{
    let $newplaces := (      
        for $p in $collection/tei:TEI[@xml:id]//(tei:placeName|tei:settlement|tei:region|tei:country)[matches(@key, 'place_') and not(tokenize(@key, '\s+') = $currentkeys) and string-length(normalize-space(string())) gt 1]
            return 
            <place xml:id="{ $p/@key }">
                <norm>{ local:normalize4Crossrefing($p/text()) }</norm>
                <placeName type="index">{ normalize-space(string-join($p/text(), ' ')) }</placeName>
                {
                comment{concat(' ../collections/', local:percentEncode(substring-after(base-uri($p), 'collections/')), ' ')}
                }
            </place>       
    )
           
    let $placesfrompreviousrun := (
        for $p in $additions[starts-with(@xml:id, 'place_')]
            return
            <place>
                { $p/@* }
                { $p/* }
                { $p/comment() }                
            </place>
    )
    
    let $placesinbase := (
        for $p in $base[starts-with(@xml:id, 'place_')]
            return
            <place>
                { $p/@* }
                { $p/* }               
                { $p/comment() }                
            </place>
    )   

    let $dedupednewplaces := (
        for $p at $pos in $newplaces
        (:  Skip if $p already existed in a previous run :)
        return
        if (($p/norm = $placesfrompreviousrun/placeName) and ($p/@xml:id/data() = $placesfrompreviousrun/@xml:id/data())) then
            ()
        else
            let $possibleduplicatesinbase :=
                $placesinbase[./placeName = $p/placeName]                   

            let $possibleduplicatesinbasecomments :=
                for $pd in $possibleduplicatesinbase
                return comment{
                        concat(' POSSIBLE DUPLICATE OF: places_base.xml#',
                                $pd/@xml:id/data(),
                                ' ')
                        }
            
            (: Find new place entries that share the same norm :)
            let $duplicates :=
                $newplaces[position() > $pos and ./norm = $p/norm]

            return
            if (exists($duplicates)) then
                (: Merge $p with its later duplicates :)
                <place>
                { $p/@* }
                {
                    for $pn at $idx in distinct-values(($p/placeName/text(),
                                                        $duplicates/placeName/text()))
                    return
                    if ($idx eq 1) then
                        <placeName type="index">{ $pn }</placeName>
                    else
                        <placeName type="formInDocument">{ $pn }</placeName>
                }
                { $p/comment() }
                { $possibleduplicatesinbasecomments }
                </place>
            else               
                <place>
                { $p/@* }
                { $p/* }
                { $p/comment() }
                { $possibleduplicatesinbasecomments }
                </place>
    )      
    
    (: Places already in Additions file :)
    let $placesfrompreviousrunwithnewvariants := (
        for $p in $placesfrompreviousrun
            let $duplicates := $newplaces[some $v in ./norm/text() satisfies $v = $p/placeName/text()]
            return
            if (count($duplicates) gt 0) then
                <place>
                    { $p/@xml:id }
                    (:~ { $p/norm } ~:)
                    {
                    for $pn at $pos in distinct-values(($p/placeName/text(), $duplicates/placeName/text()))
                        return
                        (
                        if ($pos eq 1) then
                            <placeName type="index">{ $pn }</placeName>
                        else
                            <placeName type="formInDocument">{ $pn }</placeName>
                        )
                    }
                    {
                    for $c in distinct-values(($p/comment(), $duplicates/comment()))
                        order by $c
                        return comment{ $c }
                    }
                </place>
            else
                $p
    )
 
    
    let $dedupedplaceswithids := (
        for $p at $pos in $dedupednewplaces[not(exists(@xml:id))]
            return
            <place xml:id="{ concat('place_', ($highestcurrentkey + $pos)) }">
                { $p/* }
                { $p/comment() }
            </place>
        ,
        for $p in $dedupednewplaces[exists(@xml:id)]
            return
            <place xml:id="{ $p/@xml:id }">
                { $p/* }
                { $p/comment() }
            </place>
        ,
        for $p in $placesfrompreviousrunwithnewvariants
            return
            <place xml:id="{ $p/@xml:id }">
                { $p/* }
                { $p/comment() }
            </place>
    )


    (: Group places by key :)
    let $finalPlaces := 
        for $place in $dedupedplaceswithids
            group by $key := $place/@xml:id
            (: Merge places in the group (same key) that have distinct names of type index, adding as a form :)
            let $variantIndexNames := distinct-values($place/placeName[@type='index']/text())        
            let $merged-names := 
                for $pn at $pos in $variantIndexNames               
                    return
                    (
                    if ($pos eq 1) then
                        <placeName type="index">{ $pn }</placeName>
                    else
                        <placeName type="formInDocument">{ $pn }</placeName>
                    )                     
            let $first := $place[1]
            let $merged-comments := distinct-values(($place/comment()))
            let $placeName := $first/placeName[@type='index']/text()

            (: Determine duplicate place names that have different IDs, and which file they are in - added as a comment :)
            let $duplicates := 
                for $place in $dedupedplaceswithids
                where $place/placeName[@type='index']/text() = $placeName
                and $place/@xml:id != $key  (: exclude itself :)
                return concat( $place/@xml:id, ' in ', $place/comment()[1], ' ')
            let $uniqueDuplicates := distinct-values($duplicates) (: ensure uniqueness of duplicates :)
            order by $first/placeName[@type='index']/text()
            return
                <place xml:id="{ $key }">
                { $merged-names }
                {
                    for $c in $merged-comments
                    order by $c
                    return comment{ $c }               
                }
                {
                    if (empty($uniqueDuplicates)) then () else
                        for $duplicate in $uniqueDuplicates
                        return 
                            comment { " Possible duplicate: ", $duplicate }                    
                }
                </place> 


    (: Output the new _additions authority file :)
    return (   
        $linebreak,
        <place>{ comment{' Dummy place, just so this file validates, do not delete '} }<placeName type="display"/></place>,
        $linebreak,
        $linebreak,
        comment{' TODO: Review the following entries, update their key attributes in the TEI files, then cut and paste them into places_base.xml '},
        $linebreak,
        for $e in $finalPlaces order by $e/placeName[@type='index']/text() return ($e, $linebreak),
        $linebreak, 
        $linebreak
    )
}
            </listPlace>
        </body>
    </text>
</TEI>




        
