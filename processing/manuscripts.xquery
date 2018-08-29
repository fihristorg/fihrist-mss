import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "lib/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

declare variable $collection := collection('../collections/?select=*.xml;recurse=yes');

<add>
{
    comment{concat(' Indexing started at ', current-dateTime(), ' using files in ', substring-before(substring-after(base-uri($collection[1]), 'file:'), 'collections/'), ' ')}
}
{
    let $msids := $collection/tei:TEI/@xml:id/data()
    return if (count($msids) ne count(distinct-values($msids))) then
        let $duplicateids := distinct-values(for $msid in $msids return if (count($msids[. eq $msid]) gt 1) then $msid else '')
        return bod:logging('error', 'There are multiple manuscripts with the same xml:id in their root TEI elements', $duplicateids)
        
    else
        for $ms in $collection
            let $msid := $ms/tei:TEI/@xml:id/string()
            order by $msid
            return
            if (string-length($msid) ne 0) then
                let $mainshelfmark := ($ms/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno)[1]
                let $allshelfmarks := $ms//tei:msIdentifier/tei:idno
                let $subfolders := string-join(tokenize(substring-after(base-uri($ms), 'collections/'), '/')[position() lt last()], '/')
                let $htmlfilename := concat($msid, '.html')
                let $htmldoc := doc(concat('html/', $subfolders, '/', $htmlfilename))
                
                let $repository := normalize-space($ms//tei:msDesc/tei:msIdentifier/tei:repository[1]/text())
                let $institution := normalize-space($ms//tei:msDesc/tei:msIdentifier/tei:institution/text())
                let $shelfmark := normalize-space($ms//tei:msDesc/tei:msIdentifier/tei:idno[1]/text())
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

                return <doc>
                    <field name="type">manuscript</field>
                    <field name="pk">{ $msid }</field>
                    <field name="id">{ $msid }</field>
                    { bod:string2one($title, 'title') }
                    { bod:one2one($ms//tei:titleStmt/tei:title[@type='collection'], 'ms_collection_s') }
                    { bod:one2one($ms//tei:msDesc/tei:msIdentifier/tei:collection, 'ms_collection_s', 'Not specified') }
                    { bod:one2one($ms//tei:msDesc/tei:msIdentifier/tei:institution, 'institution_sm') }
                    { bod:many2one($ms//tei:msDesc/tei:msIdentifier/tei:repository, 'ms_repository_s') }
                    { bod:strings2many(bod:shelfmarkVariants($allshelfmarks), 'shelfmarks') (: Non-tokenized field :) }
                    { bod:many2many($allshelfmarks, 'ms_shelfmarks_sm') (: Tokenized field :) }
                    { bod:one2one($mainshelfmark, 'ms_shelfmark_sort') }
                    { bod:many2many($ms//tei:msIdentifier/tei:altIdentifier[@type='internal']/tei:idno[not(starts-with(text(), 'Not in'))], 'ms_altid_sm') }
                    { bod:many2many($ms//tei:msIdentifier/tei:altIdentifier[@type='external']/tei:idno, 'ms_extid_sm') }
                    { bod:many2one($ms//tei:msIdentifier/tei:msName, 'ms_name_sm') }
                    { bod:one2one(($ms//tei:publicationStmt/tei:pubPlace/tei:address/tei:addrLine/tei:email, $ms//tei:additional/tei:adminInfo/tei:availability//tei:email)[1], 'ms_contactemail_sni') }
                    <field name="filename_s">{ substring-after(base-uri($ms), 'collections/') }</field>
                    { bod:materials($ms//tei:msDesc//tei:physDesc//tei:supportDesc[@material], 'ms_materials_sm', 'Not specified') }
                    { bod:physForm($ms//tei:physDesc/tei:objectDesc, 'ms_physform_sm', 'Not specified') }
                    { bod:trueIfExists($ms//tei:sourceDesc//tei:decoDesc/tei:decoNote, 'ms_deconote_b') }
                    { bod:digitized($ms//tei:sourceDesc//tei:surrogates/tei:bibl, 'ms_digitized_s') }
                    { bod:languages($ms//tei:sourceDesc//tei:textLang, 'lang_sm') }
                    { bod:centuries(
                        $ms//tei:origin//tei:origDate[@calendar = '#Gregorian' or @calendar = '#Hijri-qamari'], 
                        'ms_date_sm', 
                        if ($ms//tei:origin//tei:origDate[@calendar = '#Gregorian' or @calendar = '#Hijri-qamari']) 
                            then 'Date not machine-readable' 
                        else if ($ms//tei:origin//tei:origDate) 
                            then 'Date in unsupported calendar' 
                        else 'Undated') }
                    { bod:one2one($ms//tei:msContents/tei:summary, 'ms_summary_s') }
                    { bod:indexHTML($htmldoc, 'ms_textcontent_tni') }
                    { bod:displayHTML($htmldoc, 'display') }
                </doc>

            else
                bod:logging('warn', 'Cannot process manuscript without @xml:id for root TEI element', base-uri($ms))
}
</add>