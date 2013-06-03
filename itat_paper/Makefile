RM	 = /bin/rm -f
OUT = bajer2013itat.pdf
SRC = bajer2013itat.tex
BIB = bajer2013itat.aux
DVI = bajer2013itat.dvi
TMP = bajer2013itat.aux bajer2013itat.log bajer2013itat.bbl bajer2013itat.blg bajer2013itat.out

single: 
	pdflatex $(SRC)
all: $(OUT)
$(OUT): clean single postscript
	bibtex $(BIB)
	pdflatex $(SRC)
	pdflatex $(SRC)
display: $(OUT)
	open $(OUT) # Platform dependent
postscript:
	latex $(SRC)
	dvips $(DVI)
clean:
	$(RM) $(OUT) $(TMP)
clean_tmp:
	$(RM) $(TMP)
