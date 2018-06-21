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
            <listPerson>
{

    let $skipids := ()
    
    (: First build an in-memory nodeset temporarily storing names, IDs and the files they come from. :)
    let $allpeople := (
        for $x in collection('../../collections/?select=*.xml;recurse=yes')//(tei:author|tei:persName|tei:name[.//tei:persName])/@key
            return
            if ($x eq $skipids) then
                ( )
            else if ($x/parent::tei:persName and ($x/ancestor::tei:author[@key] or $x/ancestor::tei:name[@key])) then
                ( (: Skip this persName. It is included in an author or name element, and those @keys are generally better to use. :) )
            else if ($x/parent::tei:persName and ($x/ancestor::tei:author)[not(@key)] or $x/ancestor::tei:name[not(@key)]) then
                (: Use the @key of the first persName in an author or name when that author or name has no @key of its own :)
                <person id="{ ($x/ancestor::*[self::tei:author or self::tei:name]//tei:persName/@key)[1] }">
                    <name>{ normalize-space(string-join($x/parent::*//text()[not(ancestor::tei:foreign)], ' ')) }</name>
                    {
                    if ($x/parent::*//tei:foreign) then
                        <name>{ normalize-space(string-join($x/parent::*//text()[ancestor::tei:foreign], ' ')) }</name>
                    else
                        ()
                    }
                    <target>{ concat(substring-after(base-uri($x), 'collections/'), '#', $x/ancestor::*[@xml:id][1]/@xml:id) }</target>
                    <ref>{ $x/parent::tei:persName/@ref/data() }</ref>
                </person>
            else if (($x/parent::tei:author and $x/parent::tei:author//tei:persName) or ($x/parent::tei:name and $x/parent::tei:name//tei:persName)) then
                (: This is an author or name containing one of more persNames. Add each separately, but with the same @key, that of the author/name :)
                for $p in ($x/parent::tei:author//tei:persName | $x/parent::tei:name//tei:persName)
                    return
                    <person id="{ $x }">
                        <name>{ normalize-space(string-join($p//text()[not(ancestor::tei:foreign)], ' ')) }</name>
                        {
                        if ($x/parent::*//tei:foreign) then
                            <name>{ normalize-space(string-join($p//text()[ancestor::tei:foreign], ' ')) }</name>
                        else
                            ()
                        }
                        <target>{ concat(substring-after(base-uri($x), 'collections/'), '#', $x/ancestor::*[@xml:id][1]/@xml:id) }</target>
                        <ref>{ $p/@ref/data() }</ref>
                        <ref>{ $x/parent::tei:persName/@ref/data() }</ref>
                        <ref>{ $x/parent::tei:name/@ref/data() }</ref>
                    </person>
            else if ($x/parent::tei:author and not($x/parent::tei:author//tei:persName)) then
                (: Author tag with no child persNames :)
                <person id="{ $x }">
                    <name>{ normalize-space(string-join($x/parent::*//text()[not(ancestor::tei:foreign)], ' ')) }</name>
                    {
                    if ($x/parent::*//tei:foreign) then
                        <name>{ normalize-space(string-join($x/parent::*//text()[ancestor::tei:foreign], ' ')) }</name>
                    else
                        ()
                    }
                    <target>{ concat(substring-after(base-uri($x), 'collections/'), '#', $x/ancestor::*[@xml:id][1]/@xml:id) }</target>
                    <ref>{ $x/parent::tei:author/@ref/data() }</ref>
                </person>
            else if ($x/parent::tei:persName) then
                (: A persName on its own - usually a person who isn't an author :)
                <person id="{ $x }">
                    <name>{ normalize-space(string-join($x/parent::*//text()[not(ancestor::tei:foreign)], ' ')) }</name>
                    {
                    if ($x/parent::*//tei:foreign) then
                        <name>{ normalize-space(string-join($x/parent::*//text()[ancestor::tei:foreign], ' ')) }</name>
                    else
                        ()
                    }
                    <target>{ concat(substring-after(base-uri($x), 'collections/'), '#', $x/ancestor::*[@xml:id][1]/@xml:id) }</target>
                    <ref>{ $x/parent::tei:persName/@ref/data() }</ref>
                </person>
            else
                (local:logging('error', 'Cannot do anything with this author/name/persName', ($x, base-uri($x))))
    )

    let $dedupedpeople := (
        for $y in distinct-values($allpeople/@id)
            return
            <person id="{ $y }">
                {
                let $variantnames := distinct-values($allpeople[@id = $y]/name)
                return if (count($variantnames) eq 1) then
                    <persName>{ $variantnames[1] }</persName>
                else 
                    for $z in $variantnames
                        let $popularity := count($allpeople[@id = $y and name/text() = $z]) 
                        order by $popularity descending, string-length($z) descending
                        return 
                        <persName popularity="{ $popularity }">{ $z }</persName>
                    }
                {
                for $t in $allpeople[@id = $y]/target/text()
                    return <target>{ $t }</target>
                }
                {
                for $r in distinct-values($allpeople[@id = $y]/ref[text()]/text())
                    return <ref>{ $r }</ref>
                }
            </person>
    )
    
    for $v in $dedupedpeople
        let $displayname := $v/persName[1]
        order by $displayname
        return
        <person xml:id="{ $v/@id }">
            {
            for $q at $pos in $v/persName[string-length(normalize-space(string-join(text(), ''))) gt 1]
                return
                if ($pos eq 1) then
                    <persName type="display">{ $q/text() }</persName>
                else
                    <persName type="variant">{ $q/text() }</persName>
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
        </person>

}
            </listPerson>
        </body>
    </text>
</TEI>




        
