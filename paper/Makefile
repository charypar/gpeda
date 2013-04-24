RM	 = /bin/rm -f
OUT = gecco_lb_abstract.pdf
SRC = gecco_lb_abstract.tex
BIB = gecco_lb_abstract.aux
DVI = gecco_lb_abstract.dvi
TMP = gecco_lb_abstract.aux gecco_lb_abstract.log gecco_lb_abstract.bbl gecco_lb_abstract.blg gecco_lb_abstract.out

all: $(OUT)
$(OUT): clean single postscript
	bibtex $(BIB)
	pdflatex $(SRC)
	pdflatex $(SRC)
single: 
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
