
This repository contains the underlying XML files for this catalogue
- [collections](collections/) contains the TEI P5 manuscript description files
- [processing](processing/) contains any scripts to convert or process them
- [working](working/) contains the working files before and after conversion

To create the persons.xml index:

- run processing/build-name-index-xml.sh which will output names_index.xml
- convert names_index.xml with dedupe-names-index.xsl and output as persons.xml

To create the terms.xml index:

- run processing/build-term-index.sh which will output terms_index.xml
- convert terms_index.xml with deduce-terms-index.xsl and output as terms.xml


