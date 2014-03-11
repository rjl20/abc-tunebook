ABCM2PS = /Applications/EasyABC.app/Contents/Resources/bin/abcm2ps
DATE:=$(shell git log Combined_Tunebook.abc | grep Date | head -n 1 | sed -e 's/Date: *//')

fmt:
	@echo "Building format files"
	cat std.fmt tunebook.fmt | perl -pe "s/\|VERSION\|/${DATE}/g"> out/std.fmt 
	cat dusty.fmt tunebook.fmt | perl -pe "s/\|VERSION\|/${DATE}/g"> out/dusty.fmt 

	cat combined.fmt tunebook.fmt | perl -pe "s/\|VERSION\|/${DATE}/g"> out/combined.fmt 

abc:
	@echo "Building ABC files"
	perl tools/mklists.pl
	perl tools/mkabc.pl

ps: fmt abc
	@echo "Building PostScript"
	${ABCM2PS} -F out/std.fmt -O out/SlowerThanDirt_Tunebook.ps out/std.abc
	${ABCM2PS} -F out/std.fmt -O out/DustyStrings_Tunebook.ps out/dusty.abc
	${ABCM2PS} -F out/std.fmt -O out/Combined_Tunebook.ps out/combined.abc

#	./tools/abcmaddidx.tcl -b out/Combined_Tunebook.ps tmp.ps
#	mv tmp.ps out/Combined_Tunebook.ps

pdf: ps
	echo "Building PDF"
	pstopdf -p out/Combined_Tunebook.ps -o out/Combined_Tunebook.pdf 
	pstopdf -p out/SlowerThanDirt_Tunebook.ps -o out/SlowerThanDirt_Tunebook.pdf 
	pstopdf -p out/DustyStrings_Tunebook.ps -o out/DustyStrings_Tunebook.pdf 

all: ps pdf
