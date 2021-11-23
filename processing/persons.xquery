import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "lib/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

(: Read authority file :)
declare variable $authorityentries := doc("../authority/persons.xml")/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id];
declare variable $worksauthority := doc("../authority/works.xml")/tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl[@xml:id];

(: Set options :)
declare variable $nonworkroles := ('ann','art','asn','bnd','cataloguer','crr','dpc','drt','dte','dtm','fmo','own','pat','ppm','reviser','scr','scribe','spn','trc');
declare variable $authorsinworksauthority := false();

(: Find instances in manuscript description files, building in-memory data structure, to avoid having to search across all files for each authority file entry :)
declare variable $allinstances :=
    for $instance in collection('../collections?select=*.xml;recurse=yes')//tei:msDesc//(tei:author|tei:editor|tei:persName[not(parent::tei:author or parent::tei:editor)])
        let $roottei := $instance/ancestor::tei:TEI
        let $shelfmark := normalize-space(($roottei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/string())
        let $roles := distinct-values(
            for $role in (
                tokenize($instance/@role/data(), '\s+')[string-length() gt 0],
                if ($instance/self::tei:author) then 'aut' else ()
                
            ) return lower-case($role)
        )
        let $roles := if (count($roles) gt 0) then $roles else if ($instance/parent::tei:title) then 'subject' else ()
        let $datesoforigin := bod:summarizeDates($roottei//tei:origin//tei:origDate)
        let $placesoforigin := distinct-values($roottei//tei:origin//tei:origPlace/normalize-space()[string-length(.) gt 0])
        let $institution := $roottei//tei:msDesc/tei:msIdentifier/tei:institution/string()
        let $repository := $roottei//tei:msDesc/tei:msIdentifier/tei:repository[1]/string()
        return
        <instance>
            { for $key in tokenize(($instance/@key, $instance/tei:persName[@key][1]/@key)[1], '\s+')[string-length() gt 0] return <key>{ $key }</key> }
            <name>{ normalize-space($instance/string()) }</name>
            <manuscript path="/catalog/{ $roottei/@xml:id/data() }">{ $shelfmark } ({ $repository }{ if ($repository ne $institution) then concat(', ', translate(replace($institution, ' \(', ', '), ')', ''), ')') else ')' }</manuscript>
            { for $role in $roles return <role>{ $role }</role> }
            {
            if ($authorsinworksauthority) then () else
                if (some $role in $roles satisfies $role = ('author','aut') and not($instance/ancestor::tei:bibl[not(@type='text-relations')] or $instance/ancestor::tei:biblStruct)) then 
                    for $workid in distinct-values($instance/ancestor::tei:msItem[tei:title/@key][1]/tei:title/@key/tokenize(data(), '\s+')[string-length() gt 0])
                        return <authored>{ $workid }</authored>
                else
                    ()
            }
            {
            (
            for $workid in distinct-values($instance/ancestor::tei:msItem[tei:title/@key][1]/tei:title/@key/tokenize(data(), '\s+')[string-length() gt 0])
                let $contributions := 
                    for $role in $roles[not(. = ('author','aut',$nonworkroles))]
                        return
                        if ($role eq 'oth') then
                            <contributed>{ $workid }</contributed>
                        else
                            <contributed role="{ $role }">{ $workid }</contributed>
                return
                if (count($contributions) gt 0) then
                    $contributions
                else if (count($roles) eq 0) then
                    <contributed>{ $workid }</contributed>
                else
                    ()
            ,
            for $role in $roles[. = $nonworkroles]
                return <nonworkrole path="/catalog/{ $roottei/@xml:id/data() }">{ $role }</nonworkrole>
            )
            }
            <shelfmark>{ $shelfmark }</shelfmark>
        </instance>;

<add>
{
    comment{concat(' Indexing started at ', current-dateTime(), ' using authority file at ', substring-after(base-uri($authorityentries[1]), 'file:'), ' ')}
}
{
    (: Log instances with key attributes not in the authority file :)
    for $key in distinct-values($allinstances/key)
        return if (not(some $entryid in $authorityentries/@xml:id/data() satisfies $entryid eq $key)) then
            bod:logging('warn', 'Key attribute not found in authority file: will create broken link', ($key, $allinstances[@k = $key]/name))
        else
            ()
}
{
    (: Loop thru each entry in the authority file :)
    for $person in $authorityentries

        (: Get info in authority entry :)
        let $id := $person/@xml:id/data()
        let $name := if ($person/tei:persName[@type='display']) then normalize-space($person/tei:persName[@type='display'][1]/string()) else normalize-space($person/tei:persName[1]/string())
        let $variants := for $variant in $person/tei:persName[not(@type='display')] return normalize-space($variant/string())
        let $extrefs := for $ref in $person/tei:note[@type='links']//tei:item/tei:ref return concat($ref/@target/data(), '|', bod:lookupAuthorityName(normalize-space($ref/tei:title/string())))
        let $extauths := distinct-values(for $ref in $person/tei:note[@type='links']//tei:item/tei:ref return normalize-space($ref/tei:title/string()))
        let $bibrefs := for $bibl in $person/tei:bibl return bod:italicizeTitles($bibl)
        let $notes := for $note in $person/tei:note[not(@type='links')] return bod:italicizeTitles($note)
        
        (: Get info in all the instances in the manuscript description files :)
        let $instances := $allinstances[key = $id]
        let $roles := distinct-values(for $role in distinct-values($instances/role/text()) return bod:personRoleLookup2($role))
        let $rolessorted := for $role in $roles order by $role return $role
        let $isauthor := some $role in $instances/role/text() satisfies $role = ('author','aut')
        let $iscontributor := some $role in $instances/role/text() satisfies not($role = ('author','aut',$nonworkroles))

        (: Output a Solr doc element :)
        return if (count($instances) gt 0) then
            <doc>
                <field name="type">person</field>
                <field name="pk">{ $id }</field>
                <field name="id">{ $id }</field>
                <field name="title">{ $name }</field>
                <field name="alpha_title">{  bod:alphabetize($name) }</field>
                {
                (: Roles (e.g. author, translator, scribe) for search filter :)
                if (count($roles) gt 0) then
                    (
                    for $role in $rolessorted
                        return <field name="pp_roles_sm">{ $role }</field>
                    ,
                    if (count($rolessorted[not(. = 'Other')]) gt 0) then
                        <field name="roles_smni">{ string-join($rolessorted[not(. = 'Other')], ', ') }</field>
                    else
                        ()
                    )
                else
                    <field name="pp_roles_sm">Not specified</field>
                }
                {
                (: Alternative names :)
                for $variant in distinct-values($variants)
                    order by $variant
                    return <field name="pp_variant_sm">{ $variant }</field>
                }
                {
                let $lcvariants := for $variant in ($name, $variants) return lower-case($variant)
                for $instancevariant in distinct-values($instances/name/text())
                    order by $instancevariant
                    return if (not(lower-case($instancevariant) = $lcvariants)) then
                        <field name="pp_variant_sm">{ $instancevariant }</field>
                    else
                        ()
                }
                {
                (: Links to external authorities and other web sites :)
                for $extref in $extrefs
                    order by $extref
                    return <field name="link_external_smni">{ $extref }</field>
                }
                {
                (: Bibliographic references about the person :)
                for $bibref in $bibrefs
                    return <field name="bibref_smni">{ $bibref }</field>
                }
                {
                (: Notes about the person :)
                for $note in $notes
                    return <field name="note_smni">{ $note }</field>
                }
                {
                (: See also links to other entries in the same authority file :)
                let $relatedids := tokenize(translate(string-join(($person/@corresp, $person/@sameAs), ' '), '#', ''), '\s+')[string-length() gt 0]
                for $relatedid in distinct-values($relatedids)
                    let $url := concat("/catalog/", $relatedid)
                    let $linktext := replace(normalize-space(($authorityentries[@xml:id = $relatedid]/tei:persName[@type = 'display'][1])[1]/string()), '\|' , '&#8739;')
                    order by lower-case($linktext)
                    return
                    if (exists($linktext) and $allinstances[key = $relatedid]) then
                        let $link := concat($url, "|", $linktext)
                        return
                        <field name="link_related_smni">{ $link }</field>
                    else
                        bod:logging('info', 'Cannot create see-also link', ($id, $relatedid))
                }
                {
                (: Links to works by this person (if they're an author) :)
                if ($isauthor) then 
                    let $workids :=
                        if ($authorsinworksauthority) then distinct-values($worksauthority[tei:author[not(@role)]/@key = $id]/@xml:id)
                        else distinct-values(($instances/authored/text(), $worksauthority[tei:author[not(@role)]/@key = $id]/@xml:id))
                    return
                    if (count($workids) eq 0) then
                        bod:logging('info', "Cannot create link from author to any of their works", ($id))
                    else
                        for $workid in $workids
                            let $url := concat("/catalog/", $workid)
                            let $linktext := replace(normalize-space(($worksauthority[@xml:id = $workid]/tei:title[@type = 'uniform'][1])[1]/string()), '\|' , '&#8739;')
                            order by lower-case(bod:stripLeadingStopWords(($linktext, '')[1]))
                            return
                            if (exists($linktext)) then
                                let $link := concat($url, "|", $linktext)
                                return
                                <field name="link_works_smni">{ $link }</field>
                            else
                                bod:logging('info', 'Cannot create link from author to work', ($id, $workid))
                else
                    ()
                }
                {
                (: Links to works this person has contributed to in some way other than being the author :)
                if ($iscontributor) then 
                    let $workids := distinct-values($instances/contributed/text())
                    return 
                    for $workid in $workids
                        let $url := concat("/catalog/", $workid)
                        let $rolecodes := distinct-values($instances/contributed[text()=$workid]/@role/data())
                        let $rolelabels := distinct-values(for $role in $rolecodes return bod:personRoleLookup2($role))
                        let $linktext := replace(normalize-space(($worksauthority[@xml:id = $workid]/tei:title[@type = 'uniform'][1])[1]/string()), '\|' , '&#8739;')
                        order by lower-case($linktext)
                        return
                        if (exists($linktext)) then
                            let $link := concat($url, "|", $linktext, '|', string-join(for $role in $rolelabels order by $role return $role, ', '))
                            return
                            <field name="link_contributions_smni">{ $link }</field>
                        else
                            bod:logging('info', 'Cannot create link from contributor to the work', ($id, $workid))
                else
                    ()
                }
                {
                (: Shelfmarks (indexed in special non-tokenized field) :)
                for $shelfmark in bod:shelfmarkVariants(distinct-values($instances/shelfmark/text()))
                    order by $shelfmark
                    return
                    <field name="shelfmarks">{ $shelfmark }</field>
                }
                {
                (: Links to manuscripts containing mentions of the person :)
                for $url in distinct-values($instances/manuscript/@path/data())
                    let $linktext := ($instances/manuscript[@path=$url]/text())[1]
                    let $rolecodes := distinct-values($instances/nonworkrole[@path=$url]/text())
                    let $roles := for $role in $rolecodes return bod:personRoleLookup2($role)
                    let $link := concat($url, "|", $linktext, '|', string-join(for $role in $roles order by $role return $role, ', '))
                    order by $linktext
                    return
                    <field name="link_manuscripts_smni">{ $link }</field>
                }
                {
                (: Filter on which external authorities, if any, this person has been identified in :)
                let $majorextauths := ('VIAF', 'LC', 'ISNI')
                return
                (
                for $majorextauth in $majorextauths
                    return
                    (
                    if (some $extauth in $extauths satisfies $extauth eq $majorextauth) then
                        <field name="extauth_sm">{ $majorextauth }</field>
                    else
                        <field name="extauth_sm">Not{$majorextauth}</field>
                    )
                ,
                if (some $extauth in $extauths satisfies not($extauth = $majorextauths)) then
                    <field name="extauth_sm">Other</field>
                else
                    ()
                ,
                if (count($extauths) eq 0) then
                    <field name="extauth_sm">None</field>
                else
                    ()
                )
                }
            </doc>
        else
            (
            bod:logging('info', 'Skipping unused authority file entry', ($id, $name))
            )
}
{
    (: Log instances without key attributes :)
    for $instancename in distinct-values($allinstances[not(key)]/name)
        order by $instancename
        return bod:logging('info', 'Person without key attribute', $instancename)
}
</add>