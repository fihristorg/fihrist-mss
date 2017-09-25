declare namespace tei="http://www.tei-c.org/ns/1.0";

(:~
: User: ahankins
: Date: 18/09/2017
: Time: 14:55
: To change this template use File | Settings | File Templates.
:)

<add>
{
    for $x in collection('../collections/?select=*.xml;recurse=yes')
        let $filepath := fn:tokenize(fn:base-uri($x), '/')
        let $title := $x//tei:msDesc/tei:msIdentifier/tei:idno[@type="shelfmark"]/text()
        let $msid := $x//tei:TEI/@xml:id/data()

        return <doc>
            <field name="type">manuscript</field>
            <field name="pk">{ $msid }</field>
            <field name="id">{ $msid }</field>
            <field name="title">{ $title }</field>
        </doc>
}
</add>