ABCM2PS = /Applications/EasyABC.app/Contents/Resources/bin/abcm2ps
ps:
	@echo "Building PostScript"
	${ABCM2PS} -F tunebook.fmt -O out/Combined_Tunebook.ps Combined_Tunebook.abc

pdf: ps
	echo "Building PDF"
	pstopdf -p out/Combined_Tunebook.ps -o out/Combined_Tunebook.pdf 

all: ps pdf