MAKEFLAGS += -J2
ONTOLOGY_DATE = $(shell ./xpath-unicode -e '/rdf:RDF/owl:Ontology/dc:date/text()' appearances.owl 2> /dev/null)
ONTOLOGY_VERSION = $(shell ./xpath-unicode -e '/rdf:RDF/owl:Ontology/owl:versionInfo/text()' appearances.owl 2> /dev/null)
PREVIOUS_ONTOLOGY = $(shell ./xpath-unicode -e '/rdf:RDF/owl:Ontology/owl:priorVersion/@rdf:resource' appearances.owl 2> /dev/null | cut -d "\"" -f 2 | rev | cut -d "." -f 2- | cut -d "-" -f 1 |rev)
ONTOLOGY_LONGDATE = $(shell date -d '$(ONTOLOGY_DATE)'  +'%d %B %Y')
PREVIOUS_VERSION = $(shell curl '$(PREVIOUS_ONTOLOGY)'  2> /dev/null | ./xpath-unicode -e '/rdf:RDF/owl:Ontology/owl:versionInfo/text()' 2> /dev/null)
all:	appearances-$(ONTOLOGY_DATE).html appearances-$(ONTOLOGY_DATE).owl appearances-overall-$(ONTOLOGY_DATE).png		
	cp -f appearances-$(ONTOLOGY_DATE).html ~/public_html/.
	cp -f appearances-$(ONTOLOGY_DATE).owl  ~/public_html/.
	cp -f appearances-overall-$(ONTOLOGY_DATE).png ~/public_html/.
	cp -f appearances-overall-small-$(ONTOLOGY_DATE).png ~/public_html/.
deploy:	appearances-$(ONTOLOGY_DATE).html appearances-$(ONTOLOGY_DATE).owl appearances-overall-$(ONTOLOGY_DATE).png		
	cp -f appearances-$(ONTOLOGY_DATE).html /var/www/rdf.muninn-project.org/ontologies/.
	cp -f appearances-$(ONTOLOGY_DATE).owl  /var/www/rdf.muninn-project.org/ontologies/.
	cp -f appearances-overall-$(ONTOLOGY_DATE).png /var/www/rdf.muninn-project.org/ontologies/.
	cp -f appearances-overall-small-$(ONTOLOGY_DATE).png /var/www/rdf.muninn-project.org/ontologies/.
#	ONTOLOGY_VERSION
appearances-$(ONTOLOGY_DATE).dot: appearances.owl
	grep -v "rdfs:label" appearances.owl  | grep -v "rdfs:comment"| grep -v "foaf:name" | grep -v "rdf:type" | rapper -o dot - "http://rdf.muninn-project.org/ontologies/appearances#" | grep -v "owl:Class" | grep -v "owl:ObjectProperty" > appearances-$(ONTOLOGY_DATE).dot
appearances-template-$(ONTOLOGY_DATE).html: appearances-template.html 
	sed "s/PREVIOUS_ONTOLOGY/$(PREVIOUS_ONTOLOGY)/g"  < appearances-template.html | sed "s/ONTOLOGY_DATE/$(ONTOLOGY_DATE)/g" |  sed "s/ONTOLOGY_LONGDATE/$(ONTOLOGY_LONGDATE)/g"  | sed "s/ONTOLOGY_VERSION/$(ONTOLOGY_VERSION)/g" > appearances-template-$(ONTOLOGY_DATE).html
appearances-$(ONTOLOGY_DATE).html: appearances.owl appearances-template-$(ONTOLOGY_DATE).html appearances-overall-$(ONTOLOGY_DATE).png appearances-overall-small-$(ONTOLOGY_DATE).png $(DOCS_TEMPLATES)
	specgen.py appearances.owl appearances appearances-template-$(ONTOLOGY_DATE).html  appearances-$(ONTOLOGY_DATE).html  -i
appearances-overall-$(ONTOLOGY_DATE).png: appearances-$(ONTOLOGY_DATE).dot
	dot -o appearances-overall-$(ONTOLOGY_DATE).png -Tpng appearances-$(ONTOLOGY_DATE).dot
appearances-overall-small-$(ONTOLOGY_DATE).png:  appearances-overall-$(ONTOLOGY_DATE).png
	convert -resize 320x200 appearances-overall-$(ONTOLOGY_DATE).png -resize 320x200 appearances-overall-small-$(ONTOLOGY_DATE).png
appearances-$(ONTOLOGY_DATE).owl: appearances.owl
	cp -f appearances.owl  appearances-$(ONTOLOGY_DATE).owl	
clean:
	rm -f appearances-$(ONTOLOGY_DATE).dot appearances-$(ONTOLOGY_DATE).owl appearances-template-$(ONTOLOGY_DATE).html appearances-$(ONTOLOGY_DATE).html