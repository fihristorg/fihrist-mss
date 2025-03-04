import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "lib/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

(: Read authority file :)
declare variable $authorityentries := doc("../authority/subjects.xml")/tei:TEI/tei:text/tei:body/tei:list/tei:item[@xml:id];

(: Find instances in manuscript description files, building in-memory data structure, to avoid having to search across all files for each authority file entry :)
declare variable $allinstances :=
    for $instance in collection('../collections?select=*.xml;recurse=yes')/(.//tei:msDesc//(tei:placeName|tei:name[@type='place'])[starts-with(@key, 'subject_')]|.//tei:term)[not(ancestor::tei:msIdentifier)]
        let $roottei := $instance/ancestor::tei:TEI
        let $shelfmark := ($roottei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/string()
        let $datesoforigin := bod:summarizeDates($roottei//tei:origin//tei:origDate)
        let $placesoforigin := distinct-values($roottei//tei:origin//tei:origPlace/normalize-space()[string-length(.) gt 0])
        let $institution := $roottei//tei:msDesc/tei:msIdentifier/tei:institution/string()
        let $repository := $roottei//tei:msDesc/tei:msIdentifier/tei:repository[1]/string()
        return
        <instance>
            { attribute of { if ($instance/self::tei:term) then 'term' else 'place' } }
            { for $key in tokenize($instance/@key, '\s+')[string-length() gt 0] return <key>{ $key }</key> }
            <name>{ normalize-space($instance/string()) }</name>
            <link>{ concat(
                        '/catalog/', 
                        $roottei/@xml:id/data(), 
                        '|', 
                        $shelfmark,
                        ' (', 
                        $repository,
                        if ($repository ne $institution) then concat(', ', translate(replace($institution, ' \(', ', '), ')', ''), ')') else ')',
                        '|',
                        if ($roottei//tei:msPart) then 'Composite manuscript' else string-join(($datesoforigin, $placesoforigin)[string-length() gt 0], '; ')
                    )
            }</link>
            <shelfmark>{ $shelfmark }</shelfmark>
            <type>{ if ($instance/self::tei:placeName or $instance/self::tei:name) then 'place' else 'term' }</type>
            <file>{ substring-after(base-uri($instance), '-mss') }</file>
        </instance>;

<add>
{
    comment{concat(' Indexing started at ', current-dateTime(), ' using authority file at ', substring-after(base-uri($authorityentries[1]), 'file:'), ' ')}
}
{
    (: Log instances with key attributes not in the authority file :)
    for $key in distinct-values($allinstances/key)
        return if (not(some $entryid in $authorityentries/@xml:id/data() satisfies $entryid eq $key)) then
            bod:logging('warn', 'Key attribute not found in authority file: will create broken link', ($key, $allinstances[key = $key]/name, $allinstances[key = $key]/file, $allinstances[key = $key]/link))
        else
            ()
}
{
    (: Loop thru each entry in the authority file :)
    for $subject in $authorityentries
    
        (: Get info in authority entry :)
        let $id := $subject/@xml:id/data()
        let $name := if ($subject/tei:term[@type='display']) then normalize-space($subject/tei:term[@type='display'][1]/string()) else normalize-space($subject/tei:term[1]/string())
        let $variants := for $v in $subject/tei:term[not(@type='display')] return normalize-space($v/string())
        let $extrefs := for $r in $subject/tei:note[@type="links"]//tei:item/tei:ref return concat($r/@target/data(), '|', bod:lookupAuthorityName(normalize-space($r/tei:title/string())))
        let $bibrefs := for $b in $subject/tei:bibl return bod:italicizeTitles($b)
        let $notes := for $n in $subject/tei:note[not(@type="links")] return bod:italicizeTitles($n)
        
        (: Get info in all the instances in the manuscript description files :)
        let $instances := $allinstances[key = $id]
        
        let $types := distinct-values((
                                        if ($instances/type/text() = 'place') then 'Place' else (),
                                        if (starts-with($id, 'subject_s')) then 'Library of Congress Subject Heading' else (),
                                        if (starts-with($id, 'subject_n')) then 'Library of Congress Name Authority' else ()
                                     ))
        
        (: Output a Solr doc element :)
        return if (count($instances) gt 0) then
            <doc>
                <field name="type">subject</field>
                <field name="pk">{ $id }</field>
                <field name="id">{ $id }</field>
                <field name="title">{ $name }</field>
                <field name="alpha_title">{  bod:alphabetize($name) }</field>
                {
                (: Alternative names :)
                for $variant in distinct-values($variants)
                    order by $variant
                    return <field name="sb_variant_sm">{ $variant }</field>
                }
                {
                let $lcvariants := for $variant in ($name, $variants) return lower-case($variant)
                for $instancevariant in distinct-values($instances/name/text())
                    order by $instancevariant
                    return if (not(lower-case($instancevariant) = $lcvariants)) then
                        <field name="sb_variant_sm">{ $instancevariant }</field>
                    else
                        ()
                }
                {
                for $type in $types
                    order by $type
                    return <field name="sb_type_sm">{ $type }</field>
                }
                {
                (: Links to external authorities and other web sites :)
                for $extref in $extrefs
                    order by $extref
                    return <field name="link_external_smni">{ $extref }</field>
                }
                {
                (: Bibliographic references :)
                for $bibref in $bibrefs
                    return <field name="bibref_smni">{ $bibref }</field>
                }
                {
                (: Notes :)
                for $note in $notes
                    return <field name="note_smni">{ $note }</field>
                }
                {
                (: See also links to other entries in the same authority file :)
                let $relatedids := tokenize(replace(string-join(($subject/@corresp, $subject/@sameAs), ' '), '\S*#', ''), '\s+')[string-length() gt 0]
                for $relatedid in distinct-values($relatedids)
                    let $url := concat("/catalog/", $relatedid)
                    let $linktext := ($authorityentries[@xml:id = $relatedid]/tei:term[@type = 'display'][1])[1]
                    order by lower-case($linktext)
                    return
                    if (exists($linktext) and $allinstances[key = $relatedid]) then
                        let $link := concat($url, "|", normalize-space($linktext/string()))
                        return
                        <field name="link_related_smni">{ $link }</field>
                    else
                        bod:logging('info', 'Cannot create see-also link', ($id, $relatedid))
                }
                {
                (: Shelfmarks (indexed in special non-tokenized field) :)
                for $shelfmark in bod:shelfmarkVariants(distinct-values($instances/shelfmark/text()))
                    order by $shelfmark
                    return
                    <field name="shelfmarks">{ $shelfmark }</field>
                }
                {
                (: Links to manuscripts containing mentions of the term or place :)
                for $link in distinct-values($instances/link/text())
                    order by lower-case(tokenize($link, '\|')[2])
                    return
                    <field name="link_manuscripts_smni">{ $link }</field>
                }
            </doc>
        else
            bod:logging('info', 'Skipping unused authority file entry', ($id, $name))
}
{
    (: Log instances without key attributes :)
    (
    for $instancename in distinct-values($allinstances[@of='place' and not(key)]/name)
        order by $instancename
        return bod:logging('info', 'Place name without key attribute', $instancename)
    ,
    for $instancename in distinct-values($allinstances[@of='term' and not(key)]/name)
        order by $instancename
        return bod:logging('info', 'Term without key attribute', $instancename)
    )
}
</add>