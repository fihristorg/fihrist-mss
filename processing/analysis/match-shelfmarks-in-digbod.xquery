declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace saxon = "http://saxon.sf.net/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option saxon:output "indent=no";

declare variable $collection := collection('../../collections/oxford%20university?select=*.xml;recurse=yes');
declare variable $digbodsolrxml := doc('/tmp/arabic_in_digbod.xml');
declare variable $tab := '&#9;';
declare variable $newline := '&#10;';

<dummy>
{
    for $teidoc in $collection
        return
        if (exists($teidoc//tei:surrogates)) then
            let $shelfmark as xs:string := normalize-space(($teidoc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]/string())
            let $matches as element()* := $digbodsolrxml/response/result/doc/str[@name='full_shelfmark_s'][text() = $shelfmark or substring-after(text(), 'Bodleian Library ') = $shelfmark]
            order by $shelfmark
            return
            if (count($matches) gt 0) then
                for $match in $matches
                    return
                    concat(string-join((
                        $shelfmark,
                        $match,
                        $match/../str[@name='object_id']/text(),
                        $match/../str[@name='completeness_s']/text(),
                        count($match/../arr[@name='surface_ids']/str)
                    ), $tab), $newline)
            else
                ()
        else
            ()
}
</dummy>