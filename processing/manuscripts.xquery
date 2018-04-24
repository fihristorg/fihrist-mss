import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";


<add>
{
    let $collection := collection('../collections/?select=*.xml;recurse=yes')
    let $msids := $collection/tei:TEI/@xml:id/data()
    return if (count($msids) ne count(distinct-values($msids))) then
        let $duplicateids := distinct-values(for $msid in $msids return if (count($msids[. eq $msid]) gt 1) then $msid else '')
        return bod:logging('error', 'There are multiple manuscripts with the same xml:id in their root TEI elements', $duplicateids)
    else
        for $x in $collection

            let $msid := $x//tei:TEI/@xml:id/string()
            return 
            if (string-length($msid) ne 0) then 
            
                let $subfolders := string-join(tokenize(substring-after(base-uri($x), 'collections/'), '/')[position() lt last()], '/')
                let $htmlfilename := concat($msid, '.html')
                let $htmldoc := doc(concat("html/", $subfolders, '/', $htmlfilename))
                
                let $repository := normalize-space($x//tei:msDesc/tei:msIdentifier/tei:repository[1]/text())
                let $institution := normalize-space($x//tei:msDesc/tei:msIdentifier/tei:institution/text())
                let $shelfmark := normalize-space($x//tei:msDesc/tei:msIdentifier/tei:idno[1]/text())
                let $normalizedshelfmark := replace($shelfmark, '\W', ' ')
                let $sortshelfmark := upper-case(replace($normalizedshelfmark, '\s', ''))
                let $title := concat(
                                    $shelfmark, 
                                    ' (', 
                                    $repository,
                                    if ($repository ne $institution) then
                                        concat(', ', translate(replace($institution, ' \(', ', '), ')', ''), ')')
                                    else
                                        ')'
                                )
        
                (:
                    Guide to Solr field naming conventions:
                        ms_ = manuscript index field
                        _i = integer field
                        _b = boolean field
                        _s = string field (tokenized)
                        _t = text field (not tokenized)
                        _?m = multiple field (typically facets)
                        *ni = not indexed (except _tni fields which are copied to the fulltext index)
                :)
    
                return <doc>
                    <field name="type">manuscript</field>
                    <field name="pk">{ $msid }</field>
                    <field name="id">{ $msid }</field>
                    <field name="filename_sni">{ base-uri($x) }</field>
                    { bod:one2one($x//tei:msDesc/tei:msIdentifier/tei:collection, 'ms_collection_s', 'Not specified') }
                    { bod:one2one($x//tei:msDesc/tei:msIdentifier/tei:institution, 'institution_sm', 'Not specified') }
                    { bod:string2one($shelfmark, 'ms_shelfmark_s') }
                    { bod:strings2many(($normalizedshelfmark, $sortshelfmark), 'ms_altshelfmark_sm')}
                    { bod:string2one($sortshelfmark, 'ms_shelfmark_sort') }
                    { bod:one2one(($x//tei:publicationStmt/tei:pubPlace/tei:address/tei:addrLine/tei:email, $x//tei:additional/tei:adminInfo/tei:availability//tei:email)[1], 'ms_contactemail_sni') }
                    { bod:string2one($title, 'title') }
                    { bod:many2one($x//tei:msDesc/tei:msIdentifier/tei:repository, 'ms_repository_s') }
                    { bod:many2many($x//tei:msContents/tei:msItem/tei:title, 'ms_works_sm') }
                    { bod:many2many($x//tei:msContents/tei:msItem/tei:author/tei:persName, 'ms_authors_sm') }
                    { bod:many2many($x//tei:sourceDesc//tei:name[@type="corporate"]/tei:persName, 'ms_corpnames_sm') }
                    { bod:many2many($x//tei:sourceDesc//tei:persName, 'ms_persnames_sm') }
                    { bod:many2many($x//tei:physDesc//tei:extent, 'ms_extents_sm') }
                    { bod:many2many($x//tei:physDesc//tei:layout, 'ms_layout_sm') }
                    { bod:many2many($x//tei:msContents/tei:msItem/tei:note, 'ms_notes_sm') }
                    { bod:many2many($x//tei:msContents/tei:summary, 'ms_summary_sm') }
                    { bod:many2many($x//tei:msContents/tei:msItem/tei:title[@xml:lang='ar'], 'ms_works_ar_sm') }
                    { bod:many2many($x//tei:msContents/tei:msItem/tei:title[@xml:lang='ar-Latn-x-lc'], 'ms_works_ar_latn_sm') }
                    { bod:many2many($x//tei:msContents/tei:msItem/tei:title[@xml:lang='en'], 'ms_works_en_sm') }
                    { bod:many2many($x//tei:msContents/tei:msItem/tei:title[@xml:lang='ps'], 'ms_works_ps_sm') }
                    { bod:trueIfExists($x//tei:sourceDesc//tei:decoDesc/tei:decoNote, 'ms_deconote_b') }
                    { bod:materials($x//tei:msDesc//tei:physDesc//tei:supportDesc[@material], 'ms_materials_sm', 'Not specified') }
                    { bod:physForm($x//tei:physDesc/tei:objectDesc, 'ms_physform_sm', 'Not specified') }
                    { bod:languages($x//tei:sourceDesc//tei:textLang, 'lang_sm', 'Not specified') }
                    { bod:centuries($x//tei:origin//tei:origDate[@calendar = '#Gregorian' or @calendar = '#Hijri-qamari'], 'ms_date_sm', if ($x//tei:origin//tei:origDate[@calendar = '#Gregorian' or @calendar = '#Hijri-qamari']) then 'Date not machine-readable' else if ($x//tei:origin//tei:origDate) then 'Date in unsupported calendar' else 'Undated') }
                    { bod:string2one(bod:shortenToNearestWord(string-join(($x//tei:msContents/tei:summary)[1]//text(), ' '), 128), 'ms_summary_sni') }
                    { bod:indexHTML($htmldoc, 'ms_textcontent_tni') }
                    { bod:displayHTML($htmldoc, 'display') }
                </doc>
             else
                bod:logging('warn', 'Cannot process manuscript without @xml:id for root TEI element', base-uri($x))
        
}
</add>


