import csv
import argparse
from rdflib import Graph, Literal, Namespace, RDF, URIRef, BNode
# rdflib knows about quite a few popular namespaces, like W3C ontologies, schema.org etc.
from rdflib.namespace import RDF, RDFS


# construct the argument parse and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-c", "--csvfile", required=True, help="csv file")
args = vars(ap.parse_args())

csvfile=args["csvfile"]

infile=open(csvfile, 'r', newline='')
outfile=open('outfile.rdf', 'w')

reader = csv.reader(infile)

# Create a Graph
g = Graph()

BIBFRAME=Namespace("https://id.loc.gov/ontologies/bibframe/")
FIHRIST=Namespace("https://www.fihrist.org.uk/")

g.bind("bf", BIBFRAME)
g.bind("fih", FIHRIST)

rowcount=0

for row in reader:

    if rowcount>0:

        (msid,filename, repository, collection, idno, start_century, end_century, origplace, country, material, script, mainlang,
         decorated, orientation, lines, size) = row

        manuscript=URIRef(f"https://www.fihrist.org.uk/catalog/{msid}")

        country=f"https://dbpedia.org/ontology/countryCode/{country}"
        mainlang=f"http://dbpedia.org/ontology/languageCode/{mainlang}"



        g.add((manuscript, BIBFRAME.identifiedBy, Literal(msid)))
        g.add((manuscript, BIBFRAME.electronicLocator, Literal(filename)))
        g.add((manuscript, BIBFRAME.heldBy, Literal(repository)))
        g.add((manuscript, BIBFRAME.sublocation, Literal(collection)))
        g.add((manuscript, BIBFRAME.shelfmark, Literal(idno)))
        g.add((manuscript, FIHRIST.startCentury, Literal(start_century)))
        g.add((manuscript, FIHRIST.endCentury, Literal(end_century)))
        g.add((manuscript, BIBFRAME.originPlace, Literal(origplace)))
        g.add((manuscript, FIHRIST.country, URIRef(country)))
        g.add((manuscript, BIBFRAME.material, Literal(material)))
        g.add((manuscript, FIHRIST.script, Literal(script)))
        g.add((manuscript, BIBFRAME.language, URIRef(mainlang)))
        g.add((manuscript, FIHRIST.decorated, Literal(decorated)))
        g.add((manuscript, FIHRIST.orientation, Literal(orientation)))
        g.add((manuscript, BIBFRAME.layout, Literal(lines)))
        g.add((manuscript, BIBFRAME.extent, Literal(size)))
        
    rowcount+=1
# Print out the entire Graph
outfile.write(g.serialize(format="xml"))