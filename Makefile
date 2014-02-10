ABCM2PS = /Applications/EasyABC.app/Contents/Resources/bin/abcm2ps
DATE:=$(shell git log Combined_Tunebook.abc | grep Date | head -n 1 | sed -e 's/Date: *//')

fmt:
	@echo "Building format file"
	perl -pe "s/\|VERSION\|/${DATE}/g" < tunebook.fmt > tmp.fmt 

ps: fmt
	@echo "Building PostScript"
	${ABCM2PS} -F tmp.fmt -O out/Combined_Tunebook.ps Combined_Tunebook.abc
	rm tmp.fmt
	./tools/abcmaddidx.tcl -b out/Combined_Tunebook.ps tmp.ps
	mv tmp.ps out/Combined_Tunebook.ps

pdf: ps
	echo "Building PDF"
	pstopdf -p out/Combined_Tunebook.ps -o out/Combined_Tunebook.pdf 

all: ps pdf