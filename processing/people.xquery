import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../authority/persons.xml")
    let $collection := collection('../collections?select=*.xml;recurse=yes')
    let $people := $doc//tei:person[@xml:id]

    for $person in $people
    
        let $id := $person/@xml:id/string()
        let $name := normalize-space($person//tei:persName[@type = 'display' or (@type = 'variant' and not(preceding-sibling::tei:persName))]/string())
        let $isauthor := boolean($collection//tei:author[@key = $id or .//persName/@key = $id])
        let $issubject := boolean($collection//tei:msItem/tei:title//tei:persName[not(@role) and @key = $id])

        let $mss1 := $collection//tei:TEI[.//(tei:persName)[@key = $id]]/concat('/catalog/', string(@xml:id), '|', (./tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text())
        let $mss2 := $collection//tei:TEI[.//(tei:author)[@key = $id]]/concat('/catalog/', string(@xml:id), '|', (./tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text())
        let $mss3 := $collection//tei:TEI[.//(tei:name)[@key = $id]]/concat('/catalog/', string(@xml:id), '|', (./tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/text())
        let $mss := distinct-values(($mss1, $mss2, $mss3))

        let $variants := $person/tei:persName[@type="variant"]
        let $noteitems := $person/tei:note[@type="links"]//tei:item

        return if (count($mss) > 0) then
        <doc>
            <field name="type">person</field>
            <field name="pk">{ $id }</field>
            <field name="id">{ $id }</field>
            <field name="title">{ $name }</field>
            <field name="alpha_title">{  bod:alphabetize($name) }</field>
            <field name="pp_name_s">{ $name }</field>
            {
            let $roles := distinct-values(
                            (
                            $collection//(tei:persName|tei:author|tei:name)[@key = $id]/@role/tokenize(., ' '), 
                            $collection//(tei:persName|tei:author|tei:name)[@key = $id]/parent::*[self::tei:author or self::tei:name or self::tei:editor]/@role/tokenize(., ' '), 
                            if ($isauthor) then 'author' else if ($issubject) then 'subject' else ()
                            )
                            )
            return if (count($roles) > 0) then
                for $role in $roles
                    order by $role
                    return <field name="pp_roles_sm">{ bod:personRoleLookup($role) }</field>
            else
                <field name="pp_roles_sm">Not Specified</field>
            }
            {
            for $variant in $variants
                let $vname := normalize-space($variant/string())
                order by $vname
                return <field name="pp_variant_sm">{ $vname }</field>
            }
            {
            for $item in $noteitems
                let $refs := $item//tei:ref
                order by $refs[1]
                for $ref in $refs
                    let $linktarget := $ref/string(@target)
                    let $linktext := $ref/normalize-space(tei:title/string())
                    order by $linktarget
                    return <field name="link_external_smni">{ concat($linktarget, "|", $linktext)}</field>
            }
            {
            for $ms in $mss
                order by $ms
                return <field name="link_manuscripts_smni">{ $ms }</field>
            }
        </doc>
        else
            bod:logging('info', 'Skipping person in authority files but not in any manuscript', ($id, $name))
}

{
    let $allpeople := collection("../collections?select=*.xml;recurse=yes")//tei:TEI//(tei:persName|tei:author)
    return if (count($allpeople[not(@key)]) > 0) then bod:logging('info', concat(count($allpeople[not(@key)]), ' people found in manuscripts which lack @key attributes'), ()) else ()
}
</add>
