ABCM2PS = /Applications/EasyABC.app/Contents/Resources/bin/abcm2ps
#ABCM2PS = /usr/local/bin/abcm2ps
DATE:=$(shell git log Combined_Tunebook.abc | grep Date | head -n 1 | sed -e 's/Date: *//')

out/tunelist.csv:
	@curl -L -o out/tunelist.csv 'https://docs.google.com/spreadsheet/pub?key=0AiGRqa7-uLzmdDNESDR6YUhrUVg5LS16UEFXMzdINlE&single=true&gid=0&output=csv'

fmt:
	@echo "Building format files"
	@cat std.fmt tunebook.fmt | perl -pe "s/\|VERSION\|/${DATE}/g"> out/std.fmt 
	@cat dusty.fmt tunebook.fmt | perl -pe "s/\|VERSION\|/${DATE}/g"> out/dusty.fmt 
	@cat combined.fmt tunebook.fmt | perl -pe "s/\|VERSION\|/${DATE}/g"> out/combined.fmt 


abc:	out/tunelist.csv
	@echo "Building ABC files"
	@perl tools/mklists.pl
	@perl tools/mkabc.pl
	@echo ${DATE} > out/version.txt

ps: fmt abc
	@echo "Building PostScript and intermediate PDF"
	@${ABCM2PS} -F out/std.fmt -O out/SlowerThanDirt_Tunes.ps out/std.abc
	@ps2pdf out/SlowerThanDirt_Tunes.ps out/SlowerThanDirt_Tunes.pdf
	@${ABCM2PS} -F out/dusty.fmt -O out/DustyStrings_Tunes.ps out/dusty.abc
	@ps2pdf out/DustyStrings_Tunes.ps out/DustyStrings_Tunes.pdf
	@${ABCM2PS} -F out/combined.fmt -O out/Combined_Tunes.ps out/combined.abc
	@ps2pdf out/Combined_Tunes.ps out/Combined_Tunes.pdf

pdf: ps
	@echo "Building final PDF"
	@(cat includes/preamble.tex ; cat includes/SlowerThanDirt_title.tex; ./tools/mktex.pl SlowerThanDirt) > out/SlowerThanDirt_Tunebook.tex
	@(cat includes/preamble.tex ; cat includes/DustyStrings_title.tex; ./tools/mktex.pl DustyStrings) > out/DustyStrings_Tunebook.tex
	@(cat includes/preamble.tex ; ./tools/mktex.pl Combined ) > out/Combined_Tunebook.tex
	@(cd out; pdflatex SlowerThanDirt_Tunebook && pdflatex SlowerThanDirt_Tunebook && mv SlowerThanDirt_Tunebook.pdf ../PDF/)
	@(cd out; pdflatex DustyStrings_Tunebook && pdflatex DustyStrings_Tunebook && mv DustyStrings_Tunebook.pdf ../PDF/)
	@(cd out; pdflatex Combined_Tunebook && pdflatex Combined_Tunebook)
	@ls -l PDF

love:
	@echo "Not war."

all: pdf

clean:
	@rm -fv out/* *~ */*~
