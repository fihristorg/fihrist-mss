declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace saxon = "http://saxon.sf.net/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option saxon:output "indent=no";

(: This was written for Wadham, but should work with any institution, just change the folder path in the next line :)

declare variable $collection := collection('../../collections/wadham%20college%20(university%20of%20oxford)/?select=*.xml;recurse=yes');
declare variable $tab := '&#9;';
declare variable $newline := '&#10;';

<dummy>
{
    (
    string-join(('CLASSMARK', 'MIN WIDTH', 'MAX WIDTH', 'MIN HEIGHT', 'MAX HEIGHT', $newline), $tab)
    ,
    for $doc in $collection
        let $classmark as xs:string* := $doc//tei:msDesc/tei:msIdentifier/tei:idno/normalize-space(string())
        let $leafdimensions as element(tei:dimensions)* := $doc//tei:physDesc//tei:dimensions[@type='leaf' and @unit='cm']
        let $widths as xs:double* := distinct-values(for $w in $leafdimensions/tei:width/string() return tokenize($w, '[^0-9\.]')[string-length() gt 0][1] cast as xs:double)
        let $heights as xs:double* := distinct-values(for $h in $leafdimensions/tei:height/string() return tokenize($h, '[^0-9\.]')[string-length() gt 0][1] cast as xs:double)
        order by tokenize($classmark, '\D')[string-length() gt 0][1] cast as xs:integer
        return
        string-join((
            $classmark[1],
            if (count($widths) gt 1) then min($widths) else '',
            max($widths),
            if (count($heights) gt 1) then min($heights) else '',
            max($heights),
        $newline), $tab)
    )
}
</dummy>