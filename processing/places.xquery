import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "lib/msdesc2solr.xquery";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

(: Read authority file :)
declare variable $authorityentries := doc("../authority/places.xml")/tei:TEI/tei:text/tei:body//(tei:listPlace/tei:place | tei:listOrg/tei:org)[@xml:id];

(: Find instances in manuscript description files, building in-memory data structure, to avoid having to search across all files for each authority file entry :)
declare variable $allinstances :=
for $instance in collection('../collections?select=*.xml;recurse=yes')//tei:msDesc//(tei:placeName | tei:country | tei:settlement | tei:region | tei:orgName)[not(ancestor::tei:msIdentifier)]
let $roottei := $instance/ancestor::tei:TEI
let $shelfmark := ($roottei/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/string()
let $datesoforigin := bod:summarizeDates($roottei//tei:origin//tei:origDate)
let $placesoforigin := distinct-values($roottei//tei:origin//tei:origPlace/normalize-space()[string-length(.) gt 0])
let $institution := normalize-space(($roottei//tei:msDesc/tei:msIdentifier/tei:institution)[1]/string())
let $repository := normalize-space(($roottei//tei:msDesc/tei:msIdentifier/tei:repository)[1]/string())
return
    <instance>
        {
            attribute of {
                if ($instance/self::tei:orgName) then
                    'org'
                else
                    'place'
            }
        }
        {
            for $key in tokenize(normalize-space($instance/@key), ' ')
            return
                <key>{$key}</key>
        }
        <name>{normalize-space($instance/string())}</name>
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
        {
            for $role in tokenize($instance/@role/data(), ' ')
            return
                <role>{$role}</role>
        }
        {
            if (not($instance/self::tei:placeName or $instance/self::tei:orgName)) then
                <type>{local-name($instance)}</type>
            else
                ()
        }
        <shelfmark>{$shelfmark}</shelfmark>
    </instance>;

<add>
    {
        comment {concat(' Indexing started at ', current-dateTime(), ' using authority file at ', substring-after(base-uri($authorityentries[1]), 'file:'), ' ')}
    }
    {
        (: Log instances with key attributes not in the authority file :)
        for $key in distinct-values($allinstances/key)
        return
            if (not(some $entryid in $authorityentries/@xml:id/data()
                satisfies $entryid eq $key)) then
                bod:logging('warn', 'Key attribute not found in authority file: will create broken link', ($key, $allinstances[key = $key]/name))
            else
                ()
    }
    {
        (: Loop thru each place or organization entry in the authority file :)
        for $placeororg in $authorityentries
        
        (: Get info in authority entry :)
        let $id := $placeororg/@xml:id/data()
        let $isorg := exists($placeororg/self::tei:org)
        let $name :=
        if ($isorg) then
            if ($placeororg/tei:orgName[@type = 'display']) then
                normalize-space($placeororg/tei:orgName[@type = 'display'][1]/string())
            else
                normalize-space($placeororg/tei:orgName[1]/string())
        else
            if ($placeororg/tei:placeName[@type = 'index']) then
                normalize-space($placeororg/tei:placeName[@type = 'index'][1]/string())
            else
                normalize-space($placeororg/tei:placeName[1]/string())
        let $variants :=
        if ($isorg) then
            for $v in $placeororg/tei:orgName[not(@type = 'display')]
            return
                normalize-space($v/string())
        else
            for $v in $placeororg/tei:placeName[not(@type = 'index')]
            return
                normalize-space($v/string())
        let $extrefs := for $r in $placeororg/tei:note[@type = "links"]//tei:item/tei:ref
        return
            concat($r/@target/data(), '|', bod:lookupAuthorityName(normalize-space($r/tei:title/string())))
        let $extauths := distinct-values(for $r in $placeororg/tei:note[@type = 'links']//tei:item/tei:ref
        return
            normalize-space($r/tei:title/string()))
        let $bibrefs := for $b in $placeororg/tei:bibl
        return
            bod:italicizeTitles($b)
        let $notes := for $n in ($placeororg/tei:note[not(@type = "links")], $placeororg/ancestor::tei:listPlace/tei:head/tei:note, $placeororg/ancestor::tei:listOrg/tei:head/tei:note)
        return
            bod:italicizeTitles($n)
        let $geolocs := $placeororg/tei:location/tei:geo[matches(text(), '^\s*\-?[\d\.]+\s*,\s*\-?[\d\.]+\s*$')]
        
        (: Get info in all the instances in the manuscript description files :)
        let $instances := $allinstances[key = $id]
        let $roles := distinct-values(for $role in distinct-values($instances/role/text())
        return
            bod:personRoleLookup($role))
        let $parishes := $placeororg/tei:region[@type = "parish"]
        let $counties := $placeororg/tei:region[@type = "county"]
        
        let $parentlinks := for $link in $placeororg/tei:region[@type and @key]
        return
            concat(
            '/catalog/',
            $link/@key,
            '|',
            $link/text(),
            '|',
            $link/@type
            )
        let $childlinks := for $link in $authorityentries[tei:region/@key = $id]
        let $linkorg := exists($link/self::tei:org)
        return
            if ($linkorg) then
                ()
            else
                concat(
                '/catalog/',
                $link/@xml:id,
                '|',
                if ($link/tei:placeName[@type = 'index']) then
                    normalize-space($link/tei:placeName[@type = 'index'][1]/string())
                else
                    normalize-space($link/tei:placeName[1]/string()),
                '|',
                $link/@type
                )
                (: Output a Solr doc element :)
        return
            if (count($instances) ge 0) then
                <doc>
                    <field
                        name="type">place</field>
                    <field
                        name="pk">{$id}</field>
                    <field
                        name="id">{$id}</field>
                    <field
                        name="title">{$name}</field>
                    <field
                        name="alpha_title">{bod:alphabetize($name)}</field>
                    {
                        if ($placeororg/self::tei:place) then
                            if ($placeororg/@type) then
                                <field
                                    name="pl_type_s">{$placeororg/@type/data()}</field>
                            else
                                for $type in distinct-values($instances/type/text())
                                return
                                    <field
                                        name="pl_type_s">{$type}</field>
                        else
                            ()
                    }
                    {
                        for $parish in $parishes
                        return
                            <field
                                name="pl_region_parish_sm">{
                                    concat($parish/text(), if ($parish/@key) then
                                        concat('|', '/catalog/', $parish/@key)
                                    else
                                        '')
                                }</field>
                    }
                    {
                        for $county in $counties
                        return
                            <field
                                name="pl_region_county_sm">{
                                    concat($county/text(), if ($county/@key) then
                                        concat('|', '/catalog/', $county/@key)
                                    else
                                        '')
                                }</field>
                    }
                    {
                        
                        for $link in ($parentlinks, $childlinks)
                            order by tokenize($link, '\|')[2]
                        return
                            <field
                                name="link_place_smni">{$link}</field>
                    }
                    
                    {
                        (: Roles (typically for organizations such as monasteries that were former owners) :)
                        for $role in $roles
                            order by $role
                        return
                            <field
                                name="roles_sm">{$role}</field>
                    }
                    {
                        (: Alternative names :)
                        for $variant in distinct-values($variants)
                            order by $variant
                        return
                            <field
                                name="pl_variant_sm">{$variant}</field>
                    }
                    {
                        let $lcvariants := for $variant in ($name, $variants)
                        return
                            lower-case($variant)
                        for $instancevariant in distinct-values($instances/name/text())
                            order by $instancevariant
                        return
                            if (not(lower-case($instancevariant) = $lcvariants)) then
                                <field
                                    name="pl_variant_sm">{$instancevariant}</field>
                            else
                                ()
                    }
                    {
                        (: Co-ordinates (displayed as links to the same page Wikipedia uses to offer choice of mapping web sites :)
                        for $geoloc in $geolocs
                        let $coords := tokenize(translate($geoloc/text(), ' ', ''), ',')
                        let $lat := number($coords[1])
                        let $long := number($coords[2])
                        return
                            if (string($lat) ne 'NaN' and string($long) ne 'NaN') then
                                let $dmscoords := string-join(bod:latLongDecimal2DMS($lat, $long), ', ')
                                return
                                    <field
                                        name="link_geo_smni">https://tools.wmflabs.org/geohack/geohack.php?params={$lat}_N_{$long}_E|{$dmscoords}</field>
                            else
                                ()
                    }
                    {
                        (: Links to external authorities and other web sites :)
                        for $extref in $extrefs
                            order by $extref
                        return
                            <field
                                name="link_external_smni">{$extref}</field>
                    }
                    {
                        (: Bibliographic references about the place or organization :)
                        for $bibref in $bibrefs
                            order by $bibref
                        return
                            <field
                                name="bibref_smni">{$bibref}</field>
                    }
                    {
                        (: Notes about the place or organization :)
                        for $note in $notes
                            order by $note
                        return
                            <field
                                name="note_smni">{$note}</field>
                    }
                    {
                        (: See also links to other entries in the same authority file :)
                        let $relatedids := tokenize(translate(string-join(($placeororg/@corresp, $placeororg/@sameAs), ' '), '#', ''), ' ')
                        for $relatedid in distinct-values($relatedids)
                        let $url := concat("/catalog/", $relatedid)
                        let $linktext := ($authorityentries[@xml:id = $relatedid]/(tei:placeName | tei:orgName)[@type = 'display'][1])[1]
                            order by $linktext
                        return
                            if (exists($linktext) and $allinstances[key = $relatedid]) then
                                let $link := concat($url, "|", normalize-space($linktext/string()))
                                return
                                    <field
                                        name="link_related_smni">{$link}</field>
                            else
                                bod:logging('info', 'Cannot create see-also link', ($id, $relatedid))
                    }
                    {
                        (: Shelfmarks (indexed in special non-tokenized field) :)
                        for $shelfmark in bod:shelfmarkVariants(distinct-values($instances/shelfmark/text()))
                            order by $shelfmark
                        return
                            <field
                                name="shelfmarks">{$shelfmark}</field>
                    }
                    {
                        (: Links to manuscripts containing mentions of the place or organization :)
                        for $link in distinct-values($instances/link/text())
                            order by tokenize($link, '\|')[2]
                        return
                            <field
                                name="link_manuscripts_smni">{$link}</field>
                    }
                    {
                        (: Filter on which external authorities, if any, this person has been identified in :)
                        if ($isorg) then
                            let $majorextauths := ('VIAF', 'GND', 'LC', 'ISNI', 'Wikidata', 'SUDOC', 'BNF')
                            return
                                (
                                for $majorextauth in $majorextauths
                                return
                                    (
                                    if (some $extauth in $extauths
                                        satisfies $extauth eq $majorextauth) then
                                        <field
                                            name="extauth_sm">{$majorextauth}</field>
                                    else
                                        <field
                                            name="extauth_sm">Not{$majorextauth}</field>
                                    )
                                ,
                                if (some $extauth in $extauths
                                    satisfies not($extauth = $majorextauths)) then
                                    <field
                                        name="extauth_sm">Other</field>
                                else
                                    ()
                                ,
                                if (count($extauths) eq 0) then
                                    <field
                                        name="extauth_sm">None</field>
                                else
                                    ()
                                )
                        else
                            ()
                    }
                </doc>
            else
                bod:logging('info', 'Skipping unused authority file entry', ($id, $name))
    }
    {
        (: Log instances without key attributes :)
        (
        for $instancename in distinct-values($allinstances[@of = 'place' and not(key)]/name)
            order by $instancename
        return
            bod:logging('info', 'Place name without key attribute', $instancename)
        ,
        for $instancename in distinct-values($allinstances[@of = 'org' and not(key)]/name)
            order by $instancename
        return
            bod:logging('info', 'Organization name without key attribute', $instancename)
        )
    }
</add>