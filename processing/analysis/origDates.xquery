declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

declare variable $collection := collection('../../collections/?select=*.xml;recurse=yes');

<dummy>
{
    for $origin in $collection[.//tei:origDate]//tei:origin[not(ancestor::tei:msPart)]
        let $minyears := for $date in $origin//tei:origDate/(@when|@notBefore|@from)[1] return tokenize($date, '\D')[matches(., '\d\d\d\d')]
        let $maxyears := for $date in $origin//tei:origDate/(@when|@notAfter|@to)[1] return tokenize($date, '\D')[matches(., '\d\d\d\d')]
        return
        <manuscript file="{ base-uri($origin) }">
            <num>{ count($origin//tei:origin) }</num>
            <min>{ min($minyears) }</min>
            <max>{ max($maxyears) }</max>
        </manuscript>
}
</dummy>