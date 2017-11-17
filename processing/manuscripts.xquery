declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:contents_summary($contents)
{
    for $item in $contents/tei:summary/string()
    let $v := fn:normalize-space($item)

    return if (empty($v)) then
        ()
    else
        <field name="ms_summary_sm">{ $v }</field>
};


declare function local:layout($desc)
{
    for $item in $desc//tei:layout/string()
    let $v := fn:normalize-space($item)
    return if (empty($v)) then
        ()
    else
        <field name="ms_layout_sm">{ $v }</field>
};

declare function local:extent($desc)
{
    for $item in $desc//tei:extent/*[normalize-space()]
    return <field name="ms_extents_sm">{ fn:normalize-space($item) }</field>
};

declare function local:notes($contents)
{
    for $item in $contents/tei:msItem/tei:note/string(.)
    return <field name="ms_notes_sm">{ fn:normalize-space($item) }</field>
};

declare function local:authors($contents)
{
    for $item in distinct-values($contents/tei:msItem/tei:author/tei:persName/text()/fn:normalize-space(.))
    return <field name="ms_authors_sm">{ $item }</field>
};

declare function local:works_ps($contents)
{
    for $item in distinct-values(fn:data($contents/tei:msItem/tei:title[@xml:lang="ps"]))
    return <field name="ms_works_ps_sm">{ fn:normalize-space($item) }</field>
};

declare function local:works_ar($contents)
{
    for $item in distinct-values(fn:data($contents/tei:msItem/tei:title[@xml:lang="ar"]))
    return <field name="ms_works_ar_sm">{ normalize-space($item) }</field>
};

declare function local:works_en($contents)
{
    for $item in distinct-values(fn:data($contents/tei:msItem/tei:title[@xml:lang="en"]))
    return <field name="ms_works_en_sm">{ fn:normalize-space($item) }</field>
};

declare function local:works_ar_latn($contents)
{
    for $item in distinct-values(fn:data($contents/tei:msItem/tei:title[@xml:lang="ar-Latn-x-lc"]))
    return <field name="ms_works_ar_latn_sm">{ fn:normalize-space($item) }</field>
};

<add>
{
    for $x in collection('../collections/?select=*.xml;recurse=yes')
        let $title := concat($x//tei:msDesc/tei:msIdentifier/tei:repository/text(), " ", $x//tei:msDesc/tei:msIdentifier/tei:idno[1]/text())
        let $msid := $x//tei:TEI/@xml:id/data()

        return <doc>
            <field name="type">manuscript</field>
            <field name="pk">{ $msid }</field>
            <field name="id">{ $msid }</field>
            <field name="filename_sni">{ fn:base-uri($x) }</field>
            <field name="title">{ $title }</field>
            <field name="ms_collection_s">{ $x//tei:msDesc/tei:msIdentifier/tei:collection/text()  }</field>
            <field name="ms_institution_s">{ $x//tei:msDesc/tei:msIdentifier/tei:institution/text() }</field>
            <field name="ms_repository_s">{ $x//tei:msDesc/tei:msIdentifier/tei:repository/text() }</field>
            <field name="ms_date_stmt_s">{ $x//tei:history/tei:origin/tei:date/text() }</field>
            <field name="ms_shelfmark_s">{ $x//tei:msDesc/tei:msIdentifier/tei:idno/text() }</field>
            <field name="ms_shelfmark_sort">{ $x//tei:msDesc/tei:msIdentifier/tei:idno/text() }</field>
            <field name="ms_physform_s">{ $x//tei:physDesc[1]/tei:objectDesc[@form]/string(@form)[1] }</field>
            { local:contents_summary($x//tei:msContents) }
            { local:works_ar($x//tei:msContents) }
            { local:works_ps($x//tei:msContents) }
            { local:works_en($x//tei:msContents) }
            { local:works_ar_latn($x//tei:msContents) }
            { local:authors($x//tei:msContents) }
            { local:notes($x//tei:msContents) }
            { local:extent($x//tei:physDesc) }
            { local:layout($x//tei:physDesc) }
        </doc>
}
</add>