#!/usr/bin/env bash

# Change directory to the location of this script
cd "${0%/*}"

# Run XSLT on all TEI files in collections path (using pwd to get full path, not relative, which is what the XSL needs)
java -Xmx1G -Xms1G -cp "saxon/saxon9he.jar"  net.sf.saxon.Transform -it:batch -xsl:convert2HTML.xsl collections-path=`pwd`/../collections/

# Convert to full HTML and prettify
echo "Prettifying output"
#find ./html/ -name "*.html" -type f -exec xmllint --output '{}' --format '{}' \;
find ./html/ -name "*.html" -type f -exec tidy --doctype omit --numeric-entities yes --tidy-mark no -q -i -m -w 160 -asxhtml -utf8 -output '{}' '{}' \;
