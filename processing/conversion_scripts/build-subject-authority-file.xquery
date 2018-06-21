declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";


declare function local:logging($level, $msg, $values)
{
    (: Trick XQuery into doing trace() to output message to STDERR but not insert it into the XML :)
    substring(trace('', concat(upper-case($level), '	', $msg, '	', string-join($values, '	'), '	')), 0, 0)
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
            <list>
{

    let $termswithkeys := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//tei:term/@key
            return
            <term id="{ $x }">
                <name>{ normalize-space(string-join($x/parent::tei:term//text()[not(ancestor::tei:foreign)], ' ')) }</name>
                {
                if ($x/parent::tei:term//tei:foreign) then
                    <name>{ normalize-space(string-join($x/parent::tei:term//text()[ancestor::tei:foreign], ' ')) }</name>
                else
                    ()
                }
                <ref>{ replace(replace($x/parent::tei:term/@target/normalize-space(), '#.*', ''), '\.html', '') }</ref>
                <target>{ concat(substring-after(base-uri($x), 'collections/'), '#', $x/ancestor::*[@xml:id][1]/@xml:id) }</target>
                <file>{ base-uri($x) }</file>
            </term>
    )
    
    let $nokeyterms := (
        (: Cannot do these for now. Maybe add them later?
        for $t in collection('../../collections/?select=*.xml;recurse=yes')//tei:term[not(@key)]
            return
            <term>
                <name>{ normalize-space(string-join($t//text(), ' ')) }</name>
                <ref>{ replace(replace($t/@target/normalize-space(), '#.*', ''), '\.html', '') }</ref>
                <target>{ concat(substring-after(base-uri($t), 'collections/'), '#', $t/ancestor::*[@xml:id][1]/@xml:id) }</target>
                <file>{ base-uri($t) }</file>
            </term>
        :)
    )
    
    let $placeswithkeys := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//(tei:placeName|tei:name[@type='place'])/@key
            return
            <place id="{ $x }">
                <name>{ normalize-space(string-join($x/parent::*//text()[not(ancestor::tei:foreign)], ' ')) }</name>
                {
                if ($x/parent::*//tei:foreign) then
                    <name>{ normalize-space(string-join($x/parent::*//text()[ancestor::tei:foreign], ' ')) }</name>
                else
                    ()
                }
                <ref>{ $x/parent::*/@ref }</ref>
                <target>{ concat(substring-after(base-uri($x), 'collections/'), '#', $x/ancestor::*[@xml:id][1]/@xml:id) }</target>
                <file>{ base-uri($x) }</file>
            </place>
    )
    
    let $nokeyplaces := (
        (: Cannot do these for now. Maybe add them later?
        for $t in collection('../../collections/?select=*.xml;recurse=yes')//(tei:placeName|tei:name[@type='place'])[not(@key)]
            return
            <place>
                <name>{ normalize-space(string-join($t//text(), ' ')) }</name>
                <ref>{ $t/@ref }</ref>
                <target>{ concat(substring-after(base-uri($t), 'collections/'), '#', $t/ancestor::*[@xml:id][1]/@xml:id) }</target>
                <file>{ base-uri($t) }</file>
            </place>
        :)
    )
    
    let $allterms := ($termswithkeys, $nokeyterms, $placeswithkeys, $nokeyplaces)
        
    let $dedupedterms := (
        for $y in distinct-values($allterms/@id)
            return
            <item id="{ $y }">
                {
                let $variantterms := distinct-values($allterms[@id = $y]/name[string-length(.) gt 0])
                return if (count($variantterms) eq 1) then
                    <term>{ $variantterms[1] }</term>
                else
                    for $z in $variantterms
                        let $popularity := count($allterms[@id = $y and name/text() = $z]) 
                        order by $popularity descending, string-length($z) descending
                        return 
                        <term popularity="{ $popularity }">{ $z }</term>
                    }
                {
                for $t in $allterms[@id = $y]/target/text()
                    return <target>{ $t }</target>
                }
                {
                for $r in distinct-values($allterms[@id = $y]/ref[text()]/text())
                    return <ref>{ $r }</ref>
                }
            </item>
        )
        
     for $v in $dedupedterms
        let $displayname := $v/term[1]
        order by $displayname
        return
        <item xml:id="{ $v/@id }">
            {
            for $q at $pos in $v/term
                return
                if ($pos eq 1) then
                    <term type="display">{ $q/text() }</term>
                else
                    <term type="variant">{ $q/text() }</term>
            }
            {
            if ($v/ref) then
                <note type="links">
                    <list type="links">
                        {
                        for $r in distinct-values($v/ref/text()/replace(., '\s', ''))
                            return
                            <item>
                                <ref target="{ $r }">
                                    {
                                    if (contains($r, 'viaf.org')) then
                                        <title>VIAF</title>
                                    else if (contains($r, 'loc.gov')) then
                                        <title>LC</title>
                                    else
                                        ()
                                    }
                                </ref>
                            </item>
                        }
                        </list>
                    </note>
            else
                ()            
            }
            {
            for $f in distinct-values($v/target/text())
                return
                comment{concat(' ../collections/', $f, ' ')}
            }
        </item>
}
            </list>
        </body>
    </text>
</TEI>