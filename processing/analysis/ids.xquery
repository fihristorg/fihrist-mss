declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace saxon = "http://saxon.sf.net/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option saxon:output "indent=no";

declare variable $collection := collection('../../collections/?select=*.xml;recurse=yes');
declare variable $tab := '&#9;';
declare variable $newline := '&#10;';

<dummy>
{
    for $doc in $collection[.//tei:msItem/@xml:id]
        let $institution := normalize-space($doc/tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:sourceDesc[1]/tei:msDesc[1]/tei:msIdentifier[1]/tei:institution[1])
        let $classmark := normalize-space($doc/tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:sourceDesc[1]/tei:msDesc[1]/tei:msIdentifier[1]/tei:idno[1])
        for $msitem in $doc//tei:msItem
            let $id := $msitem/@xml:id/data()
            let $title := normalize-space($msitem/tei:title[1]/string())
            let $locus := normalize-space($msitem/tei:locus[1]/string())
            return 
            string-join((
                string-join((
                    $institution, 
                    $classmark,
                    $title,
                    $locus
                ), ' '),
                $id,
            $newline), $tab)
}
</dummy>