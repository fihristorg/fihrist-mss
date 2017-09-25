declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace html="http://www.w3.org/1999/xhtml";


<add>
    {
        for $x in collection('../collections/?select=*.xml;recurse=yes')
            let $works := $x//tei:msContents/tei:msItem

            for $w in $works
                let $title := $w/tei:title[text()][1]/normalize-space(.)
                let $wkid := $w/@xml:id/data()
                return <doc>
                    <field name="type">work</field>
                    <field name="pk">{ $wkid }</field>
                    <field name="id">{ $wkid }</field>
                    <field name="title">{ $title }</field>
                </doc>
    }
</add>