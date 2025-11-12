declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option saxon:output "indent=no";
declare option output:method "text";

(: 
    Update the deleted identifiers mappings
    This script will generate a new version of the file used in fihrist-mss-search: config/initializers/deleted_ids_mapping.rb
    The mapping file is used by: /app/controllers/errors_controller.rb to redirect to the replacement ID
:)


(: Read deletion authority files - only include persons/works/subjects that have both @xml:id and @sameAs :)
declare variable $deletedPeople := doc("../authority/persons_deletions.xml")/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id][@sameAs];
declare variable $deletedWorks := doc("../authority/works_deletions.xml")/tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl[@xml:id][@sameAs];
declare variable $deletedSubjects := doc("../authority/subjects_deletions.xml")/tei:TEI/tei:text/tei:body/tei:list/tei:item[@xml:id][@sameAs];

declare variable $tab := codepoints-to-string(9);
declare variable $newline := codepoints-to-string(10);



(: Function that generates the content for oldid and newid :)
(: There cannot be duplicates of xml:id - duplicates are removed leaving the last instance (row) of the duplicated value:)
declare function local:getRows($deletedDoc as node()*) as xs:string {
  let $uniqueIds := distinct-values($deletedDoc/@xml:id)

  let $rows :=
    for $idVal in $uniqueIds
        let $group := $deletedDoc[@xml:id = $idVal]
        let $last := $group[last()]
        let $id := $last/@xml:id/data()
        let $sameAs := $last/@sameAs/data()
        let $newOld as xs:string := string-join((
            "'", substring-after($id, '_'), "' => '", tokenize($sameAs, '_')[last()], "'"
        ))
    order by $id
    return normalize-space($newOld)

  return string-join((
    for $x in $rows return concat($tab, $tab, $x, $newline)
  ))
};


<output>
{
    (    
        string-join((            
            (: Debugging :)
            (:~ "count people = ", count($deletedPeople), $newline,   
            "count works = ", count($deletedWorks), $newline,  
            "count subjects = ", count($deletedSubjects), $newline,  ~:)
            
            (: Create Array :)                
            "OLDNEWMAPPING = {",
            (: Start People :)
            $newline, $tab, "'person' =&gt; {",
            $newline)
        ),

        (: Get old and new person identifiers :)
        local:getRows($deletedPeople),
       
        string-join((
            (: Close People :)
            $tab, "},", $newline, 
            (: Start Works :)
            $tab, "'work' =&gt; {",
            $newline)
        ),

        (: Get old and new work identifiers :)
        local:getRows($deletedWorks),
       
        string-join((
            (: Close Works :)
            $tab, "},", $newline, 
            (: Start Subjects :)
            $tab, "'subject' =&gt; {",
            $newline)
        ),
    
        (: Get old and new subject identifiers :)
        local:getRows($deletedSubjects),
        
        string-join((
            (: Close Subjects :)
            $tab, "}",
            (: Close Array :)
            $newline, "}")
        )
    )
}
</output>