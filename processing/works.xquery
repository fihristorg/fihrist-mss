import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../authority/works.xml")
    let $collection := collection("../collections?select=*.xml;recurse=yes")
    let $works := $doc//tei:listBibl/tei:bibl[@xml:id]
       
    for $work in $works
    
        let $id := $work/@xml:id/string()
        let $title := normalize-space($work//tei:title[@type="uniform"][1]/string())
        let $variants := $work//tei:title[@type="variant"]
        
        let $mss := $collection//tei:TEI[.//tei:title[@key = $id]]
                
        let $langs := $mss//tei:msItem[.//tei:title[@key = $id]]//tei:textLang
        
        return if (count($mss) > 0) then
        <doc>
            <field name="type">work</field>
            <field name="pk">{ $id }</field>
            <field name="id">{ $id }</field>
            <field name="title">{ $title }</field>
            <field name="wk_title_s">{ $title }</field>
            {
            for $variant in $variants
                let $vname := normalize-space($variant/string())
                order by $vname
                return <field name="wk_variant_sm">{ $vname }</field>
            }
            {
            let $institutions := (for $ms in $mss return $ms//tei:msDesc/tei:msIdentifier/tei:institution/text())
            for $institution in distinct-values($institutions) 
                return <field name="institution_sm">{ $institution }</field>
            }
            <field name="alpha_title">{ 
                if (contains($title, ':')) then
                    bod:alphabetize($title)
                else
                    bod:alphabetizeTitle($title)
            }</field>
            {
            bod:languages($langs, 'lang_sm')
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
            (
            bod:logging('info', 'Skipping work in works.xml but not in any manuscript', ($id, $title))
            )
}
</add>
