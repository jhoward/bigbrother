#!/bin/sh

rm *~ 2> /dev/null
rm *.bak 2> /dev/null
rm *.backup 2> /dev/null
rm *.aux 2> /dev/null
rm *.bbl 2> /dev/null
rm *.toc 2> /dev/null
rm *.lot 2> /dev/null
rm *.log 2> /dev/null
rm *.lof 2> /dev/null
rm *.los 2> /dev/null
rm *.loa 2> /dev/null
rm *.blg 2> /dev/null
rm *.out 2> /dev/null
rm *.dvi 2> /dev/null
rm *.nlo 2> /dev/null
rm *.glo 2> /dev/null
rm *.idx 2> /dev/null
rm *.ilg 2> /dev/null
rm *.ind 2> /dev/null
rm `ls *.pdf | grep -v "csm-thesis.pdf"` 2> /dev/null
rm lyx-example.tex lyx-example-chapter.tex 2> /dev/null

if [ "$1" = "MINIMAL" ]; then
	rm -Rf ./doc-figures 2> /dev/null;
	rm csm-thesis.pdf csm-thesis.dtx csm-thesis.ins 2> /dev/null;
fi
