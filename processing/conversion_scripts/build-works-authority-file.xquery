declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";


declare function local:logging($level, $msg, $values)
{
    (: Trick XQuery into doing trace() to output message to STDERR but not insert it into the XML :)
    substring(trace('', concat(upper-case($level), '	', $msg, '	', string-join($values, '	'), '	')), 0, 0)
};

declare function local:normalizetitle($title as xs:string)
{
    let $normtitle as xs:string:=   replace(
                                        replace(
                                            replace(
                                                replace(
                                                    lower-case(
                                                        translate(
                                                            translate(
                                                                translate(
                                                                    translate(
                                                                        translate(
                                                                            translate(
                                                                                translate(
                                                                                    replace(
                                                                                        replace($title, ' [\(\[].*[\)\]]', ''),
                                                                                    '^(al-|el-)', '', 'i'), 
                                                                                '.,"*?=…⋯ʾ“-”ʻ  ̲′،٭ʿ”ʼ“‘’ـ', ''), 
                                                                            "'", ""), 
                                                                        'ü','ü'),
                                                                    'ā','ā'),
                                                                'Ḥ','Ḥ'),
                                                            'ḥ','ḥ'),
                                                        '[]', '')
                                                    )
                                                , '^various ', ''), 
                                            '^fragments* of ', ''), 
                                        '^parts* of ', ''), 
                                    '^(the|a|an) ', '')
    return normalize-space($normtitle)
};

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

    let $skipids := ()
    
    (: First build an in-memory nodeset temporarily storing titles, IDs and the files they come from. :)
    let $titledworks := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//tei:msItem[
                                                                                        tei:title 
                                                                                        and not(
                                                                                                    (exists(tei:title/starts-with(., 'Chapter '))
                                                                                                    or exists(tei:title/starts-with(., 'باب ')))
                                                                                                    and ancestor::tei:msItem/tei:title
                                                                                                )
                                                                                        and not(@n and ancestor::tei:msItem/tei:title)
                                                                                       ]/@xml:id
            let $langs := $x/parent::tei:msItem/tei:textLang
            (: let $langs := ($x/ancestor::tei:msItem/tei:textLang)[1] :)
            return
            if ($x eq $skipids) then
                ( )
            else
                <work id="{ $x }">
                    {
                    for $y at $pos in $x/parent::tei:msItem/tei:title
                        let $titletext := normalize-space(string-join($y//text(), ' '))
                        let $normalizedtitletext := local:normalizetitle($titletext)
                        return if ($pos eq 1) then
                            (<title normalized="y">{ $normalizedtitletext }</title>,
                            <title>{ $titletext }</title>)
                        else
                            <title>{ $titletext }</title>
                    }
                    { $langs }
                    <file>{ base-uri($x) }</file>
                </work>
    )
    
    let $untitledworkswithauthors := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//tei:msItem[not(tei:title) and tei:author[text()] and not(ancestor::tei:msItem/tei:title) and not(descendant::tei:msItem/tei:title)]/@xml:id
            let $langs := $x/parent::tei:msItem/tei:textLang
            return
            if ($x eq $skipids) then
                ( )
            else
                <work id="{ $x }">
                    {
                    if ($x/parent::tei:msItem/tei:author/tei:persName) then
                        (<title normalized="y">Untitled work by { normalize-space(string-join($x/parent::tei:msItem/tei:author[1]/tei:persName[1]//text(), ' ')) }</title>,
                        <title>Untitled work by { normalize-space(string-join($x/parent::tei:msItem/tei:author[1]/tei:persName[1]//text(), ' ')) }</title>)
                    else if ($x/parent::tei:msItem/tei:author) then
                        (<title normalized="y">Untitled work by { normalize-space(string-join($x/parent::tei:msItem/tei:author[1]//text(), ' ')) }</title>,
                        <title>Untitled work by { normalize-space(string-join($x/parent::tei:msItem/tei:author[1]//text(), ' ')) }</title>)
                    else 
                        local:logging('warn', 'Cannot do anything with untitled work', $x)
                    }
                    { $langs }
                    <file>{ base-uri($x) }</file>
                </work>
    )
    
    let $allworks := ($titledworks, $untitledworkswithauthors)

    let $dedupedworks := (
        for $t at $pos in distinct-values($allworks/title[@normalized = 'y']/string())
            order by $t
            let $variants := (
                for $r in $allworks[title[@normalized = 'y'] = $t]
                    return
                    for $a in $r/title[not(@normalized = 'y')]/string()
                        return $a
            )
            let $distinctvariants := distinct-values($variants)
            return
            <bibl xml:id="{ concat('work_', $pos) }">
                <title type="uniform">{ $distinctvariants[1] }</title>
                {
                for $v in $distinctvariants[position() gt 1]
                    return <title type="variant">{ $v }</title>
                }
                {
                for $r in $allworks[title[@normalized = 'y'] = $t]
                    order by $r/@id
                    return
                    (<ref target="{ $r/@id }"/>, comment{concat(' ../', string-join(tokenize($r/file, '/')[position() gt last()-3], '/'), '#', $r/@id, ' ')})
                }
                {
                let $mainlang := (distinct-values($allworks[title[@normalized = 'y'] = $t]/textLang/@mainLang))[1]
                let $otherlangs := (distinct-values($allworks[title[@normalized = 'y'] = $t]/textLang/@otherLangs/tokenize(., ' ')))[not(. eq $mainlang)]
                return
                if (count($otherlangs) gt 0 and count($mainlang) gt 0) then
                    <textLang mainLang="{ $mainlang }" otherLangs="{ $otherlangs }"/>
                else if (count($mainlang) gt 0) then
                    <textLang mainLang="{ $mainlang }"/>
                else
                    ()
                }
            </bibl>
    
    )
    
    return $dedupedworks


}
            </listBibl>
        </body>
    </text>
</TEI>




        
