import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../authority/subjects.xml")
    let $collection := collection('../collections?select=*.xml;recurse=yes')
    let $subjects := $doc//tei:item[@xml:id]
    
    let $placekeys := distinct-values($collection//(tei:placeName|tei:name[@type='place'])/@key)

    for $subject in $subjects
    
        let $id := $subject/@xml:id/string()
        let $name := normalize-space($subject/tei:term[@type = 'display' or (@type = 'variant' and not(preceding-sibling::tei:term))]/string())
        let $isplace := boolean($id = $placekeys)
        let $islcsh := exists($subject/tei:note/tei:list/tei:item/tei:ref/@target/contains(., 'loc.gov'))
        let $variants := $subject/tei:term[@type="variant"]
        let $noteitems := $subject/tei:note[@type="links"]//tei:item

        let $mss := $collection//tei:TEI[.//(tei:term|tei:placeName|tei:name[@type='place'])[@key = $id]]
        
        let $types := distinct-values((
                                                $collection//(tei:term|tei:placeName|tei:name[@type='place'])[@key = $id]/@role/tokenize(normalize-space(.), ' '), 
                                                if ($isplace) then 'Place' else (),
                                                if ($islcsh) then 'Library of Congress Subject Heading' else ()
                                            ))

        return if (count($mss) > 0) then
        <doc>
            <field name="type">subject</field>
            <field name="pk">{ $id }</field>
            <field name="id">{ $id }</field>
            <field name="title">{ $name }</field>
            <field name="alpha_title">{  bod:alphabetize($name) }</field>
            <field name="sb_name_s">{ $name }</field>
            {
            if (count($types) > 0) then
                for $type in $types
                    order by $type
                    return <field name="sb_type_sm">{ $type }</field>
            else
                <field name="sb_type_sm">Not Specified</field>
            }
            {
            for $variant in $variants
                let $vname := normalize-space($variant/string())
                order by $vname
                return <field name="sb_variant_sm">{ $vname }</field>
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
            bod:logging('info', 'Skipping subject in authority file but not in any manuscript', ($id, $name))
}
</add>
