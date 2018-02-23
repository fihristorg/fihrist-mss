import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../authority/persons.xml")
    let $collection := collection('../collections?select=*.xml;recurse=yes')
    let $people := $doc//tei:person[@xml:id]

    let $authorkeys := distinct-values($collection//(tei:author|(tei:persName|tei:name[tei:persName])[parent::tei:author])/@key)
    let $subjectkeys := distinct-values($collection//tei:msItem/tei:title//(tei:persName|tei:name[tei:persName])/@key)

    for $person in $people
    
        let $id := $person/@xml:id/string()
        let $name := normalize-space($person//tei:persName[@type = 'display' or (@type = 'variant' and not(preceding-sibling::tei:persName))]/string())
        let $isauthor := boolean($id = $authorkeys)
        let $issubject := boolean($id = $subjectkeys)
        let $variants := $person/tei:persName[@type="variant"]
        let $noteitems := $person/tei:note[@type="links"]//tei:item
        
        let $mss := $collection//tei:TEI[.//(tei:persName|tei:author|tei:name[tei:persName])[@key = $id]]
        
        let $roles := distinct-values((
                                        $collection//(tei:persName|tei:author|tei:name[tei:persName]|tei:editor)[@key = $id or .//@key = $id]/@role/tokenize(normalize-space(.), ' '),  
                                        if ($isauthor) then 'author' else if ($issubject) then 'subject of a work' else ()
                                     ))

        return if (count($mss) > 0) then
        <doc>
            <field name="type">person</field>
            <field name="pk">{ $id }</field>
            <field name="id">{ $id }</field>
            <field name="title">{ $name }</field>
            <field name="alpha_title">{  bod:alphabetize($name) }</field>
            <field name="pp_name_s">{ $name }</field>
            {
            if (count($roles) > 0) then
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
                let $msid := $ms/string(@xml:id)
                let $url := concat("/catalog/", $msid[1])
                let $classmark := $ms//tei:msDesc/tei:msIdentifier/tei:idno[1]/text()
                let $repository := normalize-space($ms//tei:msDesc/tei:msIdentifier/tei:repository[1]/text())
                let $institution := normalize-space($ms//tei:msDesc/tei:msIdentifier/tei:institution/text())
                let $linktext := concat(
                                    $classmark, 
                                    ' (', 
                                    $repository,
                                    if ($repository ne $institution) then
                                        concat(', ', translate(replace($institution, ' \(', ', '), ')', ''), ')')
                                    else
                                        ')'
                                )
                order by $institution, $classmark
                return <field name="link_manuscripts_smni">{ concat($url, "|", $linktext[1]) }</field>
            }
        </doc>
        else
            bod:logging('info', 'Skipping person in authority files but not in any manuscript', ($id, $name))
}
</add>
